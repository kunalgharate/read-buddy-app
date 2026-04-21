---
inclusion: fileMatch
fileMatchPattern: ["**/data/**", "**/datasources/**", "**/remotesource/**", "**/models/**"]
---

# API & Data Layer Standards

## Networking
- Dio with `AppInterceptor` (auto Bearer token, 401 token refresh)
- Base URL: `https://readbuddy-server.onrender.com/api`
- Timeouts: connect 120s, receive 180s, send 120s
- Check `NetworkUtils.hasInternetConnection()` before API calls
- Endpoints: #[[file:lib/core/network/api_constants.dart]]

## API Response Patterns

```json
// Auth — nested user + tokens at root
{ "user": { "_id": "...", "name": "..." }, "accessToken": "...", "refreshToken": "..." }

// List — array at root
[ { "_id": "...", "title": "..." }, ... ]

// Error
{ "message": "Error description" }
```

## Model Rules
- EXTEND domain entities using `super` parameters
- MANUAL `fromJson`/`toJson` — no json_serializable
- Handle both flat and nested responses in fromJson
- MongoDB IDs use `_id` field

## Data Source Rules
- Abstract class + implementation
- Inject `Dio` (and `SecureStorageUtil` if auth needed) via constructor
- Handle `DioException` and rethrow

## Repository Rules
- Implement domain interface
- Take data source as constructor dependency
