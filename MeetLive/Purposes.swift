//
//  Purposes.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/07.
//

import Foundation

struct Purposes {
    let purposes: [String] = [
        "会場内で会いたい",
        "会場外で会いたい",
        "グッズ列同行",
        "ライブ同行",
        "グッズ交換",
        "その他"
    ]
    
    let displayPurposes: [String] = [
        "会場内",
        "会場外",
        "グッズ列同行",
        "ライブ同行",
        "グッズ交換",
        "その他"
    ]
    
    let colorPurposes: [[Float]] = [
        [255,75,0],
        [0,90,255],
        [3,175,122],
        [77,196,255],
        [246,170,0],
        [0,0,0]
    ]
}
