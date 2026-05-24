//
//  ChatBlockedUsersView.swift
//  Yat
//
//  Created by Codex on 08.03.2026.
//

import SwiftUI

struct ChatBlockedUser: Identifiable {
    let id: String
    let userName: String
}

struct ChatBlockedUsersView: View {
    @Environment(\.dismiss) private var dismiss

    let blockedUsers: [ChatBlockedUser]
    let onUnblock: (String) -> Void

    private enum Layout {
#if os(macOS)
        static let sheetMinWidth: CGFloat = 460
        static let sheetIdealWidth: CGFloat = 520
        static let sheetMinHeight: CGFloat = 320
        static let sheetIdealHeight: CGFloat = 420
        static let headerHorizontalPadding: CGFloat = 24
        static let headerVerticalPadding: CGFloat = 18
        static let rowVerticalPadding: CGFloat = 6
        static let contentPadding: CGFloat = 20
#endif
    }

    var body: some View {
#if os(macOS)
        macOSContent
#else
        iOSContent
#endif
    }

#if os(macOS)
    private var macOSContent: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Blocked Users")
                    .font(.title2.weight(.semibold))

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark") // 􀆄
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, Layout.headerHorizontalPadding)
            .padding(.vertical, Layout.headerVerticalPadding)

            Divider()

            Group {
                if blockedUsers.isEmpty {
                    ContentUnavailableView {
                        Label("No Blocked Users", systemImage: "person.2.slash")
                    } description: {
                        Text("When you block someone in chat, they will appear here.")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(blockedUsers) { blockedUser in
                        HStack {
                            Text(blockedUser.userName)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button("Unblock") {
                                onUnblock(blockedUser.id)
                            }
                        }
                        .padding(.vertical, Layout.rowVerticalPadding)
                        .contextMenu {
                            Button("Unblock", role: .destructive) {
                                onUnblock(blockedUser.id)
                            }
                        }
                    }
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                }
            }
            .padding(.horizontal, blockedUsers.isEmpty ? Layout.contentPadding : 0)
            .padding(.vertical, blockedUsers.isEmpty ? Layout.contentPadding : 0)
        }
        .frame(
            minWidth: Layout.sheetMinWidth,
            idealWidth: Layout.sheetIdealWidth,
            minHeight: Layout.sheetMinHeight,
            idealHeight: Layout.sheetIdealHeight
        )
    }
#endif

    private var iOSContent: some View {
        NavigationStack {
            Group {
                if blockedUsers.isEmpty {
                    ContentUnavailableView {
                        Label("No Blocked Users", systemImage: "person.2.slash")
                    } description: {
                        Text("When you block someone in chat, they will appear here.")
                    }
                } else {
                    List(blockedUsers) { blockedUser in
                        Text(blockedUser.userName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button("Unblock", role: .destructive) {
                                    onUnblock(blockedUser.id)
                                }
                                .tint(.green)
                            }
                    }
                }
            }
            .navigationTitle("Blocked Users")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark") // 􀆄
                    }
                }
            }
        }
    }
}

#Preview {
    ChatBlockedUsersView(
        blockedUsers: [
            .init(id: "1", userName: "User 1"),
            .init(id: "2", userName: "User 2")
        ],
        onUnblock: { _ in }
    )
}
