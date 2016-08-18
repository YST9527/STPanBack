Pod::Spec.new do |s|
  s.name         = "STLoadingAlert"
  s.version      = "0.0.1"
  s.summary      = "A simple to the classification of the navigation bar to add sliding back gesture."
  s.homepage     = "https://github.com/YST9527/STLoadingAlert"
  s.license      = "MIT"
  s.author       = { "尹思同" => "yinsitong9527@163.com" }
  s.source       = { :git => "https://github.com/YST9527/STPanBack.git", :tag => s.version}
  s.source_files = "UINavigationController+STTransitioning/*"
  s.requires_arc = true
  s.platform     = :ios, '7.0'

end
