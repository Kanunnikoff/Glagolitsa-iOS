/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 Identifiers for use in the store.
 */

import SwiftUI

public struct ConsumableIdentifiers {
    public var tips: String
}

public extension EnvironmentValues {
    
    @Entry var consumableIDs = ConsumableIdentifiers(
        tips: "software.kanunnikoff.Glagolitsa.Products.Tip"
    )
}
