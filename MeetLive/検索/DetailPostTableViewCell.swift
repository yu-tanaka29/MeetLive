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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentLabel.layer.cornerRadius = 10
        self.contentLabel.clipsToBounds = true
        
        self.imageLabel.layer.cornerRadius = 20
        self.imageLabel.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Private Methods
    func setComment(data: [String: Any]) {
        var commenterArray: UserData?
        let userRef = Firestore.firestore().collection(Const.UserPath).document(data["user_id"] as! String) //情報を取得する場所を決定
        userRef.getDocument { (querySnapshot, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            commenterArray = UserData(document: (querySnapshot.self)!)
            
            if commenterArray?.imageFlg == 1 {
                self.imageLabel.sd_imageIndicator = SDWebImageActivityIndicator.gray
                // 取ってくる画像の場所を指定
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(commenterArray!.id + ".jpg")
                // 画像をダウンロードして表示(sd_setimage)
                self.imageLabel.sd_setImage(with: imageRef)
            }
            
            guard let age = commenterArray?.age, let gender = commenterArray?.gender else {
                return
            }
            
            self.personalLabel.text = "\(age)歳・\(gender)"
            self.nameLabel.text =  commenterArray?.name
            self.contentLabel.text = data["comment"] as? String
            
            let date = (data["date"] as! Timestamp).dateValue()
            let formatter = DateFormatter() // フォーマットのインスタンス生成
            formatter.dateFormat = "yyyy/MM/dd HH:mm" // フォーマット指定
            self.dateLabel.text = formatter.string(from: date) // 変更
        }
    }
}
