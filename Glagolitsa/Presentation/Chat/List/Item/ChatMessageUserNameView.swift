//
//  ChatMessageUserNameView.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 27.04.2025.
//

import SwiftUI

struct ChatMessageUserNameView: View {
    
    let chatMessage: ChatMessage
    let userId: String?
    let userName: String
    let scope: ChatUserScope
    
    var body: some View {
        VStack {
            switch scope {
                case .admin:
                    HStack(spacing: 5) {
                        Text("\(userName)")
                            .foregroundStyle(.red)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "checkmark.seal") // 􀇺
                            .resizable()
                            .frame(width: 13, height: 13)
                            .foregroundStyle(.red)
                    }
                    
                case .moderator:
                    HStack(spacing: 5) {
                        Text("\(userName)")
                            .foregroundStyle(.orange)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "shield.lefthalf.filled") // 􀙨
                            .resizable()
                            .frame(width: 13, height: 13)
                            .foregroundStyle(.orange)
                    }
                    
                case .user:
                    switch chatMessage.userId {
                        case userId:
                            Text("\(userName)")
                                .bold()
                        default:
                            Text(chatMessage.userName)
                                .bold()
                    }
            }
        }
    }
}

#Preview {
    ChatMessageUserNameView(
        chatMessage: .stub,
        userId: nil,
        userName: "User Name",
        scope: .user
    )
}
