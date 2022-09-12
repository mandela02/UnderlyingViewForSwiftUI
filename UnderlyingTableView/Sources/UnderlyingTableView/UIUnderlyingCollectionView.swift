import UIKit

public class GenericCell<T>: UICollectionViewCell, CollectionCellBlueprint {
    public func setup(model: Model) {
        // TODO:
    }
    
    public typealias Model = T
}

public class GenericDatasource<T>: BaseCollectionViewDatasouce {
    public init() {}
    
    var datasource: [T] = []
    
    public typealias Model = T
    
    public func updateDatasource(datasource: [T]) {
        self.datasource = datasource
    }
    
    public func getModel(indexPath: IndexPath) -> Model? {
        return datasource.indices.contains(indexPath.row) ? datasource[indexPath.row] : nil
    }
}

public protocol CollectionCellBlueprint {
    associatedtype Model
    func setup(model: Model)
}

public protocol BaseCollectionViewDatasouce: AnyObject {
    associatedtype Model
    func getModel(indexPath: IndexPath) -> Model?
}


private extension UIView {
    static var identifier: String {
        return String(describing: self)
    }
}

public typealias AsyncVoidCallBack = () async -> Void

public class UIUnderlyingCollectionView<T: CollectionCellBlueprint,
                                        Datasource: BaseCollectionViewDatasouce>: UICollectionView,
                                                                               UICollectionViewDelegate,
                                                                               UICollectionViewDataSource,
                                                                               UICollectionViewDelegateFlowLayout,
                                                                               UIScrollViewDelegate
where T: UICollectionViewCell, Datasource.Model== T.Model {
    
    // MARK: - public
    public weak var collectionDatasource: Datasource?
    public var onRefresh: AsyncVoidCallBack?
    
    // MARK: - Private
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        
        return layout
    }()
    
    private var defaultOffset: CGPoint?
    private let thisRefreshControl = UIRefreshControl()
    
    private var numberOfColumns: Int = 2
    
    // MARK: - Init
    public init(numberOfColumns: Int) {
        self.numberOfColumns = numberOfColumns
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
        self.register(T.self,
                      forCellWithReuseIdentifier: T.identifier)
        self.alwaysBounceVertical = true
        
        self.refreshControl = thisRefreshControl
        thisRefreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
    }
    
    @objc private func didPullToRefresh(_ sender: Any) async {
        await onRefresh?()
        self.thisRefreshControl.endRefreshing()
    }
    
    // MARK: - Delegate functions
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: 250)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: T.identifier,
                                                            for: indexPath) as? T else {
            return UICollectionViewCell()
        }
        guard let model = collectionDatasource?.getModel(indexPath: indexPath) else {
            return cell
        }
        cell.setup(model: model)
        return cell
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.defaultOffset = scrollView.contentOffset
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let defaultOffset = defaultOffset else {
            return
        }
        
        let currentOffset = scrollView.contentOffset
        
        if currentOffset.y > defaultOffset.y {
            print(" \(#function) isScrollingDown")
        } else {
            print(" \(#function) isScrollingUp")
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.defaultOffset = nil
    }
}
