//
//  ViewController.swift
//  frameworktest
//
//  Created by Allan Mageto on 24/05/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//

import UIKit
//import Alamofire
import mobpay
import Eureka
import CryptoSwift
//import CreditCardRow
class ViewController: FormViewController{
    //CLIENT VARIABLES
    var clientId:String = "";
    var clientSecret:String = "";
    
    //CUSTOMER VARIABLES
    var customerId:String = "";
    var firtsName:String = "";
    var secondName:String = "";
    var emailAddress:String = "";
    var mobileNumber:String = "";
    var city:String = "";
    var country:String = "";
    var postalCode:String = "";
    var street:String = "";
    var state:String = "";
    
    //merchant variables
    var merchantId:String = "";
    var merchantDomain:String = "";
    //payment Details
    var paymentAmount:Int = 0;
    var transactionRef:String = "";
    var orderId:String = "";
    var termianalId:String = "";
    var terminalType:String = "";
    var paymentItem:String = "";
    var currency:String = "";
    var preauth:String = "";
    var narration:String = "";
    //card variables
    var pan:Int = 0;
    var cvv:Int = 0;
    var expYear:Int = 0;
    var expMonth:Int = 0;
    var tokenize:Bool = false;
    //mobile
    var phone:Int = 0;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        func showResponse(message: String){
            let alert = UIAlertController(title: "Backend Report", message: message, preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        //CUSTOMER DETAILS SECTION
        form
        +++ Section("Client Details")
            <<< TextRow(){
                row in
                row.title = "Client Id"
                row.placeholder = "Client Id"
        
            }.onChange({(row) in
                self.clientId = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){
                row in
                row.title = "Client Secret"
                row.placeholder = "Client Secret"
            }
        +++ Section("Customer Details")
            <<< TextRow(){row in
                row.title = "Customer ID"
                row.add(rule: RuleRequired())
                row.placeholder = "Customer ID"
                }.onChange({ (row) in
                    self.customerId = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "First Name"
                row.placeholder = "Enter First Name"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.firtsName = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Second Name"
                row.placeholder = "Enter Second Name"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.secondName = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Email Address"
                row.placeholder = "Enter Email Address"
                row.add(rule: RuleEmail())
                row.add(rule: RuleRequired())
                }.cellUpdate {
                    cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                }.onChange({ (row) in
                    self.emailAddress = row.value != nil ? row.value! : ""
                })
            <<< PhoneRow(){row in
                row.title = "Mobile Number"
                row.placeholder = "Enter Phone Number"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.mobileNumber = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "City"
                row.placeholder = "City"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.city = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Country"
                row.placeholder = "Country"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.country = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Postal Code"
                row.placeholder = "Postal Code"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.postalCode = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Street"
                row.placeholder = "Street"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.street = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "State"
                row.placeholder = "State"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.state = row.value != nil ? row.value! : ""
                })
            
        //MERCHANT DETAILS
        +++ Section("Merchant Details")
            <<< TextRow(){row in
                row.title = "Merchant Id"
                row.placeholder = "Merchant Id"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.merchantId = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Domain"
                row.placeholder = "Domain"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.merchantDomain = row.value != nil ? row.value! : ""
                })
        
        //PAYMENT DETAILS
         +++ Section("Payment Details")
            <<< IntRow(){row in
                row.title = "Amount"
                row.placeholder = "999"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.paymentAmount = row.value != nil ? row.value! : 0
                })
            <<< TextRow(){row in
                row.title = "TransactionRef"
                row.placeholder = "TransactionRef"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.transactionRef = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Order ID"
                row.placeholder = "Order Id"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.orderId = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Terminal Type"
                row.placeholder = "Terminal Type"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.terminalType = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Terminal Id"
                row.placeholder = "Terminal Id"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.termianalId = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Payment Item"
                row.placeholder = "Payment Item"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.paymentItem = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Currency"
                row.placeholder = "Currency"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.currency = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Narration"
                row.placeholder = "Narration"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.narration = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Preauth"
                row.placeholder = "Preauth"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.preauth = row.value != nil ? row.value! : ""
                })
        
        //CARD DETAILS
        +++ Section("Card Details")
        <<< IntRow(){row in
                row.title = "PAN"
                row.placeholder = "4111 1111 1111 1111"
                row.add(rule: RuleRequired())
//                row.formatter = Formatter()
            }.onChange({ (row) in
                self.pan = row.value != nil ? row.value! : 0
            })
            <<< IntRow(){row in
                row.title = "CVV"
                row.placeholder = "999"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.cvv = row.value != nil ? row.value! : 0
                })
            <<< IntRow(){row in
                row.title = "Expiry Year"
                row.placeholder = "20"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.expYear = row.value != nil ? row.value! : 0
                })
            <<< IntRow(){row in
                row.title = "Expiry Month"
                row.placeholder = "2"
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.expMonth = row.value != nil ? row.value! : 0
                })
            <<< SwitchRow(){row in
                row.title = "Tokenize"
                row.add(rule: RuleRequired())
                row.value = true
                }.onChange({ (row) in
                    self.tokenize = row.value != nil ? row.value! : false
                })
            
        
        //MOBILE PAYMENT DETAILS
        +++ Section("Mobile Payment Details")
        <<< IntRow(){row in
            row.title = "Phone"
            row.placeholder = "0713805241"
            row.add(rule: RuleRequired())
            }.onChange({ (row) in
                self.phone = row.value != nil ? row.value! : 0
            })
        
            
        +++ Section()
            <<< ButtonRow(){row in
                row.title = "Submit"
                row.add(rule: RuleRequired())
                }.onCellSelection({ (cell,row) in
                    
                   // let newCard = Card(pan: "4111111111111111", cvv: "123", expiryYear: "20", expiryMonth: "02", tokenize: false)
                   // let newPayment = Payment(amount: "100", transactionRef: "66809285644", orderId: "OID123453", terminalType: "MOBILE", terminalId: "3TLP0001", paymentItem: "CRD", currency: "KES")
                   // let newCustomer = Customer(customerId: "12", firstName: "Allan", secondName: "Mageto", email: "allanbmageto@gmail.com", mobile: "0713805241", city: "NBI", country: "KE", postalCode: "00200", street: "WESTLANDS", state: "NBI")
                   // let newMerchant = Merchant(merchantId: "GEPGTZ0001", domain: "ISWKE")
                    let card = Card(pan: String(self.pan), cvv: String(self.cvv), expiryYear: String(self.expYear), expiryMonth: String(self.expMonth), tokenize: self.tokenize)
                    let payment = Payment(amount: String(self.paymentAmount), transactionRef: self.transactionRef, orderId: self.orderId, terminalType: self.terminalType, terminalId: self.termianalId, paymentItem: self.paymentItem, currency: self.currency, preauth: self.preauth, narration: self.narration)
                    let customer = Customer(customerId: self.customerId, firstName: self.firtsName, secondName: self.secondName, email: self.emailAddress, mobile: self.mobileNumber, city: self.city, country: self.country, postalCode: self.postalCode, street: self.street, state: self.state)
                    let merchant = Merchant(merchantId: self.merchantId, domain: self.merchantDomain)
                    
//                    try!Mobpay.instance.makeCardPayment(card: newCard, merchant: newMerchant, payment: newPayment, customer: newCustomer, clientId: "IKIA264751EFD43881E84150FDC4D7F0717AD27C4E64",clientSecret: "J3e432fg5qdpFXDsjlinBPGs/CgCNaUs5BHLFloO3/U="){ (completion) in showResponse(message: completion)
//                  }
                    
                    try!Mobpay.instance.makeCardPayment(card: card, merchant: merchant, payment: payment, customer: customer, clientId: self.clientId,clientSecret: self.clientSecret){ (completion) in showResponse(message: completion)

                    }
                    
                    
                    
                    
                })
            <<< ButtonRow() {
                $0.title = "Mobile money"
                }
                .onCellSelection { cell, row in
                    //let newPayment = Payment(amount: "100", transactionRef: "66809285644", orderId: "OID123453", terminalType: "MOBILE", terminalId: "3TLP0001", paymentItem: "CRD", currency: "KES", preauth: "0", narration: "payment-card")
//                    let newCustomer = Customer(customerId: "12", firstName: "Allan", secondName: "Mageto", email: "allanbmageto@gmail.com", mobile: "0713805241", city: "NBI", country: "KE", postalCode: "00200", street: "WESTLANDS", state: "NBI")
//                    let newMerchant = Merchant(merchantId: "ISWKEN0001", domain: "ISWKE")
//                    let newMobile = Mobile(phone: "0713805241")
                    let payment = Payment(amount: String(self.paymentAmount), transactionRef: self.transactionRef, orderId: self.orderId, terminalType: self.terminalType, terminalId: self.termianalId, paymentItem: self.paymentItem, currency: self.currency, preauth: self.preauth, narration: self.narration)
                    let customer = Customer(customerId: self.customerId, firstName: self.firtsName, secondName: self.secondName, email: self.emailAddress, mobile: self.mobileNumber, city: self.city, country: self.country, postalCode: self.postalCode, street: self.street, state: self.state)
                    let merchant = Merchant(merchantId: self.merchantId, domain: self.merchantDomain)
                    let mobile = Mobile(phone: String(self.phone))
        
                    try!Mobpay.instance.makeMobileMoneyPayment(mobile: mobile, merchant: merchant, payment: payment, customer: customer, clientId: self.clientId, clientSecret:self.clientSecret){ (completion) in showResponse(message: completion)
                        
                    }
        }
}

}
