//
//  MyPostListViewController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/16.
//

import UIKit
import Firebase

class MyPostListViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - メンバ変数
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // カスタムセルを登録する
        let nib = UINib(nibName: "SearchPostTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "MyPostListCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getPostData()
    }
    
    // MARK: - Private Methods
    private func getPostData() {
        guard let myId = Auth.auth().currentUser?.uid else {
            return
        }
        
        self.postArray.removeAll()
        
        let postsRef = Firestore.firestore().collection(Const.PostPath).whereField("poster_id", isEqualTo: myId).order(by: "start_date")
        
        postsRef.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
            for document in querySnapshot!.documents {
                print("DEBUG_PRINT: document取得 \(document.documentID)")
                let postData = PostData(document: document)
                self.postArray.append(postData)
            }

            self.tableView.separatorStyle = .singleLine
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate,UITableViewDataSource
extension MyPostListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPostListCell", for: indexPath) as! SearchPostTableViewCell
        cell.setPostData(self.postArray[indexPath.row])
        return cell
    }
    
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // セルの選択を解除
       tableView.deselectRow(at: indexPath, animated: true)
       let deatilPostViewController = self.storyboard?.instantiateViewController(withIdentifier: "Detail") as! DetailPostViewController
       deatilPostViewController.postId = self.postArray[indexPath.row].id!
       self.navigationController?.pushViewController(deatilPostViewController, animated: true)
   }
}
