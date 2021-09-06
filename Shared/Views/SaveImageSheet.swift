//
//  SaveImageSheet.swift
//  SaveImageSheet
//
//  Created by Kanunnikov Dmitriy Sergeevich on 06.09.2021.
//

import SwiftUI

struct SaveImageSheet: View {
    
    let text: String
    
    @State private var fgColor = Color(UIColor.label)
    @State private var bgColor = Color(UIColor.systemBackground)
    @State private var size = 30
    
    private static let sizes = [15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100]
    
    @State private var imageSize = CGSize()
    
    var body: some View {
        GeometryReader { g in
            List {
                VStack {
                    textForImage
                    
                    ColorPicker("Цвет текста", selection: $fgColor)
                        .padding([.leading, .trailing], 10)
                    
                    ColorPicker("Цвет фона", selection: $bgColor)
                        .padding([.leading, .trailing, .top], 10)
                    
                    Picker("Размер", selection: $size) {
                        ForEach(SaveImageSheet.sizes, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .padding([.leading, .trailing, .top], 10)
                    
                    Spacer()
                    
                    Button(role: .none, action: {
                        save()
                    }, label: {
                        Text("Сохранить")
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    })
                        .padding()
                }
                .frame(height: g.size.height)
            }
            .listStyle(.plain) 
        }
    }
    
    private var textForImage: some View {
        GeometryReader { g in
            Text(text)
                .font(.custom("Shafarik-Regular", size: CGFloat(size), relativeTo: .body))
                .foregroundColor(fgColor)
                .background(bgColor)
                .lineLimit(nil)
                .padding()
                .fixedSize(horizontal: false, vertical: true)
                .onChange(of: size, perform: { value in
                    imageSize = g.size
                    print("onChange() -> width: \(imageSize.width), height: \(imageSize.height)")
                })
                .onAppear(perform: {
                    imageSize = g.size
                    print("onAppear() -> width: \(imageSize.width), height: \(imageSize.height)")
                })
        }
    }
    
    private func save() {
//        let image = textForImage.snapshot()
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        convertViewToData(view: textForImage, size: imageSize) {
            guard let imageData = $0, let uiImage = UIImage(data: imageData) else { return }
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        }
    }
}
