# MobPay - An iOS library for integrating card and mobile payments through Interswitch

This Pod enables you to integrate Interswitch payments to your mobile app

## Adding it to a project

## CocoaPods
CocoaPods is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Mobpay into your Xcode project using CocoaPods, specify it in your Podfile:
To get the library add the following dependency to your podfile:

```ruby
pod 'mobpay', :git => 'https://github.com/interswitch-kenya-limited/mobpay-ios-lib.git'
```

## Usage examples

Get an interswitch client Id and client secret for your interswitch merchant account then instantiate a mobpay object by doing the following:

```swift

import mobpay


let card = Card(pan: "4111111111111111", cvv: "123", expiryYear: "20", expiryMonth: "02", tokenize: false)
let payment = Payment(amount: "100", transactionRef: "66809285644", orderId: "OID123453", terminalType: "MOBILE", terminalId: "3TLP0001", paymentItem: "CRD", currency: "KES")
let customer = Customer(customerId: "12", firstName: "Allan", secondName: "Mageto", email: "test@gmail.com", mobile: "0712345678", city: "NBI", country: "KE", postalCode: "00200", street: "WESTLANDS", state: "NBI")
let merchant = Merchant(merchantId: "your merchant id", domain: "your domain")             
                    
try!Mobpay.instance.makeCardPayment(card: card, merchant: merchant, payment: payment, customer: customer, clientId: self.clientId,clientSecret: self.clientSecret){ (completion) in showResponse(message: completion)
}
```
          

## Source code

Visit https://github.com/interswitch-kenya-limited/mobpay-ios-example to get the source code and releases of this project if you want to try a manual integration process.
