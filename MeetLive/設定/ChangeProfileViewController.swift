//
//  ChangeProfileViewController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/03.
//

import UIKit
import Firebase
import SVProgressHUD
import FirebaseStorageUI

class ChangeProfileViewController: UIViewController {
    // MARK: - IBOutlet
    // プロフィール画像関連
    @IBOutlet weak var Profileimage: UIImageView!
    @IBOutlet weak var imageChangeButton: UIButton!
    // 個人情報関連
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var PersonalChangeButton: UIButton!
    // グループ・推しメン関連
    @IBOutlet weak var groupField: UITextField!
    @IBOutlet weak var memberField: UITextField!
    @IBOutlet weak var addGroupButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - メンバ変数
    var userArray: UserData?
    var pickerView: UIPickerView = UIPickerView()
    let gender = ["男性", "女性"]
    // Firestoreのリスナーの定義
    var listener: ListenerRegistration?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageChangeButton.layer.cornerRadius = 28
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.nameField.delegate = self
        self.ageField.delegate = self
        self.groupField.delegate = self
        self.memberField.delegate = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "FavoriteGroupTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "GroupCell")
        
        self.groupField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.memberField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // ピッカー設定
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        // インプットビュー設定
        self.genderField.inputView = self.pickerView
        self.genderField.inputAccessoryView = toolbar
        
        // ボタンの角を丸くする
        self.PersonalChangeButton.layer.cornerRadius = 10
        self.addGroupButton.isEnabled = false
        self.addGroupButton.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
        self.addGroupButton.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        // ログイン済みか確認
        if let user = Auth.auth().currentUser {
            // listenerを登録して投稿データの更新を監視する
            // 最初はデータを全て読み込み、その後はFirestoreの更新を監視し、更新があるたびに実行
            let userRef = Firestore.firestore().collection(Const.UserPath).document(user.uid)// 情報を取得する場所を決定
            self.listener = userRef.addSnapshotListener() { (querySnapshot, error) in // 情報取得
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                self.userArray = UserData(document: (querySnapshot.self)!, num: 0)
                
                self.nameField.text = self.userArray?.name
                self.genderField.text = self.userArray?.gender
                self.ageField.text = self.userArray?.age
                
                // 画像の表示
                // CloudStorageから画像をダウンロードしている間、ダウンロード中であることを示すインジケーターを表示する指定
                // ぐるぐる回るようなやつ
                if self.userArray?.imageFlg == 1 {
                    self.Profileimage.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    // 取ってくる画像の場所を指定
                    let imageRef = Storage.storage().reference().child(Const.ImagePath).child(self.userArray!.id + ".jpg")
                    // 画像をダウンロードして表示(sd_setimage)
                    self.Profileimage.sd_setImage(with: imageRef)
                    self.Profileimage.backgroundColor = .white
                }
                // TableViewの表示を更新する
                self.tableView.reloadData()
            }
        }
        
    }
    
    // MARK: - IBAction
    /// 画像選択ボタンがタップされた時に呼ばれるメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        // UIAlertControllerの生成
        let alert = UIAlertController(title: "カメラ/フォトライブラリの選択", message: "カメラかフォトライブラリどちらを使用するか選択してください。", preferredStyle: .actionSheet)
        
        // カメラアクション
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { action in
            // カメラを指定してピッカーを開く
            if UIImagePickerController.isSourceTypeAvailable(.camera) { // 利用可能かどうかを確かめるメソッド
                let pickerController = UIImagePickerController() // インスタンス生成
                pickerController.delegate = self
                pickerController.sourceType = .camera // 移動先をカメラに指定
                self.present(pickerController, animated: true, completion: nil) // 画面遷移
            }
        }
        // ライブラリアクション
        let libraryAction = UIAlertAction(title: "フォトライブラリ", style: .default) { action in
            // ライブラリ（カメラロール）を指定してピッカーを開く
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) { // 利用可能かどうかを確かめるメソッド
                let pickerController = UIImagePickerController() // インスタンス生成
                pickerController.delegate = self
                pickerController.sourceType = .photoLibrary // 移動先をフォトライブラリに指定
                self.present(pickerController, animated: true, completion: nil) // 画面遷移
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { action in
            print("tapped cancel")
        }
        
        // アクションの追加
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)

        // UIAlertControllerの表示
        present(alert, animated: true, completion: nil)
    }
    
    /// 個人情報変更ボタンがタップされた時に呼ばれるメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func changeProfileButtonTapped(_ sender: UIButton) {
        if let name = self.nameField.text, let gender = self.genderField.text, let age = self.ageField.text {
            var value: [String: String] = [:]
            
            if !name.isEmpty {
                value.updateValue(name, forKey: "name")
            }
            if !age.isEmpty {
                value.updateValue(age, forKey: "age")
            }
            if !gender.isEmpty {
                value.updateValue(gender, forKey: "gender")
            }
            
            let postRef = Firestore.firestore().collection(Const.UserPath).document(self.userArray!.id) // 変更カラム取得
            postRef.setData(value, merge: true)
            
            SVProgressHUD.showSuccess(withStatus: "変更しました")
        }
    }
    
    /// グループ・推しメンボタンがタップされたときに呼ばれるメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func addGroupButtonTapped(_ sender: UIButton) {
        if let group = self.groupField.text, let member = self.memberField.text {
            var value: [[String: String]] = []
            
            value = [
                ["group_name": group,
                 "member_name": member],
            ]
            
            var updateValue: FieldValue
            updateValue = FieldValue.arrayUnion(value)
            
            let postRef = Firestore.firestore().collection(Const.UserPath).document(self.userArray!.id) // 変更カラム取得
            postRef.updateData(["groups": updateValue])
            
            SVProgressHUD.showSuccess(withStatus: "追加しました")
        }
        
    }
    
    
    // MARK: - Private Methods
    // 絞り込み決定押下
    @objc func done() {
        self.genderField.endEditing(true)
        self.genderField.text = gender[self.pickerView.selectedRow(inComponent: 0)]
    }
    
    /// TextFieldの入力チェックを行うメソッド
    ///
    /// - Parameter sender: UITextField
    @objc private func textFieldDidChange(sender: UITextField) {
        // グループ・推しメンの入力チェック
        if let group = self.groupField.text, let member = self.memberField.text {

            // アドレスとパスワード6文字以上入力されていない場合はボタンを押せなくする
            if !group.isEmpty && !member.isEmpty {
                self.addGroupButton.isEnabled = true
                self.addGroupButton.backgroundColor = UIColor(red: 253/255, green: 198/255, blue: 148/255, alpha: 1)
            } else {
                self.addGroupButton.isEnabled = false
                self.addGroupButton.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
            }
        }
    }
    
    func setImage() {
        if self.userArray?.imageFlg == 1 {
            self.Profileimage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            // 取ってくる画像の場所を指定
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(self.userArray!.id + ".jpg")
            // 画像をダウンロードして表示(sd_setimage)
            self.Profileimage.sd_setImage(with: imageRef, maxImageSize: 1 * 1024 * 1024, placeholderImage: nil, options: .refreshCached, completion: nil)
            self.Profileimage.backgroundColor = .white
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ChangeProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.userArray?.groups.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! FavoriteGroupTableViewCell
        if let groups = self.userArray?.groups {
            cell.setGroupData(groups[indexPath.row])
        }
        return cell
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension ChangeProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    /// 表示する列の設定
    ///
    /// - Parameter pickerView: UIPickerView
    /// - Returns: 列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /// 表示個数の設定
    ///
    /// - Parameters:
    ///   - pickerView: UIPickerView
    ///   - component: Int
    /// - Returns: 個数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.gender.count
    }
    
    /// 表示内容の設定
    ///
    /// - Parameters:
    ///   - pickerView: UIPickerView
    ///   - row: Int
    ///   - component: Int
    /// - Returns: 表示内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.gender[row]
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ChangeProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// 写真を撮影/選択したときに呼ばれるメソッド
    ///
    /// - Parameters:
    ///   - picker: UIImagePickerController
    ///   - info: [UIImagePickerController.InfoKey : Any]
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
        // 画像加工処理(info[.originalImage]に撮影/選択した画像が入っている)
        // 省略せず書くと、info[UIImagePickerController.InfoKey.originalImage]に入っている
        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage
            self.Profileimage.backgroundColor = .white
            
            // 画像をJPEG形式に変換する(1.0が1番画質高く、0が1番低い)
            let imageData = image.jpegData(compressionQuality: 0.75)
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(self.userArray!.id + ".jpg")
            
            let metadata = StorageMetadata() // タイプを決定したりプレビューを表示できるようにする
            metadata.contentType = "image/jpeg"
            
            if let imageData = imageData {
                imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        // 画像のアップロード失敗
                        print(error)
                        SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                        return
                    }
                    
                    let postRef = Firestore.firestore().collection(Const.UserPath).document(self.userArray!.id) // 変更カラム取得
                    postRef.setData(["imageFlg": 1], merge: true)
                
                    self.setImage()
                }
            }
        }
    }
    
    /// キャンセルボタンが押されたときに呼ばれるメソッド
    ///
    /// - Parameter picker: UIImagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension ChangeProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

