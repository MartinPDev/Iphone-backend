import SwiftUI

struct ExchangesView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var exchanges: [ExchangeKey] = []
    @State private var showingCreate = false
    @State private var errorMessage: String?

    var body: some View {
        List(exchanges) { exchange in
            HStack {
                Image(systemName: "building.columns").foregroundStyle(.indigo)
                VStack(alignment: .leading) {
                    Text(exchange.label ?? exchange.exchangeName.capitalized).font(.headline)
                    Text(exchange.isTestnet ? "Testnet" : "Live").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .overlay {
            if exchanges.isEmpty {
                ContentUnavailableView("No Exchanges", systemImage: "link", description: Text("Tap + to connect one."))
            }
        }
        .navigationTitle("Exchanges")
        .toolbar { Button { showingCreate = true } label: { Image(systemName: "plus") } }
        .sheet(isPresented: $showingCreate) {
            CreateExchangeView { payload in await create(payload) }
        }
        .refreshable { await load() }
        .task { await load() }
        .alert("Exchange request failed", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    private func load() async {
        guard let token = session.token else { return }
        do { exchanges = try await APIClient.shared.send("/api/v1/exchanges/keys", token: token) }
        catch { errorMessage = error.localizedDescription }
    }

    private func create(_ payload: ExchangeKeyCreate) async -> Bool {
        guard let token = session.token else { return false }
        do {
            let exchange: ExchangeKey = try await APIClient.shared.send("/api/v1/exchanges/keys", body: payload, token: token)
            exchanges.append(exchange)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

private struct CreateExchangeView: View {
    @Environment(\.dismiss) private var dismiss
    let onCreate: (ExchangeKeyCreate) async -> Bool
    @State private var exchange = "kraken"
    @State private var label = ""
    @State private var apiKey = ""
    @State private var apiSecret = ""
    @State private var passphrase = ""
    @State private var testnet = true
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Picker("Exchange", selection: $exchange) {
                    ForEach(["kraken", "coinbase", "binance"], id: \.self) { Text($0.capitalized) }
                }
                TextField("Label (optional)", text: $label)
                TextField("API key", text: $apiKey).textInputAutocapitalization(.never)
                SecureField("API secret", text: $apiSecret)
                SecureField("Passphrase (if required)", text: $passphrase)
                Toggle("Use testnet", isOn: $testnet)
                Text("Use trading-only keys. Never grant withdrawal permission.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .navigationTitle("Connect Exchange")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        isSaving = true
                        Task {
                            let payload = ExchangeKeyCreate(
                                exchangeName: exchange, apiKey: apiKey, apiSecret: apiSecret,
                                apiPassphrase: passphrase.isEmpty ? nil : passphrase,
                                isTestnet: testnet, label: label.isEmpty ? nil : label
                            )
                            if await onCreate(payload) { dismiss() }
                            isSaving = false
                        }
                    }
                    .disabled(apiKey.isEmpty || apiSecret.isEmpty || isSaving)
                }
            }
        }
    }
}

