//
//  Mobile.swift
//  mobpay-ios
//
//  Created by Allan Mageto on 30/05/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//

import Foundation

public class Mobile {
    var phone:String;
//    var  type:Type;
    var provider:String;
    var pattern:NSRegularExpression?;
//    var providerType = ["MPESA","M-PESA","EAZZYPAY","Eazzy Pay"]

    
    public init (phone:String) {
        self.provider = "meh"
        self.phone = phone;
//        self.mobileFullyValid = false
//    self.setType(type);
    }
    
//    var providerType
    
    func refreshValidity(){
        
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
        return pattern!.firstMatch(in: phone, options: [], range: range) != nil;
    }
    
    func setMobileFullyValid()-> Bool{
        return mobilePartiallyValid && (phone.count == 10);
    }
    

    func providersAndPatterns(phone: String)->Any{
        let range = NSMakeRange(0, phone.count)
        let mpesaRegex = try! NSRegularExpression(pattern: "^(\\+?254|0)[7]([0-2][0-9]|[9][0-3])[0-9]{0,6}$")
        let eazzyPayRegex = try! NSRegularExpression(pattern: "^4[0-9]{1,12}(?:[0-9]{6})?$")
        
        func mpesaChecker(phone : String)-> Bool{
            return mpesaRegex.firstMatch(in: phone, options: [], range: range) != nil
        }
        func eazzyPayChecker(phone: String)-> Bool{
            return eazzyPayRegex.firstMatch(in: phone, options: [], range: range) != nil
        }
        switch true {
        case mpesaChecker(phone: phone):
            provider = "MPESA"
            pattern = try!NSRegularExpression(pattern: "^(\\+?254|0)[7]([0-2][0-9]|[9][0-3])[0-9]{0,6}$")
            return (provider,pattern)
        case eazzyPayChecker(phone: phone):
            provider = "EAZZYPAY"
            pattern = try!NSRegularExpression(pattern: "^4[0-9]{1,12}(?:[0-9]{6})?$")
            return (provider,pattern)
        default:
            provider = "The type selected does not have a corresponding provider set"
            pattern = try!NSRegularExpression(pattern: "!(.*)")
            return (provider,pattern);
        }
    }
}

//public enum Type {
//        MPESA("M-PESA"), EAZZYPAY("Eazzy Pay");
//        public String value;
//
//        Type(String value) {
//        this.value = value;
//        }
//
//        @Override
//        public String toString() {
//        return value;
//        }
//    }

//public class Mobile extends BaseObservable implements Serializable {
//    private String phone;
//    private Type type;
//    private String provider;
//    private boolean mobileFullyValid;
//    private boolean mobilePartiallyValid;
//    private Pattern pattern;
//
//    public Mobile(String phone, Type type) {
//        this.phone = phone;
//        this.setType(type);
//    }
//
//    public Mobile() {
//
//    }
//
//    public void refreshValidity() {
//        setMobilePartiallyValid(this.pattern != null && this.phone != null && this.pattern.matcher(this.phone).matches());
//        setMobileFullyValid(this.mobilePartiallyValid && phone.length() == 10);
//    }
//
//    public String getPhone() {
//        return phone;
//    }
//
//    public void setPhone(String phone) {
//        this.phone = phone;
//        refreshValidity();
//    }
//
//    public Type getType() {
//        return type;
//    }
//
//    public void setType(Type type) {
//        switch (type) {
//        case MPESA:
//            this.provider = "702";
//            this.setPattern(Pattern.compile("^(\\+?254|0)[7]([0-2][0-9]|[9][0-3])[0-9]{0,6}$"));
//            break;
//        case EAZZYPAY:
//            this.provider = "708";
//            this.setPattern(Pattern.compile("^(?:254|\\+254|0)?76[34]([0-9]{0,6})$"));
//            break;
//        default:
//            throw new IllegalArgumentException("The type selected does not have a corresponding provider set");
//        }
//        this.type = type;
//    }
//
//    public String getProvider() {
//        return provider;
//    }
//
//    public void setProvider(String provider) {
//        this.provider = provider;
//    }
//
//    @Bindable
//    public boolean isMobileFullyValid() {
//        return mobileFullyValid;
//    }
//
//    public void setMobileFullyValid(boolean mobileFullyValid) {
//        this.mobileFullyValid = mobileFullyValid;
//        notifyPropertyChanged(BR.mobileFullyValid);
//    }
//
//    @Bindable
//    public boolean isMobilePartiallyValid() {
//        return mobilePartiallyValid;
//    }
//
//    public void setMobilePartiallyValid(boolean mobilePartiallyValid) {
//        this.mobilePartiallyValid = mobilePartiallyValid;
//        notifyPropertyChanged(BR.mobilePartiallyValid);
//    }
//
//    public Pattern getPattern() {
//        return pattern;
//    }
//
//    public void setPattern(Pattern pattern) {
//        this.pattern = pattern;
//        refreshValidity();
//    }
//
//
//}
