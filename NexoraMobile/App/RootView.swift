import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        Group {
            if session.isRestoring {
                ProgressView("Connecting…")
            } else if session.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .animation(.easeInOut, value: session.isAuthenticated)
    }
}

private struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack { DashboardView() }
                .tabItem { Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis") }

            NavigationStack { BotsView() }
                .tabItem { Label("Bots", systemImage: "cpu") }

            NavigationStack { StrategiesView() }
                .tabItem { Label("Strategies", systemImage: "slider.horizontal.3") }

            NavigationStack { ExchangesView() }
                .tabItem { Label("Exchanges", systemImage: "link") }

            NavigationStack { AccountView() }
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
        }
        .tint(.indigo)
    }
}

