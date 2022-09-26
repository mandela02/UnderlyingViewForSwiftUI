//
//  GenericManager.swift
//  Cinder
//
//  Created by TriBQ on 12/09/2022.
//

import Foundation
import UIKit

public enum GenericScrollDirection {
    case up
    case down
}

public struct GenericSection: Identifiable, Equatable {
    public static func == (lhs: GenericSection, rhs: GenericSection) -> Bool {
        lhs.id == rhs.id
    }
    
    public init( title: String, data: [Any]) {
        self.title = title
        self.data = data
    }
    
    public var id: String {
        return UUID().uuidString
    }
    
    public let title: String
    public var data: [Any]
}
