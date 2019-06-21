//
//  Mobpay.swift
//  mobpay-ios
//
//  Created by interswitchke on 21/05/2019.
//  Copyright © 2019 interswitchke. All rights reserved.
//


import Foundation
import CryptoSwift
import SwiftyRSA

public class Mobpay {
//    var backEndResponse:String?;
    public static let instance = Mobpay()
    
    //make card token payment
    public func makeCardTokenPayment(cardToken: CardToken,merchant: Merchant, payment: Payment, customer: Customer,clientId:String,clientSecret:String,completion:@escaping (String)->())throws{
        let authData:String = try!RSAUtil.getAuthDataMerchant(panOrToken: cardToken.token, cvv: cardToken.cvv, expiry: cardToken.expiry, tokenize: "0" )
        let payload = CardPaymentStruct(
            amount: payment.amount,
            orderId: payment.orderId,
            transactionRef: payment.transactionRef,
            terminalType: payment.terminalType,
            terminalId: payment.terminalId, paymentItem: payment.paymentItem, provider: "VSI",
            merchantId: merchant.merchantId,
            authData: authData,
            customerInfor: customer.customerId+"|"+customer.firstName+"|"+customer.secondName+"|"+customer.email+"|"+customer.mobile+"|"+customer.city+"|"+customer.country+"|"+customer.postalCode+"|"+customer.street+"|"+customer.state,
            currency:payment.currency, country:customer.country,
            city:customer.city,
            narration: payment.narration, domain: merchant.domain
        )
        submitCardTokenPayment(clientId: clientId, clientSecret: clientSecret, httpRequest: "POST", payload: payload){
            (urlResponse) in completion(urlResponse)
        }
    }
    
    //make card payment
    public func makeCardPayment(card: Card,merchant: Merchant,payment:Payment,customer:Customer,clientId:String,clientSecret:String,completion: @escaping (String)->())throws{
        let authData:String = try!RSAUtil.getAuthDataMerchant(panOrToken: card.pan, cvv: card.cvv, expiry: card.expiryYear + card.expiryMonth, tokenize: card.tokenize ? "1" : "0" )
        let payload = CardPaymentStruct(
            amount: payment.amount,
            orderId: payment.orderId,
            transactionRef: payment.transactionRef,
            terminalType: payment.terminalType,
            terminalId: payment.terminalId, paymentItem: payment.paymentItem, provider: "VSI",
            merchantId: merchant.merchantId,
            authData: authData,
            customerInfor: customer.customerId+"|"+customer.firstName+"|"+customer.secondName+"|"+customer.email+"|"+customer.mobile+"|"+customer.city+"|"+customer.country+"|"+customer.postalCode+"|"+customer.street+"|"+customer.state,
            currency:payment.currency, country:customer.country,
            city:customer.city,
            narration: payment.narration, domain: merchant.domain
        )
        
        submitPayment(clientId: clientId, clientSecret: clientSecret, httpRequest: "POST", payload: payload) { (urlResponse) in
            completion(urlResponse)
        }
        
    }
    
    
    //MOBILE MONEY
    //make mobile money payment
    public func makeMobileMoneyPayment(mobile:Mobile , merchant:Merchant ,payment: Payment ,customer: Customer,clientId:String,clientSecret:String,completion:@escaping (String)->())throws{
        let mobilePayload = MobilePaymentStruct(amount: payment.amount, orderId: payment.orderId, transactionRef: payment.transactionRef, terminalType: payment.terminalType, terminalId: payment.terminalId, paymentItem: payment.paymentItem, provider: mobile.provider, merchantId: merchant.merchantId,
                                                customerInfor: customer.customerId+"|"+customer.firstName+"|"+customer.secondName+"|"+customer.email+"|"+customer.mobile+"|"+customer.city+"|"+customer.country+"|"+customer.postalCode+"|"+customer.street+"|"+customer.state,
                                                currency: payment.currency, country: customer.country, city: customer.city, narration: payment.narration, domain: merchant.domain, phone: mobile.phone)
        
        
        submitMobilePayment(clientId: clientId, clientSecret: clientSecret, httpRequest: "POST", payload: mobilePayload) { (urlResponse) in
            completion(urlResponse)
        }
    }
    
    //confirm mobile money payment
    public func confirmMobileMoneyPayment(orderId:String,clientId:String,clientSecret:String,completion:@escaping (String)->())throws{
        submitConfirmMobilePayment(clientId: clientId, clientSecret: clientSecret, httpRequest: "GET", transactionRef: orderId) { (urlResponse) in completion(urlResponse)}
    }
    

}
