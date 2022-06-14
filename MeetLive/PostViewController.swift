//
//  PostViewController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/07.
//

import UIKit
import Firebase
import SVProgressHUD

class PostViewController: UIViewController {
    // MARK: - IBOutlet
    // タイトル
    @IBOutlet weak var titleField: UITextField!
    // 開始日時
    @IBOutlet weak var startDateField: UIDatePicker!
    // 終了日時
    @IBOutlet weak var endDateField: UIDatePicker!
    // 目的関連
    @IBOutlet weak var choosePurposeField: UITextField!
    @IBOutlet weak var writePurposeField: UITextField!
    // 会場関連
    @IBOutlet weak var choosePlaceField: UITextField!
    @IBOutlet weak var choosePrefectureField: UITextField!
    @IBOutlet weak var writePlaceField: UITextField!
    // 座席
    @IBOutlet weak var seatField: UITextField!
    // グループ・推しメン関連
    @IBOutlet weak var groupField: UITextField!
    @IBOutlet weak var memberField: UITextField!
    // 内容
    @IBOutlet weak var contentField: UITextView!
    // 投稿ボタン
    @IBOutlet weak var postButton: UIButton!
    
    // MARK: - メンバ変数
    var userArray: UserData? // ユーザー情報
    var purposePickerView: UIPickerView = UIPickerView() // 目的選択用UIPickerView
    var placePickerView: UIPickerView = UIPickerView() // 会場選択用UIPickerView
    var prefecturePickerView: UIPickerView = UIPickerView() // 都道府県選択用PickerView
    var groupPickerView: UIPickerView = UIPickerView() // グループ選択用UIPickerView
    var chooseFlg: [String: Int] = [
        "purpose": 0,
        "place": 0,
        "group": 0]
    var pickerSw: Int = 0
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 目的選択用UIPickerView関連
        self.purposePickerView.delegate = self
        self.purposePickerView.dataSource = self
        self.purposePickerView.tag = 1
        self.choosePurposeField.inputView = self.purposePickerView
        
        self.writePurposeField.isHidden = true
        
        // 会場選択用UIPickerView関連
        self.placePickerView.delegate = self
        self.placePickerView.dataSource = self
        self.placePickerView.tag = 2
        self.choosePlaceField.inputView = self.placePickerView
        
        // 会場選択用UIPickerView関連
        self.prefecturePickerView.delegate = self
        self.prefecturePickerView.dataSource = self
        self.prefecturePickerView.tag = 3
        self.choosePrefectureField.inputView = self.prefecturePickerView
        
        self.writePlaceField.isHidden = true
        self.choosePrefectureField.isHidden = true
        
        // グループ・推しメン選択用UIPickerView関連
        self.groupPickerView.delegate = self
        self.groupPickerView.dataSource = self
        self.groupPickerView.tag = 4
        self.groupField.inputView = self.groupPickerView
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        toolbar.setItems([cancelItem, spacelItem, doneItem], animated: true)
        
        //入力エリアアクセス宣言
        self.choosePurposeField.inputAccessoryView = toolbar
        self.choosePlaceField.inputAccessoryView = toolbar
        self.choosePrefectureField.inputAccessoryView = toolbar
        self.groupField.inputAccessoryView = toolbar
        
        // 記述テキストフィールドの値が変わるたびに呼ばれる
        self.titleField.addTarget(self, action: #selector(checkTextField), for: .editingChanged)
        self.writePlaceField.addTarget(self, action: #selector(checkTextField), for: .editingChanged)
        
        // 投稿ボタンを押せなくする
        self.postButton.isEnabled = false
        
        // 枠のカラー
        self.contentField.layer.borderColor = CGColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        // 枠の幅
        self.contentField.layer.borderWidth = 1.0
        self.contentField.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // ログイン済みか確認
        if let user = Auth.auth().currentUser {
            let userRef = Firestore.firestore().collection(Const.UserPath).document(user.uid) //情報を取得する場所を決定
            userRef.getDocument { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                self.userArray = UserData(document: (querySnapshot.self)!, num: 0)
            }
        }
    }
    
    // MARK: - IBAction
    @IBAction func postButtonTapped(_ sender: Any) {
        
        // ボタンが押せているということは以下のフィールドテキストには値が入っているため、強制アンラップ
        //
        var value: [String: Any] = [
            "title": self.titleField.text!,
            "purpose_id": Purposes().purposes.firstIndex(of: self.choosePurposeField.text!)!,
            "place_id": Places().places.firstIndex(of: self.choosePlaceField.text!)!,
            "group_name": self.groupField.text!,
            "member_name": self.memberField.text!,
            "poster_id": (self.userArray?.id)!,
            "start_date": self.startDateField.date,
            "end_date": self.endDateField.date,
            "open_flg": 0]

        if let seat = self.seatField.text, !seat.isEmpty {
            value.updateValue(seat, forKey: "seat")
        }
        if let content = self.contentField.text, !content.isEmpty {
            value.updateValue(content, forKey: "content")
        }
        if let writePuepose = self.writePurposeField.text, !writePuepose.isEmpty {
            value.updateValue(writePuepose, forKey: "purpose")
        }
        if let prefecture = self.choosePrefectureField.text, !prefecture.isEmpty {
            value.updateValue(prefecture, forKey: "prefecture")
        }
        if let writePlace = self.writePlaceField.text, !writePlace.isEmpty {
            value.updateValue(writePlace, forKey: "place")
        }
        
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        postRef.setData(value)
        
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        
    }
    
    // MARK: - Private Methods
    // 絞り込み決定押下
    @objc func done() {
        self.view.endEditing(true)
        switch self.pickerSw {
            case 1:
                self.choosePurposeField.text = Purposes().purposes[self.purposePickerView.selectedRow(inComponent: 0)]
                self.chooseFlg["purpose"] = 1
                self.checkTextField()
            case 2:
                self.choosePlaceField.text = Places().places[self.placePickerView.selectedRow(inComponent: 0)]
                if Places().places[self.placePickerView.selectedRow(inComponent: 0)] == "その他" {
                    self.choosePrefectureField.isHidden = false
                    self.writePlaceField.isHidden = false
                    self.chooseFlg["place"] = 2
                } else {
                    self.choosePrefectureField.isHidden = true
                    self.writePlaceField.isHidden = true
                    self.chooseFlg["place"] = 1
                }
                self.checkTextField()
            case 3:
                self.choosePrefectureField.text = Prefectures().prefectures[self.prefecturePickerView.selectedRow(inComponent: 0)]
                self.chooseFlg["place"] = 2
            case 4:
                self.groupField.text = self.userArray?.groups[self.groupPickerView.selectedRow(inComponent: 0)]["group_name"]
                self.memberField.text = self.userArray?.groups[self.groupPickerView.selectedRow(inComponent: 0)]["member_name"]
                self.chooseFlg["group"] = 1
                self.checkTextField()
            default:
                break
        }
    }
    // 絞り込みキャンセル押下
    @objc func cancel() {
        self.view.endEditing(true)
    }
    
    // 日付フォーマット変更
    func dateFormat(date: Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm"
        let changeDate = format.string(from: date)
        return changeDate
    }
    
    /// TextFieldの入力チェックを行うメソッド
    @objc func checkTextField() {
        // アカウント作成の入力チェック
        if let title = self.titleField.text, !title.isEmpty,
           self.chooseFlg["purpose"] == 1, self.chooseFlg["place"]! >= 1, self.chooseFlg["group"] == 1 {
            
            if chooseFlg["place"] == 2,
               let writePlace = self.writePlaceField.text, writePlace.isEmpty{
                self.postButton.isEnabled = false
            } else {
                self.postButton.isEnabled = true
            }
        } else {
            self.postButton.isEnabled = false
        }
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension PostViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        switch pickerView.tag {
            case 1:
                return Purposes().purposes.count
            case 2:
                return Places().places.count
            case 3:
                return Prefectures().prefectures.count
            case 4:
                return self.userArray?.groups.count ?? 0
            default:
                return 0
        }
    }
    
    /// 表示内容の設定
    ///
    /// - Parameters:
    ///   - pickerView: UIPickerView
    ///   - row: Int
    ///   - component: Int
    /// - Returns: 表示内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            self.pickerSw = 1
            return Purposes().purposes[row]
        } else if pickerView.tag == 2 {
            self.pickerSw = 2
            return Places().places[row]
        } else if pickerView.tag == 3 {
            self.pickerSw = 3
            return Prefectures().prefectures[row]
        } else {
            self.pickerSw = 4
            if let groups = self.userArray?.groups {
                return groups[row]["group_name"]
            } else {
                return "aa"
            }
        }
    }
}
