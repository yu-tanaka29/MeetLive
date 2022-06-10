//
//  DetailPostViewController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/02.
//

import UIKit

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
    var postArray: [PostData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.postArray.count)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // カスタムセルを登録する
        let nib = UINib(nibName: "DetailPostTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "DetailPostCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

}

// MARK: - UITableViewDelegate,UITableViewDataSource
extension DetailPostViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailPostCell", for: indexPath) as! DetailPostTableViewCell
        return cell
    }
}
