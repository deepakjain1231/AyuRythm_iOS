//
//  SceneDelegate.swift
//  AyuRythmClip
//
//  Created by Paresh Dafda on 24/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        //guard let windowScene = (scene as? UIWindowScene) else { return }
        guard let _ = (scene as? UIWindowScene) else { return }
        
        //self.window = UIWindow(windowScene: windowScene)
        kSharedAppDelegate.window = self.window
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // Get URL components from the incoming user activity
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
              let path = components.path else { return }
        
        print(incomingURL)
        print(path)
        //show after delay b'coz without that getting "Unbalanced calls to begin/end appearance transitions" warning
        let delay = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.presentExperience(for: path)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

extension SceneDelegate {
    func presentExperience(for path: String) {
        // Route user to the appropriate place in your App Clip.
        if path == "/sparshnatest" {
            //show sparshna test flow
            print("Show user detail pickup screen")
            showGuestLoginScreen()
        }
    }
    
    func showInitialScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let rootVC = storyboard.instantiateViewController(identifier: "VC2") as? UIViewController else {
            print("ViewController not found")
            return
        }
        let rootNC = UINavigationController(rootViewController: rootVC)
        self.window?.rootViewController = rootNC
        self.window?.makeKeyAndVisible()
    }
    
    func showGuestLoginScreen() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let navController = storyBoard.instantiateViewController(withIdentifier: "HomeNVC") as? UINavigationController else {
            return
        }
        
        if let objInstructions = navController.viewControllers.first as? ClipMeasurementsViewController {
            objInstructions.isFromTryAsGuest = true
        }
        navController.interactivePopGestureRecognizer?.isEnabled = true
        //navController.interactivePopGestureRecognizer?.delegate = self
        //navController.isNavigationBarHidden = true
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
}

