//
//  main.swift
//  functionTest
//
//  Created by interswitchke on 21/05/2019.
//  Copyright © 2019 interswitchke. All rights reserved.
//


import Foundation
import CryptoSwift
import SwiftyRSA
import PercentEncoder
public class Mobpay {
    var backEndResponse:String?;
    public static let instance = Mobpay()
    
    //make card token payment
    public func makeCardTokenPayment(){}
    
    
    
    //confirm mobile money payment
    public func confirmMobileMoneyPayment(){}
    
    
    //payment structures
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
    
    
    
    func submitPayment(clientId:String, clientSecret:String,httpRequest: String,payload: CardPaymentStruct, completion:@escaping (String)->()) {
        let nonceRegex = try! NSRegularExpression(pattern: "-", options: NSRegularExpression.Options.caseInsensitive)
        
        let rawNonce = UUID().uuidString
        let nonce = nonceRegex.stringByReplacingMatches(in: rawNonce, options: [], range: NSMakeRange(0, rawNonce.count), withTemplate: "")
        let signatureMethod:String = "SHA1";
        
        
        let timestamp = String(Int(NSDate().timeIntervalSince1970))
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "testids.interswitch.co.ke"
        urlComponents.port = 9080
        urlComponents.path = "/api/v1/merchant/transact/cards"
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        print(url)
        
        // Specify this request as being a POST method
        var request = URLRequest(url: url)
        let encodedUrl = PercentEncoding.encodeURIComponent.evaluate(string: url.absoluteString)
        request.httpMethod = httpRequest
        // Make sure that we include headers specifying that our request's HTTP body
        // will be JSON encoded
        let signatureItems:Array<String> = [request.httpMethod!,encodedUrl, timestamp, nonce, clientId, clientSecret]
        let hashedJoinedItems = [UInt8](signatureItems.joined(separator: "&").utf8)
        let sha1ofbytesof = hashedJoinedItems.sha1()
        
        let signature = sha1ofbytesof.toBase64()
        let encodedClientId = (clientId.data(using: String.Encoding.utf8)! as NSData).base64EncodedData()
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        headers["User-Agent"] = "ios"
        headers["Accept"] = "application/json"
        headers["Nonce"] = nonce
        headers["Timestamp"] = timestamp
        headers["SignatureMethod"] = signatureMethod
        headers["Signature"] = signature
        headers["Authorization"] = "InterswitchAuth " + String(bytes: encodedClientId, encoding: .utf8)!
        request.allHTTPHeaderFields = headers
        
        // Now let's encode out Post struct into JSON data...
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(payload)
            // ... and set our request's HTTP body
            request.httpBody = jsonData
            //            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        } catch {
            //            completion(String(error))
        }
        
        // Create and run a URLSession data task with our JSON encoded POST request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                return
            }
            // APIs usually respond with the data you just sent in your POST request
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                
                print("response: ", utf8Representation)
                
                completion(utf8Representation)
            } else {
                completion("No readable data received in response")
            }
        }
        task.resume()
    }
    
    public func makeCardPayment(card: Card,merchant: Merchant,payment:Payment,customer:Customer,clientId:String,clientSecret:String,completion: @escaping (String)->())throws{
        let authData:String = try!RSAUtil.getAuthDataMerchant(panOrToken: card.pan, cvv: card.cvv, expiry: card.expiryYear + card.expiryMonth, tokenize: card.tokenize ? 1 : 0 )
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
            //            response = urlResponse;
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
            //            response = urlResponse;
            completion(urlResponse)
        }
    }
    
    func submitMobilePayment(clientId:String, clientSecret:String,httpRequest: String,payload: MobilePaymentStruct, completion:@escaping (String)->()) {
        let nonceRegex = try! NSRegularExpression(pattern: "-", options: NSRegularExpression.Options.caseInsensitive)
        
        let rawNonce = UUID().uuidString
        let nonce = nonceRegex.stringByReplacingMatches(in: rawNonce, options: [], range: NSMakeRange(0, rawNonce.count), withTemplate: "")
        let signatureMethod:String = "SHA1";
        
        
        let timestamp = String(Int(NSDate().timeIntervalSince1970))
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "testids.interswitch.co.ke"
        urlComponents.port = 9080
        urlComponents.path = "/api/v1/merchant/transact/bills"
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        print(url)
        
        // Specify this request as being a POST method
        var request = URLRequest(url: url)
        let encodedUrl = PercentEncoding.encodeURIComponent.evaluate(string: url.absoluteString)
        request.httpMethod = httpRequest
        // Make sure that we include headers specifying that our request's HTTP body
        // will be JSON encoded
        let signatureItems:Array<String> = [request.httpMethod!,encodedUrl, timestamp, nonce, clientId, clientSecret]
        let hashedJoinedItems = [UInt8](signatureItems.joined(separator: "&").utf8)
        let sha1ofbytesof = hashedJoinedItems.sha1()
        
        let signature = sha1ofbytesof.toBase64()
        let encodedClientId = (clientId.data(using: String.Encoding.utf8)! as NSData).base64EncodedData()
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        headers["User-Agent"] = "ios"
        headers["Accept"] = "application/json"
        headers["Nonce"] = nonce
        headers["Timestamp"] = timestamp
        headers["SignatureMethod"] = signatureMethod
        headers["Signature"] = signature
        headers["Authorization"] = "InterswitchAuth " + String(bytes: encodedClientId, encoding: .utf8)!
        request.allHTTPHeaderFields = headers
        
        // Now let's encode out Post struct into JSON data...
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(payload)
            // ... and set our request's HTTP body
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        } catch {
            //            completion(error)
        }
        
        // Create and run a URLSession data task with our JSON encoded POST request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                return
            }
            // APIs usually respond with the data you just sent in your POST request
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                completion(utf8Representation)
                print("response: ", utf8Representation)
            } else {
                completion("no readable data received in response")
            }
        }
        task.resume()
    }
}
