
Pod::Spec.new do |spec|
  spec.name         = "FunAdsCoreKit"
  spec.version      = "0.0.3"
  spec.summary      = "A short description of FunAdsCoreKit."
  spec.homepage     = "http://EXAMPLE/FunAdsCoreKit"
  spec.license      = "MIT (example)"

  spec.author             = { "sontb" => "sontb@funtap.vn" }
  spec.platform     = :ios
  spec.source       = { :git => "https://github.com/trinhson97/FunAdsCoreKit.git", :tag => "#{spec.version}" }
  spec.source_files  = "FunAdsCoreKit/**/*.{h,m,swift}"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  spec.resources = "FunAdsCoreKit/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
  spec.swift_version = "5.0"
end
