//
//  File.swift
//  
//
//  Created by Tri Bui Q. VN.Hanoi on 16/02/2023.
//

import Foundation
import SwiftUI

public enum DirectionX {
    case horizontal
    case vertical
}

public struct UnderlyingScrollView<Content: View>: UIViewControllerRepresentable {
    private var content: () -> Content
    private var axis: DirectionX
    private var hideScrollIndicators: Bool
    private let onRefresh: (() async -> Void)?
    private let onReachBottom: (() -> Void)?
    
    @Binding
    private var shouldScrollToBottom: Bool
    
    public init(axis: DirectionX = .vertical,
                hideScrollIndicators: Bool = false,
                shouldScrollToBottom: Binding<Bool> = .constant(false),
                onRefresh: (() async -> Void)? = nil,
                onReachBottom: (() -> Void)? = nil,
                @ViewBuilder content: @escaping () -> Content) {
        
        self.content = content
        self.hideScrollIndicators = hideScrollIndicators
        self.axis = axis
        self.onRefresh = onRefresh
        self._shouldScrollToBottom = shouldScrollToBottom
        self.onReachBottom = onReachBottom
    }
    
    public func makeUIViewController(context: Context) -> UIScrollViewController<Content> {
        let vc = UIScrollViewController(rootView: self.content())
        vc.axis = axis
        vc.hideScrollIndicators = hideScrollIndicators
        vc.hideRefreshControl = onRefresh == nil
        vc.delegate = context.coordinator
        return vc
    }
    
    public func updateUIViewController(_ viewController: UIScrollViewController<Content>,
                                       context: Context) {
        viewController.hostingController.rootView = AnyView(self.content())
        if shouldScrollToBottom {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewController.scrollToBottom()
                shouldScrollToBottom = false
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(onRefresh: onRefresh,
                           onReachBottom: onReachBottom)
    }
    
    public class Coordinator: NSObject, LegacyScrollViewDelegate {
        let onRefresh: AsyncVoidCallback?
        let onReachBottom: (() -> Void)?
        
        internal init(onRefresh: AsyncVoidCallback?,
                      onReachBottom: (() -> Void)?) {
            self.onRefresh = onRefresh
            self.onReachBottom = onReachBottom
        }
        
        func didReachBottom() {
            onReachBottom?()
        }
        
        func didReachTop() {
            print("top")
        }
        
        func scrolling() {
            print("scrolling")
        }
        
        func didRefresh(sender: UIRefreshControl) {
            Task { @MainActor in
                await onRefresh?()
                sender.endRefreshing()
            }
        }
    }
}

protocol LegacyScrollViewDelegate: AnyObject {
    func didRefresh(sender: UIRefreshControl)
    func didReachBottom()
    func didReachTop()
    func scrolling()
}

public class UIScrollViewController<Content: View>: UIViewController, UIScrollViewDelegate {
    var axis: DirectionX = .horizontal
    var hideRefreshControl: Bool = false
    var hideScrollIndicators: Bool = false
    weak var delegate: LegacyScrollViewDelegate?
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.showsVerticalScrollIndicator = !hideScrollIndicators
        view.showsHorizontalScrollIndicator = !hideScrollIndicators
        return view
    }()
    
    init(rootView: Content) {
        self.hostingController = SelfSizingHostingController<Content>(rootView: rootView)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var hostingController: SelfSizingHostingController<Content>! = nil
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        makefullScreen(of: self.scrollView, to: self.view)
        
        hostingController.view.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        
        if !hideRefreshControl {
            scrollView.refreshControl = UIRefreshControl()
            scrollView.refreshControl?.addTarget(self,
                                                 action: #selector(handleRefreshControl),
                                                 for: .valueChanged)
        }
        
        hostingController.willMove(toParent: self)
        scrollView.addSubview(hostingController.view)
        makefullScreen(of: hostingController.view, to: self.scrollView)
        hostingController.didMove(toParent: self)
    }
    
    func resetConstraint() {
        hostingController.willMove(toParent: self)
        makefullScreen(of: hostingController.view, to: self.scrollView)
        hostingController.didMove(toParent: self)
    }
    
    func makefullScreen(of viewA: UIView, to viewB: UIView) {
        viewA.translatesAutoresizingMaskIntoConstraints = false
        viewB.addConstraints([
            viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor),
            viewA.trailingAnchor.constraint(equalTo: viewB.trailingAnchor),
            viewA.topAnchor.constraint(equalTo: viewB.topAnchor),
            viewA.bottomAnchor.constraint(equalTo: viewB.bottomAnchor)
        ])
    }
    
    func scrollToBottom() {
        scrollView.scrollToBottom(animated: false)
    }
    
    @objc func handleRefreshControl(sender: UIRefreshControl) {
        delegate?.didRefresh(sender: sender)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            delegate?.didReachBottom()
        }
        
        if scrollView.contentOffset.y < 0 {
            delegate?.didReachTop()
        }
        
        if scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y < (scrollView.contentSize.height - scrollView.frame.size.height) {
            delegate?.scrolling()
        }
    }
}

class SelfSizingHostingController<Content>: BaseHostingViewController<Content> where Content: View {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.invalidateIntrinsicContentSize()
    }
}

extension UIScrollView {
    func scrollToBottom(animated: Bool) {
        if self.contentSize.height < self.bounds.size.height { return }
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
        self.setContentOffset(bottomOffset, animated: animated)
    }
}

open class BaseHostingViewController<Content>: UIHostingController<AnyView> where Content: View {
    public init(shouldShowNavigationBar: Bool = false,
                rootView: Content) {
        super.init(rootView: AnyView(rootView
            .navigationBarHidden(!shouldShowNavigationBar)))
    }
    
    @objc required dynamic public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
}

