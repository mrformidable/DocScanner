//
//  MainTabBarViewController.swift
//  DocReader
//
//  Created by Michael A on 2018-02-18.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

private let storyboardIdentifier = "CameraNavigationController"

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let micNavigationController = mainStoryBoard.instantiateViewController(withIdentifier: "RecordNavigationViewController") as! UINavigationController
        micNavigationController.tabBarItem.image = #imageLiteral(resourceName: "microphone_filled")
        micNavigationController.tabBarItem.selectedImage = #imageLiteral(resourceName: "microphone_filled")
        micNavigationController.tabBarItem.title = "Record"
        
        let storyboard = UIStoryboard(name: "CameraControls", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "CameraNavigationController") as! UINavigationController
        navigationController.tabBarItem.image = #imageLiteral(resourceName: "camera_icon")
        navigationController.tabBarItem.selectedImage = #imageLiteral(resourceName: "camera_icon")
        navigationController.tabBarItem.title = "Scan"
        
        let searchViewController = mainStoryBoard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        searchViewController.tabBarItem.image = #imageLiteral(resourceName: "search_unfilled")
        searchViewController.tabBarItem.selectedImage = #imageLiteral(resourceName: "search_filled")
        searchViewController.tabBarItem.title = "Search"
        
        viewControllers?.insert(micNavigationController, at: 1)
        viewControllers?.insert(navigationController, at: 2)
        viewControllers?.insert(searchViewController, at: 3)

    }
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.index(of: viewController)
        
        if index == 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let micNavigationController = storyboard.instantiateViewController(withIdentifier: "RecordNavigationViewController") as! UINavigationController
            tabBarController.present(micNavigationController, animated: true, completion: nil)
            return false
        }
        
        if index == 2 {
            let storyboard = UIStoryboard(name: "CameraControls", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "CameraNavigationController") as! UINavigationController
            tabBarController.present(navigationController, animated: true, completion: nil)
            return false
        }
        
        if index == 3 {
            let pickerController = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .open)
            pickerController.delegate = self
            present(pickerController, animated: true, completion: nil)
            return false
        }
        
        return true
    }
}


extension MainTabBarViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
    }
}



