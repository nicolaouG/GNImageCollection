# GNImageCollection

<img src="https://img.shields.io/badge/platform-iOS-blue.svg?style=flat" alt="Platform iOS" /> <a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift5.0-compatible-4BC51D.svg?style=flat" alt="Swift 5.0 compatible" /></a> <a href="https://github.com/nicolaouG/GNImageCollection/blob/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" /></a>

Shows image(s) with zooming, saving and sharing capabilities

![](imagesCollection.gif)


## Getting started
```
platform :ios, '10.0'

pod 'GNImageCollection'
```

## How to use

You can have a look at the demo project for a simple use case.

```swift
// let images: [UIImage]
let imagesCollection = GNImageCollection(images: images)
navigationController?.pushViewController(imagesCollection, animated: true)

// or
// present(imagesCollection, animated: true, completion: nil)

// or just get the collectionView to add it as a subview anywhere
// let cv = imagesCollection.getCollectionView(self)
```
