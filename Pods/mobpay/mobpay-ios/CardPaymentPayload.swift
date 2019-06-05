//
//  CardPaymentPayload.swift
//  mobpay-ios
//
//  Created by Allan Mageto on 30/05/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//

import Foundation

class CardPaymentPayload:TransactionPayload{
//    var provider:String;
    var authData: String;
    
    public init(Merchant: Merchant, Payment: Payment, Customer: Customer, authData: String) {
        self.authData = authData;
        super.init(Merchant: Merchant, Payment: Payment, Customer: Customer);
        
//        self.provider = ""
    }
}

//public class MobilePaymentPayload extends TransactionPayload {
//    
//    private String provider;
//    private String phone;
//    
//    public MobilePaymentPayload(Merchant merchant, Payment payment, Customer customer, Mobile mobile) {
//        super(merchant, payment, customer);
//        this.provider = mobile.getProvider();
//        this.phone = mobile.getPhone();
//    }
//    
//    public String getProvider() {
//        return provider;
//    }
//    
//    public void setProvider(String provider) {
//        this.provider = provider;
//    }
//}
