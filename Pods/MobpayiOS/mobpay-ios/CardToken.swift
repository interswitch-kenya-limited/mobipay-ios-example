//
//  CardToken.swift
//  mobpay-ios
//
//  Created by Allan Mageto on 30/05/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//

import Foundation

//card token class

public struct CardToken {
    var token:String;
    var expiry:String;
    var cvv:String?
    var panLast4Digits:String?
    var panFirst6Digits:String?
    var tokenizedCardPan:String?
    public init(token:String,expiry:String,cvv:String? = nil,panLast4Digits:String? = nil,panFirst6Digits:String? = nil){
        self.token = token;
        self.expiry = expiry;
        self.cvv = cvv;
        self.panLast4Digits = panLast4Digits
        self.panFirst6Digits = panFirst6Digits
        self.tokenizedCardPan = "\(panFirst6Digits ?? "41111")******\(panLast4Digits ?? "1111")"
    }
    
}
