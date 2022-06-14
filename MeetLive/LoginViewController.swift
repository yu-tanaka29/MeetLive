//
//  LoginViewController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/02.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mailField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.passwordField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        // Do any additional setup after loading the view.
        self.loginButton.isEnabled = false
    }
    
    // MARK: - IBAction
    
    /// ログインボタンが押されたときに呼ばれるメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // アンラップできた = 箱がある
        guard let address = self.mailField.text else{
            return
        }
        
        guard let password = self.passwordField.text else {
            return
        }
        
        // HUDで処理中を表示
        SVProgressHUD.show()

        Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
            if let error = error {
                print("DEBUG_PRINT: " + error.localizedDescription)
                SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                return
            }
            print("DEBUG_PRINT: ログインに成功しました。")
            
            // HUDを消す
            SVProgressHUD.dismiss()

            // 画面を閉じてタブ画面に戻る
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    // MARK: - Private Methods
    /// TextFieldの入力チェックを行うメソッド
    ///
    /// - Parameter sender: UITextField
    @objc private func textFieldDidChange(sender: UITextField) {
        // ログインの入力チェック
        if let address = self.mailField.text, !address.isEmpty,
           let password = self.passwordField.text, !password.isEmpty {
            
            self.loginButton.isEnabled = true
        } else {
            self.loginButton.isEnabled = false
        }
    }
}
