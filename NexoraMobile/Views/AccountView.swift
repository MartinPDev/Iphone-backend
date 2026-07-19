import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        List {
            Section("Profile") {
                LabeledContent("Username", value: session.user?.username ?? "—")
                LabeledContent("Email", value: session.user?.email ?? "—")
            }
            Section("Server") {
                Text(APIConfig.baseURL.absoluteString)
                    .font(.footnote.monospaced())
            }
            Section {
                Button("Sign Out", role: .destructive) { session.signOut() }
            }
        }
        .navigationTitle("Account")
    }
}

