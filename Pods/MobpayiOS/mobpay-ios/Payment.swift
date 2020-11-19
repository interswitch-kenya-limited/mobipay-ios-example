//
//  Payment.swift
//  functionTest
//
//  Created by interswitchke on 22/05/2019.
//  Copyright © 2019 interswitchke. All rights reserved.
//

import Foundation


public struct Payment{
    var amount, transactionRef, orderId,terminalType,terminalId,paymentItem,currency,preauth,narration: String;
    
    public init(amount: String, transactionRef: String, orderId : String, terminalType: String, terminalId: String, paymentItem: String,currency: String,preauth: String,narration:String) {
        self.amount = amount
        self.transactionRef = transactionRef
        self.orderId = orderId
        self.terminalType = terminalType
        self.terminalId = terminalId
        self.paymentItem = paymentItem
        self.currency = currency
        self.preauth = preauth
        self.narration = narration
    }
    
    
}
