import Foundation
import Alamofire

public enum AccountsApiRequestRouter: URLRequestConvertible {
    
    // MARK: - GET
    case getIbanInformation(iban: String)
    case getBalance(accountNumber: String)
    case getPaymentCards(cardsFilter: PSGetPaymentCardsFilterRequest)
    case getPaymentCardLimit(accountNumber: String)
    
    // MARK: - POST
    case createCard(PSCreatePaymentCardRequest)
    
    // MARK: - PUT
    case activateCard(id: Int)
    case enableCard(id: Int)
    case deactivateCard(id: Int)
    case setPaymentCardLimit(accountNumber: String, cardLimit: PSUpdatePaymentCardLimitRequest)
    case retrievePaymentCardPIN(id: Int, cvv: String)
    case cancelPaymentCard(id: Int)
    
    // MARK: - Declarations
    static var baseURLString = "https://accounts.paysera.com/public"
    
    private var method: HTTPMethod {
        switch self {
        case .getIbanInformation( _),
             .getBalance( _),
             .getPaymentCards( _),
             .getPaymentCardLimit( _):
            return .get
            
        case .createCard( _):
            return .post
            
        case .activateCard( _),
             .enableCard(_ ),
             .deactivateCard( _),
             .setPaymentCardLimit( _, _),
             .retrievePaymentCardPIN( _, _),
             .cancelPaymentCard( _):
            return .put
        }
    }
    
    private var path: String {
        switch self {
            
        case .getIbanInformation(let iban):
            return "/transfer/rest/v1/swift/\(iban)"
            
        case .getBalance(let accountNumber):
            return "/account/rest/v1/accounts/\(accountNumber)/full-balance"
            
        case .getPaymentCards( _):
            return "/issued-payment-card/v1/cards"
            
        case .getPaymentCardLimit(let accountNumber):
            return "/issued-payment-card/v1/accounts/\(accountNumber)/card-limit"
            
        case .createCard( _):
            return "/issued-payment-card/v1/cards"
            
        case .activateCard(let id):
            return "/issued-payment-card/v1/cards/\(String(id))/activate"
        
        case .enableCard(let id):
            return "/issued-payment-card/v1/cards/\(String(id))/enable"
            
        case .deactivateCard(let id):
            return "/issued-payment-card/v1/cards/\(String(id))/deactivate"
            
        case .setPaymentCardLimit(let accountNumber, _):
            return "/issued-payment-card/v1/accounts/\(accountNumber)/card-limit"
            
        case .retrievePaymentCardPIN(let id, _):
            return "/issued-payment-card/v1/cards/\(String(id))/pin"
            
        case .cancelPaymentCard(let id):
            return "/issued-payment-card/v1/cards/\(String(id))/cancel"
        }
    }
    
    private var parameters: Parameters? {
        switch self {
 
        case .getPaymentCards(let cardsFilter):
            return cardsFilter.toJSON()
            
        case .createCard(let psCard):
            return psCard.toJSON()
            
        case .setPaymentCardLimit(_, let cardLimit):
            return cardLimit.toJSON()
            
        case .retrievePaymentCardPIN( _, let cvv):
            return ["cvv2" :cvv]
            
        default:
            return nil
        }
    }
    
    // MARK: - Method
    public func asURLRequest() throws -> URLRequest {
        let url = try! AccountsApiRequestRouter.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        
        case (_) where method == .get:
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            
        case (_) where method == .post:
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
            
        case (_) where method == .put:
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
            
        default:
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        }
        
        return urlRequest
    }
}
