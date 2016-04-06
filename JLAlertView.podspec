Pod::Spec.new do |s|
  s.name = "JLAlertView"
  s.version = "0.0.3"
  s.license = "MIT"
  s.summary = "An UIAlertView replacement with a modern chainable API, written in Swift 2.2"
  s.homepage = "https://github.com/skyline75489/JLAlertView"
  s.authors = { "Chester Liu" => "skyline75489@outlook.com" }
  s.source = { :git => "https://github.com/skyline75489/JLAlertView.git", :tag => s.version }
  s.source_files = "Classes/*"

  s.ios.deployment_target = '9.0'
end
