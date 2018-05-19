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
        DeeplinkNavigator.shared.proceedToDeeplink(.Home)
        // Do any additional setup after loading the view.
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
