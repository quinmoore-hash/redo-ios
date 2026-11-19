import SwiftUI

@main
struct RedoCommerceApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.light)
                .tint(.black)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        if store.signedIn {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            InboxView()
                .tabItem { Label("Inbox", systemImage: "text.bubble.fill") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
        .tint(.white)
        .onAppear {
            let a = UITabBarAppearance()
            a.configureWithOpaqueBackground()
            a.backgroundColor = .black
            for item in [a.stackedLayoutAppearance, a.inlineLayoutAppearance, a.compactInlineLayoutAppearance] {
                item.normal.iconColor = .gray
                item.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
                item.selected.iconColor = .white
                item.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
            }
            UITabBar.appearance().standardAppearance = a
            UITabBar.appearance().scrollEdgeAppearance = a
        }
    }
}
