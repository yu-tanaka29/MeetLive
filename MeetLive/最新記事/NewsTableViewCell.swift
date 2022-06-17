//
//  NewsTableViewCell.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/17.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(data: NewsModel.Item) {
        self.titleLabel.text = data.title
        self.dateLabel.text = data.pubDate
    }
    
}
