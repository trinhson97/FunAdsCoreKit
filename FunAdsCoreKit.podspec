
Pod::Spec.new do |spec|
  spec.name         = "FunAdsCoreKit"
  spec.version      = "3.3.0"
  spec.ios.deployment_target      = "10.0"
  spec.summary      = "FunAdsCoreKit suport show ads of Playfun team to all platform"
  spec.homepage     = "https://github.com/trinhson97"
  spec.license      = "MIT"
  spec.description  = <<-DESC
                    FunAdsCoreKit is a small and lightweight Swift framework that allows to monitor and being notified for network status changes in a super-easy way!
                   DESC
  spec.author             = { "sontb" => "sontb@funtap.vn" }
  spec.platform     = :ios, "10.0"
  spec.source       = { :git => "https://github.com/trinhson97/FunAdsCoreKit.git", :tag => "#{spec.version}" }
  spec.source_files  = "FunAdsCoreKit/01.Public/**/*.{swift}"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  spec.resources = "FunAdsCoreKit/**/*.{png}"
  spec.swift_version = "5.0"
end
