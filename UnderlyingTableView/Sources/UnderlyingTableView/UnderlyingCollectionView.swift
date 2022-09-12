//
//  SwiftUIView.swift
//  
//
//  Created by Tri Bui Q. VN.Hanoi on 12/09/2022.
//

import SwiftUI

public struct UnderlyingCollectionView<T: CollectionCellBlueprint,
                                       Datasource: BaseCollectionViewDatasouce>: UIViewRepresentable
where T: UICollectionViewCell, Datasource.Model == T.Model {
    
    public init(datasouce: GenericDatasource<T.Model>, data: [T.Model]) {
        self.datasouce = datasouce
        self.data = data
    }
    
    public typealias UIViewType = UIUnderlyingCollectionView<T, Datasource>
    
    private let datasouce: GenericDatasource<Datasource.Model>
    
    private let data: [Datasource.Model]
    
    public func makeUIView(context: Context) -> UIViewType {
        let collectionView = UIViewType(numberOfColumns: 2)
        collectionView.collectionDatasource = datasouce as? Datasource
        return collectionView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        datasouce.updateDatasource(datasource: data)
        uiView.reloadData()
    }
}
