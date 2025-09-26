# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'HourOnEarth' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HourOnEarth

  pod 'Alamofire', '~> 5.8.1'
  pod 'AlamofireImage'
  pod 'SDWebImage'
  pod 'ViewDeck', '~> 2.4'
  pod 'Charts'
  pod 'Fabric'
  pod 'Crashlytics'
  #pod 'IGVimeoExtractor'
  pod 'SKCountryPicker'
  # add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Messaging'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'FirebasePerformance'
  pod 'Firebase/InAppMessaging'
  
  #pod 'IQKeyboardManagerSwift'#
  pod 'IQKeyboardManagerSwift', '6.3.0'
  pod 'SwiftDate'
  pod 'GoogleSignIn'
  pod 'FBSDKLoginKit'
  #pod 'razorpay-pod', '~> 1.1.6'
  pod 'MaterialShowcase'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'MKRingProgressView'
  pod 'SwiftyStoreKit'
  #pod 'MoEngage-iOS-SDK'
  #pod 'MoEngage-iOS-SDK','~>7.0'
  pod 'MKMagneticProgress'
  pod 'DropDown'
  
  pod 'ObjectMapper'
  pod "AlignedCollectionViewFlowLayout"
  
  pod 'ActiveLabel'
  pod 'lottie-ios','3.4.3  '

  pod 'Cosmos'
  pod 'razorpay-pod'
  
  #pod 'HCVimeoVideoExtractor'

  pod 'SVPinView'
  pod 'GoogleMLKit/FaceDetection'


  #MediaPipe Line
  pod 'MediaPipeTasksVision'
  
end

target 'AyuRythmClip' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_modular_headers!

  # Pods for AyuRythmClip
    pod 'Alamofire'
    pod 'AlamofireImage'
    pod 'IQKeyboardManagerSwift'
    #pod 'IGVimeoExtractor'
    pod 'SwiftyJSON', '~> 4.0'
end


  


post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end
