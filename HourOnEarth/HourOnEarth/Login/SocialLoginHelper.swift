//
//  ARSocialLoginHelper.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 31/07/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import Foundation
import GoogleSignIn
import FBSDKLoginKit
import Firebase
import CryptoKit
import AuthenticationServices

struct SocialLoginUser {
    var type: ARLoginType
    var socialID: String
    var name: String?
    var email: String?
    var phoneNumber: String?
}

class SocialLoginHelper: NSObject {
    typealias CompletionHanlder = (Bool, String, SocialLoginUser?, ARLoginType) -> Void
    static let socialLoginFailMessage = "Something went wrong with social login, please try after some time".localized()
    weak var presentingVC: UIViewController?
    var completionHandler: CompletionHanlder?
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    init(presentingVC: UIViewController) {
        self.presentingVC = presentingVC
        super.init()
        
        //setupGoogleSign()
    }
}

extension SocialLoginHelper {

    func doGoogleSignIn(completion: @escaping CompletionHanlder) {
        self.completionHandler = completion
        
        if let user = GIDSignIn.sharedInstance.currentUser {
            firebaseGoogleAuth(user: user)
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            let signInConfig = GIDConfiguration.init(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = signInConfig
            guard let pVC = presentingVC else { return }
            GIDSignIn.sharedInstance.signIn(withPresenting: pVC) { user, error in
                if error != nil {
                    print("\(error?.localizedDescription ?? "")")
                    self.completionHandler?(false, error?.localizedDescription ?? "", nil, .gmail)
                }else{
                    if let user_ = user?.user {
                        self.firebaseGoogleAuth(user: user_)
                    }
                }
            }
        }
    }

    
    func doFacebookSignIn(completion: @escaping CompletionHanlder) {
        self.completionHandler = completion
        if let accessToken = AccessToken.current, !accessToken.isExpired {
            //if the user is already logged in
            firebaseFacebookAuth(accessToken: accessToken)
        } else {
            doFacebookSignIn()
        }
    }
    
    @available(iOS 13, *)
    func doAppleSignIn(completion: @escaping CompletionHanlder) {
        self.completionHandler = completion
        startSignInWithAppleFlow()
    }
}

// MARK: - Google Sign In

extension SocialLoginHelper { //: GIDSignInDelegate {

    class var googleAccessToken: String? {
        if let user = GIDSignIn.sharedInstance.currentUser {
            return user.accessToken.tokenString//.authentication.accessToken
        }
        return nil
    }

    class func doGoogleSignOut() {
        if let _ = GIDSignIn.sharedInstance.currentUser {
            GIDSignIn.sharedInstance.signOut()
        }
    }
    
    func firebaseGoogleAuth(user: GIDGoogleUser) {
        //Firebase Google authentication
        guard let idToken = user.idToken?.tokenString else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        firebaseAuth(with: credential, loginType: .gmail)
    }

}

// MARK: - Facebook Sign In
fileprivate extension SocialLoginHelper {
    
    class func doFacebookSignOut() {
        if let _ = AccessToken.current {
            //if the user is logged in
            let loginManager = LoginManager()
            loginManager.logOut()
        }
    }
    
    //when login button clicked
    func doFacebookSignIn() {
        
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: presentingVC, handler: { result, error in
            DispatchQueue.main.async { [weak self] in
                if error != nil {
                    print("ERROR: Trying to get login results")
                    print(error?.localizedDescription ?? "")
                    self?.completionHandler?(false, error!.localizedDescription, nil, .facebook)
                } else if result?.isCancelled != nil {
                    print("The token is \(result?.token?.tokenString ?? "")")
                    if result?.token?.tokenString != nil {
                        print("Logged in")
                        if let accessToken_ = result?.token {
                            self?.firebaseFacebookAuth(accessToken: accessToken_)
                        }
                    } else {
                        print("Cancelled")
                        let message = "User cancelled login.".localized()
                        print(message)
                        self?.completionHandler?(false, message, nil, .facebook)
                    }
                }
            }
        })
    }
    
    func firebaseAuth(with credential: AuthCredential, user_name: String = "", loginType: ARLoginType) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    print(error.localizedDescription)
                    self?.completionHandler?(false, error.localizedDescription, nil, loginType)
                } else {
                    print("Login Successful")
                    if let user = authResult?.user {
                        //print(user.email)
                        //print(user.phoneNumber)
                        var userEmail = user.email
                        if userEmail == nil, let otherEmail = user.providerData.first?.email {
                            userEmail = otherEmail
                        }
                        
                        if loginType == .apple {
                            let socialUser = SocialLoginUser(type: loginType, socialID: user.uid, name: user_name, email: userEmail, phoneNumber: user.phoneNumber)
                            self?.completionHandler?(true, "", socialUser, loginType)
                        }
                        else {
                            let socialUser = SocialLoginUser(type: loginType, socialID: user.uid, name: user.displayName, email: userEmail, phoneNumber: user.phoneNumber)
                            self?.completionHandler?(true, "", socialUser, loginType)
                        }
                        
                    } else {
                        self?.completionHandler?(false, SocialLoginHelper.socialLoginFailMessage, nil, loginType)
                    }
                }
            }
        }
    }
    
    func firebaseFacebookAuth(accessToken: AccessToken) {
        //Firebase Facebook authentication
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
        firebaseAuth(with: credential, loginType: .facebook)
    }
}

// MARK: - Apple Sign In
fileprivate extension SocialLoginHelper {
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        //authorizationController.presentationContextProvider = presentingVC
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

@available(iOS 13.0, *)
extension SocialLoginHelper: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                completionHandler?(false, SocialLoginHelper.socialLoginFailMessage, nil, .apple)
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                completionHandler?(false, SocialLoginHelper.socialLoginFailMessage, nil, .apple)
                return
            }
            
            // Create an account in your system.
            let f_name = appleIDCredential.fullName?.givenName ?? ""
            let l_name = appleIDCredential.fullName?.familyName ?? ""
            let fullname = "\(f_name) \(l_name)"
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            firebaseAuth(with: credential, user_name: fullname, loginType: .apple)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
        completionHandler?(false, error.localizedDescription, nil, .apple)
    }
}

