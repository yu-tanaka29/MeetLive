//
//  UserData.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/06.
//

import UIKit
import Firebase

class UserData: NSObject {
    var id: String
    var name: String?
    var gender: String?
    var age: String?
    var groups: [[String: String]] = []
    var imageFlg: Int?
    
    init(document: DocumentSnapshot) {
        self.id = document.documentID

        if let userDic = document.data() {

            if let name = userDic["name"] as? String {
                self.name = name
            }
            
            if let gender = userDic["gender"] as? String {
                self.gender = gender
            }
            
            if let age = userDic["age"] as? String {
                self.age = age
            }
            
            if let groups = userDic["groups"] as? [[String: String]] {
                self.groups = groups
            }
            
            if let imageFlg = userDic["imageFlg"] as? Int {
                self.imageFlg = imageFlg
            }
        }
    }
}
