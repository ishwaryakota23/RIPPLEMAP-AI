import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:ripplemap_server/src/generated/protocol.dart';
import 'package:ripplemap_server/src/generated/future_calls.dart'
    show ServerpodFutureCallsGetter;
import 'package:ripplemap_server/src/account_data_access.dart';
import 'package:ripplemap_server/src/github/github_client.dart';
import 'package:ripplemap_server/src/web/github_webhook_signature.dart';
import 'package:serverpod/serverpod.dart';

class RippleMapApiRoute extends Route {
  RippleMapApiRoute()
    : super(
        methods: const {
          Method.get,
          Method.post,
          Method.delete,
          Method.options,
        },
        path: '/',
      );

  static final Random _random = Random.secure();

  @override
  Future<Result> handleCall(Session session, Request request) async {
    if (request.method == Method.options) {
      return Response.noContent(headers: _corsHeaders(request));
    }
    try {
      if (!_originAllowed(request)) {
        return _json(request, 403, {
          'message': 'This request origin is not allowed.',
        });
      }
      await _initializeCookieAuthentication(session, request);
      final path = request.url.path;
      if (path == '/api/configuration' && request.method == Method.get) {
        return await _configuration(session, request);
      }
      if (path == '/api/repositories' && request.method == Method.get) {
        return await _repositories(session, request);
      }
      if (path == '/api/github/connection' && request.method == Method.delete) {
        return await _disconnectGitHub(session, request);
      }
      if (path == '/api/user-settings' && request.method == Method.get) {
        return await _getUserSettings(session, request);
      }
      if (path == '/api/user-settings' && request.method == Method.post) {
        return await _saveUserSettings(session, request);
      }
      if (path == '/api/analyses/history' && request.method == Method.get) {
        return await _analysisHistory(session, request);
      }
      if (path.startsWith('/api/analyses/') &&
          path.endsWith('/review') &&
          request.method == Method.post) {
        return await _saveAnalysisReview(session, request);
      }
      if (path.startsWith('/api/repositories/') &&
          path.endsWith('/pull-requests') &&
          request.method == Method.get) {
        return await _pullRequests(session, request);
      }
      if (path == '/api/analyses' && request.method == Method.post) {
        return await _startAnalysis(session, request);
      }
      if (path.startsWith('/api/analyses/') && request.method == Method.get) {
        return await _getAnalysis(session, request);
      }
      if (path == '/auth/github/start' && request.method == Method.get) {
        return _startGitHubAuthorization(session, request);
      }
      if (path == '/auth/github/callback' && request.method == Method.get) {
        return await _completeGitHubAuthorization(session, request);
      }
      if (path == '/webhooks/github' && request.method == Method.post) {
        return await _receiveGitHubWebhook(session, request);
      }
      return _json(request, 404, {'message': 'Route not found.'});
    } on ApiRequestException catch (error) {
      return _json(request, error.statusCode, {'message': error.message});
    } on FormatException catch (error) {
      return _json(request, 400, {'message': error.message});
    } on GitHubApiException catch (error) {
      return _json(request, error.statusCode == 401 ? 401 : 502, {
        'message': error.message,
      });
    } on Exception catch (error, stackTrace) {
      session.log(
        'RippleMap request failed for ${request.method} ${request.url.path}.',
        level: LogLevel.error,
        exception: error,
        stackTrace: stackTrace,
      );
      return _json(request, 500, {
        'message':
            'The backend could not complete this request. Check the server logs and retry.',
      });
    }
  }

  Future<Response> _configuration(Session session, Request request) async {
    final authUserId = session.authenticated?.userIdentifier;
    final connected = authUserId == null
        ? null
        : await session.db.findFirstRow<GitHubConnection>(
            where: GitHubConnection.t.authUserId.equals(authUserId),
          );
    final githubConfigured =
        _configuredEnvironment('GITHUB_CLIENT_ID') != null &&
        _configuredEnvironment('GITHUB_CLIENT_SECRET') != null &&
        _configuredEnvironment('SESSION_ENCRYPTION_KEY') != null;
    final groqConfigured = _configuredEnvironment('GROQ_API_KEY') != null;
    return _json(request, 200, {
      'githubConnected': connected != null,
      'githubLogin': connected?.githubLogin,
      'githubConfigured': githubConfigured,
      'groqConfigured': groqConfigured,
      'webhooksConfigured':
          _configuredEnvironment('GITHUB_WEBHOOK_SECRET') != null,
      'aiStatus': groqConfigured ? 'configured' : 'unavailable',
      'backend': 'Serverpod',
    });
  }

  Future<Response> _repositories(Session session, Request request) async {
    final connection = await _requireConnection(session);
    final client = GitHubClient();
    try {
      final token = await CredentialVault().decrypt(
        connection.encryptedAccessToken,
      );
      final repositories = await client.listRepositories(token);
      return _json(request, 200, {
        'items': repositories
            .map((repository) {
              final owner = repository['owner'];
              return {
                'owner': owner is Map ? owner['login'] : null,
                'name': repository['name'],
                'fullName': repository['full_name'],
                'private': repository['private'] == true,
                'description': repository['description'],
                'defaultBranch': repository['default_branch'],
              };
            })
            .toList(growable: false),
      });
    } finally {
      client.close();
    }
  }

  Future<Response> _disconnectGitHub(
    Session session,
    Request request,
  ) async {
    final authUserId = _authenticatedUserId(session);
    final connection = await session.db.findFirstRow<GitHubConnection>(
      where: GitHubConnection.t.authUserId.equals(authUserId),
    );
    if (connection != null) {
      await session.db.deleteRow(connection);
    }
    final settings = await session.db.findFirstRow<UserSettings>(
      where: UserSettings.t.authUserId.equals(authUserId),
    );
    if (settings != null) {
      settings
        ..selectedRepository = null
        ..updatedAt = DateTime.now().toUtc();
      await session.db.updateRow(settings);
    }
    return _json(request, 200, {'githubConnected': false});
  }

  Future<Response> _getUserSettings(Session session, Request request) async {
    final authUserId = _authenticatedUserId(session);
    final settings = await session.db.findFirstRow<UserSettings>(
      where: UserSettings.t.authUserId.equals(authUserId),
    );
    return _json(request, 200, {
      'selectedRepository': settings?.selectedRepository,
    });
  }

  Future<Response> _saveUserSettings(Session session, Request request) async {
    final authUserId = _authenticatedUserId(session);
    final decoded = jsonDecode(await request.readAsString(maxLength: 8192));
    if (decoded is! Map || decoded['selectedRepository'] is! String) {
      throw const ApiRequestException(
        400,
        'selectedRepository must be an owner/repository string.',
      );
    }
    final selectedRepository = (decoded['selectedRepository'] as String).trim();
    final segments = selectedRepository.split('/');
    if (segments.length != 2) {
      throw const ApiRequestException(400, 'Invalid repository identifier.');
    }
    _validateRepositoryName(segments[0]);
    _validateRepositoryName(segments[1]);

    final connection = await _requireConnection(session);
    final client = GitHubClient();
    try {
      final token = await CredentialVault().decrypt(
        connection.encryptedAccessToken,
      );
      final repositories = await client.listRepositories(token);
      final authorized = repositories.any((repository) {
        final owner = repository['owner'];
        return owner is Map &&
            owner['login'] is String &&
            owner['login'].toString().toLowerCase() ==
                segments[0].toLowerCase() &&
            repository['name'] is String &&
            repository['name'].toString().toLowerCase() ==
                segments[1].toLowerCase();
      });
      if (!authorized) {
        throw const ApiRequestException(
          403,
          'The selected repository is not authorized by this GitHub account.',
        );
      }
    } finally {
      client.close();
    }

    final settings = await session.db.findFirstRow<UserSettings>(
      where: UserSettings.t.authUserId.equals(authUserId),
    );
    final now = DateTime.now().toUtc();
    if (settings == null) {
      await session.db.insertRow(
        UserSettings(
          authUserId: authUserId,
          selectedRepository: '${segments[0]}/${segments[1]}',
          updatedAt: now,
        ),
      );
    } else {
      settings
        ..selectedRepository = '${segments[0]}/${segments[1]}'
        ..updatedAt = now;
      await session.db.updateRow(settings);
    }
    return _json(request, 200, {
      'selectedRepository': '${segments[0]}/${segments[1]}',
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<Response> _analysisHistory(Session session, Request request) async {
    final authUserId = _authenticatedUserId(session);
    final jobs = await session.db.find<AnalysisJob>(
      where: AnalysisJob.t.authUserId.equals(authUserId),
      orderBy: AnalysisJob.t.createdAt.desc(),
      limit: 100,
    );
    final reviews = await session.db.find<AnalysisReview>(
      where: AnalysisReview.t.authUserId.equals(authUserId),
    );
    final reviewsByJob = {
      for (final review in reviews) review.jobKey: review,
    };
    return _json(request, 200, {
      'items': jobs
          .map((job) {
            final review = reviewsByJob[job.jobKey];
            return {
              'id': job.jobKey,
              'owner': job.owner,
              'repository': job.repository,
              'pullRequestNumber': job.pullRequestNumber,
              'status': job.status,
              'reviewDecision': review?.decision,
              'reviewNote': review?.note,
              'createdAt': job.createdAt.toIso8601String(),
              'updatedAt': job.updatedAt.toIso8601String(),
            };
          })
          .toList(growable: false),
    });
  }

  Future<Response> _saveAnalysisReview(
    Session session,
    Request request,
  ) async {
    final authUserId = _authenticatedUserId(session);
    final segments = request.url.pathSegments;
    if (segments.length != 4 ||
        segments[0] != 'api' ||
        segments[1] != 'analyses' ||
        segments[3] != 'review' ||
        segments[2].isEmpty) {
      throw const ApiRequestException(400, 'Invalid analysis review path.');
    }
    final jobKey = segments[2];
    final job = await findOwnedAnalysisJob(session, jobKey);
    if (job == null) {
      throw const ApiRequestException(404, 'Analysis job not found.');
    }
    final decoded = jsonDecode(await request.readAsString(maxLength: 8192));
    if (decoded is! Map ||
        decoded['decision'] is! String ||
        !const {'approved', 'changes_requested', 'reviewed'}.contains(
          decoded['decision'],
        )) {
      throw const ApiRequestException(
        400,
        'decision must be approved, changes_requested, or reviewed.',
      );
    }
    final noteValue = decoded['note'];
    if (noteValue != null && noteValue is! String) {
      throw const ApiRequestException(400, 'note must be a string.');
    }
    final note = (noteValue as String?)?.trim();
    if (note != null && note.length > 2000) {
      throw const ApiRequestException(
        400,
        'note must be 2000 characters or fewer.',
      );
    }
    final now = DateTime.now().toUtc();
    final existing = await session.db.findFirstRow<AnalysisReview>(
      where:
          AnalysisReview.t.authUserId.equals(authUserId) &
          AnalysisReview.t.jobKey.equals(jobKey),
    );
    final review =
        existing ??
        AnalysisReview(
          authUserId: authUserId,
          jobKey: jobKey,
          decision: decoded['decision'] as String,
          note: note,
          updatedAt: now,
        );
    review
      ..decision = decoded['decision'] as String
      ..note = note
      ..updatedAt = now;
    if (existing == null) {
      await session.db.insertRow(review);
    } else {
      await session.db.updateRow(review);
    }
    return _json(request, 200, {
      'id': review.jobKey,
      'decision': review.decision,
      'note': review.note,
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<Response> _pullRequests(Session session, Request request) async {
    final segments = request.url.pathSegments;
    if (segments.length != 5 ||
        segments[0] != 'api' ||
        segments[1] != 'repositories' ||
        segments[4] != 'pull-requests') {
      throw const ApiRequestException(400, 'Invalid repository path.');
    }
    final owner = segments[2];
    final repository = segments[3];
    _validateRepositoryName(owner);
    _validateRepositoryName(repository);
    final connection = await _requireConnection(session);
    final client = GitHubClient();
    try {
      final token = await CredentialVault().decrypt(
        connection.encryptedAccessToken,
      );
      final pullRequests = await client.listPullRequests(
        owner,
        repository,
        token,
      );
      return _json(request, 200, {
        'items': pullRequests
            .map((pullRequest) {
              final head = pullRequest['head'];
              return {
                'number': pullRequest['number'],
                'title': pullRequest['title'],
                'state': pullRequest['state'],
                'draft': pullRequest['draft'] == true,
                'headBranch': head is Map ? head['ref'] : null,
                'htmlUrl': pullRequest['html_url'],
              };
            })
            .toList(growable: false),
      });
    } finally {
      client.close();
    }
  }

  Future<Response> _startAnalysis(Session session, Request request) async {
    final connection = await _requireConnection(session);
    final decoded = jsonDecode(await request.readAsString(maxLength: 16384));
    if (decoded is! Map) {
      throw const ApiRequestException(
        400,
        'The request body must be a JSON object.',
      );
    }
    final owner = decoded['owner'];
    final repository = decoded['repository'];
    final number = decoded['pullRequestNumber'];
    if (owner is! String || repository is! String || number is! int) {
      throw const ApiRequestException(
        400,
        'owner, repository, and pullRequestNumber are required.',
      );
    }
    _validateRepositoryName(owner);
    _validateRepositoryName(repository);
    if (number < 1) {
      throw const ApiRequestException(
        400,
        'pullRequestNumber must be a positive integer.',
      );
    }
    final id = _randomId();
    final now = DateTime.now().toUtc();
    final job = await _enqueueAnalysis(
      session,
      authUserId: connection.authUserId!,
      owner: owner,
      repository: repository,
      pullRequestNumber: number,
      jobKey: id,
      createdAt: now,
    );
    return _json(request, 202, _jobResponse(job));
  }

  Future<Response> _getAnalysis(Session session, Request request) async {
    await _requireConnection(session);
    final segments = request.url.pathSegments;
    if (segments.length != 3 || segments[2].isEmpty) {
      throw const ApiRequestException(400, 'An analysis ID is required.');
    }
    final authUserId = _authenticatedUserId(session);
    final job = await findOwnedAnalysisJob(session, segments[2]);
    if (job == null) {
      throw const ApiRequestException(404, 'Analysis job not found.');
    }
    final response = _jobResponse(job);
    final review = await session.db.findFirstRow<AnalysisReview>(
      where:
          AnalysisReview.t.authUserId.equals(authUserId) &
          AnalysisReview.t.jobKey.equals(job.jobKey),
    );
    if (review != null) {
      response['reviewDecision'] = review.decision;
      response['reviewNote'] = review.note;
    }
    return _json(request, 200, response);
  }

  Response _startGitHubAuthorization(Session session, Request request) {
    final authUserId = _authenticatedUserId(session);
    final clientId = _configuredEnvironment('GITHUB_CLIENT_ID');
    final clientSecret = _configuredEnvironment('GITHUB_CLIENT_SECRET');
    final encryptionKey = _configuredEnvironment('SESSION_ENCRYPTION_KEY');
    if (clientId == null || clientSecret == null || encryptionKey == null) {
      return _json(request, 503, {
        'message':
            'Configure GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, and SESSION_ENCRYPTION_KEY on the backend.',
      });
    }
    final state = _randomId();
    final boundState = '$authUserId.$state';
    final redirectUri =
        _configuredEnvironment('GITHUB_REDIRECT_URI') ??
        'http://localhost:8082/auth/github/callback';
    final scope = _configuredEnvironment('GITHUB_OAUTH_SCOPE') ?? 'public_repo';
    if (!const {'public_repo', 'repo'}.contains(scope)) {
      throw const ApiRequestException(
        500,
        'GITHUB_OAUTH_SCOPE must be public_repo or repo.',
      );
    }
    final authorizationUri = Uri.https(
      'github.com',
      '/login/oauth/authorize',
      {
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'scope': scope,
        'state': state,
      },
    );
    final response = Response.found(
      authorizationUri,
      headers: _cookies(request, [
        _cookie('ripplemap_oauth_state', boundState, maxAge: 600),
      ]),
    );
    return response;
  }

  Future<Response> _completeGitHubAuthorization(
    Session session,
    Request request,
  ) async {
    final query = request.url.queryParameters;
    if (query['error'] != null) {
      return _githubOAuthFailure(request);
    }
    final code = query['code'];
    final state = query['state'];
    final authUserId = _authenticatedUserId(session);
    final stateCookie = _cookieValue(request, 'ripplemap_oauth_state');
    if (code == null ||
        state == null ||
        stateCookie == null ||
        !_constantTimeEquals('$authUserId.$state', stateCookie)) {
      return _githubOAuthFailure(request);
    }
    final client = GitHubClient();
    try {
      final oauth = await client.exchangeCode(code);
      final token = oauth['access_token']! as String;
      final user = await client.getCurrentUser(token);
      final login = user['login'];
      if (login is! String || login.isEmpty) {
        throw const FormatException('GitHub did not return an account name.');
      }
      final encryptedToken = await CredentialVault().encrypt(token);
      final existing = await session.db.findFirstRow<GitHubConnection>(
        where: GitHubConnection.t.authUserId.equals(authUserId),
      );
      final connection =
          existing ??
          GitHubConnection(
            authUserId: authUserId,
            githubLogin: login.toLowerCase(),
            encryptedAccessToken: encryptedToken,
            createdAt: DateTime.now().toUtc(),
          );
      connection
        ..githubLogin = login.toLowerCase()
        ..encryptedAccessToken = encryptedToken;
      if (existing == null) {
        await session.db.insertRow(connection);
      } else {
        await session.db.updateRow(connection);
      }
      return Response.found(
        Uri.parse(_frontendOrigin()).replace(
          queryParameters: const {'github': 'connected'},
        ),
        headers: _cookies(request, [
          _expiredCookie('ripplemap_oauth_state'),
        ]),
      );
    } on Exception {
      return _githubOAuthFailure(request);
    } finally {
      client.close();
    }
  }

  Future<Response> _receiveGitHubWebhook(
    Session session,
    Request request,
  ) async {
    final secret = _configuredEnvironment('GITHUB_WEBHOOK_SECRET');
    if (secret == null) {
      throw const ApiRequestException(
        503,
        'GitHub webhook signing is not configured on the backend.',
      );
    }
    final contentType = _header(
      request,
      'content-type',
    )?.split(';').first.trim().toLowerCase();
    if (contentType != 'application/json') {
      throw const ApiRequestException(
        415,
        'GitHub webhook content type must be application/json.',
      );
    }
    final rawBody = utf8.encode(await request.readAsString(maxLength: 1048576));
    final signature = _header(request, 'x-hub-signature-256');
    final deliveryId = _header(request, 'x-github-delivery');
    final eventType = _header(request, 'x-github-event');
    if (signature == null ||
        deliveryId == null ||
        eventType == null ||
        !isValidGitHubWebhookSignature(rawBody, signature, secret)) {
      throw const ApiRequestException(
        401,
        'GitHub webhook signature or delivery headers are invalid.',
      );
    }
    if (deliveryId.trim().isEmpty ||
        eventType.trim().isEmpty ||
        deliveryId.length > 100 ||
        eventType.length > 100) {
      throw const ApiRequestException(
        400,
        'GitHub webhook headers are invalid.',
      );
    }
    final duplicate = await session.db.findFirstRow<WebhookDelivery>(
      where: WebhookDelivery.t.deliveryId.equals(deliveryId),
    );
    if (duplicate != null) {
      return _json(request, 202, {'accepted': true, 'duplicate': true});
    }
    final payloadValue = jsonDecode(utf8.decode(rawBody));
    if (payloadValue is! Map) {
      throw const ApiRequestException(
        400,
        'GitHub webhook body must be a JSON object.',
      );
    }
    final repositoryValue = payloadValue['repository'];
    final repositoryOwner = repositoryValue is Map
        ? repositoryValue['owner']
        : null;
    final owner = repositoryOwner is Map ? repositoryOwner['login'] : null;
    final repository = repositoryValue is Map ? repositoryValue['name'] : null;
    if ((eventType == 'pull_request' || eventType == 'push') &&
        (owner is! String ||
            repository is! String ||
            !_validRepositoryName(owner) ||
            !_validRepositoryName(repository))) {
      throw const ApiRequestException(
        400,
        'The GitHub event did not include a valid repository owner and name.',
      );
    }
    late final WebhookDelivery delivery;
    try {
      delivery = await session.db.insertRow(
        WebhookDelivery(
          deliveryId: deliveryId,
          eventType: eventType,
          receivedAt: DateTime.now().toUtc(),
        ),
      );
    } on Exception {
      final duplicate = await session.db.findFirstRow<WebhookDelivery>(
        where: WebhookDelivery.t.deliveryId.equals(deliveryId),
      );
      if (duplicate != null) {
        return _json(request, 202, {'accepted': true, 'duplicate': true});
      }
      rethrow;
    }

    final connections = eventType == 'pull_request' || eventType == 'push'
        ? await _connectionsWithRepositoryAccess(
            session,
            (owner! as String),
            (repository! as String),
          )
        : const <GitHubConnection>[];
    final jobs = <String>[];
    try {
      for (final connection in connections.where(
        (connection) => connection.authUserId != null,
      )) {
        final targets = await _webhookAnalysisTargets(
          eventType: eventType,
          payload: Map<String, dynamic>.from(payloadValue),
          owner: owner! as String,
          repository: repository! as String,
          connection: connection,
        );
        for (final number in targets) {
          final jobKey = _randomId();
          await _enqueueAnalysis(
            session,
            authUserId: connection.authUserId!,
            owner: owner,
            repository: repository,
            pullRequestNumber: number,
            jobKey: jobKey,
            createdAt: DateTime.now().toUtc(),
          );
          jobs.add(jobKey);
        }
      }
    } on Exception {
      await session.db.deleteRow(delivery);
      rethrow;
    }
    return _json(request, 202, {
      'accepted': true,
      'duplicate': false,
      'queuedAnalyses': jobs.length,
      'analysisIds': jobs,
    });
  }

  Future<List<GitHubConnection>> _connectionsWithRepositoryAccess(
    Session session,
    String owner,
    String repository,
  ) async {
    final connections = await session.db.find<GitHubConnection>();
    final matches = <GitHubConnection>[];
    for (final connection in connections.where(
      (connection) => connection.authUserId != null,
    )) {
      final client = GitHubClient();
      try {
        final token = await CredentialVault().decrypt(
          connection.encryptedAccessToken,
        );
        final repositories = await client.listRepositories(token);
        final hasAccess = repositories.any((item) {
          final itemOwner = item['owner'];
          return itemOwner is Map &&
              itemOwner['login'] is String &&
              itemOwner['login'].toString().toLowerCase() ==
                  owner.toLowerCase() &&
              item['name'] is String &&
              item['name'].toString().toLowerCase() == repository.toLowerCase();
        });
        if (hasAccess) matches.add(connection);
      } finally {
        client.close();
      }
    }
    return matches;
  }

  Future<List<int>> _webhookAnalysisTargets({
    required String eventType,
    required Map<String, dynamic> payload,
    required String owner,
    required String repository,
    required GitHubConnection connection,
  }) async {
    if (eventType == 'pull_request') {
      final action = payload['action'];
      final number = payload['number'];
      return const {'opened', 'reopened', 'synchronize'}.contains(action) &&
              number is int &&
              number > 0
          ? [number]
          : const [];
    }
    if (eventType != 'push') return const [];
    final reference = payload['ref'];
    if (reference is! String || !reference.startsWith('refs/heads/')) {
      return const [];
    }
    final branch = reference.substring('refs/heads/'.length);
    final client = GitHubClient();
    try {
      final token = await CredentialVault().decrypt(
        connection.encryptedAccessToken,
      );
      final pullRequests = await client.listPullRequests(
        owner,
        repository,
        token,
      );
      return pullRequests
          .where((pullRequest) {
            final head = pullRequest['head'];
            return head is Map && head['ref'] == branch;
          })
          .map((pullRequest) => pullRequest['number'])
          .whereType<int>()
          .take(10)
          .toList(growable: false);
    } finally {
      client.close();
    }
  }

  Future<AnalysisJob> _enqueueAnalysis(
    Session session, {
    required String authUserId,
    required String owner,
    required String repository,
    required int pullRequestNumber,
    required String jobKey,
    required DateTime createdAt,
  }) async {
    final job = AnalysisJob(
      jobKey: jobKey,
      authUserId: authUserId,
      owner: owner,
      repository: repository,
      pullRequestNumber: pullRequestNumber,
      status: 'queued',
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    await session.db.insertRow(job);
    try {
      await session.serverpod.futureCalls
          .callWithDelay(const Duration(seconds: 1), identifier: jobKey)
          .analysis
          .process(
            AnalysisTask(
              jobKey: jobKey,
              authUserId: authUserId,
              owner: owner,
              repository: repository,
              pullRequestNumber: pullRequestNumber,
            ),
          );
    } on Exception {
      job.status = 'failed';
      job.errorMessage =
          'The analysis job could not be scheduled. Check the backend configuration.';
      job.updatedAt = DateTime.now().toUtc();
      await session.db.updateRow(job);
      rethrow;
    }
    return job;
  }

  Future<GitHubConnection> _requireConnection(
    Session session,
  ) async {
    final authUserId = _authenticatedUserId(session);
    final connection = await session.db.findFirstRow<GitHubConnection>(
      where: GitHubConnection.t.authUserId.equals(authUserId),
    );
    if (connection == null) {
      throw const ApiRequestException(
        401,
        'Connect a GitHub account before accessing repository data.',
      );
    }
    return connection;
  }

  String _authenticatedUserId(Session session) {
    final authUserId = session.authenticated?.userIdentifier;
    if (authUserId == null || authUserId.isEmpty) {
      throw const ApiRequestException(401, 'Sign in to continue.');
    }
    return authUserId;
  }

  Map<String, Object?> _jobResponse(AnalysisJob job) {
    if (job.status == 'completed' && job.reportJson != null) {
      final report = jsonDecode(job.reportJson!);
      if (report is Map) {
        return {
          ...Map<String, Object?>.from(report),
          'id': job.jobKey,
          'status': job.status,
        };
      }
    }
    return {
      'id': job.jobKey,
      'status': job.status,
      if (job.errorMessage != null) 'error': job.errorMessage,
      'createdAt': job.createdAt.toIso8601String(),
      'updatedAt': job.updatedAt.toIso8601String(),
    };
  }

  Response _json(Request request, int statusCode, Map<String, Object?> body) =>
      Response(
        statusCode,
        headers: _corsHeaders(request),
        body: Body.fromString(jsonEncode(body), mimeType: MimeType.json),
      );

  Headers _corsHeaders(Request request) {
    final origin = _header(request, 'origin');
    if (origin == null || origin != _frontendOrigin()) return Headers.empty();
    return Headers.build((headers) {
      headers['access-control-allow-origin'] = [origin];
      headers['access-control-allow-credentials'] = ['true'];
      headers['access-control-allow-methods'] = [
        'GET, POST, DELETE, OPTIONS',
      ];
      headers['access-control-allow-headers'] = [
        'Content-Type, Accept, X-Serverpod-Auth-Mode, X-GitHub-Delivery, X-Hub-Signature-256, X-GitHub-Event',
      ];
      headers['vary'] = ['Origin'];
    });
  }

  Headers _cookies(Request request, List<SetCookie> cookies) {
    final cors = _corsHeaders(request);
    return cors.transform((headers) {
      var setCookie = headers.setCookie ?? const SetCookieHeader.empty();
      for (final cookie in cookies) {
        setCookie = setCookie.add(cookie);
      }
      headers.setCookie = setCookie;
    });
  }

  SetCookie _cookie(String name, String value, {required int maxAge}) =>
      SetCookie(
        name: name,
        value: value,
        maxAge: maxAge,
        path: '/',
        httpOnly: true,
        secure: _isSecureDeployment(),
        sameSite: SameSite.lax,
      );

  SetCookie _expiredCookie(String name) => SetCookie(
    name: name,
    value: '',
    maxAge: 0,
    path: '/',
    httpOnly: true,
    secure: _isSecureDeployment(),
    sameSite: SameSite.lax,
  );

  String? _cookieValue(Request request, String name) {
    final cookies = request.headers.cookie;
    if (cookies == null) return null;
    final values = cookies.getCookies(name).toList(growable: false);
    return values.length == 1 ? values.single.value : null;
  }

  String? _header(Request request, String name) {
    final values = request.headers[name];
    return values == null || values.isEmpty ? null : values.first;
  }

  bool _originAllowed(Request request) {
    final origin = _header(request, 'origin');
    return origin == null || origin == _frontendOrigin();
  }

  Future<void> _initializeCookieAuthentication(
    Session session,
    Request request,
  ) async {
    if (session.authenticated != null) return;
    final authCookie = session.serverpod.config.authCookie;
    if (authCookie == null) return;

    final path = request.url.path;
    final isOAuthNavigation =
        path == '/auth/github/start' || path == '/auth/github/callback';
    final usesCookieAuth =
        _header(request, 'x-serverpod-auth-mode') == 'cookie';
    if (!usesCookieAuth && !isOAuthNavigation) return;

    final token = _cookieValue(request, authCookie.name);
    if (token == null || token.isEmpty) return;
    final authentication = await session.server.authenticationHandler(
      session,
      token,
    );
    session.updateAuthenticated(authentication);
  }

  String _frontendOrigin() =>
      _environment('RIPPLEMAP_FRONTEND_ORIGIN') ?? 'http://localhost:5000';

  bool _isSecureDeployment() => _frontendOrigin().startsWith('https://');

  Response _githubOAuthFailure(Request request) => Response.found(
    Uri.parse(_frontendOrigin()).replace(
      queryParameters: const {'github': 'authorization-failed'},
    ),
    headers: _cookies(request, [_expiredCookie('ripplemap_oauth_state')]),
  );

  String? _environment(String name) => PlatformEnvironment.value(name)?.trim();

  String? _configuredEnvironment(String name) {
    final value = _environment(name);
    return value == null || value.isEmpty ? null : value;
  }

  String _randomId() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  bool _constantTimeEquals(String left, String right) {
    final a = utf8.encode(left);
    final b = utf8.encode(right);
    var mismatch = a.length ^ b.length;
    final length = min(a.length, b.length);
    for (var index = 0; index < length; index++) {
      mismatch |= a[index] ^ b[index];
    }
    return mismatch == 0;
  }

  void _validateRepositoryName(String value) {
    if (!_validRepositoryName(value)) {
      throw const ApiRequestException(400, 'Invalid repository identifier.');
    }
  }

  bool _validRepositoryName(String value) =>
      RegExp(r'^[A-Za-z0-9_.-]{1,100}$').hasMatch(value);
}

class ApiRequestException implements Exception {
  const ApiRequestException(this.statusCode, this.message);

  final int statusCode;
  final String message;
}
