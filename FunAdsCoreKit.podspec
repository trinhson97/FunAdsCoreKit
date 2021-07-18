
Pod::Spec.new do |spec|

  spec.name         = "FunAdsCoreKit"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of FunAdsCoreKit."
  spec.platform = :ios
  spec.ios.deployment_target = '10.0'

  spec.description  = <<-DESC
                   DESC

  spec.homepage = "http://EXAMPLE/FunAdsCoreKit"

  spec.license = = { :type => "MIT", :file => "LICENSE" }

  spec.author = { "sontb" => "sontb@funtap.vn" }

  spec.source = { :git => "https://github.com/trinhson97/FunAdsCoreKit.git", :tag => "#{spec.version}" }

  spec.source_files  = "FunAdsCoreKit/**/*.{swift}"

end
