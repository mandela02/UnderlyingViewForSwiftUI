# UnderlyingViewForSwiftUI

##### Requirements
- iOS 13.0+

To use this package, first, create a datasource

```
@State private var datasource = [GenericSection(title: "Alphabet", data: ["A", "B", "C"])]

```

Put this datasource into `UnderlyingCollectionView` 

```
UnderlyingCollectionView(data: datasource)
```

and you good to go. 

##### You can use a `SwiftUI` view in `UICollectionViewCell`

```
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
```
