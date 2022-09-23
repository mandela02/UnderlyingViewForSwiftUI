import UIKit

public class UIUnderlyingCollectionView: UICollectionView,
                                         UICollectionViewDelegate,
                                         UICollectionViewDataSource,
                                         UICollectionViewDelegateFlowLayout,
                                         UICollectionViewDataSourcePrefetching,
                                         UIScrollViewDelegate {
    
    // MARK: - public
    public var data: [GenericSection] = []
    public var onRefresh: (() async -> Void)?
    public var onReachEnd: (() async -> Void)?
    public var calculateSizeForCell: ((UICollectionView, IndexPath) -> CGSize)?
    public var buildCellForItem: ((UICollectionView, IndexPath) -> UICollectionViewCell)?
    public var buildHeader: ((UICollectionView, IndexPath) -> UICollectionReusableView)?
    public var buildFooter: ((UICollectionView, IndexPath) -> UICollectionReusableView)?

    public var onChangeScrollDirection: ((GenericScrollDirection) -> Void)?
    
    // MARK: - Private
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        
        return layout
    }()
    
    private var defaultOffset: CGPoint?
    private let thisRefreshControl = UIRefreshControl()
    
    var spacing: CGFloat = 20
    var edgeInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    private var isLoadingMore = false
    
    // MARK: - Init
    public init() {
        super.init(frame: .zero, collectionViewLayout: self.layout)
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
        self.alwaysBounceVertical = true
        
        if onRefresh != nil {
            self.refreshControl = thisRefreshControl
            thisRefreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        }
    }
    
    @objc private func didPullToRefresh(_ sender: Any) {
        Task {
            await onRefresh?()
            self.thisRefreshControl.endRefreshing()
        }
    }
    
    // MARK: - Delegate functions
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return data[safe: section]?.data.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return calculateSizeForCell?(collectionView, indexPath) ?? .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return buildCellForItem?(collectionView, indexPath) ?? UICollectionViewCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return buildHeader?(collectionView, indexPath) ?? UICollectionReusableView()
        case UICollectionView.elementKindSectionFooter:
            return buildFooter?(collectionView, indexPath) ?? UICollectionReusableView()
        default:
            return UICollectionReusableView()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return edgeInset
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.map({ $0.item }).contains(collectionView.numberOfItems(inSection: collectionView.numberOfSections - 1) - 5) && !isLoadingMore {
            Task {
                isLoadingMore = true
                await onReachEnd?()
                isLoadingMore = false
            }
        }
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
