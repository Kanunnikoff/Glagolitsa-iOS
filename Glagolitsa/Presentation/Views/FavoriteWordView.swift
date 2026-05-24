//
//  FavoriteWordView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 15.03.2025.
//

import SwiftUI

struct FavoriteWordView: View {
    
    let word: Translation
    
    var body: some View {
        let liked = word.isFeatured
        
        Image(systemName: "heart") // 􀊴
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .symbolVariant(liked ? .fill : .none)
            .foregroundColor(liked ? Color.red : Util.labelColor)
            .contentTransition(.symbolEffect(.replace))
            .onTapGesture(perform: onTapGestureAction())
    }
    
    private func onTapGestureAction() -> (() -> Void) {
        return {
            withAnimation {
                word.isFeatured = !word.isFeatured
            }
        }
    }
}

#Preview {
    FavoriteWordView(word: Translation.stub())
}
