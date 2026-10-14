# RippleMap AI

**See the impact before the breakage.**

RippleMap analyzes a real GitHub pull request before merge. The deterministic engine retrieves the PR diff, parses supported JavaScript and TypeScript, traces repository dependencies, identifies relevant tests, and reports evidence, uncertainty, and heuristic risk. Groq explains supplied evidence when configured; it does not create dependency edges.

## Architecture decision

The hackathon compatibility check found no submission rules in the workspace. The user confirmed that **Flutter is mandatory**, so this project uses Flutter and Serverpod with Dart.

## Project structure

```text
apps/
  flutter_app/              Flutter dashboard (web-first, responsive)
  api/ripplemap/            Serverpod workspace
    ripplemap_server/        Dart backend, analysis engine, migrations
    ripplemap_client/        Generated Serverpod client
docs/                        Architecture and setup
```

## Requirements

- Flutter stable 3.44.4 or later (Serverpod 4 requirement)
- Dart 3.12.2 or later
- Serverpod CLI 4.x
- Network access on first run so Serverpod can download its PostgreSQL bundle and Tree-sitter can download TypeScript/JavaScript parser assets
- GitHub OAuth App credentials for repository authorization
- A Groq API key for optional AI insights

Serverpod 4 runs a real local PostgreSQL instance through its embedded database workflow; Docker is not required for local development. The PostgreSQL bundle is downloaded once from the official Serverpod GitHub release and verified before use.

## Configuration

`.env.example` is a reference, not an automatically loaded file. Set the backend variables in the Serverpod process environment. Keep OAuth secrets, the session encryption key, webhook secret, `serverSideSessionKeyHashPepper`, and `GROQ_API_KEY` on the backend only. The frontend receives only `RIPPLEMAP_API_URL` through a Flutter `--dart-define`; never pass secrets to Flutter or commit them.

Use the Serverpod email identity provider for sign-up, verification, login, and password-reset flows. Local dev can use verification codes surfaced in Serverpod logs; production/staging require a working Serverpod Cloud email configuration. Repository analysis is available only after real GitHub authorization and a repository/PR selection. GitHub webhooks require a public HTTPS deployment and a configured webhook secret; manual PR analysis is the local fallback. Groq is optional: deterministic findings remain available when AI is not configured or unavailable.

Signed-in users have account-scoped analysis history, a validated default repository preference, and persisted review decisions/notes. GitHub can be disconnected from the account settings; the associated encrypted connection and repository preference are removed while analysis history remains. Serverpod applies the generated migrations on startup. Existing anonymous rows are retained without being reassigned to accounts.

GitHub authorization is a separate repository connection, not a RippleMap login provider. The callback and webhook flows require real OAuth credentials and a reachable deployment to be verified. Review the [manual deployment checklist](./docs/setup.md#manual-deployment-checklist) before staging or production.

## Development

Install the Flutter and Serverpod dependencies, then follow the exact commands in [docs/setup.md](./docs/setup.md). Start the Serverpod backend and Flutter web app in separate terminals. Backend test, analyzer, and Flutter widget-test commands are documented there as they are wired into the project.

## Analysis semantics

- **Confirmed dependency**: direct import relationship parsed from source.
- **Potential impact**: bounded reverse-dependency path or disclosed test-selection heuristic.
- **AI hypothesis**: Groq suggestion tied to supplied evidence and clearly marked for verification.
- Graph edge direction: importing file → imported module.
- Risk levels are deterministic, explainable heuristics, not failure guarantees.
- Unsupported languages and unavailable GitHub diff/source evidence are disclosed in the report.
