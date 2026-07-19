import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var bots: [TradingBot] = []
    @State private var strategies: [Strategy] = []
    @State private var exchanges: [ExchangeKey] = []
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                metric("Bots", value: "\(bots.count)", icon: "cpu")
                metric("Running", value: "\(bots.filter(\.isEnabled).count)", icon: "play.circle.fill")
                metric("Strategies", value: "\(strategies.count)", icon: "slider.horizontal.3")
                metric("Exchanges", value: "\(exchanges.count)", icon: "link")
            }
            .padding()

            if bots.isEmpty {
                ContentUnavailableView(
                    "No Bots Yet",
                    systemImage: "cpu",
                    description: Text("Add an exchange and strategy, then create your first bot.")
                )
                .padding(.top, 30)
            }
        }
        .navigationTitle("Dashboard")
        .refreshable { await load() }
        .task { await load() }
        .alert("Could not load dashboard", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    private func metric(_ title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon).foregroundStyle(.indigo).font(.title2)
            Text(value).font(.largeTitle.bold())
            Text(title).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private func load() async {
        guard let token = session.token else { return }
        do {
            async let loadedBots: [TradingBot] = APIClient.shared.send("/api/v1/bots", token: token)
            async let loadedStrategies: [Strategy] = APIClient.shared.send("/api/v1/strategies", token: token)
            async let loadedExchanges: [ExchangeKey] = APIClient.shared.send("/api/v1/exchanges/keys", token: token)
            (bots, strategies, exchanges) = try await (loadedBots, loadedStrategies, loadedExchanges)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

