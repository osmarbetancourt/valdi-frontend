# Mercedes Analytics — API Reference (summary)

Base OpenAPI: https://api-backoffice.mercedes-mb.org/api-docs/openapi.json

Quick guide (minimal, for mobile app development)

Authentication
- POST /admin/auth/login — body: { username, password } → returns an access_token (server uses JWT / bearer scheme; backend sets cookies for session too). Status: 200 / 401
- POST /admin/auth/logout — logs out (200)
- GET /admin/auth/me — get current user (requires bearerAuth / valid session)
- POST /admin/auth/forgot-password, POST /admin/auth/set-password — password reset flows

Admin resources (require bearerAuth / admin role)
- Businesses: GET /admin/businesses, POST /admin/businesses, GET/PUT/DELETE /admin/businesses/{id}
- Users: GET /admin/users, POST /admin/users, GET/PUT/DELETE /admin/users/{id}

Public (read) endpoints — commonly used by mobile app
- GET /public/businesses — list public businesses
- GET /public/businesses/{id} — get business detail
- GET /public/businesses/stats?ids=... — aggregated counts (by production business UUID)
- GET /public/clients — list clients
- GET /public/clients/{id}
- GET /public/conversations — cursor-based pagination (query: cursor, limit)
- GET /public/messages — cursor-based pagination; supports conversation_id and business_client_id filters
- GET /public/messages/{id} — message detail
- GET /public/paymentaudits — list payment audits
- GET /public/paymentaudits/{id}
- GET /public/productaccounts — paginated, many query filters (client, business, status, date_from/to)
- GET /public/productaccounts/{id}
- POST /public/metabase/embed — generate Metabase embed token + iframe URL for dashboards (body: business_id or business_name; optional question_id) — returns { iframe_url, token, question_id }

Pagination notes
- Many list endpoints are cursor-based. Typical query parameters: cursor (string|null) and limit (int). Responses include next_cursor for paging.

Schemas (examples)
- ConversationDto — id, client_id, started_at, ended_at
- MessageDto — id, conversation_id, text, timestamp, sender, receiver, status flags
- ProductAccountDto — id, client, current_debt, product_type, status, latest_messages
- PaymentAuditDto — id, amount, currency, payment_date, status

Auth & mobile best practices
- The backend supports sessions via cookies (server sets JWT cookies) and bearerAuth in OpenAPI. For mobile: use Dio + PersistCookieJar (cookie persistence) and/or store tokens in `flutter_secure_storage`.
- Protect sensitive storage (tokens) and prefer secure storage for credentials.

Examples — curl
- Login (returns access_token in response body when available):

```bash
curl -X POST https://api-backoffice.mercedes-mb.org/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"secret"}'
```

- Get paginated conversations (public):

```bash
curl "https://api-backoffice.mercedes-mb.org/public/conversations?limit=20" -H "Accept: application/json"
```

- Generate a Metabase embed (public):

```bash
curl -X POST https://api-backoffice.mercedes-mb.org/public/metabase/embed \
  -H "Content-Type: application/json" \
  -d '{"business_id":"<uuid>", "question_id": 12345}'
```

Where to find more
- Full OpenAPI JSON: https://api-backoffice.mercedes-mb.org/api-docs/openapi.json (authoritative; use for code-generation — swagger-codegen / openapi-generator / retrofit / dio client scaffolding)

Notes
- This reference is a short developer-facing summary focused on mobile client usage. For full types and all endpoints, consult the OpenAPI JSON and generate models or DTOs.
