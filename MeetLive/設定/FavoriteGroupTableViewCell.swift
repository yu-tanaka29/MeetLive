//
//  FavoriteGroupTableViewCell.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/03.
//

import UIKit

class FavoriteGroupTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - IBAction
    
    // MARK: - Private Methods
    func setGroupData(_ groups: [String: String]) {
        self.groupLabel.text = "グループ名：" + groups["group_name"]!
        self.memberLabel.text = "推しメン：" + groups["member_name"]!
    }
}
