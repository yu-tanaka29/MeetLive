//
//  SettingViewController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/02.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var changeProfileButton: UIButton!
    @IBOutlet weak var myPostListButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // ボタンの角を丸くする
        self.changeProfileButton.layer.cornerRadius = 10
        self.myPostListButton.layer.cornerRadius = 10
        self.logoutButton.layer.cornerRadius = 10
    }
    


    // MARK: - IBAction
    /// ログアウトボタンが押された時に呼ばれるメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        // UIAlertControllerの生成
        let alert = UIAlertController(title: "ログアウト", message: "本当にログアウトしますか？", preferredStyle: .actionSheet)

        // アクションの生成
        let yesAction = UIAlertAction(title: "はい", style: .default) { action in
            // ログアウトする
            try! Auth.auth().signOut()
            // ログイン画面を表示する
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            // ログイン画面遷移
            self.present(loginViewController!, animated: true, completion: nil)
            // ログイン画面から戻ってきた時のために検索画面（index = 2）を選択している状態にしておく
            self.tabBarController?.selectedIndex = 2
            
        }

        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { action in
            print("tapped cancel")
        }

        // アクションの追加
        alert.addAction(yesAction)
        alert.addAction(cancelAction)

        // UIAlertControllerの表示
        present(alert, animated: true, completion: nil)
    }

}
