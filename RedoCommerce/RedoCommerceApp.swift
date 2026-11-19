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
    @EnvironmentObject var store: AppStore
    @State private var tab = 0

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                InboxView().opacity(tab == 0 ? 1 : 0)
                if tab == 1 { ProfileView() }
            }
            if !store.inTicket {
                HStack {
                    tabButton(0, "Inbox", "text.bubble.fill")
                    tabButton(1, "Profile", "person")
                }
                .padding(.top, 10)
                .background(Color.black.ignoresSafeArea(edges: .bottom))
            }
        }
    }

    func tabButton(_ index: Int, _ title: String, _ icon: String) -> some View {
        Button { tab = index } label: {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 20))
                Text(title).font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(tab == index ? Color.white : Color.gray)
            .frame(maxWidth: .infinity)
        }
    }
}
