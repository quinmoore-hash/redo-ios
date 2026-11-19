import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: AppStore
    @State private var push = true
    @State private var sound = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 14) {
                        Avatar(initials: "HB", size: 56)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.agent).font(.system(size: 20, weight: .semibold))
                            Text(store.agentEmail).foregroundStyle(Color.redoMuted)
                        }
                    }
                    card {
                        row("Store", "\(store.storeHandle).myshopify.com")
                        Divider()
                        row("Team", "Customer Experience")
                        Divider()
                        row("Open tickets", "\(store.tickets.filter { $0.status == .open && $0.assignee == store.agent }.count)")
                    }
                    card {
                        Toggle("Push notifications", isOn: $push)
                        Divider()
                        Toggle("Notification sound", isOn: $sound)
                    }
                    .tint(Color.redoPurple)
                    Button { store.signedIn = false } label: { Text("Sign out").frame(maxWidth: .infinity) }
                        .buttonStyle(OutlineButton())
                    HStack { Spacer(); RedoLogo(size: 18).opacity(0.5); Spacer() }
                    Text("Version 1.0").font(.footnote).foregroundStyle(Color.redoMuted).frame(maxWidth: .infinity)
                }
                .padding(24)
            }
            .navigationTitle("Profile")
        }
    }

    func card<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        VStack(spacing: 12) { content() }
            .padding(16)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.redoBorder))
    }

    func row(_ label: String, _ value: String) -> some View {
        HStack { Text(label); Spacer(); Text(value).foregroundStyle(Color.redoMuted) }
    }
}
