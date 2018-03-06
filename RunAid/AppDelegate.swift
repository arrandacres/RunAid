    //
    //  AppDelegate.swift
    //  RunAid
    //
    //  Created by Arran Dacres on 21/02/2018.
    //  Copyright © 2018 Arran Dacres. All rights reserved.
    //
    
    import UIKit
    import AWSCore
    import AWSCognitoIdentityProvider
    
    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
        
        var window: UIWindow?
        var loginViewController: LoginViewController?
        var navigationController: UINavigationController?
        var storyboard: UIStoryboard?{
            return UIStoryboard(name: "Main", bundle: nil)
        }
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
            
            //AWS Cognito Configuration Strings
            let poolId:String = "eu-west-2_Nj6df2yGj"
            let clientId:String = "3c6o4hj15fcf4ch54acgig301"
            let clientSecret:String = "vvt7qvaihfavj3hc7v6ksqmq4triho4osqnrriubs22cspeo7o2"
            let region:AWSRegionType = .EUWest2
            
            //Registering with AWS Cognito using configuration strings
            let serviceConfiguration:AWSServiceConfiguration = AWSServiceConfiguration(region: region, credentialsProvider: nil)
            let cognitoConfiguration:AWSCognitoIdentityUserPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: clientId, clientSecret: clientSecret, poolId: poolId)
            AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: cognitoConfiguration, forKey: "runaid_userpool_MOBILEHUB_56721510")
            let pool:AWSCognitoIdentityUserPool = AWSCognitoIdentityUserPool(forKey: "runaid_userpool_MOBILEHUB_56721510")
            pool.delegate = self
            
            return true
        }
        
        class func getUserPool() -> AWSCognitoIdentityUserPool {
            return AWSCognitoIdentityUserPool(forKey: "runaid_userpool_MOBILEHUB_56721510")
        }
    }
    
    extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {
        
        //startPasswordAuthentication called by AWS - returns custom Login View
        func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
            
            self.navigationController = nil
            self.loginViewController = nil
            
            //Sets up NavigationController and LoginViewController
            if(self.navigationController == nil) {
                self.navigationController = self.window?.rootViewController as? UINavigationController
            }
            
            if(self.loginViewController == nil) {
                self.loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
            }
            
            //if Login View isnt displayed - then display it
            DispatchQueue.main.async {
                if(self.loginViewController!.isViewLoaded || self.loginViewController!.view.window == nil) {
                    self.navigationController?.present(self.loginViewController!, animated: true, completion: nil)
                }
            }
            
            return self.loginViewController!
        }
        
    }
