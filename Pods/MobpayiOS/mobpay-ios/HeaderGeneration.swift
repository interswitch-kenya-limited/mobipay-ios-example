//
//  HeaderGeneration.swift
//  mobpay-ios
//
//  Created by Allan Mageto on 28/06/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//

import Foundation
import PercentEncoder

func generateHeaders(clientId:String,clientSecret:String,httpRequest: String,path:String)throws->URLRequest{
    do {
        let nonceRegex = try NSRegularExpression(pattern: "-", options: NSRegularExpression.Options.caseInsensitive)
        
        let rawNonce = UUID().uuidString
        let nonce = nonceRegex.stringByReplacingMatches(in: rawNonce, options: [], range: NSMakeRange(0, rawNonce.count), withTemplate: "")
        let signatureMethod:String = "SHA1";
        
        
        let timestamp = String(Int(NSDate().timeIntervalSince1970))
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "testids.interswitch.co.ke"
        urlComponents.port = 18082
        urlComponents.path = path
        guard let url = urlComponents.url else {
            throw fatalError("Unable to create url from the given components")
        }
        
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
        return request
    } catch {
        throw error
    }
}
