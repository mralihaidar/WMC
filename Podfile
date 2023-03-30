# Uncomment the next line to define a global platform for your project

platform :ios, '13.0'

target 'WorldMedicalCard' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Firebase/Auth', '~> 10.1.0'
  pod 'Firebase/Crashlytics', '~> 10.1.0'
  pod 'GoogleSignIn', '~> 6.2.4'
  pod 'Lokalise', '~> 0.10.2'
  pod 'Kingfisher'
  pod 'Alamofire'
  #pod 'SPError'

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end

pre_install do |installer|
    remove_swiftui()
end
#Temp Workaround to remove swiftUI files for kingfisher lib
def remove_swiftui
  system("rm -rf ./Pods/Kingfisher/Sources/SwiftUI")
  code_file = "./Pods/Kingfisher/Sources/General/KFOptionsSetter.swift"
  code_text = File.read(code_file)
  code_text.gsub!(/#if canImport\(SwiftUI\) \&\& canImport\(Combine\)(.|\n)+#endif/,'')
  system("rm -rf " + code_file)
  aFile = File.new(code_file, 'w+')
  aFile.syswrite(code_text)
  aFile.close()
end
