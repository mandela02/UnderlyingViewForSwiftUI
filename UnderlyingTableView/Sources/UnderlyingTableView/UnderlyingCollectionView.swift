//
//  SwiftUIView.swift
//  
//
//  Created by Tri Bui Q. VN.Hanoi on 12/09/2022.
//

import SwiftUI

public struct UnderlyingCollectionView: UIViewRepresentable {
    
    public init(data: [GenericSection] = [],
                scrollDirection: Binding<GenericScrollDirection> = .constant(.down),
                onRefesh: AsyncVoidCallback? = nil,
                onReachEnd: AsyncVoidCallback? = nil,
                calculateSizeForCell: @escaping (UICollectionView, IndexPath) -> CGSize,
                buildCellForItem: @escaping (UICollectionView, IndexPath) -> UICollectionViewCell,
                buildHeader: ((UICollectionView, IndexPath) -> UICollectionReusableView)? = nil,
                buildFooter: ((UICollectionView, IndexPath) -> UICollectionReusableView)? = nil,
                extraSetting: ((UICollectionView) -> Void)?) {
        
        self._scrollDirection = scrollDirection
        self.data = data
        self.onRefesh = onRefesh
        self.onReachEnd = onReachEnd
        self.extraSetting = extraSetting
        self.calculateSizeForCell = calculateSizeForCell
        self.buildCellForItem = buildCellForItem
        self.buildFooter = buildFooter
        self.buildHeader = buildHeader
    }
    
    public typealias UIViewType = UIUnderlyingCollectionView
            
    @Binding
    private var scrollDirection: GenericScrollDirection
    private let onRefesh: AsyncVoidCallback?
    private let onReachEnd: AsyncVoidCallback?
    private let data: [GenericSection]
    private let extraSetting: ((UICollectionView) -> Void)?
    private let calculateSizeForCell: ((UICollectionView, IndexPath) -> CGSize)?
    private var buildCellForItem: ((UICollectionView, IndexPath) -> UICollectionViewCell)?
    private var buildHeader: ((UICollectionView, IndexPath) -> UICollectionReusableView)?
    private var buildFooter: ((UICollectionView, IndexPath) -> UICollectionReusableView)?

    public func makeUIView(context: Context) -> UIViewType {
        let collectionView = UIViewType()
        collectionView.onChangeScrollDirection = { direction in
            scrollDirection = direction
        }
        collectionView.buildHeader = buildHeader
        collectionView.buildFooter = buildFooter
        collectionView.buildCellForItem = buildCellForItem
        collectionView.calculateSizeForCell = calculateSizeForCell
        extraSetting?(collectionView)
        collectionView.onRefresh = onRefesh
        collectionView.onReachEnd = onReachEnd
        return collectionView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.data = data
        uiView.reloadData()
    }
}
