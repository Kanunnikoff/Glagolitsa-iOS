//
//  ChatViewModel.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 4/26/25.
//

import OSLog
import Foundation
import FirebaseAuth
import FirebaseFirestore

private enum ChatModerationError: LocalizedError {
    case emptyMessage
    case globallyBlocked(String)
    
    var errorDescription: String? {
        switch self {
            case .emptyMessage:
                return "Message is empty after moderation."
            case .globallyBlocked(let reason):
                return reason
        }
    }
}

private enum ChatPermissionsError: LocalizedError {
    case insufficientPermissions
    case unsupportedScopeChange
    
    var errorDescription: String? {
        switch self {
            case .insufficientPermissions:
                return "Insufficient permissions."
                
            case .unsupportedScopeChange:
                return "Unsupported scope change."
        }
    }
}

@MainActor
@Observable
final class ChatViewModel {
    
    private let logger = MyLogger(category: "ChatViewModel")
    
    private let authDataSource: AuthDataSource
    private let authRepository: AuthRepository
    
    private let chatMessagesDataSource: ChatMessagesDataSource
    private let chatMessagesRepository: ChatMessagesRepository
    
    private let chatUserScopesDataSource: ChatUserScopesDataSource
    private let chatUserScopesRepository: ChatUserScopesRepository
    
    private let chatReportsDataSource: ChatReportsDataSource
    private let chatReportsRepository: ChatReportsRepository
    
    private let chatBlockedUsersDataSource: ChatBlockedUsersDataSource
    private let chatBlockedUsersRepository: ChatBlockedUsersRepository
    
    private var authStateCgangesTask: Task<Void, Never>?
    private var currentUserMetadataTask: Task<Void, Never>?
    private var chatMessagesTask: Task<Void, Never>?
    private var chatReportsTask: Task<Void, Never>?
    private var blockedUsersTask: Task<Void, Never>?
    private var isInitialUserReloadCompleted: Bool = false
    private let prohibitedWordStems = [
        "fuck", "shit", "bitch",
        "бля", "бляд", "ху", "пизд", "еб"
    ]
    
    var user: User? = nil
    var currentUserScope: ChatUserScope = .user
    var userScopesById: [String: ChatUserScope] = [:]
    var isCurrentUserGloballyBlocked: Bool = false
    var currentUserGlobalBlockReason: String? = nil
    
    var isUserSignedIn: Bool {
        get {
            user != nil
        }
    }
    
    var isEmailVerified: Bool {
        get {
            user?.isEmailVerified ?? false
        }
    }
    
    var isSendingChatMessage: Bool = false
    var chatMessageDraft: String = ""
    var chatMessageForEdit: ChatMessage?
    var chatMessageForReply: ChatMessage?
    var chatMessages: [ChatMessage] = []
    var chatReports: [ChatMessageReport] = []
    var blockedUserIds: Set<String> = []
    
    var isCurrentUserAdmin: Bool {
        get {
            currentUserScope == .admin
        }
    }
    
    var isCurrentUserModerator: Bool {
        get {
            currentUserScope == .moderator
        }
    }
    
    init() {
        authDataSource = AuthDataSourceImpl()
        authRepository = AuthRepositoryImpl(authDataSource: authDataSource)
        
        chatMessagesDataSource = ChatMessagesDataSourceImpl()
        chatMessagesRepository = ChatMessagesRepositoryImpl(chatMessagesDataSource: chatMessagesDataSource)
        
        chatUserScopesDataSource = ChatUserScopesDataSourceImpl()
        chatUserScopesRepository = ChatUserScopesRepositoryImpl(chatUserScopesDataSource: chatUserScopesDataSource)
        
        chatReportsDataSource = ChatReportsDataSourceImpl()
        chatReportsRepository = ChatReportsRepositoryImpl(chatReportsDataSource: chatReportsDataSource)
        
        chatBlockedUsersDataSource = ChatBlockedUsersDataSourceImpl()
        chatBlockedUsersRepository = ChatBlockedUsersRepositoryImpl(chatBlockedUsersDataSource: chatBlockedUsersDataSource)
        
        startAllListening()
    }
    
    private func startAllListening() {
        logger.debug("startAllListening()")
        
        startListeningAuthStateChanges()
    }
    
    private func startListeningAuthStateChanges() {
        stopListeningAuthStateChanges()
        
        authStateCgangesTask = Task {
            for await user in authRepository.subscribeToAuthStateChanges() {
                if Task.isCancelled {
                    break
                }
                
                logger.debug("subscribeToAuthStateChanges() user: \(String(describing: user)), isEmailVerified: \(self.isEmailVerified)")
                
                self.user = user
                
                if isUserSignedIn /*&& isEmailVerified*/ {
                    if let userId = user?.uid {
                        startListeningBlockedUsers(userId: userId)
                        startListeningCurrentUserMetadata(userId: userId)
                        await syncCurrentUserScope(userId: userId)
                    }
                    
                    if !isCurrentUserGloballyBlocked {
                        startListeningChatMessages()
                    }
                } else {
                    self.currentUserScope = .user
                    self.isCurrentUserGloballyBlocked = false
                    self.currentUserGlobalBlockReason = nil
                    self.userScopesById = [:]
                    self.chatReports = []
                    self.blockedUserIds = []
                    self.clearChatComposer()
                    
                    stopListeningCurrentUserMetadata()
                    stopListeningChatMessages()
                    stopListeningChatReports()
                    stopListeningBlockedUsers()
                }
            }
        }
    }
    
    private func stopListeningAuthStateChanges() {
        authStateCgangesTask?.cancel()
        authStateCgangesTask = nil
    }
    
    private func startListeningChatMessages() {
        stopListeningChatMessages()
        
        chatMessagesTask = Task {
            do {
                for try await chatMessages in chatMessagesRepository.getAll() {
                    if Task.isCancelled {
                        break
                    }
                    
                    self.chatMessages = chatMessages
                    await refreshScopes(for: chatMessages)
                }
            } catch {
                logger.error("chatMessagesRepository.getAll() error: \(error)")
            }
        }
    }
    
    private func startListeningCurrentUserMetadata(userId: String) {
        stopListeningCurrentUserMetadata()
        
        currentUserMetadataTask = Task {
            do {
                for try await metadata in chatUserScopesRepository.subscribeToMetadata(userId: userId) {
                    if Task.isCancelled {
                        break
                    }
                    
                    await MainActor.run {
                        self.currentUserScope = metadata.scope
                        self.userScopesById[userId] = metadata.scope
                        self.isCurrentUserGloballyBlocked = metadata.isGloballyBlocked
                        self.currentUserGlobalBlockReason = metadata.globalBlockReason
                    }
                    
                    if metadata.isGloballyBlocked {
                        stopListeningChatMessages()
                        stopListeningChatReports()
                    } else {
                        if isUserSignedIn {
                            startListeningChatMessages()
                        }
                        if metadata.scope == .admin {
                            startListeningChatReports()
                        } else {
                            stopListeningChatReports()
                        }
                    }
                }
            } catch {
                logger.error("startListeningCurrentUserMetadata() error: \(error.localizedDescription)")
            }
        }
    }
    
    private func stopListeningCurrentUserMetadata() {
        currentUserMetadataTask?.cancel()
        currentUserMetadataTask = nil
    }
    
    private func startListeningChatReports() {
        guard isCurrentUserAdmin || isCurrentUserModerator else {
            stopListeningChatReports()
            return
        }
        
        stopListeningChatReports()
        
        chatReportsTask = Task {
            do {
                for try await reports in chatReportsRepository.getAll() {
                    if Task.isCancelled {
                        break
                    }
                    
                    self.chatReports = reports
                }
            } catch {
                logger.error("chatReportsRepository.getAll() error: \(error.localizedDescription)")
            }
        }
    }
    
    private func stopListeningChatReports() {
        chatReportsTask?.cancel()
        chatReportsTask = nil
        chatReports = []
    }
    
    private func startListeningBlockedUsers(userId: String) {
        stopListeningBlockedUsers()
        
        blockedUsersTask = Task {
            do {
                for try await blockedUserIds in chatBlockedUsersRepository.subscribeBlockedUserIds(userId: userId) {
                    if Task.isCancelled {
                        break
                    }
                    
                    self.blockedUserIds = blockedUserIds
                }
            } catch {
                logger.error("chatBlockedUsersRepository.subscribeBlockedUserIds() error: \(error.localizedDescription)")
            }
        }
    }
    
    private func stopListeningBlockedUsers() {
        blockedUsersTask?.cancel()
        blockedUsersTask = nil
    }
    
    private func stopListeningChatMessages() {
        chatMessagesTask?.cancel()
        chatMessagesTask = nil
    }
    
    private func stopAllListening() {
        logger.debug("stopAllListening()")
        
        stopListeningAuthStateChanges()
        stopListeningCurrentUserMetadata()
        stopListeningChatMessages()
        stopListeningChatReports()
        stopListeningBlockedUsers()
    }
    
    func signUp(
        email: String,
        name: String,
        password: String,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    ) async {
        authRepository.signUp(
            email: email,
            password: password,
            completion: { authDataResult, error in
                self.user = authDataResult?.user
                
                completion(authDataResult, error)
            }
        )
        
        do {
            try await authRepository.changeUserName(name: name)
            try await authRepository.sendEmailVerification()
        } catch {
            logger.error("signUp() error: \(error.localizedDescription)")
            
            completion(nil, error)
        }
    }
    
    func signIn(
        email: String,
        password: String,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    ) async {
        authRepository.signIn(
            email: email,
            password: password,
            completion: { authDataResult, error in
                self.user = authDataResult?.user
                
                completion(authDataResult, error)
            }
        )
    }
    
    func signIn(
        withIDToken idToken: String,
        rawNonce: String?,
        fullName: PersonNameComponents?,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    ) async {
        logger.debug("signIn(): idToken=\(idToken), rawNonce=\(String(describing: rawNonce)), givenName=\(String(describing: fullName?.givenName))")
        
        KeychainManager.addSecret(
            secret: idToken,
            byName: Config.KEYCHAIN_ACCOUNT_IDENTITY_TOKEN
        )
        
        authRepository.signIn(
            withIDToken: idToken,
            rawNonce: rawNonce,
            fullName: fullName,
            completion: { authDataResult, error in
                self.user = authDataResult?.user
                
                self.logger.debug("signIn(): userName=\(String(describing: self.user?.displayName)), error=\(String(describing: error?.localizedDescription ?? "nil"))")
                
                completion(authDataResult, error)
            }
        )
    }
    
    func verifyBeforeUpdateEmail(
        email: String,
        completion: @escaping (Error) -> Void
    ) async {
        do {
            try await authRepository.verifyBeforeUpdateEmail(email: email)
        } catch {
            completion(error)
        }
    }
    
    func sendEmailVerification(completion: @escaping (Error) -> Void) async {
        do {
            try await authRepository.sendEmailVerification()
        } catch {
            completion(error)
        }
    }
    
    func updatePassword(
        password: String,
        completion: @escaping (Error) -> Void
    ) async {
        do {
            try await authRepository.updatePassword(password: password)
        } catch {
            completion(error)
        }
    }
    
    func sendPasswordResetEmail(
        email: String,
        completion: @escaping (Error) -> Void
    ) async {
        do {
            try await authRepository.sendPasswordResetEmail(email: email)
        } catch {
            completion(error)
        }
    }
    
    func reauthenticate(
        email: String,
        password: String,
        completion: @escaping (Error) -> Void
    ) async {
        do {
            try await authRepository.reauthenticate(email: email, password: password)
        } catch {
            completion(error)
        }
    }
    
    func reauthenticate(
        appleIdToken: String,
        rawNonce: String,
        completion: @escaping (Error?) -> Void
    ) async {
        logger.debug("reauthenticate(): appleIdToken=\(appleIdToken), rawNonce: \(rawNonce)")
        
        do {
            let _ = try await authRepository.reauthenticate(
                appleIdToken: appleIdToken,
                rawNonce: rawNonce
            )
            
            completion(nil)
        } catch {
            logger.error("reauthenticate(): error=\(error)")
            completion(error)
        }
    }
    
    func changeUserName(
        name: String,
        completion: @escaping (Error) -> Void
    ) async {
        logger.debug("changeUserName(): name=\(name)")
        
        do {
            try await authRepository.changeUserName(name: name)
            
            await reloadUser { error in
                completion(error)
            }
        } catch {
            logger.error("changeUserName(): error=\(error.localizedDescription)")
            completion(error)
        }
    }
    
    private func getCurrentUser() -> User? {
        authRepository.getCurrentUser()
    }
    
    func reloadUser(completion: @escaping (Error) -> Void) async {
        logger.debug("reloadUser()")
        
        do {
            try await authRepository.reload()
            
            user = getCurrentUser()
        } catch {
            logger.error("reloadUser(): error=\(error.localizedDescription)")
            completion(error)
        }
    }

    func reloadUserIfNeeded(completion: @escaping (Error) -> Void) async {
        guard !isInitialUserReloadCompleted else {
            return
        }

        // Этот вызов нужен только при первом показе чата. После переноса модели выше
        // экран может появляться повторно, но заново перезагружать пользователя уже не нужно.
        isInitialUserReloadCompleted = true

        await reloadUser(completion: completion)
    }

    private func clearChatComposer() {
        chatMessageDraft = ""
        chatMessageForEdit = nil
        chatMessageForReply = nil
        isSendingChatMessage = false
    }

    func signOut(completion: @escaping (Error) -> Void) {
        logger.debug("signOut()")
        
        KeychainManager.deleteSecret(byName: Config.KEYCHAIN_ACCOUNT_IDENTITY_TOKEN)
        
        do {
            try authRepository.signOut()
        } catch {
            logger.error("signOut(): error=\(error.localizedDescription)")
            completion(error)
        }
    }
    
    func revokeTokenAndDeleteAccount(
        authCodeString: String,
        completion: @escaping (Error) -> Void
    ) async {
        logger.debug("revokeTokenAndDeleteAccount(): authCodeString=\(authCodeString)")
        
        do {
            try await deleteUserChatMessages()
            try await authRepository.revokeToken(authCodeString: authCodeString)
            try await authRepository.deleteAccount()
            
            // TODO: Проверить, нужно ли вручную перезагружать пользователя
            //            await reloadUser { error in
            //                completion(error)
            //            }
        } catch {
            logger.error("revokeTokenAndDeleteAccount(): error=\(error.localizedDescription)")
            completion(error)
        }
    }
    
    func deleteAccount(completion: @escaping (Error) -> Void) async {
        logger.debug("deleteAccount()")
        
        do {
            try await deleteUserChatMessages()
            try await authRepository.deleteAccount()
      
// TODO: Проверить, нужно ли вручную перезагружать пользователя
//            await reloadUser { error in
//                completion(error)
//            }
        } catch {
            logger.error("deleteAccount(): error=\(error.localizedDescription)")
            completion(error)
        }
    }
    
    func addChatMessage(
        text: String,
        quotedChatMessageId: String? = nil,
        completion: (DocumentReference?, Error?) -> Void
    ) async {
        guard let currentUser = getCurrentUser() else { return }
        
        guard !isCurrentUserGloballyBlocked else {
            completion(nil, ChatModerationError.globallyBlocked(currentUserBlockReason()))
            return
        }
        
        let moderatedText = moderateMessageText(text)
        
        isSendingChatMessage = true
        
        guard !moderatedText.isEmpty else {
            isSendingChatMessage = false
            completion(nil, ChatModerationError.emptyMessage)
            return
        }
        
        do {
            let reference = try await chatMessagesRepository.add(
                userId: currentUser.uid,
                userName: currentUser.displayName ?? "",
                text: moderatedText,
                quotedChatMessageId: quotedChatMessageId
            )
            
            completion(reference, nil)
        } catch {
            completion(nil, error)
        }
        
        isSendingChatMessage = false
    }
    
    func editChatMessage(
        messageId: String,
        newText: String,
        completion: @escaping (Error?) -> Void
    ) async {
        guard !isCurrentUserGloballyBlocked else {
            completion(ChatModerationError.globallyBlocked(currentUserBlockReason()))
            return
        }
        
        let moderatedText = moderateMessageText(newText)
        
        guard !moderatedText.isEmpty else {
            completion(ChatModerationError.emptyMessage)
            return
        }

        isSendingChatMessage = true

        do {
            try await chatMessagesRepository.edit(messageId: messageId, newText: moderatedText)
            completion(nil)
        } catch {
            completion(error)
        }

        isSendingChatMessage = false
    }
    
    func deleteChatMessage(messageId: String) async throws {
        try await chatMessagesRepository.delete(messageId: messageId)
        try await chatReportsRepository.resolveReportsForMessage(
            messageId: messageId,
            reason: "Resolved automatically: message deleted."
        )
    }
    
    func reportChatMessage(
        messageId: String,
        reportedUserId: String,
        reportedUserName: String,
        messageText: String,
        reason: String = "Inappropriate content"
    ) async throws {
        guard let currentUser = getCurrentUser() else { return }
        
        try await chatReportsRepository.add(
            messageId: messageId,
            messageText: messageText,
            reporterUserId: currentUser.uid,
            reporterUserName: currentUser.displayName ?? currentUser.uid,
            reportedUserId: reportedUserId,
            reportedUserName: reportedUserName,
            reason: reason
        )
    }
    
    func blockUser(userId: String) async throws {
        guard let currentUserId = getCurrentUser()?.uid else { return }
        guard currentUserId != userId else { return }
        try await chatBlockedUsersRepository.block(userId: currentUserId, blockedUserId: userId)
    }
    
    func unblockUser(userId: String) async throws {
        guard let currentUserId = getCurrentUser()?.uid else { return }
        try await chatBlockedUsersRepository.unblock(userId: currentUserId, blockedUserId: userId)
    }
    
    func deleteAllChatMessages(for userId: String) async throws {
        guard isCurrentUserAdmin || isCurrentUserModerator else {
            throw ChatPermissionsError.insufficientPermissions
        }
        
        let messages = try await chatMessagesRepository.getAllForUser(userId: userId)
        
        for message in messages {
            try await chatMessagesRepository.delete(messageId: message.id)
        }
    }
    
    func globallyBlockUser(userId: String, reason: String) async throws {
        guard isCurrentUserAdmin || isCurrentUserModerator else {
            throw ChatPermissionsError.insufficientPermissions
        }
        
        try await chatUserScopesRepository.setGlobalBlock(userId: userId, reason: reason)
        try await deleteAllChatMessages(for: userId)
        try await chatReportsRepository.resolveReportsForReportedUser(
            reportedUserId: userId,
            reason: "Resolved automatically: user globally blocked."
        )
    }
    
    func unblockUserGlobally(userId: String) async throws {
        guard isCurrentUserAdmin || isCurrentUserModerator else {
            throw ChatPermissionsError.insufficientPermissions
        }
        
        try await chatUserScopesRepository.clearGlobalBlock(userId: userId)
    }
    
    func userScope(for userId: String) -> ChatUserScope {
        return userScopesById[userId] ?? .user
    }
    
    func updateUserScope(userId: String, scope: ChatUserScope) async throws {
        guard isCurrentUserAdmin else {
            throw ChatPermissionsError.insufficientPermissions
        }
        
        guard scope == .user || scope == .moderator else {
            throw ChatPermissionsError.unsupportedScopeChange
        }
        
        try await chatUserScopesRepository.setScope(userId: userId, scope: scope)
        
        userScopesById[userId] = scope
    }
    
    private func deleteUserChatMessages() async throws {
        logger.debug("deleteUserChatMessages()")
        
        guard let currentUser = getCurrentUser() else { return }
        
        let userChatMessages = try await chatMessagesRepository.getAllForUser(userId: currentUser.uid)
        
        logger.debug("deleteUserChatMessages(): userChatMessages count=\(userChatMessages.count)")
        
        for chatMessage in userChatMessages {
            try await deleteChatMessage(messageId: chatMessage.id)
        }
    }
    
    private func moderateMessageText(_ text: String) -> String {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedText.isEmpty else {
            return ""
        }
        
        var moderatedText = trimmedText
        
        for prohibitedWordStem in prohibitedWordStems {
            moderatedText = replaceWordStem(
                prohibitedWordStem,
                in: moderatedText,
                with: "***"
            )
        }
        
        return moderatedText
    }
    
    private func replaceWordStem(_ stem: String, in text: String, with replacement: String) -> String {
        let escapedStem = NSRegularExpression.escapedPattern(for: stem)
        let pattern = "(?i)\\b\(escapedStem)[\\p{L}\\p{M}]*"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return text
        }
        
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: replacement)
    }
    
    private func syncCurrentUserScope(userId: String) async {
        do {
            let metadata = try await loadOrCreateUserMetadata(userId: userId)
            currentUserScope = metadata.scope
            userScopesById[userId] = metadata.scope
            isCurrentUserGloballyBlocked = metadata.isGloballyBlocked
            currentUserGlobalBlockReason = metadata.globalBlockReason
            
            if (metadata.scope == .admin || metadata.scope == .moderator) && !metadata.isGloballyBlocked {
                startListeningChatReports()
            } else {
                stopListeningChatReports()
            }
        } catch {
            logger.error("syncCurrentUserScope() error: \(error.localizedDescription)")
            currentUserScope = .user
            isCurrentUserGloballyBlocked = false
            currentUserGlobalBlockReason = nil
        }
    }
    
    private func refreshScopes(for chatMessages: [ChatMessage]) async {
        let userIds = Set(chatMessages.map(\.userId))
        
        for userId in userIds {
            if userScopesById[userId] != nil {
                continue
            }
            
            do {
                let metadata = try await loadOrCreateUserMetadata(userId: userId)
                userScopesById[userId] = metadata.scope
            } catch {
                logger.error("refreshScopes() error: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadOrCreateUserMetadata(userId: String) async throws -> ChatUserMetadata {
        if let metadata = try await chatUserScopesRepository.getMetadata(userId: userId) {
            return metadata
        }
        
        let defaultMetadata = ChatUserMetadata()
        try await chatUserScopesRepository.setScope(userId: userId, scope: defaultMetadata.scope)
        
        return defaultMetadata
    }
    
    private func currentUserBlockReason() -> String {
        currentUserGlobalBlockReason ?? "You have been blocked by chat moderation."
    }
}
