//
//  DeeplinkNavigator.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 18/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//

import Foundation
import UIKit


class DeeplinkNavigator {
    
    static let shared = DeeplinkNavigator()
    
    lazy var homeViewController: HomeViewController = {
        let slideStoryboard = UIStoryboard(name: StoryBoard.Home.rawValue, bundle: nil)
        let homeVC = slideStoryboard.instantiateInitialViewController() as! HomeViewController
        AppDelegate.shared.window?.rootViewController = homeVC
        return homeVC
    }()
    
    private init() {
        
    }
    
    func proceedToDeeplink(_ type: DeeplinkPath) {
        switch type {
        case .Home:
            setRootView(toStoryBoard: StoryBoard.Home, initialViewControllerIdentifier: "HomeViewController")
        }
    }
    
    private func setRootView(toStoryBoard storyBoardName: StoryBoard, initialViewControllerIdentifier identifier: String) {
        let viewController = self.getViewController(toStoryBoard: storyBoardName, initialViewControllerIdentifier: identifier)
        AppDelegate.shared.window?.rootViewController = viewController
    }
    
    private func getViewController(toStoryBoard storyBoardName: StoryBoard, initialViewControllerIdentifier identifier: String) -> UIViewController {
        let storyBoard = UIStoryboard(name: storyBoardName.rawValue, bundle: nil)
        return storyBoard.instantiateViewController(withIdentifier: identifier)
    }
    
//    private func navigate(toStoryBoard storyBoardName: StoryBoard, initialViewControllerIdentifier identifier: String, style: DeeplinkPath.PresentationStyle, preferdString: Any) {
//        let viewController = self.getViewController(toStoryBoard: storyBoardName, initialViewControllerIdentifier: identifier)
//
//
//        switch style {
//        case .push:
//            if let navigationController = self.slidePanelViewController.centerViewController as? UINavigationController {
//                navigationController.pushViewController(viewController, animated: true)
//            }
//            return
//        case .center:
//
//            let navigation = UINavigationController(rootViewController: viewController)
//
//            return
//        case .present:
//
//                let navigation = UINavigationController(rootViewController: viewController)
//                navigation.delegate = navigation
//                //self.slidePanelViewController.getViewController().present(navigation, animated: true, completion: nil)
//            return
//        }
//    }
}

enum StoryBoard: String {
    case Home       = "Home"
    
}

enum DeeplinkPath {
    enum PresentationStyle {
        case push
        case center
        case present
    }
    case Home
}


