Pod::Spec.new do |s|
s.name         = "DKShare"
s.version      = "3.0"
s.summary      = "for liudukun DKShare"
s.description  = "DKShare for liudukn DKShare DKShare"
s.homepage     = "https://github.com/liudukun/DKShare"
s.license      = "MIT"
s.author       = { "liudukun" => "liudukun@126.com" }
s.source       = { :git => "https://github.com/liudukun/DKShare.git", :tag => s.version }
s.ios.deployment_target = "8.0"
s.source_files = "**/*"
s.requires_arc = true
end
