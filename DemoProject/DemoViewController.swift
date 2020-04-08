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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .white
        view.addSubview(pushButton)
        view.addSubview(presentButton)
        setupConstraints()
    }
    
    private func setupConstraints() {
        pushButton.translatesAutoresizingMaskIntoConstraints = false
        let cx = pushButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let cy = pushButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40)
        let w = pushButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        let h = pushButton.heightAnchor.constraint(equalToConstant: 50)
        [cx, cy, w, h].forEach({ $0.isActive = true })
        
        presentButton.translatesAutoresizingMaskIntoConstraints = false
        let _cx = presentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let _cy = presentButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40)
        let _w = presentButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        let _h = presentButton.heightAnchor.constraint(equalToConstant: 50)
        [_cx, _cy, _w, _h].forEach({ $0.isActive = true })
    }
    
    @objc func goToImagesCVC(_ sender: UIButton) {
        let images: [UIImage] = [#imageLiteral(resourceName: "rickAndMorty"), #imageLiteral(resourceName: "dog"), #imageLiteral(resourceName: "united_portrait")]
        let cvc = GNImageCollection(images: images)
        
        if sender == pushButton {
            navigationController?.pushViewController(cvc, animated: true)
            cvc.title = "Collection"
        } else {
            present(cvc, animated: true, completion: nil)
        }
    }
}
