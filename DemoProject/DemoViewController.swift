//
//  DemoViewController.swift
//  DemoProject
//
//  Created by george on 08/04/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit
import GNImageCollection

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
//        let urlStrings = ["https://picsum.photos/id/238/400/300", "https://picsum.photos/id/237/350/600", "https://picsum.photos/seed/picsum/500/300", "https://picsum.photos/id/236/350/600", "https://picsum.photos/id/235/350/600", "https://picsum.photos/id/234/350/600", "https://picsum.photos/id/233/350/600"]
//        let imagesCollection = GNImageCollection(urlStrings: urlStrings, imagePlaceholder: #imageLiteral(resourceName: "placeholder"), bottomImageTracker: .thumbnails) /// .dots or .none

        let images: [UIImage] = [#imageLiteral(resourceName: "rickAndMorty"), #imageLiteral(resourceName: "dog"), #imageLiteral(resourceName: "united_portrait")]
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
