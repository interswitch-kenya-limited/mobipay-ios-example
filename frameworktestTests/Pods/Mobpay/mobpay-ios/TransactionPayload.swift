//
//  TransactionPayload.swift
//  mobpay-ios
//
//  Created by Allan Mageto on 30/05/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//

import Foundation

class TransactionPayload{
    var amount:String;
    var transactionRef:String;
    var preauth:String;
    var orderId:String;
    var terminalType:String;
    var terminalId:String;
    var paymentItem:String;
    var merchantId:String;
    var customerInfor:String;
    var currency:String;
    var country:String;
    var city:String;
    var domain:String;
    var narration:String;

    public init(Merchant: Merchant,Payment: Payment, Customer: Customer) {
        self.amount = Payment.amount;
        self.transactionRef = Payment.transactionRef;
        self.orderId = Payment.orderId;
        self.terminalType = Payment.terminalType;
        self.terminalId = Payment.terminalId;
        self.paymentItem = Payment.paymentItem;
        self.merchantId = Merchant.merchantId;
        self.currency = Payment.currency;
        self.domain = Merchant.domain;
        self.customerInfor = Customer.customerId+"|"+Customer.firstName+"|"+Customer.secondName+"|"+Customer.email+"|"+Customer.mobile+"|"+Customer.city+"|"+Customer.country+"|"+Customer.postalCode+"|"+Customer.street+"|"+Customer.state;
        self.country = Customer.country;
        self.city = Customer.city;
        self.preauth = Payment.preauth;
        self.narration = Payment.narration;
    }

}
