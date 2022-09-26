//
//  File.swift
//  
//
//  Created by TriBQ on 27/09/2022.
//

import SwiftUI

public extension View {
    var uiView: UIView {
        let view = UIHostingController(rootView: self).view
        view?.backgroundColor = .clear
        return view ?? UIView()
    }
}
