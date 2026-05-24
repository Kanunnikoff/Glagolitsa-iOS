//
//  VariantWord.swift
//  Glagolitsa
//
//  Created by Дмитрiй Канунниковъ on 16.04.2019.
//  Copyright © 2019 Dmitry Kanunnikoff. All rights reserved.
//

import Foundation

struct VariantWord: Identifiable, Hashable {
    
    static let VARIANT_1 = "если сущ. или прилаг. м.р."
    static let VARIANT_2 = "если прилаг. ж.р. и ср.р."
    
    let id: UUID
    
    let word: String
    let type: WordType
    let position: Int
    
    var var1: String = ""
    var var1Desc: String = ""
    var var2: String = ""
    var var2Desc: String = ""
    var key: Int = 0
    
    init(word: String, type: WordType, position: Int) {
        self.id = UUID()
        self.word = word
        self.type = type
        self.position = position
    }
    
    func getVariant1() -> String {
        return type == .tail ? word : var1
    }
    
    func getVariant2() -> String {
        if type == .tail {
            if word.hasSuffix("ые") {
                return "\(word.dropLast(2))ыя"
            } else if word.hasSuffix("іе") {
                return "\(word.dropLast(2))ія"
            } else {
                return "\(word.dropLast(4))іяся"
            }
        }
        
        return var2
    }
    
    func getVariant1Description() -> String {
        return type == .tail ? "1. \(word) - \(VariantWord.VARIANT_1)" : "1. \(var1) - \(var1Desc)"
    }
    
    func getVariant2Description() -> String {
        if type == .tail {
            if word.hasSuffix("ые") {
                return "2. \(word.dropLast(2))ыя - \(VariantWord.VARIANT_2)"
            } else if word.hasSuffix("іе") {
                return "2. \(word.dropLast(2))ія - \(VariantWord.VARIANT_2)"
            } else {
                return "2. \(word.dropLast(4))іяся - \(VariantWord.VARIANT_2)"
            }
        }
        
        return "2. \(var2) - \(var2Desc)"
    }
    
    enum WordType {
        case tail
        case root
    }
}
