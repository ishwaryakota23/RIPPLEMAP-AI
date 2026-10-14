# RippleMap AI Architecture

## Hackathon compatibility

The submission rules were not present in the workspace. The user confirmed Flutter is mandatory. The frontend is therefore Flutter, and the genuine application backend is Serverpod using Dart.

## Runtime components

- **Flutter web dashboard**: repository selection, PR selection, diff viewer, evidence findings, risk and recommendation views, dependency visualization.
- **Serverpod RPC and HTTP routes**: backend business logic, GitHub OAuth callback, GitHub API access, signed webhook route, status polling and persisted reports.
- **PostgreSQL**: OAuth session and encrypted credential metadata, idempotent webhook event IDs, analysis jobs, and complete report JSON.
- **GitHub API**: authorized repository/PR metadata, changed-file patches, branch/tree snapshot and pull-request event source.
- **Tree-sitter language pack**: TypeScript and JavaScript parsing for imports, declarations, exports, symbols, and source spans.
- **Groq API**: optional evidence-based explanation and recommendations; server-only API key.

## Request flow

1. A developer authorizes RippleMap through GitHub OAuth. The backend exchanges the code and stores the credential encrypted at rest; browser code receives only an HttpOnly session cookie.
2. Flutter loads repositories and open pull requests through the Serverpod web API.
3. Manual analysis or a verified `pull_request` webhook creates a persisted job. The job is processed by Serverpod and its status can be polled.
4. Serverpod retrieves the real PR metadata, diff, and base-branch source snapshot. Size and rate limits are explicit.
5. Tree-sitter parses supported JS/TS files. Import edges point from importer to dependency; reverse traversal identifies confirmed direct consumers and bounded potential impacts.
6. Test files are identified from parser references and transparent path/name heuristics. Priorities are calculated from changed public symbols, dependency reach, change type, and test evidence.
7. Groq receives only a bounded diff excerpt and parser-derived evidence. Its output is validated and labeled as hypothesis; unavailable AI never replaces deterministic output.
8. The full report and job status are persisted and rendered in Flutter.

## Webhooks and local use

GitHub webhook callbacks must verify `X-Hub-Signature-256` against the raw body before processing, and deduplicate `X-GitHub-Delivery`. Webhooks require HTTPS and a reachable backend in deployment. Local development uses manually triggered pull-request analysis and does not claim live monitoring.

Tree-sitter initializes its native bridge in the Serverpod process and downloads language parser assets on first use. The host therefore needs outbound HTTPS access to the package's GitHub release; parser initialization or parsing failures are surfaced through the analysis job rather than reported as successful analysis.

## Security boundaries

- OAuth client secret, GitHub access token, session-encryption key, webhook secret, and Groq API key stay on the Serverpod backend.
- GitHub tokens are encrypted with authenticated encryption before persistence and are never returned to Flutter.
- OAuth state, HttpOnly cookies, origin checks, least-privilege API requests, bounded inputs, and rate-limit handling protect the integration.
- Only evidence needed for an explanation is sent to Groq; full repository source is not sent.
- Logs contain status and correlation identifiers, not secrets, authorization headers, diffs, or Groq prompts.

## Deployment

No hosting provider is selected until its support for Serverpod 4, persistent PostgreSQL, TLS, environment secrets, and custom webhook routes is verified. Serverpod Cloud is a candidate because Serverpod documents its integrated deployment flow, but it still needs a project-level verification before deployment.
