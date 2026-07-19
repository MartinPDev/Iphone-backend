import SwiftUI

struct BotsView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var bots: [TradingBot] = []
    @State private var strategies: [Strategy] = []
    @State private var exchanges: [ExchangeKey] = []
    @State private var showingCreate = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            ForEach(bots) { bot in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(bot.name).font(.headline)
                            Text(bot.status.capitalized).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { bot.isEnabled },
                            set: { enabled in Task { await toggle(bot, enabled: enabled) } }
                        ))
                        .labelsHidden()
                    }
                    if let error = bot.lastError, !error.isEmpty {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .overlay {
            if bots.isEmpty {
                ContentUnavailableView("No Bots", systemImage: "cpu", description: Text("Tap + to create one."))
            }
        }
        .navigationTitle("Bots")
        .toolbar {
            Button { showingCreate = true } label: { Image(systemName: "plus") }
                .disabled(strategies.isEmpty || exchanges.isEmpty)
        }
        .sheet(isPresented: $showingCreate) {
            CreateBotView(strategies: strategies, exchanges: exchanges) { payload in
                await create(payload)
            }
        }
        .refreshable { await load() }
        .task { await load() }
        .alert("Bot request failed", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    private func load() async {
        guard let token = session.token else { return }
        do {
            async let loadedBots: [TradingBot] = APIClient.shared.send("/api/v1/bots", token: token)
            async let loadedStrategies: [Strategy] = APIClient.shared.send("/api/v1/strategies", token: token)
            async let loadedExchanges: [ExchangeKey] = APIClient.shared.send("/api/v1/exchanges/keys", token: token)
            (bots, strategies, exchanges) = try await (loadedBots, loadedStrategies, loadedExchanges)
        } catch { errorMessage = error.localizedDescription }
    }

    private func toggle(_ bot: TradingBot, enabled: Bool) async {
        guard let token = session.token else { return }
        do {
            let updated: TradingBot = try await APIClient.shared.send(
                "/api/v1/bots/\(bot.id)/toggle", method: "PATCH",
                body: BotToggle(isEnabled: enabled), token: token
            )
            if let index = bots.firstIndex(where: { $0.id == updated.id }) { bots[index] = updated }
        } catch { errorMessage = error.localizedDescription }
    }

    private func create(_ payload: BotCreate) async -> Bool {
        guard let token = session.token else { return false }
        do {
            let bot: TradingBot = try await APIClient.shared.send("/api/v1/bots", body: payload, token: token)
            bots.append(bot)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

private struct CreateBotView: View {
    @Environment(\.dismiss) private var dismiss
    let strategies: [Strategy]
    let exchanges: [ExchangeKey]
    let onCreate: (BotCreate) async -> Bool
    @State private var name = ""
    @State private var strategyID = ""
    @State private var exchangeID = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Bot name", text: $name)
                Picker("Strategy", selection: $strategyID) {
                    ForEach(strategies) { Text($0.name).tag($0.id) }
                }
                Picker("Exchange", selection: $exchangeID) {
                    ForEach(exchanges) { Text($0.label ?? $0.exchangeName.capitalized).tag($0.id) }
                }
            }
            .navigationTitle("New Bot")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        isSaving = true
                        Task {
                            if await onCreate(BotCreate(name: name, strategyID: strategyID, exchangeKeyID: exchangeID)) {
                                dismiss()
                            }
                            isSaving = false
                        }
                    }
                    .disabled(name.isEmpty || strategyID.isEmpty || exchangeID.isEmpty || isSaving)
                }
            }
            .onAppear {
                strategyID = strategies.first?.id ?? ""
                exchangeID = exchanges.first?.id ?? ""
            }
        }
    }
}

