import SwiftUI

@main
struct NexoraMobileApp: App {
    @StateObject private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .task { await session.restoreSession() }
        }
    }
}

