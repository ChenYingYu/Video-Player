//
//  VPTimeFormat.swift
//  VideoPlayer_Alan
//
//  Created by AlanChen on 2018/11/8.
//  Copyright © 2018年 ChenAlan. All rights reserved.
//

import Foundation

extension Int {
    
    func minute() -> Int {
        return self / 60
    }
    
    func second() -> Int {
        return self % 60
    }
    
    func twoDigitString() -> String {
        let string = self < 10 ? "0\(self)" : "\(self)"
        return string
    }
}
