//
//  RegistUserViewController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/02.
//

import UIKit
import Firebase
import SVProgressHUD

class RegistUserViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var registButton: UIButton!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mailField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.passwordField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.nameField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        // Do any additional setup after loading the view.
        self.registButton.isEnabled = false
    }
    
    // MARK: - IBAction
    
    /// 新規登録ボタンが押されたときに呼ばれるメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func registButtonTapped(_ sender: UIButton) {
        guard let address = self.mailField.text else {
            return
        }
        
        guard let password = self.passwordField.text else {
            return
        }
        
        guard let name = self.nameField.text else {
            return
        }
        
        // HUDで処理中を表示
        SVProgressHUD.show()
            
        // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
        Auth.auth().createUser(withEmail: address, password: password) { authResult, error in
            if let error = error {
                // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                print("DEBUG_PRINT: " + error.localizedDescription)
                SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
                return
            }
            print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
            // 表示名を設定する
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest() // リクエスト作成
                changeRequest.displayName = name // リクエスト内容を入れる
                changeRequest.commitChanges { error in // リクエスト送信
                    if let error = error {
                        // プロフィールの更新でエラーが発生
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました。")
                        return
                    }
                    print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                    
                    // usersコレクションにドキュメント追加
                    let postRef = Firestore.firestore().collection(Const.UserPath).document(user.uid) // 投稿場所
                    let postDic = [
                        "name": name, // 表示名
                        "date": FieldValue.serverTimestamp(), // 更新時刻
                        "imageFlg": 0,
                        ] as [String : Any]
                    postRef.setData(postDic) // 追加
                }
                
                // HUDを消す
                SVProgressHUD.dismiss()
                // 画面を閉じてタブ画面に戻る
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// TextFieldの入力チェックを行うメソッド
    ///
    /// - Parameter sender: UITextField
    @objc private func textFieldDidChange(sender: UITextField) {
        // アカウント作成の入力チェック
        if let address = self.mailField.text, !address.isEmpty,
           let password = self.passwordField.text, password.count >= 6,
           let name = self.nameField.text, !name.isEmpty {
            
            self.registButton.isEnabled = true
        } else {
            self.registButton.isEnabled = false
        }
    }
    
}
