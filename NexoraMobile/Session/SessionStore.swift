import Foundation

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var token: String?
    @Published private(set) var user: User?
    @Published private(set) var isRestoring = true
    @Published var errorMessage: String?

    var isAuthenticated: Bool { token != nil && user != nil }

    func restoreSession() async {
        defer { isRestoring = false }
        guard let savedToken = KeychainStore.load() else { return }
        token = savedToken
        do {
            user = try await APIClient.shared.send("/api/v1/users/me", token: savedToken)
        } catch {
            signOut()
        }
    }

    func signIn(identity: String, password: String) async -> Bool {
        do {
            let response: TokenResponse = try await APIClient.shared.send(
                "/api/v1/auth/login",
                body: LoginRequest(usernameOrEmail: identity, password: password)
            )
            token = response.accessToken
            KeychainStore.save(token: response.accessToken)
            user = try await APIClient.shared.send("/api/v1/users/me", token: response.accessToken)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func register(email: String, username: String, password: String) async -> Bool {
        do {
            let _: User = try await APIClient.shared.send(
                "/api/v1/auth/register",
                body: RegistrationRequest(email: email, username: username, password: password)
            )
            return await signIn(identity: username, password: password)
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func signOut() {
        KeychainStore.delete()
        token = nil
        user = nil
    }
}

