//
//  UnderlyingTableView.swift
//  Cinder
//
//  Created by TriBQ on 12/09/2022.
//

import SwiftUI

public struct UnderlyingTableView: UIViewRepresentable {
    
    public init(scrollDirection: Binding<GenericScrollDirection> = .constant(.down),
                reloadTrigger: Binding<Bool> = .constant(false),
                data: [any GenericSection],
                onRefesh: AsyncVoidCallback? = nil,
                onReachEnd: AsyncVoidCallback? = nil,
                extraSetting: ((UITableView) -> Void)? = nil,
                calcuteSizeForCell: @escaping (UITableView, IndexPath) -> CGFloat,
                buildCellForRow: @escaping (UITableView, IndexPath) -> UITableViewCell,
                didSelectRowAt: ((UITableView, IndexPath) -> Void)? = nil,
                buildHeaderView: ((UITableView, Int) -> UIView?)? = nil,
                headerHeight: ((UITableView, Int) -> CGFloat)? = nil) {
        self._scrollDirection = scrollDirection
        self._reloadTrigger = reloadTrigger
        self.data = data
        self.onRefesh = onRefesh
        self.onReachEnd = onReachEnd
        self.extraSetting = extraSetting
        self.calcuteSizeForCell = calcuteSizeForCell
        self.buildCellForRow = buildCellForRow
        self.buildHeaderView = buildHeaderView
        self.headerHeight = headerHeight
        self.didSelectRowAt = didSelectRowAt
    }
    
    public typealias UIViewType = UIUnderlyingTableView
        
    @Binding
    private var scrollDirection: GenericScrollDirection
    
    @Binding
    private var reloadTrigger: Bool
    
    private let onRefesh: AsyncVoidCallback?
    private let onReachEnd: AsyncVoidCallback?
    private let data: [any GenericSection]
    private let extraSetting: ((UITableView) -> Void)?
    private let calcuteSizeForCell: ((UITableView, IndexPath) -> CGFloat)?
    private let buildCellForRow: ((UITableView, IndexPath) -> UITableViewCell)?
    private var buildHeaderView: ((UITableView, Int) -> UIView?)?
    private var headerHeight: ((UITableView, Int) -> CGFloat)?
    private var didSelectRowAt: ((UITableView, IndexPath) -> Void)?

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
        collectionView.headerHeight = headerHeight
        collectionView.buildHeaderView = buildHeaderView
        collectionView.didSelectRowAt = didSelectRowAt
        return collectionView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
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
