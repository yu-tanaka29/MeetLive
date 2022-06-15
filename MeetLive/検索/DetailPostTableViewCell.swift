//
//  DetailPostTableViewCell.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/10.
//

import UIKit
import Firebase
import FirebaseStorageUI

class DetailPostTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var personalLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: CustomLabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var decideButton: UIButton!
    @IBOutlet weak var addPinButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentLabel.layer.cornerRadius = 10
        self.contentLabel.clipsToBounds = true
        
        self.imageLabel.layer.cornerRadius = 20
        self.imageLabel.clipsToBounds = true
        
        self.decideButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        self.decideButton.layer.cornerRadius = 10
        
        self.addPinButton.isHidden = true
        self.addPinButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        self.addPinButton.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Private Methods
    func setComment(commentData: [String: Any], userData: UserData) {
        self.contentLabel.text = commentData["comment"] as? String
        
        if let myid = Auth.auth().currentUser?.uid, myid != commentData["user_id"] as! String,
           commentData["comment"] as! String == "位置情報を送信しました。" {
            self.addPinButton.isHidden = false
        } else {
            self.addPinButton.isHidden = true
        }
            
        if userData.imageFlg == 1 {
            self.imageLabel.sd_imageIndicator = SDWebImageActivityIndicator.gray
            // 取ってくる画像の場所を指定
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(userData.id + ".jpg")
            // 画像をダウンロードして表示(sd_setimage)
            self.imageLabel.sd_setImage(with: imageRef)
        }
        
        guard let age = userData.age, let gender = userData.gender else {
            return
        }
            
        self.personalLabel.text = "\(age)歳・\(gender)"
        self.nameLabel.text =  userData.name
            
        let date = (commentData["date"] as! Timestamp).dateValue()
        let formatter = DateFormatter() // フォーマットのインスタンス生成
        formatter.dateFormat = "yyyy/MM/dd HH:mm" // フォーマット指定
        self.dateLabel.text = formatter.string(from: date) // 変更
    }
}
