//
//  Mobile.swift
//  mobpay-ios
//
//  Created by Allan Mageto on 30/05/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//

import Foundation

public struct Mobile {
 
    var phone:String;
   
    public init (phone:String) {
        self.phone = phone;
    }
 
    
    func refreshValidity(){
        
    }
    
    
    var provider:String{
        get{
            return providersAndPatterns(phone: phone).0
        }
    }
    var pattern:NSRegularExpression{
        get{
            return providersAndPatterns(phone: phone).1
        }
    }
    
  
    var mobilePartiallyValid: Bool{
        get{
            return setMobilePartiallyValid();
        }
    }
    
    var mobileFullyValid: Bool {
        get{
            return setMobileFullyValid();
        }
    }
    
    func setMobilePartiallyValid() -> Bool{
        let range = NSMakeRange(0, phone.count)
//        provider = providersAndPatterns(phone: <#T##String#>)
        return pattern.firstMatch(in: phone, options: [], range: range) != nil;
    }
    
    func setMobileFullyValid()-> Bool{
        return mobilePartiallyValid && (phone.count == 10);
    }
    

    func providersAndPatterns(phone: String)->(String,NSRegularExpression){
        var provider:String;
        var pattern:NSRegularExpression;
        let range = NSMakeRange(0, phone.count)
        let mpesaRegex = try! NSRegularExpression(pattern: "^(\\+?254|0)[7]([0-2][0-9]|[9][0-9]|[4]([0-3]|[6]|[8]))[0-9]{0,6}$")
        let eazzyPayRegex = try! NSRegularExpression(pattern: "^4[0-9]{1,12}(?:[0-9]{6})?$")
        
        func mpesaChecker(phone : String)-> Bool{
            return mpesaRegex.firstMatch(in: phone, options: [], range: range) != nil
        }
        func eazzyPayChecker(phone: String)-> Bool{
            return eazzyPayRegex.firstMatch(in: phone, options: [], range: range) != nil
        }
        switch true {
        case mpesaChecker(phone: phone):
            provider = "703"
            //use the mpesa regex
            pattern = try!NSRegularExpression(pattern: "^(\\+?254|0)[7]([0-2][0-9]|[9][0-9]|[4]([0-3]|[6]|[8]))[0-9]{0,6}$")
            return (provider,pattern)
        case eazzyPayChecker(phone: phone):
            provider = "708"
            //use the eazzy pay regex
            pattern = try!NSRegularExpression(pattern: "^4[0-9]{1,12}(?:[0-9]{6})?$")
            return (provider,pattern)
        default:
            provider = "The type selected does not have a corresponding provider set"
            pattern = try!NSRegularExpression(pattern: "!(.*)")
            return (provider,pattern);
        }
    }
   
}

