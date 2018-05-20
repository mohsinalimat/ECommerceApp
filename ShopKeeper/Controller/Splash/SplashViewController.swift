//
//  SplashViewController.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 17/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let manageobjectContext = CoreDataManager.coreDataManager.managedObjectContext
    let apiManager          = APIManager.apiManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiManager.setupAPIStart()
        
        // Do any additional setup after loading the view.
        if Product.count(MOC: CoreDataManager.coreDataManager.managedObjectContext) == 0{
            NotificationCenter.default.addObserver(self, selector: #selector(SplashViewController.deepLink), name: .category, object: nil)
        }else{
            self.navigate()
        }
        
    }
    @objc func deepLink(noti: Notification){
        self.navigate()
    }
    
    func navigate(){
        DispatchQueue.main.async {
            DeeplinkNavigator.shared.proceedToDeeplink(.HomeTab)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
