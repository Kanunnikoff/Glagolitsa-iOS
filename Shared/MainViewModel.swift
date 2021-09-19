//
//  MainViewModel.swift
//  MainViewModel
//
//  Created by Kanunnikov Dmitriy Sergeevich on 11.09.2021.
//

import Foundation

//@MainActor
class MainViewModel: ObservableObject {
    
    static let shared = MainViewModel()
    
    private let converter: Converter = Converter.create()
    
    @Published var cyrillicText: String = ""
    @Published var glagoliticText: String = ""
    
    private init() {
    }
    
    func convertFromCyrillicToGlagolitic() {
//        if #available(iOS 15.0, macOS 12.0, *) {
//            Task(priority: .background) {
//                glagoliticText = await converter.convertAsync(fromCyrillic: cyrillicText)
//            }
//        } else {
            DispatchQueue.global(qos: .background).async {
                let result = self.converter.convert(fromCyrillic: self.cyrillicText)

                DispatchQueue.main.async {
                    self.glagoliticText = result
                }
            }
//        }
    }
    
    func convertFromGlagoliticToCyrillic() {
//        if #available(iOS 15.0, macOS 12.0, *) {
//            Task(priority: .background) {
//                cyrillicText = await converter.convertAsync(fromGlagolitic: glagoliticText)
//            }
//        } else {
            DispatchQueue.global(qos: .background).async {
                let result = self.converter.convert(fromGlagolitic: self.glagoliticText)

                DispatchQueue.main.async {
                    self.cyrillicText = result
                }
            }
//        }
    }
    
    func clear() {
        cyrillicText = ""
        glagoliticText = ""
    }
}
