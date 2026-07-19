# Nexora iPhone

A native SwiftUI client for the Nexora FastAPI backend. The app uses the authenticated
`/api/v1` routes for accounts, strategies, exchange connections, and trading bots.

## Requirements

- Xcode 16 or newer
- iOS 17 or newer
- A reachable Nexora backend

## Run

1. Open `NexoraMobile.xcodeproj` in Xcode.
2. Select the `NexoraMobile` scheme.
3. Set your development team under **Signing & Capabilities**.
4. Copy `Config/Local.xcconfig.example` to `Config/Local.xcconfig`.
5. Replace the example URL with the HTTPS address of your FastAPI server.
6. Build and run on an iPhone or simulator.

For a backend running on your Mac, the iOS simulator can normally use
`http://127.0.0.1:8000`. A physical iPhone must use your Mac's LAN address or a
public HTTPS URL. iOS blocks arbitrary insecure HTTP hosts by default.

## API coverage

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `GET /api/v1/users/me`
- `GET|POST /api/v1/strategies`
- `GET|POST /api/v1/exchanges/keys`
- `GET|POST /api/v1/bots`
- `PATCH /api/v1/bots/{id}/toggle`

The bearer token is stored in the iOS Keychain. Exchange secrets are sent only when
creating a connection and are never stored by the app.

