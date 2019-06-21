//
//  submitMobilePayment.swift
//  mobpay-ios
//
//  Created by Allan Mageto on 18/06/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//

import Foundation
import PercentEncoder

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
    
    var request = URLRequest(url: url)
    let encodedUrl = PercentEncoding.encodeURIComponent.evaluate(string: url.absoluteString)
    request.httpMethod = httpRequest
    let signatureItems:Array<String> = [request.httpMethod!,encodedUrl, timestamp, nonce, clientId, clientSecret]
    let hashedJoinedItems = [UInt8](signatureItems.joined(separator: "&").utf8)
    let sha1ofbytesof = hashedJoinedItems.sha1()
    
    let signature = sha1ofbytesof.toBase64()
    let encodedClientId = (clientId.data(using: String.Encoding.utf8)! as NSData).base64EncodedData()
    var headers = request.allHTTPHeaderFields ?? [:]
    headers["Content-Type"] = "application/json"
    headers["User-Agent"] = "iOS"
    headers["Accept"] = "application/json"
    headers["Nonce"] = nonce
    headers["Timestamp"] = timestamp
    headers["SignatureMethod"] = signatureMethod
    headers["Signature"] = signature
    headers["Authorization"] = "InterswitchAuth " + String(bytes: encodedClientId, encoding: .utf8)!
    request.allHTTPHeaderFields = headers
    
    let encoder = JSONEncoder()
    do {
        let jsonData = try encoder.encode(payload)
        request.httpBody = jsonData
        print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
    } catch {
        //            completion(error)
    }
    
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    
    let task = session.dataTask(with: request) { (responseData, response, responseError) in
        guard responseError == nil else {
            return
        }
        if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
            completion(utf8Representation)
            print("response: ", utf8Representation)
        } else {
            completion("no readable data received in response")
        }
    }
    task.resume()
}
