//
//  ChatView.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 19.04.2025.
//

import SwiftUI
import OSLog

struct ChatView: View {
    
    private let logger = MyLogger(category: "ChatView")
    
    @Bindable var viewModel: ChatViewModel
    
    @AppStorage("isOldRusMonthNames")
    private var isOldRusMonthNames: Bool = false
    
    @State private var showingErrorAlert: Bool = false
    @State private var error: Error?
    
    var body: some View {
        VStack {
            if !viewModel.isUserSignedIn {
                ChatWelcomeView(
                    viewModel: viewModel,
                    showingErrorAlert: $showingErrorAlert,
                    error: $error
                )
            } else if viewModel.isCurrentUserGloballyBlocked {
                ContentUnavailableView {
                    Label("Chat Unavailable", systemImage: "exclamationmark.shield")
                } description: {
                    Text(viewModel.currentUserGlobalBlockReason ?? "You have been blocked by chat moderation.")
                }
            } /*else if !viewModel.isEmailVerified {
                EmailVerificationView(
                    viewModel: viewModel,
                    showingErrorAlert: $showingErrorAlert,
                    error: $error
                )
            }*/ else {
                ChatMessagesListView(
                    viewModel: viewModel,
                    isOldRusMonthNames: isOldRusMonthNames,
                    chatMessageForEdit: $viewModel.chatMessageForEdit,
                    chatMessageForReply: $viewModel.chatMessageForReply,
                    showingErrorAlert: $showingErrorAlert,
                    error: $error
                )
            }
            
            if viewModel.isUserSignedIn && !viewModel.isCurrentUserGloballyBlocked /*&& viewModel.isEmailVerified*/ {
                ChatInputMessageView(
                    viewModel: viewModel,
                    chatMessageForEdit: $viewModel.chatMessageForEdit,
                    chatMessageForReply: $viewModel.chatMessageForReply,
                    showingErrorAlert: $showingErrorAlert,
                    error: $error
                )
            }
        }
        .navigationTitle("Chat")
        .navigationSubtitle(makeSubtitleString())
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .task {
            await viewModel.reloadUserIfNeeded { error in
                logger.error("reloadUser error: \(error)")
                
                self.error = error
                self.showingErrorAlert.toggle()
            }
        }
        .alert("Error", isPresented: $showingErrorAlert, presenting: error) { error in
            Button("OK", role: .cancel) {
                self.showingErrorAlert = false
                self.error = nil
            }
        } message: { error in
            Text("\(error.localizedDescription)")
        }
    }
    
    private func makeSubtitleString() -> LocalizedStringKey {
        if viewModel.isUserSignedIn {
            LocalizedStringKey("^[\(viewModel.chatMessages.count) messages](inflect: true)")
        } else {
            LocalizedStringKey("Log in to see the number of messages")
        }
    }
}

#Preview {
    ChatView(viewModel: ChatViewModel())
}
