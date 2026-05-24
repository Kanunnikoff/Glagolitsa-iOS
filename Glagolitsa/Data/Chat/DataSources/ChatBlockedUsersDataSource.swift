//
//  ChatBlockedUsersDataSource.swift
//  Yat
//
//  Created by Codex on 08.03.2026.
//

import Foundation

protocol ChatBlockedUsersDataSource {
    func subscribeBlockedUserIds(userId: String) -> AsyncThrowingStream<Set<String>, Error>
    func block(userId: String, blockedUserId: String) async throws
    func unblock(userId: String, blockedUserId: String) async throws
}
