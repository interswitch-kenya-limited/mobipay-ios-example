//
//  SubmitCardPayment.swift
//  mobpay-ios
//
//  Created by Allan Mageto on 18/06/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//

import Foundation
import CryptoSwift
import PercentEncoder
func generateLink(transactionRef:String,merchantId: String, payload: CardPaymentStruct,transactionType:String)throws->URL{
    let encoder = JSONEncoder()
    do {
        let jsonData = try encoder.encode(payload)
        let payload = String(data: jsonData, encoding: .utf8)
        let transactionType:String = transactionType
        let key:String = generateKey(length: 16)
        // 16 bytes for AES128
        let iv:String = generateKey(length: 16)
        let encryptedKey:String = try RSAUtil.encryptBrowserPayload(payload: key)
        let encryptedIv:String = try RSAUtil.encryptBrowserPayload(payload: iv)
        let aes = try AES(key: key, iv: iv) // aes128
        let ciphertext = try aes.encrypt(Array(payload!.utf8))
        let cryptedMessage = ciphertext.toBase64()
        let encodedCryptedMessage = PercentEncoding.encodeURIComponent.evaluate(string: cryptedMessage!)
        let encodedEncryptedKey = PercentEncoding.encodeURIComponent.evaluate(string: encryptedKey)
        let encodedEncrytpedIv = PercentEncoding.encodeURIComponent.evaluate(string: encryptedIv)
        let webCardinalURL = URL(string: "https://testmerchant.interswitch-ke.com/sdkcardinal?transactionType=\(transactionType)&key=\(encodedEncryptedKey)&iv=\(encodedEncrytpedIv)&payload=\(encodedCryptedMessage)")!
        return webCardinalURL
    } catch {
        throw error
    }
    
    //rsa encrypt the payload
    
    
    
}


func generateKey(length: Int) -> String {
    let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let allowedCharsCount = UInt32(allowedChars.count)
    var key = ""
    
    for _ in 0..<length {
        let randomNum = Int(arc4random_uniform(allowedCharsCount))
        let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
        let newCharacter = allowedChars[randomIndex]
        key += String(newCharacter)
    }
    return key
}
