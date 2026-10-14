import 'package:ripplemap_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

Future<AnalysisJob?> findOwnedAnalysisJob(
  Session session,
  String jobKey,
) async {
  final authUserId = session.authenticated?.userIdentifier;
  if (authUserId == null || authUserId.isEmpty) return null;
  return session.db.findFirstRow<AnalysisJob>(
    where:
        AnalysisJob.t.jobKey.equals(jobKey) &
        AnalysisJob.t.authUserId.equals(authUserId),
  );
}
