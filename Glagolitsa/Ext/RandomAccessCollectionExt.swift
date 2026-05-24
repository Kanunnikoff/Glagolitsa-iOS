//
//  RandomAccessCollectionExt.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 05.04.2025.
//

extension RandomAccessCollection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    /// - complexity: O(1)
    subscript (safe index: Index) -> Element? {
        guard index >= startIndex, index < endIndex else {
            return nil
        }
        return self[index]
    }
    
}
