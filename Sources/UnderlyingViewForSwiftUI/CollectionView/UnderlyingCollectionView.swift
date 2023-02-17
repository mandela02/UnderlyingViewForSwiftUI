//
//  SwiftUIView.swift
//  
//
//  Created by Tri Bui Q. VN.Hanoi on 12/09/2022.
//

import SwiftUI

public typealias AsyncVoidCallback = () async -> Void

public struct UnderlyingCollectionView: UIViewRepresentable {
    
    public init(data: [any GenericSection] = [],
                frame: CGRect = .zero,
                scrollDirection: Binding<GenericScrollDirection> = .constant(.down),
                reloadTrigger: Binding<Bool> = .constant(false),
                onRefesh: AsyncVoidCallback? = nil,
                onReachEnd: AsyncVoidCallback? = nil,
                calculateSizeForCell: @escaping (UICollectionView, IndexPath) -> CGSize,
                buildCellForItem: @escaping (UICollectionView, IndexPath) -> UICollectionViewCell,
                edgeInset: ((Int) -> UIEdgeInsets)? = nil,
                spacing: ((Int) -> CGFloat)? = nil,
                buildHeader: ((UICollectionView, IndexPath) -> UICollectionReusableView)? = nil,
                buildFooter: ((UICollectionView, IndexPath) -> UICollectionReusableView)? = nil,
                sizeForHeader: ((UICollectionView, Int) -> CGSize)? = nil,
                sizeForFooter: ((UICollectionView, Int) -> CGSize)? = nil,
                willDisplay: ((UICollectionView, UICollectionViewCell, IndexPath ) -> Void)? = nil,
                didEndDisplay: ((UICollectionView, UICollectionViewCell, IndexPath ) -> Void)? = nil,
                didSelectItem: ((UICollectionView, IndexPath) -> Void)? = nil,
                extraSetting: ((UICollectionView) -> Void)?) {
        
        self._scrollDirection = scrollDirection
        self._reloadTrigger = reloadTrigger
        self.data = data
        self.onRefesh = onRefesh
        self.onReachEnd = onReachEnd
        self.extraSetting = extraSetting
        self.calculateSizeForCell = calculateSizeForCell
        self.buildCellForItem = buildCellForItem
        self.buildFooter = buildFooter
        self.buildHeader = buildHeader
        self.sizeForHeader = sizeForHeader
        self.sizeForFooter = sizeForFooter
        self.edgeInset = edgeInset
        self.spacing = spacing
        self.frame = frame
        
        self.didSelectItem = didSelectItem
    }
    
    public typealias UIViewType = UIUnderlyingCollectionView
            
    private let data: [any GenericSection]

    private let frame: CGRect
    
    @Binding
    private var scrollDirection: GenericScrollDirection
    
    @Binding
    private var reloadTrigger: Bool

    private let onRefesh: AsyncVoidCallback?
    private let onReachEnd: AsyncVoidCallback?
    private let extraSetting: ((UICollectionView) -> Void)?
    private let calculateSizeForCell: ((UICollectionView, IndexPath) -> CGSize)?
    private var buildCellForItem: ((UICollectionView, IndexPath) -> UICollectionViewCell)?
    private var buildHeader: ((UICollectionView, IndexPath) -> UICollectionReusableView)?
    private var buildFooter: ((UICollectionView, IndexPath) -> UICollectionReusableView)?
    private var sizeForHeader: ((UICollectionView, Int) -> CGSize)?
    private var sizeForFooter: ((UICollectionView, Int) -> CGSize)?
    private var edgeInset: ((Int) -> UIEdgeInsets)?
    private var spacing: ((Int) -> CGFloat)?
    private var willDisplay: ((UICollectionView, UICollectionViewCell, IndexPath ) -> Void)?
    private var didEndDisplay: ((UICollectionView, UICollectionViewCell, IndexPath ) -> Void)?
    private var didSelectItem: ((UICollectionView, IndexPath) -> Void)?

    public func makeUIView(context: Context) -> UIViewType {
        let collectionView = UIViewType()
        collectionView.onChangeScrollDirection = { direction in
            scrollDirection = direction
        }
        collectionView.buildHeader = buildHeader
        collectionView.buildFooter = buildFooter
        collectionView.buildCellForItem = buildCellForItem
        collectionView.calculateSizeForCell = calculateSizeForCell
        collectionView.onRefresh = onRefesh
        collectionView.onReachEnd = onReachEnd
        collectionView.sizeForFooter = sizeForFooter
        collectionView.sizeForHeader = sizeForHeader
        collectionView.edgeInset = edgeInset
        collectionView.spacing = spacing
        collectionView.willDisplay = willDisplay
        collectionView.didEndDisplay = didEndDisplay
        collectionView.didSelectItem = didSelectItem
        
        extraSetting?(collectionView)

        return collectionView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        if frame != .zero && frame != uiView.frame {
            uiView.frame = frame
        }
        
        if reloadTrigger {
            uiView.reloadData()
            DispatchQueue.main.async {
                reloadTrigger = false
            }
            return
        }
        
        if data.elementsEqual(uiView.data,
                              by: { section, element in
            section.id == element.id
        }) { return }

        uiView.data = data
        uiView.reloadData()
    }
}
