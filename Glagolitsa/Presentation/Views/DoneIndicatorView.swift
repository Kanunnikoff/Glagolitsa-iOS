/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 The bird happiness indicator view.
 */

import SwiftUI

struct DoneIndicatorView: View {
    
    let message: LocalizedStringKey
    let startImageName: String
    let endImageName: String
    
    @State private var showingHeart = false
    @State private var showingCallout = false
    @ScaledMetric private var indicatorHeight = 80.0
    
    @State private var imageName = "arrow.down.circle" // 􀁸
    
    init(
        message: LocalizedStringKey,
        startImageName: String = "arrow.down.circle", // 􀁸
        endImageName: String = "checkmark.circle" // 􀁢
    ) {
        self.message = message
        self.startImageName = startImageName
        self.endImageName = endImageName
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if showingHeart {
                Image(systemName: imageName)
                    .foregroundStyle(.linearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottom))
                    .font(.title)
                    .padding(8)
//                    .background(.red.gradient.opacity(0.25), in: .circle)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                    .transition(.scale(scale: 0.25).combined(with: .opacity))
            }
            
            if showingCallout {
                Text(message)
                .foregroundStyle(.secondary)
                .font(.callout)
                .transition(.scale(0.5).combined(with: .opacity))
                .padding(.trailing, 26)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .clipShape(.capsule)
        .background(.regularMaterial.shadow(.drop(color: .black.opacity(0.15), radius: 20, y: 10)), in: .capsule)
        .padding()
        .frame(height: indicatorHeight)
        .task {
            imageName = startImageName
            
            Task {
                withAnimation(.spring(duration: 0.5, bounce: 0.5)) {
                    showingHeart = true
                }
                try await Task.sleep(for: .seconds(2))
                withAnimation {
                    showingCallout = true
                }
                try await Task.sleep(for: .seconds(4))
                withAnimation {
                    imageName = endImageName
                    showingCallout = false
                }
                try await Task.sleep(for: .seconds(1))
                withAnimation {
                    showingHeart = false
                }
            }
        }
    }
}

#Preview {
    _IndicatorPreview()
}

private struct _IndicatorPreview: View {
    @State private var id = 0
    
    var body: some View {
        VStack {
            Spacer()
            DoneIndicatorView(message: "Thank you so much for your support!")
                .id(id)
            Spacer()
            Button {
                id += 1
            } label: {
                Text(verbatim: "Restart")
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.fill)
    }
}


//    .overlay(alignment: .bottom) {
//        if let bird = backyard.currentVisitorEvent?.bird {
//            if presentingHappinessIndicator {
//                BirdFoodHappinessIndicator(birdName: bird.speciesName, foodName: backyard.birdFood?.name ?? "")
//            }
//        }
//        }



//    .onChange(of: backyard.foodRefillDate) { (_, _) in
//        withAnimation(.spring(duration: 0.5, bounce: 0.5)) {
//            presentingHappinessIndicator = true
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
//            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
//                presentingHappinessIndicator = false
//            }
//        }
//        }
