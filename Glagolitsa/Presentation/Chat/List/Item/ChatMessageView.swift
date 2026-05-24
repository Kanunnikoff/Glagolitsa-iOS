//
//  ChatMessageView.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 27.04.2025.
//

import SwiftUI

struct ChatMessageView: View {

    @Bindable var viewModel: ChatViewModel
    let chatMessage: ChatMessage
    let visibleChatMessages: [ChatMessage]
    let userId: String?
    let userName: String
    let isOldRusMonthNames: Bool
    let scrollViewProxy: ScrollViewProxy

    @Binding var showingDeleteChatMessageAlert: Bool
    @Binding var chatMessageForDelete: ChatMessage?

    @Binding var chatMessageForEdit: ChatMessage?
    @Binding var chatMessageForReply: ChatMessage?

    private enum Layout {
        static let macOSBottomPadding: CGFloat = 14
        static let defaultBottomPadding: CGFloat = 0
    }

    var body: some View {
        VStack(spacing: 8) {
            if chatMessage.userId != userId {
                ChatMessageUserNameView(
                    chatMessage: chatMessage,
                    userId: userId,
                    userName: chatMessage.userName,
                    scope: viewModel.userScope(for: chatMessage.userId)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if chatMessage.quotedChatMessageId != nil {
                HStack {
                    if let quotedChatMessage = visibleChatMessages.first(where: { $0.id == chatMessage.quotedChatMessageId }) {
                        VStack {
                            Text(quotedChatMessage.userName)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(quotedChatMessage.text)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(25)
                        .background(
                            Color.accentColor.opacity(0.1),
                            in: UnevenRoundedRectangle(
                                topLeadingRadius: 50,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 50,
                                topTrailingRadius: 50,
                                style: .continuous
                            )
                        )
                        .onTapGesture {
                            withAnimation {
                                scrollViewProxy.scrollTo(quotedChatMessage.id)
                            }
                        }
                    } else {
                        Text("The quoted message was not found. It may have been removed.")
                            .italic()
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(25)
                            .background(
                                Color.accentColor.opacity(0.1),
                                in: UnevenRoundedRectangle(
                                    topLeadingRadius: 50,
                                    bottomLeadingRadius: 0,
                                    bottomTrailingRadius: 50,
                                    topTrailingRadius: 50,
                                    style: .continuous
                                )
                            )
                    }
                }
            }

            if let url = Util.extractURLs(from: chatMessage.text).first {
                LinkPreviewView(
                    url: url,
                    cornerRadius: 50
                )
                .frame(maxWidth: .infinity)
            }

            Text(chatMessage.text)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Spacer()

                if let editDate = chatMessage.editDate {
                    (Text("edited") + Text(" ") + Text(editDate.prettyFormat(isOldRusMonthNames)))
                        .font(.caption)
                        .italic()
                        .foregroundStyle(Util.labelColor.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                } else {
                    Text(chatMessage.createDate.prettyFormat(isOldRusMonthNames))
                        .font(.caption)
                        .italic()
                        .foregroundStyle(Util.labelColor.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(25)
        .background(
            Util.secondarySystemBackgroundColor,
            in: UnevenRoundedRectangle(
                topLeadingRadius: 50,
                bottomLeadingRadius: chatMessage.userId == userId ? 50 : 0,
                bottomTrailingRadius: chatMessage.userId == userId ? 0 : 50,
                topTrailingRadius: 50,
                style: .continuous
            )
        )
        .padding(
            EdgeInsets(
                top: chatMessage.userId == userId ? 0 : 0,
                leading: chatMessage.userId == userId ? 40 : 0,
                bottom: bottomPadding,
                trailing: chatMessage.userId == userId ? 0 : 40
            )
        )
    }

    private var bottomPadding: CGFloat {
#if os(macOS)
        Layout.macOSBottomPadding
#else
        Layout.defaultBottomPadding
#endif
    }
}

#Preview {
//    ChatMessageView(
//        viewModel: ChatViewModel(),
//        chatMessage: .stub,
//        userId: nil,
//        userName: "User Name",
//        isOldRusMonthNames: false,
//        scrollViewProxy: ,
//        showingDeleteChatMessageAlert: .constant(false),
//        chatMessageForDelete: .constant(.stub),
//        chatMessageForEdit: .constant(.stub),
//        chatMessageForReply: .constant(.stub),
//        scrollPosition: .constant(.init(idType: String.self))
//    )
}
