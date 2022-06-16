//
//  NewsViewController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/03.
//

import UIKit
import Alamofire

class NewsViewController: UIViewController {
    
    //MARK: 変数
    let decoder: JSONDecoder = JSONDecoder()
    var articles = [NewsModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        request()
    }
    
    func request() {
        AF.request("https://news.google.com/rss/search?hl=ja&ie=UTF-8&oe=UTF-8&q=IZ*ONE,after:2022-5-20&gl=JP&ceid=JP:ja").responseString { response in
            switch response.result {
            case .success:
                do {
                    self.articles = try self.decoder.decode([NewsModel].self, from: response.data!)
                    print(self.articles)
                } catch {
                    print("デコードに失敗しました")
                }
            case .failure(let error):
                print("error", error)
            }
        }
    }

}
