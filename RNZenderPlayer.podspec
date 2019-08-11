Pod::Spec.new do |s|
  s.name         = "RNZenderPlayer"
  s.version      = "2.5.0"
  s.summary      = "React Native wrapper around the Zender Player"
  s.description  = <<-DESC
                  RNZenderPlayer
                   DESC
  s.homepage     = "https://zender.tv"
  s.license       = { :type => "Proprietary", :text => <<-LICENSE
          Copyright 2019 Small Town Heroes BVBA.
          Confidential and Proprietary. All rights reserved.
        LICENSE
      }

  s.author             = { "Zender Team" => "hello@zender.tv" }
  s.platform     = :ios, "9.0"
  s.requires_arc = true
  s.source       = { :git => "https://github.com/zendertv/react-native-zender.git", :tag => "master" }
  s.source_files  = "ios/**/*.{h,m}"

  s.dependency "React"
  s.dependency "Zender", '2.4.0'

end

