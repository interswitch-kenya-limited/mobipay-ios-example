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
import SafariServices
import CocoaMQTT

public class Mobpay:UIViewController {

    public static let instance = Mobpay()
    
    var mqtt: CocoaMQTT!
    var merchantId:String!
    var transactionRef:String!
    
    public var MobpayDelegate:MobpayPaymentDelegate?

    
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
    
    
    //launch ui
    public func launchUI(merchant:Merchant,payment:Payment,customer:Customer,clientId:String,clientSecret:String,cardTokens:Array<CardToken>? = nil,launchUI:@escaping (UIViewController)->())throws{
        do {
            try getMerchantConfigs(clientId: clientId, clientSecret: clientSecret){
                (merchantConfig) in
                let UserInterfaceController = InterSwitchPaymentUI(payment: payment, customer: customer,clientId: clientId,clientSecret: clientSecret,merchantConfig: merchantConfig,cardTokens:cardTokens)
                UserInterfaceController.InterSwitchPaymentUIDelegate = self
                launchUI(UserInterfaceController)
            }
        } catch {
            throw error
        }
    }
    
    public func submitCardPayment(card: Card,merchant: Merchant,payment:Payment,customer:Customer,clientId:String,clientSecret:String,previousUIViewController:UIViewController,completion:@escaping(String)->())throws{
        do {
            //[TODO] get merchant config from our servers
            let authData:String = try RSAUtil.getAuthDataMerchant(panOrToken: card.pan, cvv: card.cvv, expiry: card.expiryYear + card.expiryMonth, tokenize: card.tokenize ? "1" : "0", separator: "D" )
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
                narration: payment.narration, domain: merchant.domain,preauth: "0",fee: "0",paca: "1"
            )
            self.merchantId = merchant.merchantId
            self.transactionRef = payment.transactionRef
            let webCardinalURL = try generateLink(transactionRef: payment.transactionRef, merchantId: merchant.merchantId, payload: payload,transactionType: "CARD")
            self.setUpMQTT()
            let threeDS = ThreeDSWebView(webCardinalURL: webCardinalURL)
            DispatchQueue.main.async {
                previousUIViewController.navigationController?.pushViewController(threeDS, animated: true)
            }
            mqtt.didReceiveMessage = { mqtt, message, id in
                mqtt.disconnect()
                previousUIViewController.navigationController?.popViewController(animated: true)
                completion(message.string!)
            }
        } catch {
            throw error
        }
    }
    
    public func submitTokenPayment(cardToken: CardToken,merchant: Merchant,payment:Payment,customer:Customer,clientId:String,clientSecret:String,previousUIViewController:UIViewController,completion:@escaping(String)->())throws{
        do {
            //[TODO] get merchant config from our servers
            let authData:String = try RSAUtil.getAuthDataMerchant(panOrToken: cardToken.token, cvv: cardToken.cvv, expiry: cardToken.expiry, tokenize: "true", separator: ",")
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
                narration: payment.narration, domain: merchant.domain,preauth: "0",fee: "0",paca: "1"
            )
            self.merchantId = merchant.merchantId
            self.transactionRef = payment.transactionRef
            let webCardinalURL = try generateLink(transactionRef: payment.transactionRef, merchantId: merchant.merchantId, payload: payload,transactionType: "TOKEN")
            self.setUpMQTT()
            let threeDS = ThreeDSWebView(webCardinalURL: webCardinalURL)
            DispatchQueue.main.async {
                previousUIViewController.navigationController?.pushViewController(threeDS, animated: true)
            }
            mqtt.didReceiveMessage = { mqtt, message, id in
                mqtt.disconnect()
                previousUIViewController.navigationController?.popViewController(animated: true)
                completion(message.string!)
            }
        } catch {
            throw error
        }
    }
    
    
    func getMerchantConfigs(clientId: String, clientSecret: String,completion:@escaping(MerchantConfig)->())throws{
        do {
            let request = try generateHeaders(clientId: clientId, clientSecret: clientSecret, httpRequest: "GET", path: "/api/v1/merchant/mfb/confignew")
            let task = try URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else{
                    return
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    do{
                        let responseAsJson:Dictionary<String,Any> = try self.convertToDictionary(message:dataString)!
                        let configs = responseAsJson["config"] as? Dictionary<String,Any>
                        let merchantConfig:MerchantConfig = try MerchantConfig(merchantId: configs!["merchantId"] as! String, merchantName: configs!["merchantName"] as! String, clientId: configs!["clientId"] as! String, clientSecret: configs!["clientSecret"] as! String, cardStatus: configs!["cardStatus"] as! Int, mpesaStatus: configs!["mpesaStatus"] as! Int, equitelStatus: configs!["equitelStatus"] as! Int, tkashStatus: configs!["tkashStatus"] as! Int, airtelStatus: configs!["airtelStatus"] as! Int, paycodeStatus: configs!["paycodeStatus"] as! Int, bnkStatus: configs!["bnkStatus"] as! Int, mpesaPaybill: configs!["mpesaPaybill"] as! String, equitelPaybill: configs!["equitelPaybill"] as! String, tokenizeStatus: configs!["tokenizeStatus"] as! Int, cardauthStatus: configs!["cardauthStatus"] as! Int, cardPreauth: configs!["cardPreauth"] as! Int, merchantDomain: configs!["domain"] as! String)
                        completion(merchantConfig)
                    } catch{
                        return
                    }
                    
                }
            }
            task.resume()
        } catch {
            throw error
        }
    }

    func convertToDictionary(message: String)throws -> [String: Any]? {
        if let data = message.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                throw error
            }
        }
        return nil
    }
    
    func setUpMQTT(){
        let clientID = "iOS-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: "testmerchant.interswitch-ke.com", port: 1883)
        mqtt.username = ""
        mqtt.password = ""
        mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt.keepAlive = 60
        mqtt.connect()
        mqtt.delegate = self
    }
}

extension Mobpay:CocoaMQTTDelegate{
    public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        debugPrint("mqtt Connected")
        self.mqtt.subscribe("merchant_portal/\(self.merchantId!)/\(self.transactionRef!)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        debugPrint(message.string!)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        debugPrint(topics)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        
    }
    
    public func mqttDidPing(_ mqtt: CocoaMQTT) {
        
    }
    
    public func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        
    }
    
    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        debugPrint("mqtt disconnected")
    }
}

extension Mobpay:InterSwitchPaymentUIDelegate{
    func didReceivePayload(_ message: String) {
        self.MobpayDelegate?.launchUIPayload(message)
    }
}

public protocol MobpayPaymentDelegate {
    func launchUIPayload(_ message: String)
}
