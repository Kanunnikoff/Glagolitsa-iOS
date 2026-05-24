//
//  ChatMessagesListView.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 4/26/25.
//

import SwiftUI

struct ChatMessagesListView: View {

    private static let bottomScrollTargetId = "ChatMessagesListView.bottomScrollTarget"
    private static let macOSHorizontalContentPadding: CGFloat = 16
    private static let macOSBottomScrollRetryDelays: [TimeInterval] = [0, 0.1, 0.35]

    @Bindable var viewModel: ChatViewModel
    let isOldRusMonthNames: Bool
    @Binding var chatMessageForEdit: ChatMessage?
    @Binding var chatMessageForReply: ChatMessage?
    @Binding var showingErrorAlert: Bool
    @Binding var error: Error?

    @AppStorage("isConfirmDeletion")
    private var isConfirmDeletion: Bool = true

    private let menuButtonTip = MenuButtonTip()
    private let reauthenticator = Reauthenticator()

    @State private var showingDeleteChatMessageAlert: Bool = false
    @State private var chatMessageForDelete: ChatMessage?

    @State private var showingChangeUserNameAlert: Bool = false
    @State private var userName: String = ""

    @State private var showingSignOutAlert: Bool = false
    @State private var showingDeleteAccountAlert: Bool = false
    @State private var showingBlockedUsersList: Bool = false
    @State private var showingReportsList: Bool = false

    private var userId: String? {
        get {
            viewModel.user?.uid
        }
    }

    private var isUserModerator: Bool {
        get {
            viewModel.isCurrentUserModerator
        }
    }

    private var isUserAdmin: Bool {
        get {
            viewModel.isCurrentUserAdmin
        }
    }

    private var blockedUserIds: Set<String> {
        viewModel.blockedUserIds
    }

    private var visibleChatMessages: [ChatMessage] {
        get {
            viewModel.chatMessages.filter { !blockedUserIds.contains($0.userId) }
        }
    }

    private var visibleChatMessageIds: [String] {
        visibleChatMessages.map(\.id)
    }

    private var blockedUsers: [ChatBlockedUser] {
        get {
            blockedUserIds
                .sorted()
                .map { blockedUserId in
                    let blockedUserName = viewModel.chatMessages
                        .last(where: { $0.userId == blockedUserId })?
                        .userName ?? blockedUserId

                    return ChatBlockedUser(id: blockedUserId, userName: blockedUserName)
                }
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            chatMessagesScrollView(proxy)
            .scrollDismissesKeyboard(.immediately)
            .overlay {
                if viewModel.chatMessages.isEmpty {
                    ContentUnavailableView {
                        Label("Conversation messages will be here", systemImage: "ellipsis.message") // 􁒘
                    } description: {
                        Text("To add your message, use the input field below.")
                    }
                }
            }
            .onAppear {
                scrollToLastVisibleMessage(proxy, animated: false)
            }
            // Прокручиваем в самый низ при получении каждого нового сообщения
            .onChange(of: visibleChatMessageIds) { _, _ in
                scrollToLastVisibleMessage(proxy, animated: true)
            }
        }
#if !os(watchOS)
        .toolbar {
            ToolbarItem {
                ChatToolbarMenuView(
                    userName: userName,
                    hasBlockedUsers: !blockedUserIds.isEmpty,
                    canViewReports: (isUserAdmin || isUserModerator) && !viewModel.chatReports.isEmpty,
                    showingBlockedUsersList: $showingBlockedUsersList,
                    showingReportsList: $showingReportsList,
                    showingChangeUserNameAlert: $showingChangeUserNameAlert,
                    showingSignOutAlert: $showingSignOutAlert,
                    showingDeleteAccountAlert: $showingDeleteAccountAlert
                )
            }
        }
#endif
        .sheet(isPresented: $showingBlockedUsersList) {
            ChatBlockedUsersView(
                blockedUsers: blockedUsers,
                onUnblock: { blockedUserId in
                    unblockUser(userId: blockedUserId)
                }
            )
        }
        .sheet(isPresented: $showingReportsList) {
            ChatReportsView(
                reports: viewModel.chatReports,
                onDeleteMessage: { messageId in
                    deleteChatMessage(messageId: messageId)
                },
                onGlobalBlockUser: { report in
                    globalBlockUser(report)
                },
                onUnblockGlobalUser: { report in
                    unblockGlobalUser(report)
                }
            )
        }
        .task {
            userName = viewModel.user?.displayName ?? ""
        }
        .alert(
            "Attention",
            isPresented: $showingDeleteChatMessageAlert,
            presenting: chatMessageForDelete
        ) { chatMessage in
            Button("Cancel", role: .cancel) {
                showingDeleteChatMessageAlert = false
            }

            Button("Delete", role: .destructive) {
                deleteChatMessage(messageId: chatMessage.id)
            }
        } message: { details in
            Text("Are you sure you want to delete the chat message?")
        }
        .alert("Name Change", isPresented: $showingChangeUserNameAlert) {
            TextField("User Name", text: $userName)

            Button("Cancel", role: .cancel) {
                showingChangeUserNameAlert = false
            }

            Button("Change", role: .destructive) {
                changeUserName()
            }
            .disabled(userName.isEmpty)
        } message: {
            Text("Enter a new user name")
        }
        .alert(
            "Attention",
            isPresented: $showingSignOutAlert
        ) {
            Button("Cancel", role: .cancel) {
                showingSignOutAlert = false
            }

            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert(
            "Attention",
            isPresented: $showingDeleteAccountAlert
        ) {
            Button("Cancel", role: .cancel) {
                showingDeleteAccountAlert = false
            }

            Button("Delete", role: .destructive) {
                reauthenticateAndDeleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete your account? All your messages will also be deleted. The operation is irreversible.")
        }
    }

    @ViewBuilder
    private func chatMessagesScrollView(_ proxy: ScrollViewProxy) -> some View {
#if os(macOS)
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(visibleChatMessages, id: \.id) { chatMessage in
                    chatMessageRow(chatMessage, proxy)
                        .padding(.horizontal, Self.macOSHorizontalContentPadding)
                }

                Color.clear
                    .frame(height: 1)
                    .id(Self.bottomScrollTargetId)
            }
        }
#else
        List {
            ForEach(visibleChatMessages, id: \.id) { chatMessage in
                chatMessageRow(chatMessage, proxy)
            }
        }
        .listStyle(.plain)
#endif
    }

    private func scrollToLastVisibleMessage(_ proxy: ScrollViewProxy, animated: Bool) {
        guard let lastMessageId = visibleChatMessages.last?.id else {
            return
        }

#if os(macOS)
        scrollToMessage(Self.bottomScrollTargetId, proxy, animated: animated)
#else
        scrollToMessage(lastMessageId, proxy, animated: animated)
#endif
    }

    private func scrollToMessage(_ messageId: String, _ proxy: ScrollViewProxy, animated: Bool) {
#if os(macOS)
        // SwiftUI на macOS может завершить раскладку ScrollView на несколько проходов позже,
        // особенно если в сообщениях есть предпросмотр ссылок. Повторяем ту же целевую
        // прокрутку после ближайших проходов главного цикла, чтобы нижняя метка осталась
        // прижатой к низу уже после окончательного измерения строк.
        for (index, delay) in Self.macOSBottomScrollRetryDelays.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                performScrollToMessage(messageId, proxy, animated: animated && index == 0)
            }
        }
#else
        performScrollToMessage(messageId, proxy, animated: animated)
#endif
    }

    private func performScrollToMessage(_ messageId: String, _ proxy: ScrollViewProxy, animated: Bool) {
        if animated {
            withAnimation {
                proxy.scrollTo(messageId, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(messageId, anchor: .bottom)
        }
    }

    // Пришлось вынести в отдельную функцию, ибо иначе компилятор не может проверить код... facepalm...
    @ViewBuilder
    private func chatMessageRow(_ chatMessage: ChatMessage, _ proxy: ScrollViewProxy) -> some View {
        ChatMessageView(
            viewModel: viewModel,
            chatMessage: chatMessage,
            visibleChatMessages: visibleChatMessages,
            userId: viewModel.user?.uid,
            userName: viewModel.user?.displayName ?? "",
            isOldRusMonthNames: isOldRusMonthNames,
            scrollViewProxy: proxy,
            showingDeleteChatMessageAlert: $showingDeleteChatMessageAlert,
            chatMessageForDelete: $chatMessageForDelete,
            chatMessageForEdit: $chatMessageForEdit,
            chatMessageForReply: $chatMessageForReply
        )
#if os(macOS)
        .contentShape(Rectangle())
        .contextMenu {
            chatMessageContextMenu(chatMessage)
        }
#endif
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 14, trailing: 16))
#if !os(macOS)
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            leadingSwipeActions(chatMessage)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            trailingSwipeActions(chatMessage)
        }
#endif
    }

    @ViewBuilder
    private func trailingSwipeActions(_ chatMessage: ChatMessage) -> some View {
        if canDeleteMessage(chatMessage) {
            Button(role: .destructive) {
                requestDeleteChatMessage(chatMessage)
            } label: {
                Image(systemName: "trash") // 􀈑
            }
        }

        if !isUserChatMessage(chatMessage) {
            Button {
                requestReportChatMessage(chatMessage)
            } label: {
                Image(systemName: "exclamationmark.bubble") // 􀌬
            }
            .tint(.orange)

            if !blockedUserIds.contains(chatMessage.userId) {
                Button(role: .destructive) {
                    requestBlockUser(chatMessage.userId)
                } label: {
                    Image(systemName: "hand.raised") // 􀉻
                }
            }

            roleManagementSwipeActions(chatMessage)
        }
    }

    @ViewBuilder
    private func roleManagementSwipeActions(_ chatMessage: ChatMessage) -> some View {
        if canManageUserRole(chatMessage) {
            let scope = messageAuthorScope(chatMessage)

            if scope == .user {
                Button {
                    requestSetUserScope(chatMessage.userId, .moderator)
                } label: {
                    Image(systemName: "person.badge.plus") // 􀜕
                }
                .tint(.blue)
            } else if scope == .moderator {
                Button {
                    requestSetUserScope(chatMessage.userId, .user)
                } label: {
                    Image(systemName: "person.badge.minus") // 􀜗
                }
                .tint(.brown)
            }
        }
    }

    // Пришлось вынести в отдельную функцию, ибо иначе компилятор не может проверить код... facepalm...
    @ViewBuilder
    private func leadingSwipeActions(_ chatMessage: ChatMessage) -> some View {
        Button {
            requestReplyToChatMessage(chatMessage)
        } label: {
            Image(systemName: "arrowshape.turn.up.left") // 􀉌
        }
        .tint(.accentColor)

        Button {
            requestCopyChatMessage(chatMessage)
        } label: {
            Image(systemName: "square.on.square") // 􀐅
        }
        .tint(.accentColor)

        if isUserChatMessage(chatMessage) {
            Button {
                requestEditChatMessage(chatMessage)
            } label: {
                Image(systemName: "pencil") // 􀈊
            }
            .tint(.accentColor)
        }
    }

#if os(macOS)
    @ViewBuilder
    private func chatMessageContextMenu(_ chatMessage: ChatMessage) -> some View {
        Button {
            requestReplyToChatMessage(chatMessage)
        } label: {
            Label("Reply", systemImage: "arrowshape.turn.up.left")
        }

        Button {
            requestCopyChatMessage(chatMessage)
        } label: {
            Label("Copy", systemImage: "square.on.square")
        }

        if isUserChatMessage(chatMessage) {
            Button {
                requestEditChatMessage(chatMessage)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
        }

        if canDeleteMessage(chatMessage) {
            Divider()

            Button(role: .destructive) {
                requestDeleteChatMessage(chatMessage)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }

        if !isUserChatMessage(chatMessage) {
            Divider()

            Button {
                requestReportChatMessage(chatMessage)
            } label: {
                Label("Report", systemImage: "exclamationmark.bubble")
            }

            if !blockedUserIds.contains(chatMessage.userId) {
                Button(role: .destructive) {
                    requestBlockUser(chatMessage.userId)
                } label: {
                    Label("Block User", systemImage: "hand.raised")
                }
            }

            roleManagementContextMenu(chatMessage)
        }
    }

    @ViewBuilder
    private func roleManagementContextMenu(_ chatMessage: ChatMessage) -> some View {
        if canManageUserRole(chatMessage) {
            let scope = messageAuthorScope(chatMessage)

            if scope == .user {
                Divider()

                Button {
                    requestSetUserScope(chatMessage.userId, .moderator)
                } label: {
                    Label("Make Moderator", systemImage: "person.badge.plus")
                }
            } else if scope == .moderator {
                Divider()

                Button {
                    requestSetUserScope(chatMessage.userId, .user)
                } label: {
                    Label("Remove Moderator", systemImage: "person.badge.minus")
                }
            }
        }
    }
#endif

    private func requestReplyToChatMessage(_ chatMessage: ChatMessage) {
        withAnimation {
            chatMessageForReply = chatMessage
        }
    }

    private func requestCopyChatMessage(_ chatMessage: ChatMessage) {
        Util.copyToClipboard(text: chatMessage.text)
    }

    private func requestEditChatMessage(_ chatMessage: ChatMessage) {
        withAnimation {
            chatMessageForEdit = chatMessage
        }
    }

    private func requestDeleteChatMessage(_ chatMessage: ChatMessage) {
        if isConfirmDeletion {
            chatMessageForDelete = chatMessage
            showingDeleteChatMessageAlert.toggle()
        } else {
            deleteChatMessage(messageId: chatMessage.id)
        }
    }

    private func requestReportChatMessage(_ chatMessage: ChatMessage) {
        reportChatMessage(chatMessage)
    }

    private func requestBlockUser(_ userId: String) {
        blockUser(userId: userId)
    }

    private func requestSetUserScope(_ userId: String, _ scope: ChatUserScope) {
        setUserScope(userId, scope)
    }

    private func deleteChatMessage(messageId: String) {
        Task {
            do {
                try await viewModel.deleteChatMessage(messageId: messageId)
            } catch {
                self.error = error
                showingErrorAlert.toggle()
            }
        }
    }

    private func reportChatMessage(_ chatMessage: ChatMessage) {
        Task {
            do {
                try await viewModel.reportChatMessage(
                    messageId: chatMessage.id,
                    reportedUserId: chatMessage.userId,
                    reportedUserName: chatMessage.userName,
                    messageText: chatMessage.text
                )
            } catch {
                self.error = error
                showingErrorAlert.toggle()
            }
        }
    }

    private func globalBlockUser(_ report: ChatMessageReport) {
        Task {
            do {
                try await viewModel.globallyBlockUser(
                    userId: report.reportedUserId,
                    reason: "Blocked by admin. Reason: \(report.reason)"
                )
            } catch {
                self.error = error
                showingErrorAlert.toggle()
            }
        }
    }

    private func unblockGlobalUser(_ report: ChatMessageReport) {
        Task {
            do {
                try await viewModel.unblockUserGlobally(userId: report.reportedUserId)
            } catch {
                self.error = error
                showingErrorAlert.toggle()
            }
        }
    }

    private func blockUser(userId: String) {
        Task {
            do {
                try await viewModel.blockUser(userId: userId)
            } catch {
                self.error = error
                showingErrorAlert.toggle()
            }
        }
    }

    private func unblockUser(userId: String) {
        Task {
            do {
                try await viewModel.unblockUser(userId: userId)
            } catch {
                self.error = error
                showingErrorAlert.toggle()
            }
        }
    }

    private func setUserScope(_ userId: String, _ scope: ChatUserScope) {
        Task {
            do {
                try await viewModel.updateUserScope(userId: userId, scope: scope)
            } catch {
                self.error = error
                showingErrorAlert.toggle()
            }
        }
    }

    private func changeUserName() {
        Task {
            await viewModel.changeUserName(name: userName) { error in
                self.error = error
                showingErrorAlert.toggle()
            }
        }
    }

    private func signOut() {
        viewModel.signOut { error in
            self.error = error
            showingErrorAlert.toggle()
        }
    }

    private func reauthenticateAndDeleteAccount() {
        reauthenticator.reauthenticate { appleIDToken, _, rawNonce, error in
            if let error = error {
                self.error = error
                showingErrorAlert.toggle()
                return
            }

            if let appleIDToken = appleIDToken, let rawNonce = rawNonce {
                Task {
                    await viewModel.reauthenticate(appleIdToken: appleIDToken, rawNonce: rawNonce) { error in
                        if let error = error {
                            self.error = error
                            showingErrorAlert.toggle()
                            return
                        }

                        Task {
                            await viewModel.deleteAccount { error in
                                self.error = error
                                showingErrorAlert.toggle()
                            }
                        }
                    }
                }
            }
        }
    }

    private func isUserChatMessage(_ chatMessage: ChatMessage) -> Bool {
        chatMessage.userId == userId
    }

    private func messageAuthorScope(_ chatMessage: ChatMessage) -> ChatUserScope {
        viewModel.userScope(for: chatMessage.userId)
    }

    private func canDeleteMessage(_ chatMessage: ChatMessage) -> Bool {
        if isUserChatMessage(chatMessage) {
            return true
        }

        let authorScope = messageAuthorScope(chatMessage)

        if isUserAdmin {
            return true
        }

        if isUserModerator {
            return authorScope == .user
        }

        return false
    }

    private func canManageUserRole(_ chatMessage: ChatMessage) -> Bool {
        guard isUserAdmin else { return false }
        guard !isUserChatMessage(chatMessage) else { return false }
        return messageAuthorScope(chatMessage) != .admin
    }
}

#Preview {
    ChatMessagesListView(
        viewModel: ChatViewModel(),
        isOldRusMonthNames: false,
        chatMessageForEdit: .constant(.stub),
        chatMessageForReply: .constant(.stub),
        showingErrorAlert: .constant(false),
        error: .constant(nil)
    )
}
