//
//  CardPaymentStruct.swift
//  mobpay-ios
//
//  Created by Allan Mageto on 18/06/2019.
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
}
