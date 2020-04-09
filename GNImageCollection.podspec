Pod::Spec.new do |spec|

  spec.name         = "GNImageCollection"
  spec.version      = "0.1.0"
  spec.summary      = "Shows image(s) with zooming, saving and sharing capabilities."
  spec.description  = <<-DESC
  This library can be used to show a collection view of images where they can be zoomed, saved or shared.
                   DESC
  spec.homepage     = "https://github.com/nicolaouG/GNImageCollection"
  spec.screenshots  = "https://raw.githubusercontent.com/nicolaouG/GNImageCollection/master/imagesCollection.mp4"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "george" => "georgios.nicolaou92@gmail.com" }
  spec.platform     = :ios
  spec.ios.deployment_target = "10.0"
  spec.swift_version = "5"
  spec.source       = { :git => "https://github.com/nicolaouG/GNImageCollection.git", :tag => "#{spec.version}" }
  spec.source_files = "GNImageCollection/**/*.{h,m,swift}"
  spec.framework    = "UIKit"
  spec.requires_arc = true

end
