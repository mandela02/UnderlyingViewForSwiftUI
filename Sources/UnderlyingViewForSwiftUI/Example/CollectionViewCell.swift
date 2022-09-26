//
//  File.swift
//  
//
//  Created by TriBQ on 27/09/2022.
//

import SwiftUI

class CollectionViewCell: UICollectionViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.removeAllSubviews()
    }
    
    // CellForRowAt
    func setupView(with text: String) {
        let view = TextView(text: text).uiView
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        contentView.backgroundColor = .clear
                
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

struct TextView: View {
    let text: String
    
    var body: some View {
        Text(text)
    }
}
