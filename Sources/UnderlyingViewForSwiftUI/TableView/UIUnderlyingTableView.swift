//
//  UIUnderlyingTableView.swift
//  Cinder
//
//  Created by TriBQ on 12/09/2022.
//

import Foundation
import UIKit

public class UIUnderlyingTableView: UITableView,
                                    UITableViewDelegate,
                                    UITableViewDataSource,
                                    UITableViewDataSourcePrefetching,
                                    UIScrollViewDelegate {
    // MARK: - public
    public var data: [any GenericSection] = []
    public var onRefresh: (() async -> Void)?
    public var onReachEnd: (() async -> Void)?
    public var calcuteSizeForCell: ((UITableView, IndexPath) -> CGFloat)?
    public var buildCellForRow: ((UITableView, IndexPath) -> UITableViewCell)?
    public var buildHeaderView: ((UITableView, Int) -> UIView?)?
    public var headerHeight: ((UITableView, Int) -> CGFloat)?
    
    public var didSelectRowAt: ((UITableView, IndexPath) -> Void)?

    public var onChangeScrollDirection: ((GenericScrollDirection) -> Void)?
    
    // MARK: - Private
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        
        return layout
    }()
    
    private var defaultOffset: CGPoint?
    private let thisRefreshControl = UIRefreshControl()
    
    private var isLoadingMore = false
    
    // MARK: - Init
    public init() {
        super.init(frame: .zero, style: .grouped)
        setupCollectionView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }
    
    // MARK: - Functions
    private func setupCollectionView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.delegate = self
        self.dataSource = self
        self.prefetchDataSource = self
        self.separatorStyle = .none
        self.alwaysBounceVertical = true
        
        self.refreshControl = thisRefreshControl
        thisRefreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
    }
    
    @objc private func didPullToRefresh(_ sender: Any) {
        Task {
            await onRefresh?()
            self.thisRefreshControl.endRefreshing()
        }
    }
    
    // MARK: - Delegate functions
    public func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[safe: section]?.data.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return buildCellForRow?(tableView, indexPath) ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calcuteSizeForCell?(tableView, indexPath) ?? .leastNonzeroMagnitude
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.map({ $0.item }).contains(tableView.numberOfRows(inSection: tableView.numberOfSections - 1) - 5) && !isLoadingMore {
            Task {
                isLoadingMore = true
                await onReachEnd?()
                isLoadingMore = false
            }
        }
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        buildHeaderView?(tableView, section)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerHeight?(tableView, section) ?? .leastNonzeroMagnitude
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.didSelectRowAt?(tableView, indexPath)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.defaultOffset = scrollView.contentOffset
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let defaultOffset = defaultOffset else {
            return
        }
        
        let currentOffset = scrollView.contentOffset
        
        if currentOffset.y + scrollView.height >= scrollView.contentSize.height {
            return
        }
        
        if currentOffset.y <= 0 {
            return
        }
        
        if currentOffset.y > defaultOffset.y {
            onChangeScrollDirection?(.up)
        } else {
            onChangeScrollDirection?(.down)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.defaultOffset = nil
    }
}
