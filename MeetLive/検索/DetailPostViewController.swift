//
//  DetailPostViewController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/02.
//

import UIKit
import Firebase

class DetailPostViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagImage: UIImageView!
    @IBOutlet weak var tagText: UILabel!
    @IBOutlet weak var personalLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var commentField: UITextView!
    @IBOutlet weak var sendCommentButton: UIButton!
    
    // MARK: - メンバ変数
    var postArray: DetailPostData?
    var postId = ""
    let places: [String] = Places().places
    let purposes: [String] = Purposes().displayPurposes
    let colorPurposes: [[Float]] = Purposes().colorPurposes
    var userArray: UserData? // ユーザー情報
    var listener: ListenerRegistration? // Firestoreのリスナーの定義
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // カスタムセルを登録する
        let nib = UINib(nibName: "DetailPostTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "DetailPostCell")
        
        // 枠のカラー
        self.commentField.layer.borderColor = CGColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        // 枠の幅
        self.commentField.layer.borderWidth = 1.0
        self.commentField.layer.cornerRadius = 10
        self.commentField.delegate = self
        
        self.sendCommentButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT: viewWillAppear")
        let postsRef = Firestore.firestore().collection(Const.PostPath).document(postId)
        self.listener = postsRef.addSnapshotListener() { (querySnapshot, error) in // 情報取得
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            self.postArray = DetailPostData(document: (querySnapshot.self)!)
            self.setPostData(self.postArray!)
        }
    }
    
    // MARK: - IBAction
    
    /// コメント送信ボタンが押された時のメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func sendCommentButtonTapped(_ sender: UIButton) {
        guard let myid = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let comment = self.commentField.text else{
            return
        }
        
        // 更新データ作成
        let value: [[String: Any]] = [
            [ "user_id": myid,
              "comment": comment,
              "date": Timestamp() ]]
        
        var updateValue: FieldValue
        updateValue = FieldValue.arrayUnion(value)
        
        // likesに更新データを書き込む
        guard let postId = self.postArray!.id else {
            return
        }
        
        let postRef = Firestore.firestore().collection(Const.PostPath).document(postId) // 変更カラム取得
        postRef.updateData(["comments": updateValue])// 変更依頼送信
        self.commentField.text = ""
    }
    
    
    // MARK: - Private Methods
    func setPostData(_ postData: DetailPostData) {
        if let posterId = postData.poster_id {
            let userRef = Firestore.firestore().collection(Const.UserPath).document(posterId) //情報を取得する場所を決定
            userRef.getDocument { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                self.userArray = UserData(document: (querySnapshot.self)!)
                
                if let title = postData.title, !title.isEmpty{
                    self.titleLabel.text = title
                }
                
                // 日時の表示
                self.dateLabel.text = ""
                if let start_date = postData.start_date, let end_date = postData.end_date{
                    let startDate: String = self.dateFormat(date: start_date)
                    let endDate: String = self.dateFormat(date: end_date)
                    self.dateLabel.text = "日時: \(startDate) - \(endDate)"
                }
                
                if let placeId = postData.place_id {
                    self.placeLabel.text = self.places[placeId]
                }
                
                if let groupName = postData.group_name, let memberName = postData.member_name {
                    self.favoriteLabel.text = "\(memberName)(\(groupName))"
                }
                
                if let content = postData.content {
                    self.contentLabel.text = content
                }
                
                if let gender = self.userArray?.gender, let age = self.userArray?.age {
                    self.personalLabel.text = "\(age)歳・\(gender)"
                }
                
                if let name = self.userArray?.name {
                    self.nameLabel.text = name
                }
                
                if postData.comments.count != 0 {
                    print("reverse")
                    postData.comments.reverse()
                    
                    for comment in postData.comments {
                        
                    }
                    self.tableView.reloadData()
                }
                
                
                if let purposeId = postData.purpose_id {
                    self.tagText.text = self.purposes[purposeId]
                    self.tagImage.tintColor = UIColor(red: CGFloat(self.colorPurposes[purposeId][0])/255, green: CGFloat(self.colorPurposes[purposeId][1])/255, blue: CGFloat(self.colorPurposes[purposeId][2])/255, alpha: 1)
                    self.tagText.textColor = UIColor(red: CGFloat(self.colorPurposes[purposeId][0])/255, green: CGFloat(self.colorPurposes[purposeId][1])/255, blue: CGFloat(self.colorPurposes[purposeId][2])/255, alpha: 1)
                }
            }
        }
    }
    
    func dateFormat(date: Date) -> String {
        let formatter = DateFormatter() // フォーマットのインスタンス生成
        formatter.dateFormat = "yyyy/MM/dd HH:mm" // フォーマット指定
        let dateString = formatter.string(from: date) // 変更
        return dateString
    }

}

// MARK: - UITableViewDelegate,UITableViewDataSource
extension DetailPostViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postArray?.comments.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailPostCell", for: indexPath) as! DetailPostTableViewCell
        if let comment = self.postArray?.comments {
            cell.setComment(data: comment[indexPath.row])
        }
        return cell
    }
}

// MARK: - UITextViewDelegate
extension DetailPostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text, !text.isEmpty {
            self.sendCommentButton.isEnabled = true
        } else {
            self.sendCommentButton.isEnabled = false
        }
    }
}
