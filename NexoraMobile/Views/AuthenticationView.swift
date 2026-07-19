import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var createAccount = false
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var isWorking = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label("Nexora", systemImage: "waveform.path.ecg.rectangle")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.indigo)
                }

                Section(createAccount ? "Create account" : "Sign in") {
                    if createAccount {
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }
                    TextField(createAccount ? "Username" : "Username or email", text: $username)
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $password)
                }

                Section {
                    Button {
                        submit()
                    } label: {
                        HStack {
                            Spacer()
                            if isWorking { ProgressView() }
                            Text(createAccount ? "Create Account" : "Sign In").bold()
                            Spacer()
                        }
                    }
                    .disabled(username.isEmpty || password.isEmpty || (createAccount && email.isEmpty) || isWorking)

                    Button(createAccount ? "Already have an account?" : "Create an account") {
                        createAccount.toggle()
                    }
                }
            }
            .alert("Unable to continue", isPresented: Binding(
                get: { session.errorMessage != nil },
                set: { if !$0 { session.errorMessage = nil } }
            )) {
                Button("OK") { session.errorMessage = nil }
            } message: {
                Text(session.errorMessage ?? "")
            }
        }
    }

    private func submit() {
        isWorking = true
        Task {
            if createAccount {
                _ = await session.register(email: email, username: username, password: password)
            } else {
                _ = await session.signIn(identity: username, password: password)
            }
            isWorking = false
        }
    }
}

