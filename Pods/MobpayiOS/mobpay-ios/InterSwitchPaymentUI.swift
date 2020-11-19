
import UIKit

open class InterSwitchPaymentUI : UIViewController {
    
    var InterSwitchPaymentUIDelegate:InterSwitchPaymentUIDelegate?

    var payment:Payment!
    var customer:Customer!
    var merchantConfig:MerchantConfig!
    var clientId:String!
    var clientSecret:String!
    var cardTokens:Array<CardToken>? = nil
    
    public convenience init(payment: Payment, customer: Customer,clientId:String,clientSecret:String,merchantConfig:MerchantConfig,cardTokens:Array<CardToken>? = nil) {
        self.init()
        self.payment = payment;
        self.customer = customer;
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.merchantConfig = merchantConfig
        self.cardTokens = cardTokens
        //TODO add token details
    }
    
    let tabBarCnt = UITabBarController()
    override open func viewDidLoad() {
        super.viewDidLoad()
        tabBarCnt.tabBar.tintColor = UIColor.blue
        createTabBarController()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func createTabBarController() {
        var controllerArray:Array<UIViewController> = []

        if self.merchantConfig.cardStatus == 1 {
            let cardVC = CardPaymentUI(payment: self.payment, customer: self.customer,merchantConfig: self.merchantConfig, cardTokens: self.cardTokens)
            cardVC.title = "CARD"
            cardVC.tabBarItem = UITabBarItem.init(title: "CARD", image: UIImage(named: "CARD"), tag: 0)
            cardVC.CardPaymentUIDelegate = self
            controllerArray.append(cardVC)
        }
        if self.merchantConfig.airtelStatus == 1 || self.merchantConfig.mpesaStatus == 1 || self.merchantConfig.tkashStatus == 1 || self.merchantConfig.equitelStatus == 1 {
            let mobileVC = MobilePaymentUI(payment: self.payment, customer: self.customer, merchantConfig: self.merchantConfig)
            mobileVC.title = "MOBILE"
            mobileVC.tabBarItem = UITabBarItem.init(title: "MOBILE", image: UIImage(named: "MOBILE"), tag: 1)
            mobileVC.MobilePaymentUIDelegate = self
            controllerArray.append(mobileVC)
        }
        if self.merchantConfig.paycodeStatus == 1 {
            let vervePaycodeVC = UIViewController()
            vervePaycodeVC.title = "VERVE PAYCODE"
            vervePaycodeVC.view.backgroundColor = UIColor.blue
            controllerArray.append(vervePaycodeVC)
        }
        if self.merchantConfig.bnkStatus == 1 {
            let bankVC = UIViewController()
            bankVC.title = "BANK"
            bankVC.view.backgroundColor = UIColor.yellow
            controllerArray.append(bankVC)
        }
        
        tabBarCnt.viewControllers = controllerArray.map{ UINavigationController.init(rootViewController: $0)}
        
        self.view.addSubview(tabBarCnt.view)
    }
}

protocol InterSwitchPaymentUIDelegate {
    func didReceivePayload(_ message:String)
}

extension InterSwitchPaymentUI: CardPaymentUIDelegate{
    func didReceiveCardPayload(_ payload: String) {
        self.InterSwitchPaymentUIDelegate?.didReceivePayload(payload)
    }
}

extension InterSwitchPaymentUI: MobilePaymentUIDelegate{
    func didReceiveMobilePayload(_ payload: String) {
        self.InterSwitchPaymentUIDelegate?.didReceivePayload(payload)
    }
}
