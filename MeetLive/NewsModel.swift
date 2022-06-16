//
//  NewsModel.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/16.
//

import Foundation

struct NewsModel: Codable {
    let item: Item
    
    struct Item: Codable {
        let title: String
        let link: String
    }
}
