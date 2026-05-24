//
//  AboutView.swift
//  Yat
//
//  Created by Дмитрiй Канунниковъ on 03.07.2023.
//

import SwiftUI

struct AboutView: View {
    
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    @Environment(\.dismiss) private var dismiss
    @Environment(\.consumableIDs) private var consumableIDs
    
    @State private var showingTipsPurchasedIndicator: Bool = false
    @State private var showingTipsPurchaseErrorAlert: Bool = false
    
    var body: some View {
        List {
            VStack {
                HStack {
#if os(macOS)
                    if let appIconName = Util.getAppIconName(), let image = NSImage(named: appIconName) {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(width: 65)
                    }
#else
                    if let appIconName = Util.getAppIconName(), let image = UIImage(named: appIconName) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(width: 65)
                    }
#endif
                    
                    VStack(alignment: .leading) {
                        Text(Util.getAppDisplayName())
                            .font(.headline)
                        
                        Text("Version \(Util.getAppVersion()), build \(Util.getAppBuild())")
                            .font(.caption)
                        
                        Text("© 2026 Dmitry Kanunnikoff")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 5)
                }
                .frame(maxWidth: .infinity)
            }
            
            Section {
                Link("Rate", destination: Config.APPSTORE_APP_REVIEW_URL)
                
#if !os(tvOS)
                ShareLink(item: Config.APPSTORE_APP_URL) {
                    Text("Share")
                }
#endif
                
                Link("Other Apps", destination: Config.APPSTORE_DEVELOPER_URL)
            } header: {
                Text("App Store")
            } footer: {
                Text("Your opinion is very important to me. Please feel free to rate and write a review.")
            }
            
            Section {
                Link("Write a letter", destination: Config.EMAIL_URL)
            } header: {
                Text("Feedback")
            } footer: {
                Text("In case of questions or suggestions, I am at your service. Let's be in touch!")
            }
            
#if !os(watchOS)
            Section {
                Link("Read", destination: Config.PRIVACY_POLICY_URL)
            } header: {
                Text("Privacy Policy")
            } footer: {
                Text("Detailed information about how the application uses your data.")
            }
            
            Section {
                Button("Tips") {
                    purchaseTips()
                }
            } header: {
                Text("Support")
            } footer: {
                Text("If you like the result of my work, then you can, if you wish, support me in one of the above ways.")
            }
#endif
        }
        .navigationTitle("About")
        .toolbar {
            if prefersTabNavigation {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark") // 􀆄
                    }
                }
            }
        }
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .tips(
            showingTipsPurchasedIndicator: $showingTipsPurchasedIndicator,
            showingTipsPurchaseErrorAlert: $showingTipsPurchaseErrorAlert
        )
    }
    
    private func purchaseTips() {
        Task {
            await PurchaseManager.shared.purchaseConsumable(
                productId: consumableIDs.tips,
                onSuccess: { transactionId in
                    withAnimation(.spring(duration: 0.5, bounce: 0.5)) {
                        showingTipsPurchasedIndicator = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                        withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                            showingTipsPurchasedIndicator = false
                        }
                    }
                },
                onFailure: { transactionId, error in
                    showingTipsPurchaseErrorAlert.toggle()
                }
            )
        }
    }
}

#Preview {
    AboutView()
}
