//
//  ViewExt.swift
//  ViewExt
//
//  Created by Kanunnikov Dmitriy Sergeevich on 03.09.2021.
//

import SwiftUI

extension View {
    
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
    
    func convertViewToData<V>(view: V, size: CGSize, completion: @escaping (Data?) -> Void) where V: View {
        guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
            completion(nil)
            return
        }
        let imageVC = UIHostingController(rootView: view.edgesIgnoringSafeArea(.all))
        imageVC.view.frame = CGRect(origin: .zero, size: size)
        DispatchQueue.main.async {
            rootVC.view.insertSubview(imageVC.view, at: 0)
            let uiImage = imageVC.view.asImage(size: size)
            imageVC.view.removeFromSuperview()
            completion(uiImage.pngData())
        }
    }
    
    func navigatePush(whenTrue toggle: Binding<Bool>, text: String) -> some View {
        NavigationLink(destination: SaveImageView(text: text), isActive: toggle) { EmptyView() }
    }
    
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
            .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}
