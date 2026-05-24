//
//  EmailVerificationView.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 4/26/25.
//

import SwiftUI
import OSLog

struct EmailVerificationView: View {
    
    private let logger = MyLogger(category: "EmailVerificationView")
    
    let viewModel: ChatViewModel
    @Binding var showingErrorAlert: Bool
    @Binding var error: Error?
    
    var body: some View {
        VStack(spacing: 24) {
            Text("You have been sent a letter with a link to activate your account. After activation, click the \"Update\" button.")
            
            Button("Update") {
                reloadUser()
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            
            Button("Send Again") {
                sendEmailVerification()
            }
        }
        .padding(25)
        .background(Util.secondarySystemBackgroundColor)
        .clipShape(.rect(corners: 50))
        .padding()
    }
    
    private func sendEmailVerification() {
        Task {
            await viewModel.sendEmailVerification { error in
                logger.error("sendEmailVerification error: \(error)")
                
                self.error = error
                self.showingErrorAlert.toggle()
            }
        }
    }
    
    private func reloadUser() {
        Task {
            await viewModel.reloadUser { error in
                logger.error("reloadUser error: \(error)")
                
                self.error = error
                self.showingErrorAlert.toggle()
            }
        }
    }
}

#Preview {
    EmailVerificationView(
        viewModel: .init(),
        showingErrorAlert: .constant(false),
        error: .constant(nil)
    )
}
