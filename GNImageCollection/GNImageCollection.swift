//
//  GNImageCollection.swift
//  GNImageCollection
//
//  Created by george on 08/04/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit

public class GNImageCollection: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    enum Identifiers: String {
        case cell = "ImageZoomCell"
        case removeAction = "Remove"
        case shareAction = "Share"
        case saveAction = "Save"
        case rotateAction = "Rotate"
        case alertErrorTitle = "Error"
        case alertOkAction = "OK"
        case alertCancelAction = "Cancel"
    }
    
    public var images: [UIImage]? {
        didSet {
            addImagesTracker()
        }
    }
    
    private var textColor: UIColor {
        get {
            if #available(iOS 13.0, *) {
                return UIColor.label
            } else {
                return UIColor.black
            }
        }
    }

    private var backgroundColor: UIColor {
        get {
            if #available(iOS 13.0, *) {
                return UIColor.systemBackground
            } else {
                return UIColor.white
            }
        }
    }

    private lazy var emptyMessageLabel: UILabel = {
        let l = UILabel(frame: CGRect(x: 20, y: 20, width: collectionView.frame.width - 40, height: collectionView.frame.height - 40))
        l.numberOfLines = 0
        l.textColor = textColor
        l.textAlignment = .center
        l.font = UIFont(name: "TrebuchetMS", size: 16)
        return l
    }()
    
    private lazy var closeButtonLeftConstraint = NSLayoutConstraint(item: closeButton, attribute: .leading, relatedBy: .equal, toItem: collectionView, attribute: .leading, multiplier: 1, constant: 20)
    
    private lazy var closeButton: UIButton = {
        let b = UIButton()
        b.setTitle("Close", for: .normal)
        b.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        b.setTitleColor(textColor, for: .normal)
        b.contentEdgeInsets = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6)
        return b
    }()
    
    private lazy var imagesTrackerStack: UIStackView = {
        let s = UIStackView()
        s.alignment = .center
        s.axis = .horizontal
        s.distribution = .equalSpacing
        s.spacing = trackerSize - 2
        return s
    }()
    
    private lazy var currentImageTracker: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBlue
        return v
    }()
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let g = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        return g
    }()

    private let flowLayout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .horizontal
        l.minimumInteritemSpacing = 0
        l.minimumLineSpacing = 0
        return l
    }()
    
    public var currentImageTrackerColor: UIColor = .systemBlue {
        didSet {
            currentImageTracker.backgroundColor = currentImageTrackerColor
        }
    }
    
    public var defaultImageTrackerColor: UIColor = .systemGray {
        didSet {
            currentImageTracker.backgroundColor = defaultImageTrackerColor
        }
    }
    
    public var shouldTrackImages: Bool = true {
        didSet {
            currentImageTracker.isHidden = shouldTrackImages
        }
    }
    
    private let trackerSize: CGFloat = 8
    
    
    public init(images: [UIImage]) {
        self.images = images
        super.init(collectionViewLayout: flowLayout)
        collectionView.isPagingEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = backgroundColor
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: Identifiers.cell.rawValue)
        flowLayout.itemSize = collectionCellSize()
        addImagesTracker()
        
        if #available(iOS 13.0, *) { }
        else {
            view.addGestureRecognizer(longPressGesture)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { /// wait for the navBar / tabBar to load (if any)
            if self.isModal {
                self.addCloseButton()
            }
        }
    }
            
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let index = indexOfVisibleItem()
        coordinator.animate(alongsideTransition: { _ in
            self.flowLayout.invalidateLayout()
            let ip = IndexPath(item: index, section: 0)
            self.collectionView.scrollToItem(at: ip, at: .centeredHorizontally, animated: false)
            ((self.collectionView.cellForItem(at: ip) as? ImageCollectionViewCell)?.zoomView)?.setupImageViewContentMode()
            ((self.collectionView.cellForItem(at: ip) as? ImageCollectionViewCell)?.zoomView)?.setZoomScale(1, animated: false)
        }, completion: { _ in })
    }
    
    
        
    private func addCloseButton() {
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        let t = closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
        let l = closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20)
        [t, l].forEach({ $0.isActive = true })
        
        addBlurBackground(to: closeButton)
    }
    
    private func addImagesTracker() {
        guard (images?.count ?? 0) > 1 else {
            imagesTrackerStack.isHidden = true
            return
        }
        
        if !view.subviews.contains(imagesTrackerStack) {
            view.addSubview(imagesTrackerStack)

            imagesTrackerStack.translatesAutoresizingMaskIntoConstraints = false
            let w = imagesTrackerStack.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -40)
            let h = imagesTrackerStack.heightAnchor.constraint(equalToConstant: 20)
            let b = imagesTrackerStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
            let cx = imagesTrackerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            [w, b, h, cx].forEach({ $0.isActive = true })

            addBlurBackground(to: imagesTrackerStack)
        }
        
        setupStackArrangedSubviews()
    }
    
    private func setupStackArrangedSubviews() {
        let selectedSubviewIndex = indexOfVisibleItem()
        let areTooManyImages = areTooManySubviews()
        imagesTrackerStack.spacing = areTooManyImages ? trackerSize / 2 : trackerSize - 2
        
        /// clear and fill in the stack from scratch
        imagesTrackerStack.arrangedSubviews.forEach({
            $0.removeFromSuperview()
        })
        for _ in 0..<(images?.count ?? 0) {
            let v = UIView()
            if areTooManyImages {
                v.heightAnchor.constraint(equalToConstant: trackerSize / 2).isActive = true
                v.widthAnchor.constraint(equalToConstant: trackerSize / 2).isActive = true
                v.layer.cornerRadius = trackerSize / 4
            } else {
                v.heightAnchor.constraint(equalToConstant: trackerSize).isActive = true
                v.widthAnchor.constraint(equalToConstant: trackerSize).isActive = true
                v.layer.cornerRadius = trackerSize / 2
            }
            v.backgroundColor = defaultImageTrackerColor
            imagesTrackerStack.addArrangedSubview(v)
        }
        
        /// color current image tracker
        if imagesTrackerStack.arrangedSubviews.count > selectedSubviewIndex + 1 {
            imagesTrackerStack.arrangedSubviews[selectedSubviewIndex].backgroundColor = currentImageTrackerColor
        } else {
            imagesTrackerStack.arrangedSubviews.last?.backgroundColor = currentImageTrackerColor
        }
    }
    
    private func areTooManySubviews() -> Bool {
        let screenWidth = Int(view.bounds.width)
        let numOfImages = images?.count ?? 0
        let stackWidth = numOfImages * Int(trackerSize) + (numOfImages - 1) * Int(imagesTrackerStack.spacing)
        return stackWidth > screenWidth - 40
    }
    
    private func addBlurBackground(to v: UIView) {
        v.backgroundColor = .clear
        let blurStyle: UIBlurEffect.Style
        if #available(iOS 13.0, *) {
            blurStyle = .systemUltraThinMaterial
        } else {
            blurStyle = .extraLight
        }
        let blurEffect = UIBlurEffect(style: blurStyle)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.isUserInteractionEnabled = false
        v.insertSubview(effectView, at: 0)

        effectView.layer.cornerRadius = 8
        effectView.clipsToBounds = true
        effectView.translatesAutoresizingMaskIntoConstraints = false
        let cx = effectView.centerYAnchor.constraint(equalTo: v.centerYAnchor)
        let cy = effectView.centerXAnchor.constraint(equalTo: v.centerXAnchor)
        let w = effectView.widthAnchor.constraint(equalTo: v.widthAnchor)
        let h = effectView.heightAnchor.constraint(equalTo: v.heightAnchor)
        [cx, cy, w, h].forEach({ $0.isActive = true })
    }
    
    @objc private func closeButtonClicked() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func longPressAction() {
        let index = indexOfVisibleItem()
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell,
            let image = cell.zoomView.imageView.image else { return }

        let alert = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        let save = UIAlertAction(title: Identifiers.saveAction.rawValue, style: .default) { _ in
            self.saveAction(image)
        }
        let share = UIAlertAction(title: Identifiers.shareAction.rawValue, style: .default) { _ in
            self.shareAction(image)
        }
        let remove = UIAlertAction(title: Identifiers.removeAction.rawValue, style: .destructive) { _ in
            self.removeAction(index)
        }
        let cancel = UIAlertAction(title: Identifiers.alertCancelAction.rawValue, style: .cancel) { _ in }
        [save, share, remove, cancel].forEach({ alert.addAction($0) })
        present(alert, animated: true, completion: nil)
    }
    
    private func setEmptyMessage(_ message: String) {
        emptyMessageLabel.text = message
        collectionView.backgroundView = emptyMessageLabel
    }
    
    private func indexOfVisibleItem() -> Int {
        guard collectionView != nil else { return 0 }
        let itemWidth = collectionCellSize().width
        let offset = collectionView.contentOffset.x / itemWidth
        let index = Int(round(offset))
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let safeIndex = max(0, min(numberOfItems - 1, index))
        return safeIndex
    }

    
    
    override public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for (i, subV) in imagesTrackerStack.arrangedSubviews.enumerated() {
            if i == indexOfVisibleItem() {
                subV.backgroundColor = currentImageTrackerColor
            } else {
                subV.backgroundColor = defaultImageTrackerColor
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if images == nil {
            setEmptyMessage("Image not found")
        } else if images?.count ?? 0 == 0 {
            setEmptyMessage("No image to display")
        }
        return 1
    }


    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }

    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.cell.rawValue, for: indexPath) as? ImageCollectionViewCell
        if cell == nil {
            cell = ImageCollectionViewCell()
        }

        if indexPath.item < images?.count ?? 0 {
            cell?.image = images?[indexPath.item]
        }
        return cell ?? ImageCollectionViewCell()
    }
    
    override public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ImageCollectionViewCell {
            cell.zoomView.setZoomScale(1, animated: false)
        }
    }

    // MARK: UICollectionViewDelegate
    
    override public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    

    override public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    // MARK: FlowLayoutDelegate
        
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionCellSize()
    }
    
    public func collectionCellSize() -> CGSize {
        var h = collectionView.frame.height
        var w = collectionView.frame.width
        if #available(iOS 11.0, *) {
            h = collectionView.safeAreaLayoutGuide.layoutFrame.height
            w = collectionView.safeAreaLayoutGuide.layoutFrame.width
        }

        if let sectionInset = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset {
            w -= sectionInset.left + sectionInset.right + collectionView.contentInset.left + collectionView.contentInset.right
            h -= sectionInset.top + sectionInset.bottom + collectionView.contentInset.top + collectionView.contentInset.bottom
        }
        
        return CGSize(width: w, height: h)
    }
}



// MARK: - Context Menu

extension GNImageCollection {
    @available(iOS 13.0, *)
    override public func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return contextMenu(for: indexPath)
    }
    
    @available(iOS 13.0, *)
    private func contextMenu(for indexPath: IndexPath) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: "\(indexPath.item)" as NSCopying, previewProvider: {
            return self.contextMenuPreviewVC(for: indexPath)
        }, actionProvider: { _ in
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell,
                let image = cell.zoomView.imageView.image else { return nil }

            let save = UIAction(title: Identifiers.saveAction.rawValue, image: UIImage(systemName: "tray.and.arrow.down"), identifier: UIAction.Identifier(rawValue: Identifiers.saveAction.rawValue)) { _ in
                self.saveAction(image)
            }
            let share = UIAction(title: Identifiers.shareAction.rawValue, image: UIImage(systemName: "square.and.arrow.up"), identifier: UIAction.Identifier(rawValue: Identifiers.shareAction.rawValue)) { _ in
                self.shareAction(image)
            }
            let remove = UIAction(title: Identifiers.removeAction.rawValue, image: UIImage(systemName: "trash"), identifier: UIAction.Identifier(rawValue: Identifiers.removeAction.rawValue), discoverabilityTitle: nil, attributes: .destructive, handler: { _ in
                self.removeAction(indexPath.item)
            })
//            let editMenu = UIMenu(title: "Edit...", children: [rotate, delete])
            return UIMenu(title: "Options", image: nil, identifier: nil, children: [save, share, remove])
        })
        return configuration
    }
    
    private func contextMenuPreviewVC(for indexPath: IndexPath) -> UIViewController? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else { return nil }
        let vc = UIViewController()
        let iv = UIImageView()
        let maxWidth = UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width * 0.5 : UIScreen.main.bounds.width * 0.8
        let maxHeight = UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.height * 0.5 : UIScreen.main.bounds.height * 0.5
        iv.frame = CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)
        iv.image = cell.zoomView.imageView.image
        iv.contentMode = .scaleAspectFit

        let desiredSize = iv.aspectFitSize
        iv.frame.size = desiredSize
        vc.view = iv
        vc.preferredContentSize = desiredSize
        return vc
    }
    
    private func saveAction(_ image: UIImage) {
        /// PList -> Privacy - Photo Library Additions Usage Description
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let err = error {
            let ac = UIAlertController(title: Identifiers.alertErrorTitle.rawValue, message: err.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: Identifiers.alertOkAction.rawValue, style: .default))
            present(ac, animated: true)
        }
    }
    
    private func shareAction(_ image: UIImage) {
        /// PList -> Privacy - Photo Library Additions Usage Description
        let activityvc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        ///activityvc.excludedActivityTypes = [.saveToCameraRoll]
        activityvc.popoverPresentationController?.sourceView = collectionView /// for ipads
        present(activityvc, animated: true, completion: nil)
    }
    
    private func removeAction(_ index: Int) {
        guard index < (images?.count ?? 0) else { return }
        images?.remove(at: index)
        collectionView.reloadData()
    }
}




// MARK: - ImageCollectionViewCell

class ImageCollectionViewCell: UICollectionViewCell {
    lazy var zoomView: ImageZoomView = {
        let iv = ImageZoomView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    var image: UIImage? {
        didSet {
            if let img = image {
                zoomView.image = img
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        zoomView.setZoomScale(1, animated: false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init(image: UIImage) {
        self.init()
        self.image = image
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(zoomView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        zoomView.translatesAutoresizingMaskIntoConstraints = false
        let l = zoomView.leftAnchor.constraint(equalTo: leftAnchor)
        let r = zoomView.rightAnchor.constraint(equalTo: rightAnchor)
        let t = zoomView.topAnchor.constraint(equalTo: topAnchor)
        let b = zoomView.bottomAnchor.constraint(equalTo: bottomAnchor)
        [l, r, t, b].forEach({ $0.isActive = true })
    }
}



// MARK: - ImageZoomView

class ImageZoomView: UIScrollView, UIScrollViewDelegate {
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private lazy var doubleTapToZoomGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = 2
        gesture.addTarget(self, action: #selector(doubleTapped))
        return gesture
    }()
    
    public var image: UIImage? {
        didSet {
            if let img = image {
                imageView.image = img
                setupImageViewContentMode()
            }
        }
    }
    
    func setupImageViewContentMode() {
        layoutIfNeeded()
        if (image?.size.width ?? 0) >= bounds.width || (image?.size.height ?? 0) >= bounds.height {
            imageView.contentMode = .scaleAspectFit
        } else {
            imageView.contentMode = .center
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init(frame: CGRect = .zero, image: UIImage) {
        self.init()
        self.image = image
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(imageView)
        setupConstraints()
        
        delegate = self
        minimumZoomScale = 1
        maximumZoomScale = 5
        addGestureRecognizer(doubleTapToZoomGesture)
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let w = imageView.widthAnchor.constraint(equalTo: widthAnchor)
        let h = imageView.heightAnchor.constraint(equalTo: heightAnchor)
        let cx = imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        let cy = imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        [w, h, cx, cy].forEach({ $0.isActive = true })
        
        if image != nil {
            setupImageViewContentMode()
        }
    }
    
    @objc private func doubleTapped() {
        if zoomScale == 1 {
            zoom(to: zoomRectForScale(2, center: doubleTapToZoomGesture.location(in: doubleTapToZoomGesture.view)), animated: true)
        } else {
            setZoomScale(1, animated: true)
        }
    }
    
    private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        let newCenter = convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}




// MARK: - Usefull extensions

extension UIViewController {
    public var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}

extension UIImageView {
    /// Find the size of the image, once the parent imageView has been given a contentMode of .scaleAspectFit
    /// Querying the image.size returns the non-scaled size. This helper property is needed for accurate results.
    public var aspectFitSize: CGSize {
        guard let image = image else { return CGSize.zero }

        var aspectFitSize = CGSize(width: frame.size.width, height: frame.size.height)
        let newWidth: CGFloat = frame.size.width / image.size.width
        let newHeight: CGFloat = frame.size.height / image.size.height

        if newHeight < newWidth {
            aspectFitSize.width = newHeight * image.size.width
        } else if newWidth < newHeight {
            aspectFitSize.height = newWidth * image.size.height
        }

        return aspectFitSize
    }
}

