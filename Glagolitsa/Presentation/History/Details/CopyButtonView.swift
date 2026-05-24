//
//  CopyButtonView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 19.04.2025.
//

import SwiftUI

struct CopyButtonView: View {
    
    let textToCopy: String
    
    @State private var isCopied: Bool = false
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isCopied ? "checkmark": "square.on.square") // 􀆅 : 􀐅
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .contentTransition(.symbolEffect(.replace))
            
            Text("Copy")
        }
        .foregroundColor(Color.accentColor)
        .onTapGesture(perform: onTapGestureAction())
    }
    
    private func onTapGestureAction() -> (() -> Void) {
        return {
            Util.copyToClipboard(text: textToCopy)
            
            withAnimation {
                isCopied.toggle()
                
                Task {
                    try? await Task.sleep(for: .milliseconds(1_500))
                    
                    await MainActor.run {
                        isCopied.toggle()
                    }
                }
            }
        }
    }
}

#Preview {
    CopyButtonView(textToCopy: "Hi")
}
