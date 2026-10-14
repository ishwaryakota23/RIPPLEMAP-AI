# Local setup

## Toolchain

Use Flutter stable 3.44.4 or later, Dart 3.12.2 or later, and Serverpod CLI 4.x. The hackathon requires Flutter. Serverpod runs embedded PostgreSQL locally, so Docker is not a prerequisite. The first backend startup downloads a checksum-verified PostgreSQL bundle from the official Serverpod GitHub release. The first supported-source analysis downloads Tree-sitter parser assets; allow outbound HTTPS access for both.

## Configuration and secrets

Copy `.env.example` to `.env` in the repository root and fill in the backend values. The Serverpod backend reads `.env` from its current directory or the nearest parent directory; process environment variables take precedence. Do not copy the backend secrets into Flutter `--dart-define` options.

The GitHub OAuth App callback URL must be exactly `http://localhost:8082/auth/github/callback`. The app also validates a per-login, random `state` value against an HttpOnly, SameSite=Lax cookie bound to the authenticated RippleMap user.

```powershell
Copy-Item .env.example .env
```

Set or update these values in the root `.env` file:

```powershell
$env:GITHUB_CLIENT_ID = "<OAuth app client ID>"
$env:GITHUB_CLIENT_SECRET = "<OAuth app client secret>"
$env:GITHUB_REDIRECT_URI = "http://localhost:8082/auth/github/callback"
$env:GITHUB_OAUTH_SCOPE = "public_repo" # use "repo" for private repositories
$env:SESSION_ENCRYPTION_KEY = "<base64-encoded random 32-byte key>"
$env:GITHUB_WEBHOOK_SECRET = "<optional webhook secret>"
$env:GROQ_API_KEY = "<optional Groq API key>"
$env:RIPPLEMAP_FRONTEND_ORIGIN = "http://localhost:5000"
```

Register the callback URL with the GitHub OAuth app. Generate the encryption key with:

```powershell
$bytes = New-Object byte[] 32
[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
[Convert]::ToBase64String($bytes)
```

The local embedded database generates and persists a development password. If you provide a database password explicitly, keep it in the ignored `config/passwords.yaml` Serverpod file or the backend-only `SERVERPOD_PASSWORD_database` environment variable. Do not add credentials to Flutter build defines, repository files, logs, or screenshots.

### GitHub webhooks

Webhooks are optional; manual repository analysis remains available without them. To enable delivery, configure a **GitHub App or repository webhook** with:

- Payload URL: `https://<your-public-host>/webhooks/github` (for local testing, use a temporary HTTPS tunnel; do not configure `localhost` as a public URL).
- Content type: `application/json`.
- Secret: a new random secret in `GITHUB_WEBHOOK_SECRET`; do not reuse the OAuth client secret.
- Events: `push` and `pull_request`.

The endpoint validates `X-Hub-Signature-256` with HMAC-SHA256, validates delivery/event headers, limits the body to 1 MB, and deduplicates delivery IDs. Local signature tests verify valid and invalid signatures; live GitHub delivery requires a reachable HTTPS URL and must be tested separately.

### Groq

Set `GROQ_API_KEY` only in the backend `.env` or backend process environment. `GROQ_MODEL` defaults to `openai/gpt-oss-20b`; the backend checks that the selected model is available to the key before requesting insights. Groq is optional and failures leave deterministic analysis intact. Do not put the key in Flutter configuration.

For server-side session hashing, the backend uses `SERVERPOD_PASSWORD_serverSideSessionKeyHashPepper` from the root `.env` when present; otherwise it uses `serverSideSessionKeyHashPepper` from the ignored `apps/api/ripplemap/ripplemap_server/config/passwords.yaml`. If the `.env` pepper differs from the existing Serverpod password, the old value is retained as a fallback so existing sessions remain verifiable. Keep the active pepper stable; rotating it without a fallback invalidates existing sessions. This pepper is required for the Serverpod email identity provider and HTTP-only auth cookies.

Serverpod Cloud email delivery is supported through the email identity provider. During local development, verification/reset codes are surfaced through Serverpod alerts and logs; staging/production require the actual `scloudAuthEmailKey` and a configured email sender. Without those credentials, sign-up and password reset still work in a limited dev flow but live email delivery will not occur.

The backend reports unavailable integrations explicitly when credentials have not been configured. Analysis must not return example or fabricated repository data.

The development session pepper has been generated in the ignored `config/passwords.yaml` for this workspace. Generate a different stable value for each deployment; do not copy development secrets into staging or production. Losing a deployment's pepper invalidates sessions issued with it.

## Run locally

The Serverpod package is the source of truth for generated protocol bindings and database migrations. Start the backend from the Serverpod workspace:

```powershell
cd apps\api\ripplemap
dart pub get
serverpod generate
serverpod start --no-flutter --no-tui
```

In a second terminal:

```powershell
cd apps\flutter_app
flutter pub get
flutter run -d web-server --web-hostname localhost --web-port 5000 --dart-define=RIPPLEMAP_API_URL=http://localhost:8082
```

The Flutter web client sends credentialed requests to the Serverpod Relic listener on port 8082, while generated auth endpoint calls use port 8080. Keep both origins on `localhost` during development. Configure the backend's allowed origins to the Flutter app's exact origin.

Serverpod applies pending PostgreSQL migrations on startup. The account ownership migration retains old anonymous records but does not assign them to newly created users. New analysis jobs, GitHub connections, repository preferences, and review decisions are scoped to the authenticated Serverpod user identifier. Do not manually edit migration SQL or the migration registry.

## Account data features

- RippleMap identity is email/password with verification and reset through Serverpod's email identity provider. GitHub OAuth is a separate repository authorization connection, not RippleMap login.
- The selected repository preference is saved only after the backend verifies it is accessible with that account's GitHub token.
- Analysis history is limited to the most recent 100 account-owned jobs. Review decisions (`approved`, `changes_requested`, `reviewed`) and optional notes are persisted separately and checked against the analysis owner.
- Disconnecting GitHub deletes only the signed-in user's encrypted connection and clears that user's selected-repository preference. Analysis reports remain in that account's history.
- The backend rejects unauthenticated settings/history reads and filters analysis lookup and review writes by the authenticated identity. Run the ownership integration test with the test database started.

To run any Serverpod integration tests that use the test database, start it in a separate terminal first:

```powershell
cd apps\api\ripplemap
serverpod database start --mode test
```

Keep it running while tests execute; stop it with Ctrl+C afterward.

The focused User A/User B record-isolation check is `test/integration/account_ownership_test.dart`.

## Tests

```powershell
cd apps\api\ripplemap\ripplemap_server
dart test
dart analyze

cd ..\..\..\flutter_app
flutter test
flutter analyze
```

The native Tree-sitter integration test downloads parser assets and is skipped by default. Run it explicitly when network access is available:

```powershell
cd apps\api\ripplemap\ripplemap_server
$env:RIPPLEMAP_RUN_NATIVE_PARSER_TESTS = "true"
dart test test\unit\impact_analyzer_parser_test.dart
```

## GitHub webhooks

Manual pull-request analysis is the fallback for local development. Configure a GitHub OAuth App with callback `http://localhost:8082/auth/github/callback`, and set `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`, `SESSION_ENCRYPTION_KEY`, and the selected scopes in the Serverpod process environment. The code flow binds authorization state to the signed-in RippleMap identity and encrypts the token at rest. The configured scope is `public_repo` for public repositories or `repo` for private repositories.

To test live webhooks, deploy Serverpod to a reachable HTTPS endpoint, configure a GitHub webhook for `pull_request` and `push`, and set the same webhook secret on GitHub and the backend. The server verifies HMAC signatures, deduplicates delivery IDs, and maps organization repositories by checking each connected user's authorized repository list. A live GitHub OAuth or webhook flow has not been validated until credentials and a reachable callback/webhook endpoint are supplied.

## Manual deployment checklist

1. Choose a PostgreSQL host compatible with Serverpod 4 and configure production database connection values.
2. Configure stable, unique Serverpod production secrets, especially `serverSideSessionKeyHashPepper`, email IDP secrets, database credentials, GitHub OAuth secrets, and the session encryption key.
3. Configure Serverpod Cloud email delivery (`scloudAuthEmailKey` and sender) and verify signup and password-reset messages reach inboxes.
4. Register the HTTPS GitHub OAuth callback for the deployed API and test public/private repository authorization with the least required scope.
5. Configure HTTPS origins/cookies and `allowedOrigins`; verify auth cookies are secure and HttpOnly.
6. Configure GitHub webhook delivery only if live monitoring is required; test signature rejection, duplicate events, pull-request updates, and organization repositories.
7. Set `GROQ_API_KEY` only if AI explanations are desired; deterministic analysis remains available without it.
8. Build/deploy Flutter and Serverpod separately or serve the built Flutter app through Serverpod; run the migration and verify account isolation in the deployed database.

## AI insights

The backend uses only the official Groq API. With `GROQ_API_KEY` absent, deterministic findings still render and the UI labels AI as unavailable. When configured, the backend first queries the account's available models, selects/validates a chat model, and validates structured responses before persistence.
