import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: AppStore
    @State private var handle = "court-and-field"
    @State private var loading = false

    var body: some View {
        VStack(spacing: 0) {
            RedoLogo(size: 38).padding(.top, 70)

            VStack(alignment: .leading, spacing: 10) {
                Text("Shopify store address").font(.system(size: 15))
                HStack(spacing: 4) {
                    TextField("Enter store URL", text: $handle)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .multilineTextAlignment(.trailing)
                    Text(".myshopify.com")
                }
                .font(.system(size: 17))
                .padding(.horizontal, 12)
                .frame(height: 44)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.redoBorder))

                Button {
                    loading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        store.storeHandle = handle
                        loading = false
                        withAnimation { store.signedIn = true }
                    }
                } label: {
                    Group {
                        if loading { ProgressView().tint(.white) } else { Text("Sign in with Shopify") }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SolidButton(enabled: !handle.isEmpty))
                .disabled(handle.isEmpty || loading)
                .padding(.top, 20)
            }
            .padding(.horizontal, 40)
            .padding(.top, 80)

            Spacer()

            HStack(spacing: 6) {
                Text("Or sign in with")
                Button("Email") { store.signedIn = true }.foregroundStyle(Color.blue)
            }
            .font(.system(size: 15))
            .padding(.bottom, 24)
        }
        .background(Color.white)
    }
}
