//
//  CardPaymentUI.swift
//  mobpay-ios
//
//  Created by Allan Mageto on 26/06/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//


import UIKit
import WebKit

protocol CardPaymentUIDelegate {
    func didReceiveCardPayload(_ payload:String)
}
class CardPaymentUI : UIViewController,WKUIDelegate {
    
    let height = CGFloat(60)
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
    let screenDimensions = UIScreen.main.bounds
    
    var CardPaymentUIDelegate:CardPaymentUIDelegate?
    
    var cardTokenIndex:Int = 0
    var payment:Payment!
    var customer:Customer!
    var merchantConfig:MerchantConfig!
    var cardTokens:Array<CardToken>? = nil
    var useCardTokenSection:Bool = false
    var cardToken:String!
    var shownPaymentAmount:String!
    var merchant:Merchant!
   //ui input elements
    var tokenize:Bool!
    
    
    convenience init(payment: Payment, customer: Customer, merchantConfig:MerchantConfig,cardTokens:Array<CardToken>? = nil ) {
        self.init()
        self.payment = payment;
        self.customer = customer;
        self.merchantConfig = merchantConfig
        self.shownPaymentAmount = String(format:"%.02f",Double(self.payment.amount)!/100)
        if cardTokens != nil && cardTokens?.count ?? 0 > 0{
            self.cardTokens = cardTokens
            self.useCardTokenSection = true
        }
        if (merchantConfig.tokenizeStatus != 2) {
            self.tokenize = true
        }else{
            self.tokenize = false
        }
        self.merchant = Merchant(merchantId: merchantConfig.merchantId, domain: merchantConfig.merchantDomain)
    }
    func convertToDictionary(message: String) throws-> [String: Any]? {
        if let data = message.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                throw error
                self.CardPaymentUIDelegate?.didReceiveCardPayload(error.localizedDescription)
            }
        }
        return nil
    }
    func showResponse(message: String){
        
        let responseAsString = message
        let responseAsJson = try!convertToDictionary(message: responseAsString)
        let errorExists = responseAsJson?["error"] != nil
        if errorExists == true {
            let paymentMessage:String = "Please try again ot select an alternative payment option"
            let alert = UIAlertController(title: "Payment Failed", message: paymentMessage, preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "Quit", style: .destructive) { (action:UIAlertAction!) in
                self.CardPaymentUIDelegate?.didReceiveCardPayload(responseAsString)
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
                self.CardPaymentUIDelegate?.didReceiveCardPayload(responseAsString)
            })
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.dismiss(animated: true)
                self.CardPaymentUIDelegate?.didReceiveCardPayload(responseAsString)
            })
        }
        
    }
    override open var shouldAutorotate: Bool {return false}
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {return .portrait}
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {return .portrait}
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
    }
    
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: CGRect(x: 0, y: initialY + 5, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.addSubview(headerSection)
        view.addSubview(enterCardDetailsLabel)
        view.addSubview(cardNumberLabel)
        //card details without token

        view.addSubview(cardNumberLabel)
        view.addSubview(cardNumberField)
        view.addSubview(cardTokenField)
        view.addSubview(cardExpiryDateLabel)
        view.addSubview(cardExpirationDateField)
        view.addSubview(cvcLabel)
        view.addSubview(whatIsThis)
        view.addSubview(cvcField)
        //card details with token
        view.addSubview(useTokenOrCardSegmentedControl)
        view.addSubview(submitButton)
        view.addSubview(cancelButton)
        view.addSubview(tokenizeSwitchButton)
        view.addSubview(saveCardLabel)
        view.addSubview(imageRowSection)
        view.addSubview(submitButton)
        view.addSubview(cancelButton)
        view.addSubview(poweredByInterswitch)
        view.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1000)
        return view
    }()
    //HEADER
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
        imageView.frame = CGRect(x: margin, y: 0, width: 30, height: 50)
        return imageView
    }()
    lazy var amountLabel:UILabel = {
        let margin = CGFloat(5)
        let label = UILabel.init(frame: CGRect(x: margin, y: 0, width: self.view.frame.width - (margin * 2.0), height: 30))
        debugPrint(label.frame.size.width)
        label.text = "\(self.payment.currency) \(self.shownPaymentAmount!)"
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
    
    //CARD DETAILS SECTION
    lazy var enterCardDetailsLabel:UILabel = {
        let margin = CGFloat(10)
        var previousFrame = self.customerEmailLabel.frame
        previousFrame.origin.y = self.customerEmailLabel.frame.maxY + margin
        previousFrame.size.width = previousFrame.size.width
        let label = UILabel(frame: previousFrame)
        label.textAlignment = .center
        label.text = "Enter your card details"
        label.textColor = UIColor.gray
        return label
    }()
    
   
    //card details without token
    lazy var cardNumberLabel:UILabel = {
        let margin = CGFloat(30)
        var previousFrame = self.enterCardDetailsLabel.frame
        previousFrame.origin.y = self.enterCardDetailsLabel.frame.maxY + margin
        previousFrame.size.width = previousFrame.size.width - margin
        previousFrame.origin.x = (self.screenDimensions.maxX - previousFrame.size.width)/2
        let label = UILabel(frame: previousFrame)
        label.text = "Card number"
        label.textColor = UIColor.gray
        label.font = label.font.withSize(15)
        return label
    }()
    lazy var cardNumberField:FormTextField = {
        let margin = CGFloat(20)
        var previousFrame = self.cardNumberLabel.frame
        previousFrame.origin.y = self.cardNumberLabel.frame.maxY + 10
        previousFrame.size.height = self.cardNumberLabel.frame.size.height * 1.5
        previousFrame.size.width = self.cardNumberLabel.frame.size.width

        let textField = FormTextField(frame: previousFrame)
        textField.inputType = .integer
        textField.formatter = CardNumberFormatter()
        textField.placeholder = "0000 0000 0000 0000"
        textField.isHidden = self.useCardTokenSection
        var validation = Validation()
        validation.maximumLength = 19
        validation.minimumLength = 19
        validation.format = "^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14})$"
        let characterSet = NSMutableCharacterSet.decimalDigit()
        characterSet.addCharacters(in: " ")
        validation.characterSet = characterSet as CharacterSet
        let inputValidator = InputValidator(validation: validation)
        textField.inputValidator = inputValidator
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.validBorderColor = UIColor.green
        return textField
    }()
    lazy var tokenPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    lazy var cardTokenField:UITextField = {
        let margin = CGFloat(20)
        var previousFrame = self.cardNumberLabel.frame
        previousFrame.origin.y = self.cardNumberLabel.frame.maxY + margin
        previousFrame.size.height = self.cardNumberLabel.frame.size.height * 1.5
        previousFrame.size.width = self.cardNumberLabel.frame.size.width
        let textField = UITextField()
        textField.frame = previousFrame
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.inputView = tokenPicker
        textField.text = self.cardTokens?[0].tokenizedCardPan
        textField.isHidden = !self.useCardTokenSection
        textField.allowsEditingTextAttributes = false
        return textField
    }()
    lazy var useTokenOrCardSegmentedControl:UISegmentedControl = {
        let margin = CGFloat(20)
        let items = ["Saved","New"]
        var previousFrame = self.enterCardDetailsLabel.frame
        previousFrame.origin.y = self.enterCardDetailsLabel.frame.maxY + margin
        previousFrame.origin.x = self.enterCardDetailsLabel.frame.maxX - 150
        previousFrame.size.width = CGFloat(150)
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.frame = previousFrame
        segmentedControl.addTarget(self, action: #selector(CardPaymentUI.useTokenOrCardSegmentedControlChanged(_:)), for: .valueChanged)
        segmentedControl.isHidden = !self.useCardTokenSection
        return segmentedControl
    }()
    lazy var cardExpiryDateLabel:UILabel = {
        let margin = CGFloat(10)
        var previousFrame = self.cardNumberField.frame
        previousFrame.origin.y = self.cardNumberField.frame.maxY + margin
        previousFrame.size.width = previousFrame.size.width * 0.6
        let label = UILabel(frame: previousFrame)
        label.text = "Card expiry date"
        label.textColor = UIColor.gray
        label.font = label.font.withSize(15)
        return label
    }()
   
    lazy var cardExpirationDateField: FormTextField = {
        let margin = CGFloat(5)
        var previousFrame = self.cardExpiryDateLabel.frame
        previousFrame.origin.y = self.cardExpiryDateLabel.frame.maxY
        previousFrame.size.width = self.cardNumberField.frame.size.width * 0.6
        let textField = FormTextField(frame: previousFrame)
        textField.inputType = .integer
        textField.formatter = CardExpirationDateFormatter()
        if(self.useCardTokenSection == false){
            textField.placeholder = "MM/YY"
        }else{
            textField.placeholder = self.cardTokens?[0].expiry
            textField.isEnabled = false
        }
        var validation = Validation()
        validation.minimumLength = 1
        let inputValidator = CardExpirationDateInputValidator(validation: validation)
        textField.inputValidator = inputValidator
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.validBorderColor = UIColor.green
        textField.invalidBorderColor = UIColor.red
        return textField
    }()
    lazy var cvcLabel:UILabel = {
        let margin = CGFloat(10)
        var previousFrame = self.cardNumberField.frame
        previousFrame.origin.x = self.cardExpirationDateField.frame.maxX + previousFrame.size.width * 0.05
        previousFrame.origin.y = self.cardNumberField.frame.maxY + margin
        previousFrame.size.width = previousFrame.size.width * 0.35
        let label = UILabel(frame: previousFrame)
        label.text = "CVV"
        label.font = label.font.withSize(10)
        label.textColor = UIColor.gray
        label.textAlignment = .left
        return label
    }()
    lazy var whatIsThis:UILabel = {
        let margin = CGFloat(10)
        var previousFrame = self.cardNumberField.frame
        previousFrame.origin.x = self.cardExpirationDateField.frame.maxX + previousFrame.size.width * 0.05
        previousFrame.origin.y = self.cardNumberField.frame.maxY + margin
        previousFrame.size.width = previousFrame.size.width * 0.35
        let label = UILabel(frame: previousFrame)
        label.text = "What is this?"
        label.textAlignment = .right
        label.textColor = UIColor.gray
        label.font = label.font.withSize(15)
        label.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showWhatIsThisAlert(_ :)))
        label.addGestureRecognizer(gestureRecognizer)
        return label
    }()
    
    @objc func showWhatIsThisAlert(_ : UITapGestureRecognizer){
        let alert = UIAlertController(title: "What is this?", message: "The CVV is a 3-digit security code at the back of your card", preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel,handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    lazy var cvcField: FormTextField = {
        let margin = CGFloat(5)
        var previousFrame = self.cardNumberField.frame
        previousFrame.origin.x = self.cardExpirationDateField.frame.maxX + previousFrame.size.width * 0.05
        previousFrame.origin.y = self.cvcLabel.frame.maxY
        previousFrame.size.width = self.cardNumberField.frame.size.width * 0.35
        let textField = FormTextField(frame: previousFrame)
        textField.inputType = .integer
        textField.placeholder = "CVC"
        var validation = Validation()
        validation.maximumLength = 3
        validation.minimumLength = 3
        validation.characterSet = NSCharacterSet.decimalDigits
        let inputValidator = InputValidator(validation: validation)
        textField.inputValidator = inputValidator
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.validBorderColor = UIColor.green
        textField.isSecureTextEntry = true
        return textField
    }()
    lazy var tokenizeSwitchButton:UISwitch = {
        let margin = CGFloat(20)
        var previousFrame = self.cardExpirationDateField.frame
        previousFrame.origin.y = self.cardExpirationDateField.frame.maxY + margin
        let tokenizeSwitchButton = UISwitch(frame: previousFrame)
        tokenizeSwitchButton.addTarget(self, action: #selector(switchTokenize(_:)), for: .valueChanged)
        tokenizeSwitchButton.setOn(true, animated: false)
        tokenizeSwitchButton.isHidden  = self.merchantConfig.tokenizeStatus != 1 || self.useCardTokenSection
        return tokenizeSwitchButton
    }()
    lazy var saveCardLabel:UILabel = {
        let margin = CGFloat(20)
        var previousFrame = self.cardExpirationDateField.frame
        previousFrame.origin.x = self.tokenizeSwitchButton.frame.maxX + 10
        previousFrame.origin.y = self.cardExpirationDateField.frame.maxY + margin - 10
        previousFrame.size.width = previousFrame.size.width
        let label = UILabel(frame: previousFrame)
        label.isHidden  = self.merchantConfig.tokenizeStatus != 1 || self.useCardTokenSection
        label.text = "Save Card"
        return label
    }()
   
    
    lazy var imageRowSection:UIView = {
        let section = UIView()
        section.addSubview(verveSafeTokenImage)
        section.addSubview(verifiedByVisa)
        section.addSubview(mastercardSecureCode)
        section.addSubview(pciDss)
        return section
    }()
    //BUTTONS
    lazy var  submitButton:UIButton = {
        var previousFrame = self.cardNumberField.frame
        if(self.useCardTokenSection){
            previousFrame.origin.y = self.cvcField.frame.maxY + 20
        }else{
            previousFrame.origin.y = self.tokenizeSwitchButton.frame.maxY + 20
        }
        let submitButton = UIButton.init(type: .roundedRect)
        submitButton.frame = previousFrame
        submitButton.setTitle("Pay \(self.payment.currency) \(self.shownPaymentAmount!)", for: .normal)
        submitButton.addTarget(self, action: #selector(submitButtonAction(_ :)), for: .touchDown)
        submitButton.backgroundColor = UIColor(red: 124.0/255, green: 160.0/255, blue: 172.0/255, alpha: 1.0)
        submitButton.setTitleColor(UIColor.white, for: .normal)
        submitButton.layer.cornerRadius = 5;
        submitButton.clipsToBounds = true;
        return submitButton
    }()
    
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
        cancelButton.layer.cornerRadius = 5;
        return cancelButton
    }()
    
    //BUTTON ACTIONS
    @objc func submitButtonAction(_ : UIButton){
        if (self.useCardTokenSection == false) {
            if cardNumberField.validate() && cardExpirationDateField.validate() && cvcField.validate() {
                let expDateArray = Array(self.cardExpirationDateField.text!)
                let expMonth = String(expDateArray[0]) + String(expDateArray[1])
                let expYear = String(expDateArray[3]) + String(expDateArray[4])
                let cardInput = Card(pan: self.cardNumberField.text!.replacingOccurrences(of: " ", with: ""), cvv: self.cvcField.text!, expiryYear: expYear, expiryMonth: expMonth, tokenize: self.tokenize)
                try!Mobpay.instance.submitCardPayment(card: cardInput, merchant: Merchant(merchantId: self.merchantConfig.merchantId, domain: self.merchantConfig.merchantDomain), payment: self.payment, customer: self.customer, clientId: self.merchantConfig.clientId,clientSecret: self.merchantConfig.clientSecret,previousUIViewController: self){(completion) in
                    self.dismiss(animated: true)
                    self.showResponse(message: completion)
                }
            }else{
                print("card number: \(cardNumberField.validate()) card expiration : \(cardExpirationDateField.validate()) cvv field: \(cvcField.validate())")
            }
        }else{
            if cvcField.validate(){
                let token = CardToken(token: self.cardTokens![self.cardTokenIndex].token, expiry: cardTokens![0].expiry, cvv: self.cvcField.text!)
                try!Mobpay.instance.submitTokenPayment(cardToken: token, merchant: Merchant(merchantId: self.merchantConfig.merchantId, domain: self.merchantConfig.merchantDomain), payment: self.payment, customer: self.customer, clientId: self.merchantConfig.clientId,clientSecret: self.merchantConfig.clientSecret,previousUIViewController: self){
                    (completion) in
                    self.dismiss(animated: true)
                    self.showResponse(message: completion)
                }
            }else{
                print(cvcField.validate())
            }
        }
       
    }
    @objc func useTokenOrCardSegmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            self.useCardTokenSection = true
            tokenizeSwitchButton.isHidden = true
            saveCardLabel.isHidden = true
            refreshButtons()
            refreshTextFields()
        case 1:
            cardExpirationDateField.placeholder = "MM/YY"
            if(merchantConfig.tokenizeStatus == 1){
                self.useCardTokenSection = false
                tokenizeSwitchButton.isHidden = false
                saveCardLabel.isHidden = false
                tokenizeSwitchButton.layoutMarginsDidChange()
                saveCardLabel.layoutMarginsDidChange()
            }
            refreshButtons()
            refreshTextFields()
        default:
            break
        }
        if #available(iOS 11.0, *) {
            self.viewLayoutMarginsDidChange()
        } else {
            // Fallback on earlier versions
        }
        self.view.setNeedsDisplay()
    }
    @objc func switchTokenize(_ sender:UISwitch){
        self.tokenize = sender.isOn
    }
    
    @objc func cancelTransaction(_ : UIButton){
        self.CardPaymentUIDelegate?.didReceiveCardPayload("{\"error\":{\"code\":2,\"message\":\"User quit before finishing the transaction\"}}")
    }
    
    //LOAD IMAGES
    
    lazy var verveSafeTokenImage:UIImageView = {
        let imageView = UIImageView(image: loadImageFromBase64(base64String: Base64Images().verveSafeToken))
        var previousFrame = self.tokenizeSwitchButton.frame
        previousFrame.origin.x = UIScreen.main.bounds.width * 0.1875
        previousFrame.origin.y = self.cancelButton.frame.maxY + 80
        previousFrame.size.height = CGFloat(20.0)
        previousFrame.size.width = UIScreen.main.bounds.width * 0.110
        imageView.frame = previousFrame
        return imageView
    }()
    lazy var verifiedByVisa:UIImageView = {
        let imageView = UIImageView(image: loadImageFromBase64(base64String: Base64Images().verifiedByVisa))
        var previousFrame = self.verveSafeTokenImage.frame
        previousFrame.origin.y = self.verveSafeTokenImage.frame.minY
        previousFrame.origin.x = self.verveSafeTokenImage.frame.maxX + UIScreen.main.bounds.width * 0.0725
        previousFrame.size.height = CGFloat(20.0)
        previousFrame.size.width = UIScreen.main.bounds.width * 0.115
        imageView.frame = previousFrame
        return imageView
    }()
    lazy var mastercardSecureCode:UIImageView = {
        let imageView = UIImageView(image: loadImageFromBase64(base64String: Base64Images().masterCardSecureCode))
        var previousFrame = self.verveSafeTokenImage.frame
        previousFrame.origin.y = self.verveSafeTokenImage.frame.minY
        previousFrame.origin.x = self.verifiedByVisa.frame.maxX + UIScreen.main.bounds.width * 0.0725
        previousFrame.size.height = CGFloat(20.0)
        previousFrame.size.width = UIScreen.main.bounds.width * 0.115
        imageView.frame = previousFrame
        return imageView
    }()
    
    lazy var pciDss:UIImageView = {
        let imageView = UIImageView(image: loadImageFromBase64(base64String: Base64Images().pciDss))
        var previousFrame = self.verveSafeTokenImage.frame
        previousFrame.origin.y = self.verveSafeTokenImage.frame.minY
        previousFrame.origin.x = self.mastercardSecureCode.frame.maxX + UIScreen.main.bounds.width * 0.0725
        previousFrame.size.height = CGFloat(20.0)
        previousFrame.size.width = UIScreen.main.bounds.width * 0.115
        imageView.frame = previousFrame
        return imageView
    }()
    
    lazy var poweredByInterswitch:UIImageView = {
        let imageView = UIImageView(image: loadImageFromBase64(base64String: Base64Images().poweredByInterswitch))
        var previousFrame = self.cancelButton.frame
        previousFrame.origin.x = UIScreen.main.bounds.width/2 - 60
        previousFrame.origin.y = self.pciDss.frame.maxY + 50
        previousFrame.size.height  = CGFloat(30)
        previousFrame.size.width = CGFloat(120)
        imageView.frame = previousFrame
        return imageView
    }()
    
   
    func loadImageFromBase64(base64String: String) -> UIImage{
        let dataDecoded : Data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)!
        return decodedimage
    }
}
extension CardPaymentUI:UIPickerViewDelegate,UIPickerViewDataSource{
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return self.cardTokens!.count
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.cardTokens?[row].tokenizedCardPan
    }
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        cardTokenField.text = self.cardTokens?[row].tokenizedCardPan
        self.cardTokenIndex = row
        self.cardToken = cardTokenField.text!
        cardExpirationDateField.placeholder = self.cardTokens![self.cardTokenIndex].expiry
        cardTokenField.endEditing(true)
        refreshTextFields()
    }
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func refreshTextFields(){
        cardTokenField.isHidden = !self.useCardTokenSection
        cardNumberField.isHidden = self.useCardTokenSection
        cardExpirationDateField.isEnabled = true
        cardExpirationDateField.setNeedsLayout()
        self.view.setNeedsDisplay()
    }
    
    func refreshButtons(){
        var previousFrame = self.cardNumberField.frame
        if(self.useCardTokenSection){
            previousFrame.origin.y = self.cvcField.frame.maxY + 20
        }else{
            previousFrame.origin.y = self.tokenizeSwitchButton.frame.maxY + 20
        }
        submitButton.frame = previousFrame

        var cancelPreviousFrame = self.submitButton.frame
        cancelPreviousFrame.origin.y = self.submitButton.frame.maxY + 20
        cancelPreviousFrame.size.width = self.submitButton.frame.size.width * 0.5
        cancelPreviousFrame.origin.x = (self.screenDimensions.maxX - cancelPreviousFrame.size.width)/2
        cancelButton.frame = cancelPreviousFrame
        
        imageRowSection.setNeedsLayout()
        imageRowSection.setNeedsDisplay()

        
        if #available(iOS 11.0, *) {
            self.viewLayoutMarginsDidChange()
        } else {
            // Fallback on earlier versions
        }
        self.view.setNeedsDisplay()
    }
}

extension CardPaymentUI:MobpayPaymentDelegate{
    public func launchUIPayload(_ message: String) {
        
    }
    
    public func receivedPayload(_ message: String) {}
}
