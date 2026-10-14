import 'package:path/path.dart' as p;
import 'package:ripplemap_server/src/github/github_client.dart';
import 'package:tree_sitter_language_pack/tree_sitter_language_pack.dart';
// The package documents RustLib as its initialization entry point but exports it
// only from this generated bridge path.
// ignore: implementation_imports
import 'package:tree_sitter_language_pack/src/tree_sitter_language_pack_bridge_generated/frb_generated.dart'
    show RustLib;

class ImpactAnalyzer {
  ImpactAnalyzer(this._github);

  static Future<void>? _nativeInitialization;
  static const _maximumFiles = 150;
  static const _maximumSourceBytes = 256 * 1024;
  static const _maximumDepth = 3;

  final GitHubClient _github;

  Future<Map<String, Object?>> analyze({
    required String owner,
    required String repository,
    required int pullRequestNumber,
    required String token,
  }) async {
    await _initializeParser();

    final pullRequest = await _github.getObject(
      _repositoryUri(
        owner,
        repository,
        '/pulls/$pullRequestNumber',
      ),
      token: token,
    );
    final base = pullRequest['base'];
    final head = pullRequest['head'];
    final baseSha = base is Map ? base['sha'] : null;
    final headSha = head is Map ? head['sha'] : null;
    if (baseSha is! String || headSha is! String) {
      throw const FormatException(
        'GitHub did not return the base and head revisions for this pull request.',
      );
    }

    final rawChanges = await _github.listPullRequestFiles(
      owner,
      repository,
      pullRequestNumber,
      token,
    );
    final changes = rawChanges
        .where((file) => file['filename'] is String)
        .map(_changedFile)
        .toList(growable: false);

    final tree = await _github.getObject(
      _repositoryUri(owner, repository, '/git/trees/$baseSha', {
        'recursive': '1',
      }),
      token: token,
    );
    final rawTree = tree['tree'];
    final Iterable<Map> treeEntries = rawTree is List
        ? rawTree.whereType<Map>()
        : const <Map>[];
    final repositoryPaths = <String, int>{};
    for (final entry in treeEntries) {
      final path = entry['path'];
      final size = entry['size'];
      if (entry['type'] == 'blob' &&
          path is String &&
          size is int &&
          _supportedSource(path) &&
          !_ignoredPath(path)) {
        repositoryPaths[path] = size;
      }
    }

    final changedPaths = changes
        .map((file) => file['path'])
        .whereType<String>()
        .where(_supportedSource)
        .toSet();
    final selectedPaths = <String>{
      ...changedPaths,
      ...repositoryPaths.keys.take(_maximumFiles),
    }.toList(growable: false);
    final limitations = <String>[
      'Import edges point from an importing file to its resolved relative dependency.',
      'Dependency evidence is file-level import evidence; package aliases and dynamic imports are not resolved.',
    ];
    if (tree['truncated'] == true || repositoryPaths.length > _maximumFiles) {
      limitations.add(
        'The repository source snapshot is bounded to $_maximumFiles supported files; dependency reach may be incomplete.',
      );
    }

    final baseSources = <String, String>{};
    final sourceErrors = <String>[];
    await _fetchSources(
      owner,
      repository,
      baseSha,
      selectedPaths,
      token,
      baseSources,
      sourceErrors,
    );
    if (sourceErrors.isNotEmpty) {
      limitations.add(
        '${sourceErrors.length} source file(s) could not be retrieved from the base revision.',
      );
    }

    final headSources = <String, String>{};
    final changedSourcePaths = changedPaths.toList(growable: false);
    await _fetchSources(
      owner,
      repository,
      headSha,
      changedSourcePaths,
      token,
      headSources,
      sourceErrors,
    );

    final parsed = <String, _ParsedFile>{};
    for (final entry in baseSources.entries) {
      parsed[entry.key] = await _parse(entry.key, entry.value);
    }
    final parsedHead = <String, _ParsedFile>{};
    for (final entry in headSources.entries) {
      parsedHead[entry.key] = await _parse(entry.key, entry.value);
    }
    final filesWithParseErrors = parsed.values
        .where((file) => file.parseErrorCount > 0)
        .length;
    if (filesWithParseErrors > 0) {
      limitations.add(
        'Tree-sitter reported syntax errors in $filesWithParseErrors parsed source file(s); relationships from those files may be incomplete.',
      );
    }

    final pathSet = repositoryPaths.keys.toSet()..addAll(changedPaths);
    final importsByFile = <String, Set<String>>{};
    final importedNames = <(String, String), Set<String>>{};
    final graphSources = {...parsed, ...parsedHead};
    for (final entry in graphSources.entries) {
      for (final import in entry.value.imports) {
        final target = _resolveImport(entry.key, import.source, pathSet);
        if (target == null) continue;
        importsByFile.putIfAbsent(entry.key, () => <String>{}).add(target);
        importedNames
            .putIfAbsent((entry.key, target), () => <String>{})
            .addAll(import.items);
      }
    }

    final reverseImports = <String, Set<String>>{};
    for (final entry in importsByFile.entries) {
      for (final dependency in entry.value) {
        reverseImports.putIfAbsent(dependency, () => <String>{}).add(entry.key);
      }
    }

    final changedSourceFiles = changes
        .where((file) => changedPaths.contains(file['path']))
        .toList(growable: false);
    final directImpacts = <Map<String, Object?>>[];
    final potentialImpacts = <Map<String, Object?>>[];
    final seenImpacts = <String>{};
    final queue = <(String, int, List<String>)>[];
    for (final changed in changedSourceFiles) {
      final changedPath = changed['path']! as String;
      for (final consumer in reverseImports[changedPath] ?? const <String>{}) {
        final names =
            importedNames[(consumer, changedPath)] ?? const <String>{};
        final key = '$changedPath->$consumer';
        if (!seenImpacts.add(key)) continue;
        directImpacts.add({
          'path': consumer,
          'changedPath': changedPath,
          'depth': 1,
          'symbols': names.toList()..sort(),
          'reason': names.isEmpty
              ? 'Parser-confirmed import of the changed module; imported symbols were not identified.'
              : 'Parser-confirmed import of ${names.join(', ')} from the changed module.',
        });
        queue.add((consumer, 1, [changedPath, consumer]));
      }
    }

    while (queue.isNotEmpty) {
      final (current, depth, path) = queue.removeAt(0);
      if (depth >= _maximumDepth) continue;
      for (final consumer in reverseImports[current] ?? const <String>{}) {
        if (path.contains(consumer)) continue;
        final nextDepth = depth + 1;
        final impactedPath = [...path, consumer];
        if (seenImpacts.add(impactedPath.join('->'))) {
          potentialImpacts.add({
            'path': consumer,
            'changedPath': path.first,
            'via': current,
            'depth': nextDepth,
            'reason':
                'Potential transitive impact through ${impactedPath.skip(1).join(' → ')}.',
          });
          queue.add((consumer, nextDepth, impactedPath));
        }
      }
    }

    final publicChanges = _changedExports(
      changedSourceFiles,
      parsed,
      parsedHead,
    );
    final testFiles = parsed.keys.where(_isTestFile).toSet();
    final relevantTests = testFiles
        .where(
          (test) => (importsByFile[test] ?? const <String>{}).any(
            (dependency) =>
                changedPaths.contains(dependency) ||
                directImpacts.any((impact) => impact['path'] == dependency),
          ),
        )
        .toList(growable: false);
    final recommendations = <Map<String, Object?>>[
      ...relevantTests.map(
        (test) => {
          'text':
              'Run $test; its parsed imports reach a changed or directly affected file.',
          'evidence': 'parser',
        },
      ),
    ];
    if (relevantTests.isEmpty) {
      recommendations.add({
        'text':
            'No test file with a parsed import path to the changed modules was found. Run the repository test suite and add regression coverage for changed behavior.',
        'evidence': 'disclosed heuristic',
      });
    }

    final unsupportedChanged = changes
        .where((file) => !_supportedSource(file['path']! as String))
        .map((file) => file['path']! as String)
        .toList(growable: false);
    if (unsupportedChanged.isNotEmpty) {
      limitations.add(
        'Changed files outside JavaScript/TypeScript were not parsed: ${unsupportedChanged.take(12).join(', ')}${unsupportedChanged.length > 12 ? ', …' : ''}.',
      );
    }
    if (tree['truncated'] == true) {
      limitations.add(
        'GitHub marked the recursive repository tree as truncated; unreturned paths were not analyzed.',
      );
    }
    if (parsed.isEmpty) {
      limitations.add(
        'No supported JavaScript or TypeScript source files were successfully parsed.',
      );
    }

    final score = _riskScore(
      changes.length,
      changes.any((file) => file['status'] == 'removed'),
      publicChanges.length,
      directImpacts.length,
      potentialImpacts.length,
      relevantTests.isNotEmpty,
    );
    return {
      'status': 'completed',
      'owner': owner,
      'repository': repository,
      'pullRequestNumber': pullRequestNumber,
      'title': pullRequest['title'] ?? '',
      'baseSha': baseSha,
      'headSha': headSha,
      'changedFiles': changes,
      'directImpacts': directImpacts,
      'potentialImpacts': potentialImpacts,
      'changedSymbols': publicChanges,
      'recommendations': recommendations,
      'riskScore': score,
      'riskLevel': score >= 70
          ? 'high'
          : score >= 40
          ? 'medium'
          : 'low',
      'riskExplanation':
          'Heuristic score: 20 base + 20 when public exports change + up to 35 for direct consumers + up to 15 for transitive consumers + 5 for more than five changed files + 5 for a deletion − 10 when a relevant test import was found; clamped to 0–100.',
      'dependencyEdges': [
        for (final entry in importsByFile.entries)
          for (final dependency in entry.value)
            {'from': entry.key, 'to': dependency},
      ],
      'limitations': [
        ...limitations.map((text) => {'text': text}),
      ],
      'aiStatus': 'unavailable',
      'aiInsights': <Map<String, Object?>>[],
      'aiUnavailableReason': 'Groq insights were not requested.',
    };
  }

  Future<void> _initializeParser() async {
    final pending = _nativeInitialization ??= _initializeNativeParser();
    try {
      await pending;
    } on Object {
      _nativeInitialization = null;
      rethrow;
    }
  }

  Future<void> _initializeNativeParser() async {
    await RustLib.init();
    await TreeSitterLanguagePackBridge.init();
  }

  Future<void> _fetchSources(
    String owner,
    String repository,
    String revision,
    List<String> paths,
    String token,
    Map<String, String> output,
    List<String> errors,
  ) async {
    var index = 0;
    Future<void> worker() async {
      while (index < paths.length) {
        final current = paths[index++];
        final size = _maximumSourceBytes;
        try {
          output[current] = await _github.getRaw(
            _contentsUri(owner, repository, current, revision),
            token: token,
            maximumBytes: size,
          );
        } on Exception {
          errors.add(current);
        }
      }
    }

    await Future.wait(List.generate(6, (_) => worker()));
  }

  Future<_ParsedFile> _parse(String path, String source) async {
    final extension = p.posix.extension(path).toLowerCase();
    final language = switch (extension) {
      '.tsx' => 'tsx',
      '.ts' || '.mts' || '.cts' => 'typescript',
      '.jsx' => 'jsx',
      '.js' || '.mjs' || '.cjs' => 'javascript',
      _ => throw FormatException('Unsupported source file: $path'),
    };
    final result = await TreeSitterLanguagePackBridge.process(
      source,
      config: ProcessConfig(
        language: language,
        structure: true,
        imports: true,
        exports: true,
        comments: false,
        docstrings: false,
        symbols: false,
        diagnostics: true,
        dataExtraction: false,
        maxSourceBytes: _maximumSourceBytes,
        parseTimeoutMs: 1500,
      ),
    );
    return _ParsedFile(
      imports: result.imports,
      exports: result.exports.map((item) => item.name).toSet(),
      parseErrorCount: result.metrics.errorCount.toInt(),
    );
  }

  List<Map<String, Object?>> _changedExports(
    List<Map<String, Object?>> changedFiles,
    Map<String, _ParsedFile> baseFiles,
    Map<String, _ParsedFile> headFiles,
  ) {
    final result = <Map<String, Object?>>[];
    for (final file in changedFiles) {
      final path = file['path']! as String;
      final before = baseFiles[path]?.exports ?? const <String>{};
      final after = headFiles[path]?.exports ?? const <String>{};
      final added = after.difference(before).toList()..sort();
      final removed = before.difference(after).toList()..sort();
      for (final symbol in added) {
        result.add({
          'path': path,
          'symbol': symbol,
          'change': 'added export',
          'evidence':
              'Tree-sitter export extraction at the pull-request head revision.',
        });
      }
      for (final symbol in removed) {
        result.add({
          'path': path,
          'symbol': symbol,
          'change': 'removed export',
          'evidence':
              'Export present at the base revision and absent at the pull-request head revision.',
        });
      }
    }
    return result;
  }

  int _riskScore(
    int changedFiles,
    bool hasDeletion,
    int changedExports,
    int direct,
    int potential,
    bool hasRelevantTests,
  ) {
    final score =
        20 +
        (changedExports > 0 ? 20 : 0) +
        (direct * 7).clamp(0, 35) +
        (potential * 2).clamp(0, 15) -
        (hasRelevantTests ? 10 : 0) +
        (changedFiles > 5 ? 5 : 0) +
        (hasDeletion ? 5 : 0);
    return score.clamp(0, 100).toInt();
  }

  Uri _repositoryUri(
    String owner,
    String repository,
    String suffix, [
    Map<String, String>? query,
  ]) => Uri.https(
    'api.github.com',
    '/repos/${Uri.encodeComponent(owner)}/${Uri.encodeComponent(repository)}$suffix',
    query,
  );

  Uri _contentsUri(
    String owner,
    String repository,
    String path,
    String revision,
  ) {
    final encodedPath = path.split('/').map(Uri.encodeComponent).join('/');
    return Uri.https(
      'api.github.com',
      '/repos/${Uri.encodeComponent(owner)}/${Uri.encodeComponent(repository)}/contents/$encodedPath',
      {'ref': revision},
    );
  }
}

class _ParsedFile {
  const _ParsedFile({
    required this.imports,
    required this.exports,
    required this.parseErrorCount,
  });

  final List<ImportInfo> imports;
  final Set<String> exports;
  final int parseErrorCount;
}

Map<String, Object?> _changedFile(Map<String, dynamic> file) {
  final path = file['filename']! as String;
  final patch = file['patch'] is String ? file['patch']! as String : '';
  final lineRanges = <Map<String, int>>[];
  final hunkPattern = RegExp(
    r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@',
    multiLine: true,
  );
  for (final match in hunkPattern.allMatches(patch)) {
    final oldStart = int.parse(match.group(1)!);
    final oldCount = int.parse(match.group(2) ?? '1');
    final newStart = int.parse(match.group(3)!);
    final newCount = int.parse(match.group(4) ?? '1');
    lineRanges.add({
      'oldStart': oldStart,
      'oldEnd': oldCount == 0 ? oldStart : oldStart + oldCount - 1,
      'newStart': newStart,
      'newEnd': newCount == 0 ? newStart : newStart + newCount - 1,
    });
  }
  return {
    'path': path,
    'status': file['status'] ?? 'modified',
    'changeType': file['status'] ?? 'modified',
    'additions': file['additions'] ?? 0,
    'deletions': file['deletions'] ?? 0,
    'patch': patch,
    'patchAvailable': patch.isNotEmpty,
    'changedLineRanges': lineRanges,
  };
}

String? _resolveImport(String importer, String source, Set<String> paths) {
  if (!source.startsWith('.')) return null;
  final resolved = p.posix.normalize(
    p.posix.join(p.posix.dirname(importer), source),
  );
  final candidates = <String>[
    resolved,
    for (final extension in ['.ts', '.tsx', '.js', '.jsx', '.mts', '.cts'])
      '$resolved$extension',
    for (final extension in ['.ts', '.tsx', '.js', '.jsx'])
      '$resolved/index$extension',
  ];
  for (final candidate in candidates) {
    if (paths.contains(candidate)) return candidate;
  }
  return null;
}

bool _supportedSource(String path) {
  final extension = p.posix.extension(path).toLowerCase();
  return const {
    '.ts',
    '.tsx',
    '.mts',
    '.cts',
    '.js',
    '.jsx',
    '.mjs',
    '.cjs',
  }.contains(extension);
}

bool _ignoredPath(String path) {
  return path
      .split('/')
      .any(
        (segment) => const {
          'node_modules',
          'dist',
          'build',
          'coverage',
          'vendor',
          '.next',
        }.contains(segment),
      );
}

bool _isTestFile(String path) {
  final lower = path.toLowerCase();
  return lower.contains('/test/') ||
      lower.contains('/tests/') ||
      lower.contains('/__tests__/') ||
      lower.endsWith('.test.ts') ||
      lower.endsWith('.test.tsx') ||
      lower.endsWith('.test.js') ||
      lower.endsWith('.test.jsx') ||
      lower.endsWith('.spec.ts') ||
      lower.endsWith('.spec.tsx') ||
      lower.endsWith('.spec.js') ||
      lower.endsWith('.spec.jsx');
}
