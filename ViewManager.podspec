Pod::Spec.new do |spec|

  spec.name         = "ViewManager"
  spec.version      = "1.0.3"
  spec.summary      = "A CocoaPods library written in Swift"

  spec.description  = "This CocoaPods library helps you perform navigation."

  spec.homepage     = "https://github.com/arimunandar/ViewManager"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Ari Munandar" => "arimunandar.dev@gmail.com" }

  spec.ios.deployment_target = "12.4"
  spec.swift_version = "5.0"

  spec.source        = { :git => "https://github.com/arimunandar/ViewManager.git", :tag => "#{spec.version}" }
  spec.source_files  = "ViewManager/**/*.{h,m,swift}"

  spec.frameworks = 'UIKit'
end
