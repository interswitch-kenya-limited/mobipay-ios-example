//
//  Payloads.swift
//  mobpay-ios
//
//  Created by Allan Mageto on 19/06/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//

import Foundation


struct CardPaymentStruct: Codable {
    let amount: String
    let orderId: String
    let transactionRef: String
    let terminalType: String
    let terminalId :String
    let paymentItem :String
    let provider: String
    let merchantId: String
    let authData: String
    let customerInfor: String
    let currency: String
    let country: String
    let city: String
    let narration: String
    let domain: String
    let preauth:String
    let fee: String
    let paca: String
}



struct MobilePaymentStruct: Codable {
    let amount: String
    let orderId: String
    let transactionRef: String
    let terminalType: String
    let terminalId :String
    let paymentItem :String
    let provider: String
    let merchantId: String
    let customerInfor: String
    let currency: String
    let country: String
    let city: String
    let narration: String
    let domain: String
    let phone:String
}


public struct MerchantConfig{
    let merchantId:String
    let merchantName:String
    let clientId:String
    let clientSecret:String
    let cardStatus:Int
    let mpesaStatus:Int
    let equitelStatus:Int
    let tkashStatus:Int
    let airtelStatus:Int
    let paycodeStatus:Int
    let bnkStatus:Int
    let mpesaPaybill:String
    let equitelPaybill:String
    let tokenizeStatus:Int
    let cardauthStatus:Int
    let cardPreauth:Int
    let merchantDomain:String
}
