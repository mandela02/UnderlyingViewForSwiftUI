//
//  File.swift
//  
//
//  Created by TriBQ on 27/09/2022.
//

import UIKit

extension UIView {
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
}
