import 'package:flutter_test/flutter_test.dart';
import 'package:ripplemap_flutter/auth/ripplemap_auth_service.dart';
import 'package:ripplemap_flutter/main.dart';

void main() {
  testWidgets('unauthenticated users see the public landing page', (
    tester,
  ) async {
    await tester.pumpWidget(
      RippleMapApp(authService: _UnauthenticatedAuthService()),
    );
    await tester.pumpAndSettle();

    expect(find.text('See the impact before the breakage.'), findsOneWidget);
    expect(find.text('Analysis history'), findsNothing);
    expect(find.text('A grounded stack. A clear boundary.'), findsNothing);
    expect(find.text('PostgreSQL'), findsNothing);
  });
}

class _UnauthenticatedAuthService extends RippleMapAuthService {
  @override
  Future<String?> currentUserId() async => null;
}
