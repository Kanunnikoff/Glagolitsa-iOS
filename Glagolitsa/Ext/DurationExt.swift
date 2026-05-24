//
//  DurationExt.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 16.03.2025.
//

extension Duration {
    
    var inMilliseconds: Double {
        return Double(components.seconds) * 1000 + Double(components.attoseconds) * 1e-15
    }
}
