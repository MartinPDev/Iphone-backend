import SwiftUI

struct StrategiesView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var strategies: [Strategy] = []
    @State private var showingCreate = false
    @State private var errorMessage: String?

    var body: some View {
        List(strategies) { strategy in
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(strategy.name).font(.headline)
                    Spacer()
                    if strategy.isAIEnabled {
                        Label("AI", systemImage: "sparkles").font(.caption).foregroundStyle(.indigo)
                    }
                }
                Text("\(strategy.symbol) · \(strategy.timeframe)")
                Text("Risk \(strategy.riskPercent, specifier: "%.1f")%")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .overlay {
            if strategies.isEmpty {
                ContentUnavailableView("No Strategies", systemImage: "slider.horizontal.3", description: Text("Tap + to add one."))
            }
        }
        .navigationTitle("Strategies")
        .toolbar { Button { showingCreate = true } label: { Image(systemName: "plus") } }
        .sheet(isPresented: $showingCreate) {
            CreateStrategyView { payload in await create(payload) }
        }
        .refreshable { await load() }
        .task { await load() }
        .alert("Strategy request failed", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    private func load() async {
        guard let token = session.token else { return }
        do { strategies = try await APIClient.shared.send("/api/v1/strategies", token: token) }
        catch { errorMessage = error.localizedDescription }
    }

    private func create(_ payload: StrategyCreate) async -> Bool {
        guard let token = session.token else { return false }
        do {
            let strategy: Strategy = try await APIClient.shared.send("/api/v1/strategies", body: payload, token: token)
            strategies.append(strategy)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

private struct CreateStrategyView: View {
    @Environment(\.dismiss) private var dismiss
    let onCreate: (StrategyCreate) async -> Bool
    @State private var name = ""
    @State private var symbol = "BTC/USD"
    @State private var timeframe = "15m"
    @State private var risk = 1.0
    @State private var takeProfit = 4.0
    @State private var stopLoss = 2.0
    @State private var aiEnabled = true
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Symbol", text: $symbol).textInputAutocapitalization(.characters)
                Picker("Timeframe", selection: $timeframe) {
                    ForEach(["1m", "5m", "15m", "1h", "4h", "1d"], id: \.self) { Text($0) }
                }
                Section("Risk") {
                    Stepper("Risk: \(risk, specifier: "%.1f")%", value: $risk, in: 0.1...25, step: 0.1)
                    Stepper("Take profit: \(takeProfit, specifier: "%.1f")%", value: $takeProfit, in: 0.1...100, step: 0.1)
                    Stepper("Stop loss: \(stopLoss, specifier: "%.1f")%", value: $stopLoss, in: 0.1...25, step: 0.1)
                    Toggle("AI assistance", isOn: $aiEnabled)
                }
            }
            .navigationTitle("New Strategy")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        isSaving = true
                        Task {
                            let payload = StrategyCreate(
                                name: name, symbol: symbol, timeframe: timeframe,
                                riskPercent: risk, takeProfitPercent: takeProfit,
                                stopLossPercent: stopLoss, isAIEnabled: aiEnabled
                            )
                            if await onCreate(payload) { dismiss() }
                            isSaving = false
                        }
                    }
                    .disabled(name.isEmpty || symbol.isEmpty || isSaving)
                }
            }
        }
    }
}

