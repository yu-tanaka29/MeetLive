//
//  PostData.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/08.
//

import Foundation
import Firebase

class PostData: NSObject {
    var id: String?
    var title: String?
    var place_id: Int?
    var seat: String?
    var group_name: String?
    var member_name: String?
    var content: String?
    var purpose_id: Int?
    var poster_id: String?
    var comments: [[String: Any]] = []
    var start_date: Date?
    var end_date: Date?
    var open_id: String?
    var poster_location: Double?
    var commenter_location: Double?
    var place: String?
    var prefecture: String?
    var purpose: String?
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID

        let postDic = document.data()
        
        self.title = postDic["title"] as? String
        
        self.place_id = postDic["place_id"] as? Int
        
        self.purpose_id = postDic["purpose_id"] as? Int
        
        self.content = postDic["content"] as? String
        
        var timestamp = postDic["start_date"] as? Timestamp // 日付
        self.start_date = timestamp?.dateValue() // Date型に変更
        
        timestamp = postDic["end_date"] as? Timestamp // 日付
        self.end_date = timestamp?.dateValue() // Date型に変更
        
        self.group_name = postDic["group_name"] as? String
        self.member_name = postDic["member_name"] as? String
        
        self.poster_id = postDic["poster_id"] as? String
        
        if let comments = postDic["comments"] as? [[String: Any]] {
            self.comments = comments
        }
        
        if let prefecture = postDic["prefecture"] as? String,
           let place = postDic["place"] as? String {
            self.prefecture = prefecture
            self.place = place
        }
    }
}
