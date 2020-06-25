//
//  DemoViewController.swift
//  DemoProject
//
//  Created by george on 08/04/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit
import GNImageCollection
import Kingfisher

class DemoViewController: UIViewController {
    lazy var pushButton: UIButton = {
        let b = UIButton()
        b.setTitle("Push images", for: .normal)
        b.addTarget(self, action: #selector(goToImagesCVC(_:)), for: .touchUpInside)
        b.backgroundColor = .darkGray
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 12
        return b
    }()
    
    lazy var presentButton: UIButton = {
        let b = UIButton()
        b.setTitle("Present images", for: .normal)
        b.addTarget(self, action: #selector(goToImagesCVC(_:)), for: .touchUpInside)
        b.backgroundColor = .darkGray
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 12
        return b
    }()
    
    lazy var subviewButton: UIButton = {
        let b = UIButton()
        b.setTitle("Add as subview", for: .normal)
        b.addTarget(self, action: #selector(goToImagesCVC(_:)), for: .touchUpInside)
        b.backgroundColor = .darkGray
        b.setTitle("Subview added", for: .disabled)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 12
        return b
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .white
        view.addSubview(pushButton)
        view.addSubview(presentButton)
        view.addSubview(subviewButton)
        setupConstraints()
    }
    
    private func setupConstraints() {
        let navBarHeight = navigationController?.navigationBar.frame.height ?? 0
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        pushButton.translatesAutoresizingMaskIntoConstraints = false
        let cx = pushButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let t = pushButton.topAnchor.constraint(equalTo: view.topAnchor, constant: navBarHeight + statusBarHeight + 20)
        let w = pushButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        let h = pushButton.heightAnchor.constraint(equalToConstant: 50)
        [cx, t, w, h].forEach({ $0.isActive = true })
        
        presentButton.translatesAutoresizingMaskIntoConstraints = false
        let _cx = presentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let _t = presentButton.topAnchor.constraint(equalTo: pushButton.bottomAnchor, constant: 30)
        let _w = presentButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        let _h = presentButton.heightAnchor.constraint(equalToConstant: 50)
        [_cx, _t, _w, _h].forEach({ $0.isActive = true })
        
        subviewButton.translatesAutoresizingMaskIntoConstraints = false
        let cx_ = subviewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let t_ = subviewButton.topAnchor.constraint(equalTo: presentButton.bottomAnchor, constant: 30)
        let w_ = subviewButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        let h_ = subviewButton.heightAnchor.constraint(equalToConstant: 50)
        [cx_, t_, h_, w_].forEach({ $0.isActive = true })
    }

    @objc func goToImagesCVC(_ sender: UIButton) {
        let urlStrings = ["https://picsum.photos/id/238/400/300", "https://picsum.photos/id/237/350/600", "https://picsum.photos/seed/picsum/500/300", "https://picsum.photos/id/236/350/600", "https://picsum.photos/id/235/350/600", "https://picsum.photos/id/234/350/600", "https://picsum.photos/id/233/350/600"]
//        let imagesCollection = GNImageCollection(urlStrings: urlStrings, imagePlaceholder: #imageLiteral(resourceName: "placeholder"), bottomImageTracker: .thumbnails) /// .dots or .none

//        let images: [UIImage] = [#imageLiteral(resourceName: "rickAndMorty"), #imageLiteral(resourceName: "dog"), #imageLiteral(resourceName: "united_portrait")]
        var images: [UIImage] = Array.init(repeating: #imageLiteral(resourceName: "placeholder"), count: urlStrings.count)
        let imagesCollection = GNImageCollection(images: images, bottomImageTracker: .thumbnails) /// .dots or .none
        imagesCollection.defaultImageTrackerColor = .red
        imagesCollection.currentImageTrackerColor = .green
        
        
        if sender == pushButton {
            navigationController?.pushViewController(imagesCollection, animated: true)
            imagesCollection.title = "Collection"
        } else if sender == presentButton {
            present(imagesCollection, animated: true, completion: nil)
        } else {
            guard let cv = imagesCollection.getCollectionView(self) else { return }
            addCollectionViewAsSubview(cv)
            sender.isEnabled = false
            sender.alpha = 0.8
        }
        
        
        // update each row as soon as its image is downloaded
        // bottomTrackerCollectionView needs updating only when .thumbnails is used
        setImagesWithKingfisher(imagesCollection, urlStrings, nil, { (index, image) in
            guard index < imagesCollection.images?.count ?? 0,
                index < imagesCollection.bottomTrackerCollectionView.numberOfItems(inSection: 0),
                index < imagesCollection.collectionView.numberOfItems(inSection: 0)
                else { return }
            imagesCollection.images?[index] = image
            let trackerCell = imagesCollection.bottomTrackerCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? GNTrackerCollectionViewCell
            let mainCell = imagesCollection.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? GNImageCollectionViewCell
            if trackerCell?.imageView.image != nil {
                imagesCollection.bottomTrackerCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
            if mainCell?.image != nil {
                imagesCollection.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }, nil)
        
        // or reload once all of them are downloaded
//        setImagesWithKingfisher(imagesCollection, urlStrings, images) { (downloadedImages) in
//            imagesCollection.images = downloadedImages
//            imagesCollection.bottomTrackerCollectionView.reloadData()
//            imagesCollection.collectionView.reloadData()
//        }
    }
    
    func setImagesWithKingfisher(_ imagesCollection: GNImageCollection, _ links: [String], _ images: [UIImage]? = nil, _ onDownloadImage: ((_ index: Int, _ image: UIImage) -> Void)? = nil, _ completion: ((_ downloadedImages: [UIImage]) -> Void)? = nil) {
        var images = images ?? []
        var total = 0
        for (i, link) in links.enumerated() {
            guard let url = URL(string: link) else {
                total += 1
                if total == links.count {
                    completion?(images)
                }
                continue
            }
            KingfisherManager.shared.retrieveImage(with: url) { result in
                total += 1
                switch result {
                case .success(let value):
                    if images.count > i {
                        images[i] = value.image
                    }
                    onDownloadImage?(i, value.image)
                case .failure(_):
                    break
                }
                if total == links.count {
                    completion?(images)
                }
            }
        }
    }
    
    func addCollectionViewAsSubview(_ cv: UIView) {
        view.addSubview(cv)
        cv.clipsToBounds = true
        cv.contentMode = .scaleAspectFit
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        let b = cv.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let t = cv.topAnchor.constraint(equalTo: subviewButton.bottomAnchor, constant: 30)
        let l = cv.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let r = cv.widthAnchor.constraint(equalToConstant: 200)
        [b, l, r, t].forEach({ $0.isActive = true })
        
//        cv.layoutIfNeeded()
    }
}
