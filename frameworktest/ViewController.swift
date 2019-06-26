//
//  ViewController.swift
//  frameworktest
//
//  Created by Allan Mageto on 24/05/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//

import UIKit
import MobpayiOS
import Eureka
import CryptoSwift

class ViewController: FormViewController{
    //CLIENT VARIABLES
    var clientId:String = "IKIA7C2981C715915A2D9DF952D8422F956BAB4ABB8A";
    var clientSecret:String = "2NZ4AlYFzabz6+eTMp9pYJvcgWTLjfYBvsFQFRkfuUc=";
    
    //CUSTOMER VARIABLES
    var customerId:String = "test@example.com";
    var firstName:String = "John";
    var secondName:String = "Doe";
    var emailAddress:String = "johnDoe@test.com";
    var mobileNumber:String = "0712345678";
    var city:String = "NBI";
    var country:String = "KE";
    var postalCode:String = "00200";
    var street:String = "Westlands";
    var state:String = "NBI";
    
    //merchant variables
    var merchantId:String = "ISWKEN0001";
    var merchantDomain:String = "ISWKE";
    //payment Details
    var paymentAmount:Int = 850;
    var transactionRef:String = "LINiOS0009";
    var orderId:String = "LINiOS0009";
    var termianalId:String = "3CRZ0001";
    var terminalType:String = "MOBILE";
    var paymentItem:String = "CRD";
    var currency:String = "KES";
    var preauth:String = "1";
    var narration:String = "Test iOS";
    //card variables
    var pan:String = "4111111111111111";
    var cvv:String = "234";
    var expYear:String = "23";
    var expMonth:String = "02";
    var tokenize:Bool = true;
    
    //mobile
    var phone:String = "0712345678";
    
    //token
    var tokens:Array<String> = ["1E83B03ACFC5DF31985B83CF1F018B63AD54134DA6C425E83D"];
    var token:String = ""
    var expiry:String = "0222"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        func convertToDictionary(message: String) -> [String: Any]? {
            if let data = message.data(using: .utf8) {
                do {
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                } catch {
                    print(error.localizedDescription)
                }
            }
            return nil
        }
        func showResponse(message: String){
            //while showing the response if theres a token it will add the token to the array
            let responseAsJson = convertToDictionary(message: message)
            let tokenExists = responseAsJson?["token"] != nil
            if(tokenExists == true){
                self.tokens.append(responseAsJson?["token"] as! String)
                self.form.rowBy(tag: "ExampleTokens")?.updateCell()
            }
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
                row.value = clientId
        
            }.onChange({(row) in
                self.clientId = row.value != nil ? row.value! : ""
                print(self.clientId)
                })
            <<< TextRow(){
                row in
                row.title = "Client Secret"
                row.placeholder = "Client Secret"
                row.value = clientSecret
            }
        +++ Section("Customer Details")
            <<< TextRow(){row in
                row.title = "Customer ID"
                row.add(rule: RuleRequired())
                row.placeholder = "Customer ID"
                row.value = customerId
                }.onChange({ (row) in
                    self.customerId = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "First Name"
                row.placeholder = "Enter First Name"
                row.value = firstName
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.firstName = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Second Name"
                row.placeholder = "Enter Second Name"
                row.value = secondName
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.secondName = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Email Address"
                row.placeholder = "Enter Email Address"
                row.value = emailAddress
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
                row.value = mobileNumber
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.mobileNumber = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "City"
                row.placeholder = "City"
                row.value = city
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.city = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Country"
                row.placeholder = "Country"
                row.value = country
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.country = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Postal Code"
                row.placeholder = "Postal Code"
                row.value = postalCode
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.postalCode = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Street"
                row.placeholder = "Street"
                row.value = street
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.street = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "State"
                row.placeholder = "State"
                row.value = state
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.state = row.value != nil ? row.value! : ""
                })
            
        //MERCHANT DETAILS
        +++ Section("Merchant Details")
            <<< TextRow(){row in
                row.title = "Merchant Id"
                row.placeholder = "Merchant Id"
                row.value = merchantId
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.merchantId = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Domain"
                row.placeholder = "Domain"
                row.value = merchantDomain
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.merchantDomain = row.value != nil ? row.value! : ""
                })
        
        //PAYMENT DETAILS
         +++ Section("Payment Details")
            <<< IntRow(){row in
                row.title = "Amount"
                row.placeholder = "999"
                row.value = paymentAmount
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.paymentAmount = row.value != nil ? row.value! : 0
                })
            <<< TextRow(){row in
                row.title = "TransactionRef"
                row.placeholder = "TransactionRef"
                row.value = transactionRef
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.transactionRef = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Order ID"
                row.placeholder = "Order Id"
                row.value = orderId
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.orderId = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Terminal Type"
                row.placeholder = "Terminal Type"
                row.value = terminalType
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.terminalType = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Terminal Id"
                row.placeholder = "Terminal Id"
                row.value = termianalId
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.termianalId = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Payment Item"
                row.placeholder = "Payment Item"
                row.value = paymentItem
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.paymentItem = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Currency"
                row.placeholder = "Currency"
                row.value = currency
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.currency = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Narration"
                row.placeholder = "Narration"
                row.value = narration
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.narration = row.value != nil ? row.value! : ""
                })
            <<< TextRow(){row in
                row.title = "Preauth"
                row.placeholder = "Preauth"
                row.value = preauth
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.preauth = row.value != nil ? row.value! : ""
                })
        
        //CARD DETAILS
        +++ Section("Card Details")
        <<< TextRow(){row in
                row.title = "PAN"
                row.placeholder = "4111 1111 1111 1111"
                row.add(rule: RuleRequired())
                row.value = pan
//                row.formatter = Formatter()
            }.onChange({ (row) in
                self.pan = row.value != nil ? row.value! : "0"
//                print(self.pan)
            })
            <<< TextRow(){row in
                row.title = "CVV"
                row.placeholder = "999"
                row.add(rule: RuleRequired())
                row.value = cvv
                }.onChange({ (row) in
                    self.cvv = row.value != nil ? row.value! : "0"
                })
            <<< TextRow(){row in
                row.title = "Expiry Year"
                row.placeholder = "20"
                row.value = expYear
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.expYear = row.value != nil ? row.value! : "0"
                })
            <<< TextRow(){row in
                row.title = "Expiry Month"
                row.placeholder = "2"
                row.value = expMonth
                row.add(rule: RuleRequired())
                }.onChange({ (row) in
                    self.expMonth = row.value != nil ? row.value! : "0"
                })
            <<< SwitchRow(){row in
                row.title = "Tokenize"
                row.add(rule: RuleRequired())
                row.value = tokenize
                }.onChange({ (row) in
                    self.tokenize = row.value != nil ? row.value! : false
                })
            <<< ActionSheetRow<String>() {
                $0.tag = "ExampleTokens"
                $0.title = "Example Tokens"
                $0.selectorTitle = "choose your token"
                $0.options = self.tokens
                $0.value = self.tokens[0]
                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
                }.onChange({
                    self.token = $0.value != nil ? $0.value! : ""
                }).cellUpdate { cell, row in
                    row.options = self.tokens
            }
            
            
            
        
        //MOBILE PAYMENT DETAILS
        +++ Section("Mobile Payment Details")
        <<< TextRow(){row in
            row.title = "Phone"
            row.placeholder = "0726983805"
            row.value = phone
            row.add(rule: RuleRequired())
            }.onChange({ (row) in
                self.phone = row.value != nil ? row.value! : "0"
            })
        
            
        +++ Section()
            <<< ButtonRow(){row in
                row.title = "Submit card Payment"
                row.add(rule: RuleRequired())
                }.onCellSelection({ (cell,row) in
                    
                    let cardInput = Card(pan: String(self.pan), cvv: String(self.cvv), expiryYear: String(self.expYear), expiryMonth: String(self.expMonth), tokenize: self.tokenize)
                    let paymentInput = Payment(amount: String(self.paymentAmount), transactionRef: self.transactionRef, orderId: self.orderId, terminalType: self.terminalType, terminalId: self.termianalId, paymentItem: self.paymentItem, currency: self.currency, preauth: self.preauth, narration: self.narration)
                    let customerInput = Customer(customerId: self.customerId, firstName: self.firstName, secondName: self.secondName, email: self.emailAddress, mobile: self.mobileNumber, city: self.city, country: self.country, postalCode: self.postalCode, street: self.street, state: self.state)
                    let merchantInput = Merchant(merchantId: self.merchantId, domain: self.merchantDomain)
                        try!Mobpay.instance.makeCardPayment(card: cardInput, merchant: merchantInput, payment: paymentInput, customer: customerInput, clientId: self.clientId,clientSecret: self.clientSecret){ (completion) in showResponse(message: completion)
                        }
                    
                })
            <<< ButtonRow(){ row in
                row.title = "Submit with token"
                }.onCellSelection{
                 cell, row in
                    let paymentInput = Payment(amount: String(self.paymentAmount), transactionRef: self.transactionRef, orderId: self.orderId, terminalType: self.terminalType, terminalId: self.termianalId, paymentItem: self.paymentItem, currency: self.currency, preauth: self.preauth, narration: self.narration)
                    let customerInput = Customer(customerId: self.customerId, firstName: self.firstName, secondName: self.secondName, email: self.emailAddress, mobile: self.mobileNumber, city: self.city, country: self.country, postalCode: self.postalCode, street: self.street, state: self.state)
                    let merchantInput = Merchant(merchantId: self.merchantId, domain: self.merchantDomain)
                    let cardToken = CardToken(token: self.token, expiry: self.expiry, cvv: String(self.cvv))
                    
                    try!Mobpay.instance.makeCardTokenPayment(cardToken: cardToken, merchant: merchantInput, payment: paymentInput, customer: customerInput, clientId: self.clientId,clientSecret: self.clientSecret){ (completion) in showResponse(message: completion)
                    }
            }
            <<< ButtonRow() {
                $0.title = "Mobile money"
                }
                .onCellSelection { cell, row in

                    let paymentInput = Payment(amount: String(self.paymentAmount), transactionRef: self.transactionRef, orderId: self.orderId, terminalType: self.terminalType, terminalId: self.termianalId, paymentItem: self.paymentItem, currency: self.currency, preauth: self.preauth, narration: self.narration)
                    let customerInput = Customer(customerId: self.customerId, firstName: self.firstName, secondName: self.secondName, email: self.emailAddress, mobile: self.mobileNumber, city: self.city, country: self.country, postalCode: self.postalCode, street: self.street, state: self.state)
                    let merchantInput = Merchant(merchantId: self.merchantId, domain: self.merchantDomain)
                    let mobileInput = Mobile(phone: self.phone)
        
                    try!Mobpay.instance.makeMobileMoneyPayment(mobile: mobileInput, merchant: merchantInput, payment: paymentInput, customer: customerInput, clientId: self.clientId, clientSecret:self.clientSecret){ (completion) in showResponse(message: completion)
                    }
        }
            
            <<< ButtonRow(){
                $0.title = "Confirm Mobile Money Payment"
                }.onCellSelection {cell , row in
                    try!Mobpay.instance.confirmMobileMoneyPayment(orderId: self.orderId, clientId: self.clientId,clientSecret: self.clientSecret){ (completion) in showResponse(message: completion)}
            }
            <<< ButtonRow("Launch UI") { (row: ButtonRow) -> Void in
                row.title = row.tag
                }.onCellSelection {cell, row in
                    let interSwitchPaymentController = InterSwitchPaymentUI()
                    self.navigationController?.pushViewController(interSwitchPaymentController, animated: true)
        }
//            <<< ButtonRow("Hidden rows") { (row: ButtonRow) -> Void in
//                row.title = row.tag
//                row.presentationMode = .segueName(segueName: "HiddenRowsControllerSegue", onDismiss: nil)
//        }
}

}
