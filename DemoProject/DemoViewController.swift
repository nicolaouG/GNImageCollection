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
        let images: [UIImage] = [#imageLiteral(resourceName: "rickAndMorty"), #imageLiteral(resourceName: "dog"), #imageLiteral(resourceName: "united_portrait")]
        let imagesCollection = GNImageCollection(images: images)

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
        cv.translatesAutoresizingMaskIntoConstraints = false
        let b = cv.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let t = cv.topAnchor.constraint(equalTo: subviewButton.bottomAnchor, constant: 30)
        let l = cv.leftAnchor.constraint(equalTo: view.leftAnchor)
        let r = cv.rightAnchor.constraint(equalTo: view.rightAnchor)
        [b, l, r, t].forEach({ $0.isActive = true })
        cv.layoutIfNeeded()
    }
}
