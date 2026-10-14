import 'dart:convert';

import 'package:ripplemap_server/src/generated/protocol.dart';
import 'package:ripplemap_server/src/github/github_client.dart';
import 'package:serverpod/serverpod.dart';

import 'groq_insights.dart';
import 'impact_analyzer.dart';

class AnalysisFutureCall extends FutureCall<AnalysisTask> {
  Future<void> process(Session session, AnalysisTask task) async {
    final job = await session.db.findFirstRow<AnalysisJob>(
      where: AnalysisJob.t.jobKey.equals(task.jobKey) &
          AnalysisJob.t.authUserId.equals(task.authUserId),
    );
    if (job == null || job.status != 'queued') return;

    job.status = 'running';
    job.updatedAt = DateTime.now().toUtc();
    await session.db.updateRow(job);

    try {
      final connection = await session.db.findFirstRow<GitHubConnection>(
        where: GitHubConnection.t.authUserId.equals(task.authUserId),
      );
      if (connection == null) {
        throw StateError('The GitHub connection is no longer available.');
      }
      final token = await CredentialVault().decrypt(
        connection.encryptedAccessToken,
      );
      final github = GitHubClient();
      late final Map<String, Object?> report;
      try {
        report = await ImpactAnalyzer(github).analyze(
          owner: task.owner,
          repository: task.repository,
          pullRequestNumber: task.pullRequestNumber,
          token: token,
        );
      } finally {
        github.close();
      }
      final groq = GroqInsights();
      late final Map<String, Object?> ai;
      try {
        ai = await groq.explain(report);
      } finally {
        groq.close();
      }
      report.addAll(ai);
      final recommendations = report['recommendations'];
      final aiRecommendations = ai['aiRecommendations'];
      if (recommendations is List && aiRecommendations is List) {
        recommendations.addAll(aiRecommendations);
      }

      job.status = 'completed';
      job.reportJson = jsonEncode(report);
      job.errorMessage = null;
    } on Exception catch (error, stackTrace) {
      session.log(
        'Analysis job ${task.jobKey} failed.',
        level: LogLevel.error,
        exception: error,
        stackTrace: stackTrace,
      );
      job.status = 'failed';
      job.errorMessage = _publicError(error);
    }
    job.updatedAt = DateTime.now().toUtc();
    await session.db.updateRow(job);
  }

  String _publicError(Exception error) {
    if (error is GitHubApiException) return error.message;
    if (error is StateError || error is FormatException) {
      return error.toString();
    }
    return 'Analysis could not be completed. Check the backend logs for details.';
  }
}
