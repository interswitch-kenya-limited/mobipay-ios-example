//
//  MobilePaymentUI.swift
//  mobpay-ios
//
//  Created by Allan Mageto on 26/06/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//

import UIKit

class MobilePaymentUI : UIViewController,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    var initialY : CGFloat{
        get{
            if self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent{
                return 0
            }else{
                let barHeight=self.navigationController?.navigationBar.frame.height ?? 0
                let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
                return barHeight + statusBarHeight + 20
            }
        }
    }
    var payment:Payment!
    var customer:Customer!
    var merchantConfig:MerchantConfig!
    
    var MobilePaymentUIDelegate:MobilePaymentUIDelegate?
    let screenDimensions = UIScreen.main.bounds
    
    var paymentMethods:Array<String> = []
    var paymentMethod:String!
    var phoneNumber:String = ""
    var selectedPaymentOption:String = "Express Checkout"
    var shownPaymentAmount:String!
    var validPhoneNumberField:Bool = false
    convenience init(payment: Payment, customer: Customer, merchantConfig:MerchantConfig) {
        self.init()
        self.payment = payment;
        self.customer = customer;
        self.merchantConfig = merchantConfig;
        self.paymentMethods = self.populatePaymentmethods()
        self.paymentMethod = self.paymentMethods[0]
        self.shownPaymentAmount = String(format:"%.02f",Double(self.payment.amount)!/100)

        self.refreshTextViews()
    }
    func convertToDictionary(message: String) -> [String: Any]? {
        if let data = message.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
               self.MobilePaymentUIDelegate?.didReceiveMobilePayload(error.localizedDescription)
            }
        }
        return nil
    }
    func showMobileResponse(message: String){
        let responseAsString = message
        let responseAsJson = convertToDictionary(message: responseAsString)
        let errorExists = responseAsJson?["error"] != nil
        if errorExists == true {
            let paymentMessage:String = "Please try again ot select an alternative payment option"
            let alert = UIAlertController(title: "Payment Failed", message: paymentMessage, preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "Quit", style: .destructive) { (action:UIAlertAction!) in
               self.MobilePaymentUIDelegate?.didReceiveMobilePayload(responseAsString)
            })
            alert.addAction(UIAlertAction(title: "Try Again", style: .default) { (action:UIAlertAction!) in
                print("Cancelled")
            })
            self.present(alert, animated: true, completion: nil)
        }else{
            let paymentMessage:String = "Payment Success"
            let paymentSuccessfullImage = UIImageView(image: loadImageFromBase64(base64String: Base64Images().happyFace))
            paymentSuccessfullImage.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            let alert = UIAlertController(title: "Payment Success", message: paymentMessage, preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "Okay", style: .default){(action: UIAlertAction!) in
                self.MobilePaymentUIDelegate?.didReceiveMobilePayload(responseAsString)
            })
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.dismiss(animated: true)
                self.MobilePaymentUIDelegate?.didReceiveMobilePayload(responseAsString)
            })
        }
        
    }
    func populatePaymentmethods()->Array<String>{
        if self.merchantConfig.mpesaStatus == 1 {
            self.paymentMethods.append("MPESA")
        }
        if self.merchantConfig.tkashStatus == 1 {
            self.paymentMethods.append("TKASH")
        }
        if self.merchantConfig.equitelStatus == 1 {
            self.paymentMethods.append("EAZZYPAY")
        }
        if self.merchantConfig.airtelStatus == 1 {
            self.paymentMethods.append("AIRTELMONEY")
        }
        return self.paymentMethods
    }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
    }
    
    //SECTIONS
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: CGRect(x: 0, y: initialY + 5, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.addSubview(headerSection)
        view.addSubview(selectMobilePaymentOptionLabel)
        view.addSubview(selectPaymentMethod)
        view.addSubview(chooseExpressCheckoutOrPaybill)
        view.addSubview(phoneNumberField)
        view.addSubview(mobilePaymentInstructions)
        view.addSubview(submitButton)
        view.addSubview(cancelButton)
        view.addSubview(grayMpesa)
        view.addSubview(grayEazzyPay)
        view.addSubview(poweredByInterswitch)
        view.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1000)
        return view
    }()
    lazy var headerSection:UIView = {
        let section = UIView()
        section.addSubview(interswtichIcon)
        section.addSubview(amountLabel)
        section.addSubview(customerEmailLabel)
        return section
    }()
    
    lazy var interswtichIcon:UIImageView = {
        var margin = CGFloat(20)
        let imageView = UIImageView(image: loadImageFromBase64(base64String: Base64Images().interswitchIcon))
        imageView.frame = CGRect(x: margin, y: initialY + 5, width: 30, height: 50)
        return imageView
    }()
    lazy var amountLabel:UILabel = {
        let margin = CGFloat(5)
        let label = UILabel.init(frame: CGRect(x: margin, y: initialY + 5, width: self.view.frame.width - (margin * 2.0), height: 30))
        label.text = "\(self.payment.currency)  \(self.shownPaymentAmount!)"
        label.textAlignment = .right
        return label
    }()
    
    lazy var customerEmailLabel:UILabel = {
        let margin = CGFloat(2.5)
        var previousFrame = self.amountLabel.frame
        previousFrame.origin.y = self.amountLabel.frame.maxY + margin
        previousFrame.size.width = previousFrame.size.width
        let label = UILabel.init(frame: previousFrame)
        label.textAlignment = .right
        label.text = self.customer.email
        label.textColor = UIColor.gray
        return label
    }()
    
    lazy var selectMobilePaymentOptionLabel:UILabel = {
        let margin = CGFloat(30)
        var previousFrame = self.customerEmailLabel.frame
        previousFrame.origin.y = self.customerEmailLabel.frame.maxY + margin
        previousFrame.origin.x = (self.screenDimensions.maxX - previousFrame.size.width + margin)/2
        previousFrame.size.width = previousFrame.size.width - margin
        let label = UILabel(frame: previousFrame)
        label.text = "Select your mobile payment option"
        label.textAlignment = .center
        label.textColor = UIColor.gray
        return label
    }()
    lazy var paymentMethodPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    lazy var selectPaymentMethod:UITextField = {
        let margin = CGFloat(30)
        var previousFrame = self.selectMobilePaymentOptionLabel.frame
        previousFrame.origin.y = self.selectMobilePaymentOptionLabel.frame.maxY + margin
        previousFrame.origin.x = (self.screenDimensions.maxX - previousFrame.size.width)/2
        previousFrame.size.width = previousFrame.size.width
        previousFrame.size.height = CGFloat(50)
        let textField = UITextField()
        textField.frame = previousFrame
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.inputView = paymentMethodPicker
        textField.text = self.paymentMethods[0]
        return textField
    }()
    
    lazy var chooseExpressCheckoutOrPaybill:UISegmentedControl = {
        let margin = CGFloat(20)
        let items = ["Express Checkout","Paybill"]
        var previousFrame = self.selectPaymentMethod.frame
        previousFrame.origin.y = self.selectPaymentMethod.frame.maxY + margin
        previousFrame.size.width = previousFrame.size.width
        previousFrame.size.height = CGFloat(40)
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.frame = previousFrame
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(chooseExpressCheckoutOrPaybill(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    @objc func chooseExpressCheckoutOrPaybill(_ : UIButton){
        if self.selectedPaymentOption == "Express Checkout" {
            self.selectedPaymentOption = "Paybill"
            submitButton.isEnabled = true
            submitButton.backgroundColor = UIColor(red: 0.0/255, green: 69.0/255, blue: 95.0/255, alpha: 1.0)
        }else{
            self.selectedPaymentOption = "Express Checkout"
            if(!self.validPhoneNumberField){
                submitButton.backgroundColor = UIColor(red: 124.0/255, green: 160.0/255, blue: 172.0/255, alpha: 1.0)
            }
        }
        refreshTextViews()
        refreshButtons()
        self.view.setNeedsDisplay()
    }
    
    func refreshTextViews(){
        var phonePreviousFrame = self.chooseExpressCheckoutOrPaybill.frame
        phonePreviousFrame.origin.y = self.chooseExpressCheckoutOrPaybill.frame.maxY + 20
        phonePreviousFrame.size.height = CGFloat(50)
        if(self.selectedPaymentOption == "Express Checkout" && self.paymentMethod == "MPESA"){
            phoneNumberField.isHidden = false
            var previousFrame = self.phoneNumberField.frame
            previousFrame.origin.y = self.phoneNumberField.frame.maxY + 20
            mobilePaymentInstructions.frame = previousFrame
            mobilePaymentInstructions.text = """
            \u{2022} Enter your M-PESA number above.
            \u{2022} Click the pay button
            \u{2022} Enter your M-PESA pin when prompted on your phone
            \u{2022} Confirm the details then complete the transaction
            \n
            Once you receive a confirmation SMS from M-PESA, click on the confirm payment button below
            """
        }else if(self.selectedPaymentOption == "Paybill" && self.paymentMethod == "MPESA"){
            phoneNumberField.isHidden = true
            var previousFrame = self.chooseExpressCheckoutOrPaybill.frame
            previousFrame.origin.y = self.chooseExpressCheckoutOrPaybill.frame.maxY + 20
            mobilePaymentInstructions.frame = previousFrame
            mobilePaymentInstructions.text = """
                \u{2022} Go to M-PESA on your phone
                \u{2022} Select Lipa na Mpesa option
                \u{2022} Select Pay Bill Option
                \u{2022} Enter business no. \(self.merchantConfig.mpesaPaybill)
                \u{2022} Enter account no \(self.payment.transactionRef)
                \u{2022} Enter the EXACT amount \(self.shownPaymentAmount!)
                \u{2022} Enter your M-PESA PIN and send
                \n
                Once you receive a confirmation SMS from M-PESA, click on the confirm payment button below
                """
        }else if(self.selectedPaymentOption == "Express Checkout" && self.paymentMethod == "EAZZYPAY"){
            phoneNumberField.isHidden = false
            var previousFrame = self.phoneNumberField.frame
            previousFrame.origin.y = self.phoneNumberField.frame.maxY + 20
            mobilePaymentInstructions.frame = previousFrame
            self.mobilePaymentInstructions.text = """
            \u{2022} Click the Pay button
            \u{2022} Enter your EazzyPay pin when prompted on your phone
            \u{2022} Confirm the details then complete the transaction
            \n
            Didn’t get the prompt on your phone?
            Choose paybill and follow the instructions
            """
        }else if(self.selectedPaymentOption == "Paybill" && self.paymentMethod == "EAZZYPAY"){
            var previousFrame = self.chooseExpressCheckoutOrPaybill.frame
            previousFrame.origin.y = self.chooseExpressCheckoutOrPaybill.frame.maxY + 20
            phoneNumberField.isHidden = false
            mobilePaymentInstructions.frame = previousFrame
            self.mobilePaymentInstructions.text = """
                    \u{2022} Go to EazzyPay on your phone
                    \u{2022} Select Lipa na Mpesa option
                    \u{2022} Select Pay Bill Option
                    \u{2022} Enter business no. \(self.merchantConfig.equitelPaybill)
                    \u{2022} Enter account no \(self.payment.transactionRef)
                    \u{2022} Enter the EXACT amount \(self.shownPaymentAmount!)
                    \u{2022} Enter your EazzyPay PIN and send
                    \n
                    Once you receive a confirmation SMS from EazzyPay, click on the confirm payment button below
                    """
        }else{
            var previousFrame = self.chooseExpressCheckoutOrPaybill.frame
            previousFrame.origin.y = self.chooseExpressCheckoutOrPaybill.frame.maxY + 20
            phoneNumberField.isHidden = false
            mobilePaymentInstructions.frame = previousFrame
            self.mobilePaymentInstructions.text = """
            The payment method is not yet available
            """
        }
        phoneNumberField.frame = phonePreviousFrame
        mobilePaymentInstructions.sizeToFit()
        self.view.setNeedsDisplay()
    }
    func refreshButtons(){
        if self.selectedPaymentOption == "Paybill" && self.paymentMethod == "MPESA" {
            var previousFrame = self.mobilePaymentInstructions.frame
            previousFrame.origin.y = previousFrame.maxY + 20
            previousFrame.size.width = UIScreen.main.bounds.width - 20
            previousFrame.size.height = CGFloat(50)
            previousFrame.origin.x = (self.screenDimensions.maxX - previousFrame.size.width)/2
            submitButton.frame = previousFrame
            submitButton.setTitle("CONFIRM PAYMENT", for: .normal)
        }else if self.selectedPaymentOption == "Express Checkout" && self.paymentMethod == "MPESA"{
            var previousFrame = self.mobilePaymentInstructions.frame
            previousFrame.origin.y = previousFrame.maxY + 20
            previousFrame.size.width = UIScreen.main.bounds.width - 20
            previousFrame.size.height = CGFloat(50)
            previousFrame.origin.x = (self.screenDimensions.maxX - previousFrame.size.width)/2
            submitButton.frame = previousFrame
            submitButton.setTitle("Pay \(self.payment.currency) \(self.shownPaymentAmount!)", for: .normal)
        }else if self.selectedPaymentOption == "Paybill" && self.paymentMethod == "EAZZYPAY"{
            var previousFrame = self.mobilePaymentInstructions.frame
            previousFrame.origin.y = previousFrame.maxY + 20
            previousFrame.size.width = UIScreen.main.bounds.width - 20
            previousFrame.size.height = CGFloat(50)
            previousFrame.origin.x = (self.screenDimensions.maxX - previousFrame.size.width)/2
            submitButton.frame = previousFrame
            submitButton.setTitle("Pay \(self.payment.currency) \(self.shownPaymentAmount!)", for: .normal)
        }else if self.selectedPaymentOption == "Express Checkout" && self.paymentMethod == "EAZZYPAY"{
            var previousFrame = self.mobilePaymentInstructions.frame
            previousFrame.origin.y = previousFrame.maxY + 20
            previousFrame.size.width = UIScreen.main.bounds.width - 20
            previousFrame.origin.x = (self.screenDimensions.maxX - previousFrame.size.width)/2
            previousFrame.size.height = CGFloat(50)
            submitButton.frame = previousFrame
            submitButton.setTitle("Pay \(self.payment.currency) \(self.shownPaymentAmount!)", for: .normal)
        }else if self.selectedPaymentOption == "Express Checkout"{
            var previousFrame = self.mobilePaymentInstructions.frame
            previousFrame.origin.y = previousFrame.maxY + 20
            previousFrame.size.width = UIScreen.main.bounds.width - 20
            previousFrame.origin.x = (self.screenDimensions.maxX - previousFrame.size.width)/2
            previousFrame.size.height = CGFloat(50)
            submitButton.frame = previousFrame
            submitButton.setTitle("Pay \(self.payment.currency) \(self.shownPaymentAmount!)", for: .normal)
        }else{
            var previousFrame = self.mobilePaymentInstructions.frame
            previousFrame.origin.y = previousFrame.maxY + 20
            previousFrame.size.width = UIScreen.main.bounds.width - 20
            previousFrame.size.height = CGFloat(50)
            previousFrame.origin.x = (self.screenDimensions.maxX - previousFrame.size.width)/2
            submitButton.frame = previousFrame
            submitButton.setTitle("CONFIRM PAYMENT", for: .normal)
        }
        var previousFrame = self.submitButton.frame
        previousFrame.origin.y = self.submitButton.frame.maxY + 20
        previousFrame.size.width = self.submitButton.frame.size.width * 0.5
        previousFrame.origin.x = (self.screenDimensions.maxX - previousFrame.size.width)/2
        cancelButton.frame = previousFrame
        self.view.setNeedsDisplay()
    }
    
    lazy var phoneNumberField:UITextField = {
        let margin = CGFloat(20)
        var previousFrame = self.chooseExpressCheckoutOrPaybill.frame
        previousFrame.origin.y = self.chooseExpressCheckoutOrPaybill.frame.maxY + margin
        previousFrame.size.height = CGFloat(50)
        let textField = UITextField.init()
        textField.frame = previousFrame
        textField.placeholder = "0712000000"
        textField.keyboardType = UIKeyboardType.numberPad
        textField.returnKeyType = UIReturnKeyType.done
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.delegate = self
        return textField
    }()
    lazy var mobilePaymentInstructions: UITextView  = {
        let margin = CGFloat(20)
        var previousFrame = self.phoneNumberField.frame
        previousFrame.origin.y = self.phoneNumberField.frame.maxY + margin
        let textView = UITextView(frame: previousFrame)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        let attributedString = NSMutableAttributedString(string: """
        \u{2022} Enter your M-PESA number above.
        \u{2022} Click the pay button
        \u{2022} Enter your M-PESA pin when prompted on your phone
        \u{2022} Confirm the details then complete the transaction
        \n
        Once you receive a confirmation SMS from M-PESA, click on the confirm payment button below
        """)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        textView.attributedText = attributedString
        textView.textAlignment = .justified
        textView.isSelectable = true
        textView.isEditable = false
        textView.isHidden = !(self.selectedPaymentOption == "Express Checkout" && self.paymentMethod == "MPESA")
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.textColor = UIColor.gray
    
        return textView
    }()
    lazy var  submitButton:UIButton = {
        let margin = CGFloat(20)
        var previousFrame = self.mobilePaymentInstructions.frame
        previousFrame.origin.y = previousFrame.maxY + margin
        previousFrame.size.width = UIScreen.main.bounds.width - 20
        previousFrame.origin.x = (self.screenDimensions.maxX - previousFrame.size.width)/2
        previousFrame.size.height = CGFloat(50)
        let submitButton = UIButton.init(type: .roundedRect)
        submitButton.frame = previousFrame
        submitButton.setTitle("Pay \(self.payment.currency) \(self.shownPaymentAmount!)", for: .normal)
        submitButton.addTarget(self, action: #selector(submitMobilePayment(_ :)), for: .touchDown)
        submitButton.backgroundColor = UIColor(red: 124.0/255, green: 160.0/255, blue: 172.0/255, alpha: 1.0)
        submitButton.setTitleColor(UIColor.white, for: .normal)
        submitButton.layer.cornerRadius = 10;
        submitButton.clipsToBounds = true;
        submitButton.isEnabled = false
        return submitButton
    }()
    
    
    lazy var activityIndicator:UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        return indicator
    }()

    
    @objc func submitMobilePayment(_ : UIButton){
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        if(self.selectedPaymentOption == "Express Checkout"){
            let mobile = Mobile(phone: self.phoneNumberField.text!)
            try!Mobpay.instance.makeMobileMoneyPayment(mobile: mobile, merchant: Merchant(merchantId: merchantConfig.merchantId, domain: merchantConfig.merchantDomain), payment: payment, customer: customer, clientId: self.merchantConfig.clientId, clientSecret:self.merchantConfig.clientSecret){ (completion) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.showMobileResponse(message: completion)
                }
            }
        }else{
            try!Mobpay.instance.confirmMobileMoneyPayment(orderId: self.payment.orderId, clientId: self.merchantConfig.clientId, clientSecret: self.merchantConfig.clientSecret){(completion) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.showMobileResponse(message: completion)
            }
            }
        }
        
    }
    lazy var cancelButton:UIButton = {
        var previousFrame = self.submitButton.frame
        previousFrame.origin.y = self.submitButton.frame.maxY + 20
        previousFrame.size.width = self.submitButton.frame.size.width * 0.5
        previousFrame.origin.x = (self.screenDimensions.maxX - previousFrame.size.width)/2
        let cancelButton = UIButton.init(type: .roundedRect)
        cancelButton.frame = previousFrame
        cancelButton.setTitle("CANCEL", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTransaction(_ :)), for: .touchDown)
        cancelButton.setTitleColor(UIColor.black, for: .normal)
        cancelButton.backgroundColor = UIColor(red:209/255 ,green: 209/255 ,blue: 209/255,alpha: 1.0)
        cancelButton.layer.cornerRadius = 10;
        return cancelButton
    }()
    
    @objc func cancelTransaction(_ : UIButton){
        self.MobilePaymentUIDelegate?.didReceiveMobilePayload("{\"error\":{\"code\":2,\"message\":\"User quit before finishing the transaction\"}}")
    }
    
    
    //IMAGES
    func loadImageFromBase64(base64String: String) -> UIImage{
        let dataDecoded : Data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)!
        return decodedimage
    }
    lazy var grayMpesa:UIImageView = {
        let imageView = UIImageView(image: loadImageFromBase64(base64String: Base64Images().grayMpesa))
        var previousFrame = self.cancelButton.frame
        previousFrame.origin.y = self.cancelButton.frame.maxY + 50
        previousFrame.size.height = 30
        previousFrame.size.width = 50
        previousFrame.origin.x = UIScreen.main.bounds.width * 0.25 - 25
        imageView.frame = previousFrame
        return imageView
    }()
    lazy var grayEazzyPay:UIImageView = {
        let imageView = UIImageView(image: loadImageFromBase64(base64String: Base64Images().grayEazzyPay))
        var previousFrame = self.grayMpesa.frame
        previousFrame.origin.x = UIScreen.main.bounds.width * 0.75 - 25
        previousFrame.origin.y = self.grayMpesa.frame.minY + 10
        previousFrame.size.width = 30
        previousFrame.size.height = 10
        imageView.frame = previousFrame
        return imageView
    }()
    lazy var poweredByInterswitch:UIImageView = {
        let imageView = UIImageView(image: loadImageFromBase64(base64String: Base64Images().poweredByInterswitch))
        var previousFrame = self.cancelButton.frame
        previousFrame.origin.x = (UIScreen.main.bounds.width - 120)/2
        previousFrame.origin.y = self.grayMpesa.frame.maxY + 50
        previousFrame.size.height  = CGFloat(30)
        previousFrame.size.width = CGFloat(120)
        imageView.frame = previousFrame
        return imageView
    }()
    //validation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0{
            return true
        }
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        self.validPhoneNumberField = false
        if prospectiveText.count == 10 && checkIfStringHasDecimals(stringToTest: prospectiveText){
            submitButton.backgroundColor = UIColor(red: 0.0/255, green: 69.0/255, blue: 95.0/255, alpha: 1.0)
            submitButton.isEnabled = true
            submitButton.layoutMarginsDidChange()
            submitButton.layoutIfNeeded()
            self.validPhoneNumberField = true
        }
        switch textField {
        case phoneNumberField:
            return prospectiveText.count <= 10 && checkIfStringHasDecimals(stringToTest: prospectiveText)
        default:
            return true
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func checkIfStringHasDecimals(stringToTest:String)->Bool{
        let numbersRange = stringToTest.rangeOfCharacter(from: .decimalDigits)
        return numbersRange != nil
    }
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return self.paymentMethods.count
    }

    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.paymentMethods[row]
    }
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        selectPaymentMethod.text = self.paymentMethods[row]
        self.paymentMethod = selectPaymentMethod.text!
//        var previousFrame = self.selectMobilePaymentOptionLabel.frame
//        previousFrame.origin.y = self.selectMobilePaymentOptionLabel.frame.maxY + 30
//        previousFrame.origin.x = (self.screenDimensions.maxX - previousFrame.size.width)/2
//        previousFrame.size.width = previousFrame.size.width
//        previousFrame.size.height = CGFloat(50)
//        selectPaymentMethod.frame = previousFrame
//        selectPaymentMethod.layoutMarginsDidChange()
//        selectPaymentMethod.layoutIfNeeded()
        refreshTextViews()
        refreshButtons()
        self.selectPaymentMethod.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

protocol MobilePaymentUIDelegate{
    func didReceiveMobilePayload(_ payload:String)
}
