//
//  ChatToolbarMenuView.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 01.05.2025.
//

import SwiftUI

struct ChatToolbarMenuView: View {
    
//    let menuButtonTip: MenuButtonTip
    
    let userName: String
    let hasBlockedUsers: Bool
    let canViewReports: Bool
    @Binding var showingBlockedUsersList: Bool
    @Binding var showingReportsList: Bool
    @Binding var showingChangeUserNameAlert: Bool
    @Binding var showingSignOutAlert: Bool
    @Binding var showingDeleteAccountAlert: Bool
    
    var body: some View {
        Menu {
            Text(userName.isEmpty ? "Unknown User" : userName)
            
            Divider()
            
            Button {
                showingChangeUserNameAlert.toggle()
            } label: {
                Label("Change Name", systemImage: "pencil") // 􀈊
            }
            
            Button {
                showingSignOutAlert.toggle()
            } label: {
                Label("Sign Out", systemImage: "door.left.hand.open") // 􁏜
            }
            
            Divider()
            
            if hasBlockedUsers {
                Button {
                    showingBlockedUsersList.toggle()
                } label: {
                    Label("Blocked Users", systemImage: "person.2.slash") // 􁝞
                }
                
                Divider()
            }
            
            if canViewReports {
                Button {
                    showingReportsList.toggle()
                } label: {
                    Label("Reports", systemImage: "exclamationmark.bubble")
                }
                
                Divider()
            }
            
            Button(role: .destructive) {
                showingDeleteAccountAlert.toggle()
            } label: {
                Label("Delete Account", systemImage: "trash") // 􀈑
            }
        } label: {
            Image(systemName: "ellipsis.circle") // 􀍡
        }
//        .onTapGesture {
//            menuButtonTip.invalidate(reason: .actionPerformed)
//        }
    }
}

#Preview {
    ChatToolbarMenuView(
        userName: "User Name",
        hasBlockedUsers: true,
        canViewReports: true,
        showingBlockedUsersList: .constant(false),
        showingReportsList: .constant(false),
        showingChangeUserNameAlert: .constant(false),
        showingSignOutAlert: .constant(false),
        showingDeleteAccountAlert: .constant(false)
//        menuButtonTip: .init()
    )
}
