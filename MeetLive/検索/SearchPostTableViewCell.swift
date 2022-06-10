//
//  SearchPostTableViewCell.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/08.
//

import UIKit
import Firebase

class SearchPostTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    // タグ関連
    @IBOutlet weak var tagImage: UIImageView!
    @IBOutlet weak var tagText: UILabel!
    // 表示内容関連
    @IBOutlet weak var titleLabel: UILabel! // タイトル
    @IBOutlet weak var dateLabel: UILabel! // 日時
    @IBOutlet weak var placeLabel: UILabel! // 会場
    @IBOutlet weak var groupLabel: UILabel! // 好きなグループ・メンバー
    @IBOutlet weak var contentLabel: UILabel! // 内容
    @IBOutlet weak var personalLabel: UILabel!
    // 性別・年齢
    @IBOutlet weak var nameLabel: UILabel! // 名前
    
    // MARK: - メンバ変数
    let places: [String] = Places().places
    let purposes: [String] = Purposes().displayPurposes
    let colorPurposes: [[CGFloat]] = Purposes().colorPurposes
    var userArray: UserData? // ユーザー情報
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Private Methods
    func setPostData(_ postData: PostData) {
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
                    self.placeLabel.text = "会場: \(self.places[placeId])"
                }
                
                if let groupName = postData.group_name, let memberName = postData.member_name {
                    self.groupLabel.text = "推し: \(memberName)(\(groupName))"
                }
                
                if let content = postData.content {
                    self.contentLabel.text = "内容: \(content)"
                }
                
                if let gender = self.userArray?.gender, let age = self.userArray?.age {
                    self.personalLabel.text = "\(age)歳・\(gender)"
                }
                
                if let name = self.userArray?.name {
                    self.nameLabel.text = name
                }
                
                if let purposeId = postData.purpose_id {
                    self.tagText.text = self.purposes[purposeId]
                    self.tagImage.tintColor = UIColor(red: self.colorPurposes[purposeId][0]/255, green: self.colorPurposes[purposeId][1]/255, blue: self.colorPurposes[purposeId][2]/255, alpha: 1)
                    self.tagText.textColor = UIColor(red: self.colorPurposes[purposeId][0]/255, green: self.colorPurposes[purposeId][1]/255, blue: self.colorPurposes[purposeId][2]/255, alpha: 1)
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
