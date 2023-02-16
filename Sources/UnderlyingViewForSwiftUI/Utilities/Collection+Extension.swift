//
//  File.swift
//  
//
//  Created by TriBQ on 27/09/2022.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
