//
//  SubmitCardTokenPayment.swift
//  mobpay-ios
//
//  Created by Allan Mageto on 20/06/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//

import Foundation
import PercentEncoder

func submitCardTokenPayment(clientId:String, clientSecret:String,httpRequest: String,payload: CardPaymentStruct, completion:@escaping (String)->()) {
    let nonceRegex = try! NSRegularExpression(pattern: "-", options: NSRegularExpression.Options.caseInsensitive)
    
    let rawNonce = UUID().uuidString
    let nonce = nonceRegex.stringByReplacingMatches(in: rawNonce, options: [], range: NSMakeRange(0, rawNonce.count), withTemplate: "")
    let signatureMethod:String = "SHA1";
    
    
    let timestamp = String(Int(NSDate().timeIntervalSince1970))
    
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "testids.interswitch.co.ke"
    urlComponents.port = 9080
    urlComponents.path = "/api/v1/merchant/transact/tokens"
    guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
    
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
    } catch {
        //        completion(String(error))
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
