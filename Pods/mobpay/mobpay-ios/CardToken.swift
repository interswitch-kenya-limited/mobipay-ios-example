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
    var cvv:String;
    var panLast4Digits:String?
    var panFirst6Digits:String?
    
    public init(token:String,expiry:String,cvv:String){
        self.token = token;
        self.expiry = expiry;
        self.cvv = cvv;
    }
    
}
