//
//  MobilePaymentStruct.swift
//
//
//  Created by Allan Mageto on 18/06/2019.
//

import Foundation

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
