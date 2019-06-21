//
//  Card.swift
//  functionTest
//
//  Created by interswitchke on 22/05/2019.
//  Copyright © 2019 interswitchke. All rights reserved.
//

import Foundation

// card structure
public struct Card{
    var pan : String;
    var cvv : String;
    var expiryYear : String;
    var expiryMonth : String;
    var tokenize: Bool = true;
    var payWithToken: Bool = false
    let cardRegex = try! NSRegularExpression(pattern: "[^\\d.]", options: NSRegularExpression.Options.caseInsensitive)
    
    
    public init(pan: String,cvv: String, expiryYear: String, expiryMonth: String, tokenize: Bool) {
        self.pan = pan;
        self.cvv = cvv;
        self.expiryYear = expiryYear;
        self.expiryMonth = expiryMonth;
        self.tokenize = tokenize;
    }
    
    enum cardType: Int{
        case VISA = 1, MASTERCARD = 2, AMEX = 4, DISCOVER = 8, VERVE = 10;
    }
    var fullExpiry: String {
        get{
            return expiryMonth + expiryYear
        }
    }
    
    var cardFullyValid: Bool{
        get{
            return isCardValid(cvv: cvv, pan: pan, fullExpiry: fullExpiry)
        }
    }
    
    
    func isPanValid(pan: String) -> Bool{
        let range = NSMakeRange(0, pan.count)
        if pan == "null" || pan.isEmpty  {
            return false;
        }
        let modPan = cardRegex.stringByReplacingMatches(in: pan, options: [], range: range, withTemplate: "")
        let type = getType(cardNumber: modPan)
        if type != "null" {
            switch type {
            case "VERVE":
                if (modPan.count == 16 || pan.count == 19) {
                    return true;
                }
            default:
                if(modPan.count == 16){
                    return true;
                }
            }
        }
        return false;
    }
    
    
    func getType(cardNumber: String) -> String{
        let range = NSMakeRange(0, cardNumber.count)
        if cardNumber.isEmpty {
            return "null";
        }
        let modCardNumber = cardRegex.stringByReplacingMatches(in: cardNumber, options: [], range: range, withTemplate: "")
        let cardType = ACCEPTED_CARD_PATTERN_TYPES(cardNumber: modCardNumber)
        if cardType == "null" {
            return "null";
        }
        return cardType
    }
    
    func ACCEPTED_CARD_PATTERN_TYPES(cardNumber: String)-> String{
        let range = NSMakeRange(0, cardNumber.count)
        let verveRegex = try! NSRegularExpression(pattern: "^(50)[0-9]{0,17}$")
        let visaRegex = try! NSRegularExpression(pattern: "^4[0-9]{1,12}(?:[0-9]{6})?$")
        let masterCardRegex = try! NSRegularExpression(pattern: "^5[1-5][0-9]{0,14}$")
        
        func verveChecker(cardNumber : String)-> Bool{
            return verveRegex.firstMatch(in: cardNumber, options: [], range: range) != nil
        }
        func visaChecker(CardNumber: String)-> Bool{
            return visaRegex.firstMatch(in: cardNumber, options: [], range: range) != nil
        }
        func masterCardChecker(CardNumber: String)->Bool{
            return masterCardRegex.firstMatch(in: cardNumber, options: [], range: range) != nil
        }
        switch true {
        case verveChecker(cardNumber: cardNumber):
            return "VERVE"
        case visaChecker(CardNumber: cardNumber):
            return "VISA"
        case masterCardChecker(CardNumber: cardNumber):
            return "MASTERCARD"
        default:
            return "null"
        }
    }
    
    //checks if the cvv is valid
    
    func isCvvValid(cvv: String) -> Bool {
        if cvv.count == 3 {
            return true;
        }else{
            return false;
        }
    }
    
    func isCardValid(cvv: String, pan: String, fullExpiry: String) -> Bool {
        let cvvValid: Bool = isCvvValid(cvv: cvv)
        let panValid: Bool = payWithToken || isPanValid(pan: pan)
        let expiryValid: Bool = isExpiryValid(fullExpiry: fullExpiry)
        return cvvValid && panValid && expiryValid
    }
    
    //checks if expiry date is valid by checking if the date is greater than the date today
    func isExpiryValid(fullExpiry: String) -> Bool {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "MM/yyyy"
        let calendar = Calendar.current
        let formatedFullExpiry = format.date(from: expiryMonth+"/"+expiryYear)
        let todaysDate = format.date(from: String(calendar.component(.month, from: date))+"/"+String(calendar.component(.year, from: date)))
        return formatedFullExpiry! > todaysDate!;
    }
    
}
