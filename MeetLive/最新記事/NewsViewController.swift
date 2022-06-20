//
//  NewsViewController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/03.
//

import UIKit
import Alamofire
import Firebase

class NewsViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - メンバ変数
    let decoder: JSONDecoder = JSONDecoder()
    var articles: NewsModel?
    var userArray: UserData? // ユーザー情報
    var groupPickerView: UIPickerView = UIPickerView() // グループ選択用UIPickerView
    var group = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "NewsTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "NewsCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        group = ""
        // ログイン済みか確認
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let userRef = Firestore.firestore().collection(Const.UserPath).document(user.uid) //情報を取得する場所を決定
        userRef.getDocument { (querySnapshot, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            self.userArray = UserData(document: (querySnapshot.self)!, num: 0)
            
            guard let groups = self.userArray?.groups else {
                return
            }
            for group in groups {
                self.group = self.group + group["group_name"]!.replacingOccurrences(of: " ", with: "%2B") + "%2C"
                print(self.group)
            }
            self.request(group: self.group)
        }
        
    }
    
    // MARK: - Private Methods
    func request(group: String) {
        let url = "https://api.rss2json.com/v1/api.json?rss_url=https%3A%2F%2Fnews.google.com%2Frss%2Fsearch%3Fhl%3Dja%26ie%3DUTF-8%26oe%3DUTF-8%26q%3D\(group)after%3A2022%2F05%2F01%26ceid%3DJP%3Aja%26gl%3DJP"
        AF.request(url).responseData { response in
            switch response.result {
            case .success:
                do {
                    self.articles = try self.decoder.decode(NewsModel.self, from: response.data!)
                    self.articles?.items.sort(by: {$0.pubDate > $1.pubDate})
                    self.tableView.reloadData()
                    self.tableView.separatorStyle = .singleLine
                } catch {
                    print("デコードに失敗しました")
                }
            case .failure(let error):
                print("error", error)
            }
        }
    }
}

// MARK: - UITableViewDelegate,UITableViewDataSource
extension NewsViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsTableViewCell
        cell.setData(data: (self.articles?.items[indexPath.row])!)
        return cell
    }
    
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // セルの選択を解除
       tableView.deselectRow(at: indexPath, animated: true)
       let link = self.articles?.items[indexPath.row].link
       guard let url = URL(string: link!) else { return }
       UIApplication.shared.open(url)
   }
}
