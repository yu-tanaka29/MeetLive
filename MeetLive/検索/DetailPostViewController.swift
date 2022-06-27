//
//  DetailPostViewController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/02.
//

import UIKit
import Firebase
import SVProgressHUD
import CoreLocation

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
    @IBOutlet weak var seatField: UIStackView!
    @IBOutlet weak var seatLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var commentField: UITextView!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var sendPositionButton: UIButton!
    
    // MARK: - メンバ変数
    var postArray: DetailPostData? // 投稿情報
    var postId = ""
    var userArray: UserData? // ユーザー情報
    var commenterArray: [UserData] = [] // コメント一覧情報
    var listener: ListenerRegistration? // Firestoreのリスナーの定義
    var locationManager : CLLocationManager?
    
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
        
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        
        // ボタンのデザイン
        self.sendPositionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.sendPositionButton.layer.cornerRadius = 10
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    // MARK: - Life Cycle
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
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.popViewController(animated: true)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
        self.listener?.remove()
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
        
        let postRef = Firestore.firestore().collection(Const.PostPath).document(self.postId) // 変更カラム取得
        postRef.updateData(["comments": updateValue])// 変更依頼送信
        self.commentField.text = ""
    }
    
    @IBAction func sendPositionButtonTapped(_ sender: Any) {
        self.locationManager!.requestWhenInUseAuthorization()
        
        //位置情報を使用可能か
        if CLLocationManager.locationServicesEnabled() {
             //位置情報の取得開始
            self.locationManager!.startUpdatingLocation()
        }
    }
    
    
    
    // MARK: - Private Methods
    func setPostData(_ postData: DetailPostData) {
        if let posterId = postData.poster_id {
            if postData.comments.count != 0 {
                self.commenterArray.removeAll()
                postData.comments.reverse()
                
                for i in 0 ..< postData.comments.count {
                    let userRef = Firestore.firestore().collection(Const.UserPath).document(postData.comments[i]["user_id"] as! String) //情報を取得する場所を決定
                    userRef.getDocument { (querySnapshot, error) in
                        if let error = error {
                            print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                            return
                        }
                        self.commenterArray.append(UserData(document: querySnapshot!, num: i))
                        if self.commenterArray.count == postData.comments.count {
                            self.commenterArray.sort(by: {$0.num! < $1.num!})
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            let userRef = Firestore.firestore().collection(Const.UserPath).document(posterId) //情報を取得する場所を決定
            userRef.getDocument { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                self.userArray = UserData(document: (querySnapshot.self)!, num: 0)
                
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
                    self.placeLabel.text = Places().places[placeId]
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
                
                if let purposeId = postData.purpose_id {
                    self.tagText.text = Purposes().displayPurposes[purposeId]
                    self.tagImage.tintColor = UIColor(red: CGFloat(Purposes().colorPurposes[purposeId][0])/255, green: CGFloat(Purposes().colorPurposes[purposeId][1])/255, blue: CGFloat(Purposes().colorPurposes[purposeId][2])/255, alpha: 1)
                    self.tagText.textColor = UIColor(red: CGFloat(Purposes().colorPurposes[purposeId][0])/255, green: CGFloat(Purposes().colorPurposes[purposeId][1])/255, blue: CGFloat(Purposes().colorPurposes[purposeId][2])/255, alpha: 1)
                }
                
                if let seat = postData.seat {
                    self.seatField.isHidden = false
                    self.seatLabel.text = seat
                } else {
                    self.seatField.isHidden = true
                }
                
                if let openFlg = postData.open_flg, openFlg == 0 {
                    self.sendPositionButton.isHidden = true
                } else {
                    self.sendPositionButton.isHidden = false
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
    
    /// セル内のボタンがタップされた時に呼ばれるメソッド
    ///
    /// - Parameters:
    ///   - sender: UIButton
    ///   - event: UIEvent : タップ
    @objc private func decideButtonTapped(_ sender: UIButton, forEvent event: UIEvent) {
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first // タッチイベント取得
        let point = touch!.location(in: self.tableView) // タッチの位置取得
        let indexPath = self.tableView.indexPathForRow(at: point) // 位置に対するインデックス取得
        
        // 配列からタップされたインデックスのデータを取り出す
        let commenterData = self.commenterArray[indexPath!.row]
        
        
        let updateValue = [
            "open_flg": 1,
            "open_id": commenterData.id
        ] as [String: Any]
        
        let postRef = Firestore.firestore().collection(Const.PostPath).document(self.postId) // 変更カラム取得
        postRef.setData(updateValue, merge: true)
        
        SVProgressHUD.showSuccess(withStatus: "確定しました")
    }
    
    @objc private func addPinButtonTapped(_ sender: UIButton, forEvent event: UIEvent) {
        guard let myId = Auth.auth().currentUser?.uid else {
            return
        }
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first // タッチイベント取得
        let point = touch!.location(in: self.tableView) // タッチの位置取得
        let indexPath = self.tableView.indexPathForRow(at: point) // 位置に対するインデックス取得
        
        // 配列からタップされたインデックスのデータを取り出す
        let commenterData = self.commenterArray[indexPath!.row]
        
        guard let name = commenterData.name else {
            return
        }
        
        if myId == self.postArray?.poster_id {
            guard let latitude = self.postArray?.commenter_latitude else {
                return
            }
            guard let longitude = self.postArray?.commenter_longitude else {
                return
            }
            self.transitionMapViewController(latitude: latitude, longitude: longitude, name: name)
        } else {
            guard let latitude = self.postArray?.poster_latitude else {
                return
            }
            guard let longitude = self.postArray?.poster_longitude else {
                return
            }
            self.transitionMapViewController(latitude: latitude, longitude: longitude, name: name)
        }
        
    }
    
    private func transitionMapViewController(latitude: Double, longitude: Double, name: String) {
        let mapViewController = tabBarController?.viewControllers?[1] as! MapViewController
        mapViewController.pinFlg = 1
        mapViewController.longitude = longitude
        mapViewController.latitude = latitude
        mapViewController.userName = name
        mapViewController.titleLabel = (self.postArray?.title)!
        
        self.tabBarController?.selectedIndex = 1
    }

}

// MARK: - UITableViewDelegate,UITableViewDataSource
extension DetailPostViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postArray?.comments.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailPostCell", for: indexPath) as! DetailPostTableViewCell
        cell.decideButton.addTarget(self, action:#selector(decideButtonTapped(_:forEvent:)), for: .touchUpInside)
        cell.addPinButton.addTarget(self, action:#selector(addPinButtonTapped(_:forEvent:)), for: .touchUpInside)
        if let myid = Auth.auth().currentUser?.uid, myid != self.userArray?.id {
            cell.decideButton.isHidden = true
        } else if self.postArray?.open_flg == 1 {
            cell.decideButton.isHidden = true
        }
        
        if let comment = self.postArray?.comments {
            cell.setComment(commentData: comment[indexPath.row], userData: self.commenterArray[indexPath.row])
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

// MARK: - CLLocationManagerDelegate
extension DetailPostViewController: CLLocationManagerDelegate {
    // 位置情報を取得した場合
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
       guard let newLocation = locations.first else {
            return
       }
       
       self.locationManager?.stopUpdatingLocation()

       let location:CLLocationCoordinate2D
              = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)

       print("緯度：", location.latitude, "経度：", location.longitude)
       
       var updateValue: [String: Double] = [:]
       let postRef = Firestore.firestore().collection(Const.PostPath).document(self.postId) // 変更カラム取得
       guard let myid = Auth.auth().currentUser?.uid else {
           return
       }
       
       if myid == self.postArray?.poster_id {
           updateValue = [
            "poster_latitude": location.latitude,
            "poster_longitude": location.longitude ]
       } else {
           updateValue = [
            "commenter_latitude": location.latitude,
            "commenter_longitude": location.longitude ]
       }
       postRef.setData(updateValue, merge: true)
       
       let value: [[String: Any]] = [
           [ "user_id": myid,
             "comment": "位置情報を送信しました。",
             "date": Timestamp() ]]
       
       var commentValue: FieldValue
       commentValue = FieldValue.arrayUnion(value)
       postRef.updateData(["comments": commentValue])// 変更依頼送信
       
   }
}
