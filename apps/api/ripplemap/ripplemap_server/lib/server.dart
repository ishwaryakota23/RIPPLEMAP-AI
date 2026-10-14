import 'dart:io';

import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'src/cache_busting.dart';
import 'src/generated/serverpod.dart';
import 'src/github/github_client.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/ripplemap_api_route.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod. The generated Serverpod class is already connected
  // with your project's generated code.
  final pod = Serverpod(args);
  final configuredSessionPepper = PlatformEnvironment.value(
    'SERVERPOD_PASSWORD_serverSideSessionKeyHashPepper',
  )?.trim();
  final storedSessionPepper = pod.getPassword(
    'serverSideSessionKeyHashPepper',
  );
  AuthServices.set(
    tokenManagerBuilders: [
      configuredSessionPepper == null || configuredSessionPepper.isEmpty
          ? ServerSideSessionsConfigFromPasswords(
              defaultSessionLifetime: const Duration(days: 14),
              defaultSessionInactivityTimeout: const Duration(days: 30),
            )
          : ServerSideSessionsConfig(
              sessionKeyHashPepper: configuredSessionPepper,
              fallbackSessionKeyHashPeppers:
                  storedSessionPepper == null ||
                      configuredSessionPepper == storedSessionPepper
                  ? const []
                  : [storedSessionPepper],
              defaultSessionLifetime: const Duration(days: 14),
              defaultSessionInactivityTimeout: const Duration(days: 30),
            ),
    ],
    identityProviderBuilders: [
      ServerpodCloudEmailIdpConfig(appDisplayName: 'RippleMap AI'),
    ],
  );
  pod.authenticationHandler = AuthServices.instance.authenticationHandler;

  // Serve all files in the web/static relative directory under /web.
  // These are used by the default web page.
  pod.webServer.addRoute(
    StaticRoute.withCacheBusting(cacheBustingConfig),
    cacheBustingConfig.mountPrefix,
  );

  pod.webServer.addRoute(RippleMapApiRoute(), '/api/**');
  pod.webServer.addRoute(RippleMapApiRoute(), '/auth/**');
  pod.webServer.addRoute(RippleMapApiRoute(), '/webhooks/**');

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/assets/assets/config.json',
  );

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under /.
    pod.webServer.addRoute(
      FlutterRoute(
        appDir,
        // If building the Flutter app with WASM, set the below parameter to
        // true and add the --wasm flag to the flutter build command.
        enableWasmHeaders: false,
      ),
      '/',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    final defaultRoute = StaticRoute.file(
      File(
        Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
      ),
    );

    pod.webServer.addMiddleware(
      FallbackMiddleware(
        fallback: defaultRoute,
        on: (response) => response.statusCode == 404,
      ).call,
      '/',
    );

    pod.webServer.addRoute(
      defaultRoute,
      '/**',
    );
  }

  // Start the server.
  await pod.start();
}
