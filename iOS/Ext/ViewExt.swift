//
//  ViewExt.swift
//  ViewExt
//
//  Created by Kanunnikov Dmitriy Sergeevich on 03.09.2021.
//

import SwiftUI

// A View wrapper to make the modifier easier to use
extension View {
    
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
    
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
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
        NavigationLink(destination: SaveImageSheet(text: text), isActive: toggle) { EmptyView() }
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
