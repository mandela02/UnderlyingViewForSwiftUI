//
//  UnderlyingTableView.swift
//  Cinder
//
//  Created by TriBQ on 12/09/2022.
//

import SwiftUI

public struct UnderlyingTableView: UIViewRepresentable {
    
    public init(scrollDirection: Binding<GenericScrollDirection>,
                data: [GenericSection],
                onRefesh: AsyncVoidCallback? = nil,
                onReachEnd: AsyncVoidCallback? = nil,
                extraSetting: ((UITableView) -> Void)? = nil,
                calcuteSizeForCell: @escaping (UITableView, IndexPath) -> CGFloat,
                buildCellForRow: @escaping (UITableView, IndexPath) -> UITableViewCell) {
        self._scrollDirection = scrollDirection
        self.data = data
        self.onRefesh = onRefesh
        self.onReachEnd = onReachEnd
        self.extraSetting = extraSetting
        self.calcuteSizeForCell = calcuteSizeForCell
        self.buildCellForRow = buildCellForRow
    }
    
    public typealias UIViewType = UIUnderlyingTableView
        
    @Binding
    private var scrollDirection: GenericScrollDirection
    private let onRefesh: AsyncVoidCallback?
    private let onReachEnd: AsyncVoidCallback?
    private let data: [GenericSection]
    private let extraSetting: ((UITableView) -> Void)?
    private let calcuteSizeForCell: ((UITableView, IndexPath) -> CGFloat)?
    private let buildCellForRow: ((UITableView, IndexPath) -> UITableViewCell)?

    public func makeUIView(context: Context) -> UIViewType {
        let collectionView = UIViewType()
        collectionView.data = data
        extraSetting?(collectionView)
        collectionView.onChangeScrollDirection = { direction in
            scrollDirection = direction
        }
        collectionView.buildCellForRow = buildCellForRow
        collectionView.calcuteSizeForCell = calcuteSizeForCell
        collectionView.onRefresh = onRefesh
        collectionView.onReachEnd = onReachEnd
        return collectionView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.data = data
        uiView.reloadData()
    }
}
