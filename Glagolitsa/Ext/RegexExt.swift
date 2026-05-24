//
//  Regex.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 3/31/25.
//

import Foundation



extension Regex {
    
    func test(_ string: String) -> Bool {
        return (try? regex.firstMatch(in: string)) != nil
    }
}
