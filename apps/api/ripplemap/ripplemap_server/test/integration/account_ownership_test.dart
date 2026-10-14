import 'package:ripplemap_server/src/account_data_access.dart';
import 'package:ripplemap_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Account-owned analysis data', (sessionBuilder, endpoints) {
    test(
      'another authenticated account cannot read an analysis by its key',
      () async {
        const jobKey = 'ownership-test-job';
        final ownerSession = sessionBuilder
            .copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                'account-a',
                {},
              ),
            )
            .build();
        try {
          await ownerSession.db.insertRow(
            AnalysisJob(
              jobKey: jobKey,
              authUserId: 'account-a',
              owner: 'owner',
              repository: 'private-repo',
              pullRequestNumber: 1,
              status: 'completed',
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          );
        } finally {
          await ownerSession.close();
        }

        final ownerReader = sessionBuilder
            .copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                'account-a',
                {},
              ),
            )
            .build();
        final otherReader = sessionBuilder
            .copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                'account-b',
                {},
              ),
            )
            .build();
        try {
          expect(
            (await findOwnedAnalysisJob(ownerReader, jobKey))?.authUserId,
            'account-a',
          );
          expect(await findOwnedAnalysisJob(otherReader, jobKey), isNull);
        } finally {
          await ownerReader.close();
          await otherReader.close();
        }
      },
    );
  });
}
