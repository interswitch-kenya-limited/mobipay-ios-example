//
//  Customer.swift
//  functionTest
//
//  Created by interswitchke on 22/05/2019.
//  Copyright © 2019 interswitchke. All rights reserved.
//

import Foundation

public class Customer{
    var customerId,firstName,secondName,email,mobile,city,country,postalCode,street,state : String;
    
    public init(customerId: String,firstName : String , secondName : String,email : String,mobile : String, city : String, country : String, postalCode : String, street : String, state : String) {
        self.customerId = customerId
        self.firstName = firstName
        self.secondName = secondName
        self.email = email
        self.mobile = mobile
        self.city = city
        self.country = country
        self.postalCode = postalCode
        self.street = street
        self.state = state
    }

    
}

