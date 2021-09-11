//
//  MainViewModel.swift
//  MainViewModel
//
//  Created by Kanunnikov Dmitriy Sergeevich on 11.09.2021.
//

import Foundation

class MainViewModel: ObservableObject {
    
    @Published var cyrillicText: String = ""
    @Published var glagoliticText: String = ""
    
    func clear() {
        cyrillicText = ""
        glagoliticText = ""
    }
    
    private init() {
    }
    
    static let shared = MainViewModel()
}
