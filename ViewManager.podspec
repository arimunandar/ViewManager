Pod::Spec.new do |spec|
  spec.name          = 'ViewManager'
  spec.version       = '1.0.0'
  spec.license       = { :type => 'MIT' }
  spec.homepage      = 'https://github.com/arimunandar/ViewManager'
  spec.authors       = { 'Ari Munandar' => 'arimunandar.dev@gmail.com' }
  spec.summary       = 'Generic UI Component for UICollectionView and UITableView'
  spec.source        = { :git => 'https://github.com/arimunandar/ViewManager.git', :tag => 'v1.0.0' }
  spec.module_name   = 'ViewManager'
  spec.swift_version = '5'
  spec.ios.deployment_target  = '12.4'
  spec.source_files       = 'ViewManager/**/*'
  spec.ios.source_files   = 'ViewManager/**/*'
  spec.ios.framework  = 'UIKit'
end
