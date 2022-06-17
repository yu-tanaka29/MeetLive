//
//  TabBarController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/03.
//

import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // タブアイコンの色
        self.tabBar.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
        selectedIndex = 2
        
        // タブバーの背景色を設定
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 10, weight: .medium)]
        appearance.stackedLayoutAppearance.normal.iconColor = .white
        appearance.backgroundColor = UIColor(red: 253/255, green: 198/255, blue: 148/255, alpha: 1)
        self.tabBar.tintColor = UIColor(red: 255/255, green: 130/255, blue: 0/255, alpha: 1)
        
        self.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
           self.tabBar.scrollEdgeAppearance = appearance
        }

        // UITabBarControllerDelegateプロトコルのメソッドをこのクラスで処理する。
        self.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
        
        // currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            // ログインしていないときの処理
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
        }
    }
    
    private func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }

}
