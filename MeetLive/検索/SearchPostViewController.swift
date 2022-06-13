//
//  SearchPostViewController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/02.
//

import UIKit
import Firebase

class SearchPostViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var searchField: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chooseGroupField: UITextField!
    @IBOutlet weak var choosePlaceField: UITextField!
    @IBOutlet weak var choosePrefectureField: UITextField!
    @IBOutlet weak var inPlaceField: UIButton!
    @IBOutlet weak var outPlaceField: UIButton!
    @IBOutlet weak var withGoodsField: UIButton!
    @IBOutlet weak var withLiveField: UIButton!
    @IBOutlet weak var changeGoodsField: UIButton!
    @IBOutlet weak var otherField: UIButton!
    
    // MARK: - メンバ変数
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    var userArray: UserData? // ユーザー情報
    var checkList: [Int] = []
    var groupName: String = ""
    var groupPickerView: UIPickerView = UIPickerView() // グループ選択用UIPickerView
    var placePickerView: UIPickerView = UIPickerView() // 会場選択用UIPickerView
    var prefecturePickerView: UIPickerView = UIPickerView() // 都道府県選択用PickerView
    var pickerSw: Int = 0
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // グループ・推しメン選択用UIPickerView関連
        self.groupPickerView.delegate = self
        self.groupPickerView.dataSource = self
        self.groupPickerView.tag = 1
        self.chooseGroupField.inputView = self.groupPickerView
        
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
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        toolbar.setItems([cancelItem, spacelItem, doneItem], animated: true)
        
        //入力エリアアクセス宣言
        self.choosePlaceField.inputAccessoryView = toolbar
        self.choosePrefectureField.inputAccessoryView = toolbar
        self.chooseGroupField.inputAccessoryView = toolbar
        
        // 初めは都道府県選択を表示しない
        self.choosePrefectureField.isHidden = true

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.addButton.layer.cornerRadius = 34
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "SearchPostTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "SearchPostCell")
        
        self.getPostData()
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
                self.userArray = UserData(document: (querySnapshot.self)!)
            }
        }
        
        self.getPostData()
    }
    
    // MARK: - IBAction
    @IBAction func hideButtonTapped(_ sender: UIButton) {
        if self.hideButton.currentTitle == "閉じる" {
            self.hideButton.setTitle("開く", for: .normal)
            self.hideButton.setImage(UIImage(systemName: "arrow.down"), for: .normal)
            
            self.searchField.isHidden = true
        } else {
            self.hideButton.setTitle("閉じる", for: .normal)
            self.hideButton.setImage(UIImage(systemName: "arrow.up"), for: .normal)
            
            self.searchField.isHidden = false
        }
    }
    
    /// 会場内で会いたいが押された時のメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func inPlaceChecked(_ sender: UIButton) {
        self.updateCheckList(id: 0, field: self.inPlaceField)
    }
    
    /// 会場外で会いたいが押された時のメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func outPlaceChecked(_ sender: UIButton) {
        self.updateCheckList(id: 1, field: self.outPlaceField)
    }
    
    /// グッズ列同行が押された時のメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func withGoodsChecked(_ sender: UIButton) {
        self.updateCheckList(id: 2, field: self.withGoodsField)
    }
    
    /// ライブ同行が押された時のメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func withLiveChecked(_ sender: UIButton) {
        self.updateCheckList(id: 3, field: self.withLiveField)
    }
    
    /// グッズ交換が押された時のメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func changeGoodsChecked(_ sender: UIButton) {
        self.updateCheckList(id: 4, field: self.changeGoodsField)
    }
    
    /// その他が押された時のメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func othersChecked(_ sender: UIButton) {
        self.updateCheckList(id: 5, field: self.otherField)
    }
    
    
    /// 検索ボタンが押された時のメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        self.getPostData()
    }
    
    // MARK: - Private Methods
    /// Firebaseから情報を取得するメソッド
    private func getPostData() {
        var postsRef = Firestore.firestore().collection(Const.PostPath).whereField("start_date", isGreaterThan: Timestamp()).order(by: "start_date")
        
        if !self.groupName.isEmpty {
            postsRef = postsRef.whereField("group_name", isEqualTo: self.groupName)
            print(postsRef)
        }
        
        if let place = self.choosePlaceField.text, !place.isEmpty, place == "その他" {
            if let prefecture = self.choosePrefectureField.text, !prefecture.isEmpty {
                postsRef = postsRef.whereField("prefecture", isEqualTo: prefecture)
            } else {
                postsRef = postsRef.whereField("place_id", isEqualTo: Places().places.firstIndex(of: place)!)
            }
        }
        
        if self.checkList.count != 0 {
            postsRef = postsRef.whereField("purpose_id", in: self.checkList)
        }
        postsRef.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            
            // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
            self.postArray = querySnapshot!.documents.map { document in
                print("DEBUG_PRINT: document取得 \(document.documentID)")
                let postData = PostData(document: document)
                return postData
            }
            
            // TableViewの表示を更新する
            self.tableView.reloadData()
        }
    }
    
    // 絞り込み決定押下
    @objc func done() {
        self.view.endEditing(true)
        switch self.pickerSw {
            case 1:
                let member = self.userArray?.groups[self.groupPickerView.selectedRow(inComponent: 0)]["member_name"]
                let group = self.userArray?.groups[self.groupPickerView.selectedRow(inComponent: 0)]["group_name"]
                self.chooseGroupField.text = "\(member!)(\(group!))"
                self.groupName = group!
            case 2:
                self.choosePlaceField.text = Places().places[self.placePickerView.selectedRow(inComponent: 0)]
                if Places().places[self.placePickerView.selectedRow(inComponent: 0)] == "その他" {
                    self.choosePrefectureField.isHidden = false
                } else {
                    self.choosePrefectureField.isHidden = true
                }
            case 3:
                self.choosePrefectureField.text = Prefectures().prefectures[self.prefecturePickerView.selectedRow(inComponent: 0)]
            default:
                break
        }
    }
    // 絞り込みキャンセル押下
    @objc func cancel() {
        self.view.endEditing(true)
    }
    
    /// チェックをつけるかどうか判断するメソッド
    ///
    /// - Parameters:
    ///   - id: Int
    ///   - field: UIButton
    private func updateCheckList(id: Int, field: UIButton) {
        if self.checkList.contains(id) == false { // チェックされていない時
            field.setImage(UIImage(systemName: "checkmark.square"), for: .normal) // チェック済み画像に変更
            self.checkList.append(id) // チェック済み配列に入れる
        } else { // チェックされている時
            field.setImage(UIImage(systemName: "square"), for: .normal) // 未チェック画像に変更
            self.checkList.removeAll(where: {$0 == id}) // チェック済み配列から取り除く
        }
    }
}

// MARK: - UITableViewDelegate,UITableViewDataSource
extension SearchPostViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPostCell", for: indexPath) as! SearchPostTableViewCell
        cell.setPostData(self.postArray[indexPath.row])
        return cell
    }
    
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // セルの選択を解除
       tableView.deselectRow(at: indexPath, animated: true)
       let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "Detail") as! DetailPostViewController
       nextVC.postId = self.postArray[indexPath.row].id!
       print(self.postArray[indexPath.row].id!)
       self.navigationController?.pushViewController(nextVC, animated: true)
   }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension SearchPostViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
                return self.userArray?.groups.count ?? 0
            case 2:
                return Places().places.count
            case 3:
                return Prefectures().prefectures.count
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
            if let groups = self.userArray?.groups {
                return "\(groups[row]["member_name"]!)(\(groups[row]["group_name"]!))"
            } else {
                return "aa"
            }
        } else if pickerView.tag == 2{
            self.pickerSw = 2
            return Places().places[row]
        } else {
            self.pickerSw = 3
            return Prefectures().prefectures[row]
        }
    }
    
}
