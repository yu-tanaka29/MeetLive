//
//  SuccessPostViewController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/02.
//

import UIKit
import Firebase

class SuccessPostViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    // 今後会う予定の投稿のみ表示ボタン
    @IBOutlet weak var limitButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    
    // MARK: - メンバ変数
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    var checkFlg = 0
    var sortFlg = 0
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // カスタムセルを登録する
        let nib = UINib(nibName: "SearchPostTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "SuccessPostCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("aaa")
        self.getPostData()
    }
    
    // MARK: - IBAction
    @IBAction func limitButtonTapped(_ sender: UIButton) {
        if self.checkFlg == 0 {
            self.checkFlg = 1
            self.limitButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        } else {
            self.checkFlg = 0
            self.limitButton.setImage(UIImage(systemName: "square"), for: .normal)
        }
        
        print(self.checkFlg)
        self.getPostData()
    }
    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
        if self.sortButton.currentTitle == "降順にする" {
            self.sortButton.setTitle("昇順にする", for: .normal)
            self.sortFlg = 1
        } else {
            self.sortButton.setTitle("降順にする", for: .normal)
            self.sortFlg = 0
        }
        self.getPostData()
    }
    
    
    
    // MARK: - Private Methods
    private func getPostData() {
        guard let myId = Auth.auth().currentUser?.uid else {
            return
        }
        
        self.postArray.removeAll()
        
        var postsRef = Firestore.firestore().collection(Const.PostPath).whereField("open_flg", isEqualTo: 1).whereField("poster_id", isEqualTo: myId)
        
        if self.checkFlg == 1 {
            postsRef = postsRef.whereField("start_date", isGreaterThan: Timestamp())
        }
        
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
            
            
            postsRef = Firestore.firestore().collection(Const.PostPath).whereField("open_flg", isEqualTo: 1).whereField("open_id", isEqualTo: myId)
            
            if self.checkFlg == 1 {
                postsRef = postsRef.whereField("start_date", isGreaterThan: Timestamp())
            }

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

                if self.sortFlg == 1 {
                    self.postArray.sort(by: {$0.start_date! > $1.start_date!})
                } else {
                    self.postArray.sort(by: {$0.start_date! < $1.start_date!})
                }
                self.tableView.separatorStyle = .singleLine
                self.tableView.reloadData()
            }
        }
    }
    
    
}

// MARK: - UITableViewDelegate,UITableViewDataSource
extension SuccessPostViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuccessPostCell", for: indexPath) as! SearchPostTableViewCell
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
