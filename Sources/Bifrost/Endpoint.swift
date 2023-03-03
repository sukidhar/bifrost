//
//  Endpoint.swift
//  
//
//  Created by sukidhar on 01/03/23.
//

import Foundation

public struct Endpoint {
    let method: Method
    let urlString : String
    let path : String?
    var headers : [Header]
    var params: [URLQueryItem]
    private var data: Data?
    
    
    /// Initialises the endpoint with given options
    /// - Parameters:
    ///   - method: `HTTPMethod` to use
    ///   - urlString: Resource url to perform request with
    ///   - path: Resource path of the base URL
    ///   - headers: Headers to be used with Request
    ///   - params: URL query params
    ///   - data: Any data to append with request, works only with body compatible methods
    init(method: Method = .get, urlString: String, path: String? = nil, headers: [Header] = [], params: [URLQueryItem] = [], data: Data? = nil) {
        self.method = method
        self.urlString = urlString
        self.path = path
        self.headers = headers
        self.params = params
        self.data = data
    }
    
    public var url : URL {
        get throws {
            guard var url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            if let path = path {
                guard let nsPath = NSString(string: path).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
                    throw URLError(.badURL)
                }
                url = URL(string: nsPath, relativeTo: url)!
            }
            if #available(iOS 16.0, *) {
                url.append(queryItems: params)
                return url
            } else {
                guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    throw URLError(.unsupportedURL)
                }
                components.queryItems = params
                if components.url == nil {
                    throw URLError(.badURL)
                }
                return components.url!
            }
        }
    }
    
    var request : URLRequest {
        get throws{
            var req = try URLRequest(url: url)
            req.httpMethod = method.rawValue
            headers.forEach { header in
                req.setValue(header.value, forHTTPHeaderField: header.key.rawValue)
            }
            if let _ = data, [Method.put, .post, .patch].contains(method) {
                req.httpBody = data
            }
            return req
        }
    }
    
    
    
    /// set data to `URLRequest`
    /// - Parameter data: `Data`.
    /// - Returns: a discardable result of caller, helpful to chain.
    @discardableResult
    public mutating func set(_ data: Data) -> Endpoint {
        self.data = data
        return self
    }
    
    /// set dictionary to `URLRequest`
    /// - Parameter dict: Dictionary with Encodable key and value. throws an error when the data is not convertible to `JSON`
    /// - Returns: a discardable result of caller, helpful to chain.
    @discardableResult
    public mutating func set(_ dict: [String: Encodable]) throws -> Endpoint {
        self.data = try dict.json
        return self
    }
    
    /// set header to `URLRequest`
    /// - Parameter header: `Header` struct which contains `Key` as `HTTPHeader` and `Value`.
    /// - Returns: a discardable result of caller, helpful to chain.
    @discardableResult
    public mutating func set(_ header: Header) -> Endpoint {
        self.headers.append(header)
        return self
    }
    
    /// drop header to `URLRequest`
    /// - Parameter type: `HeaderType` enum
    /// - Returns: a discardable result of caller, helpful to chain.
    @discardableResult
    public mutating func drop(_ type: Header.HeaderType) -> Endpoint {
        self.headers.removeAll { $0.key == type}
        return self
    }
    
    /// set queryItem to `URLRequest`
    /// - Parameter param: `URLQueryItem` struct.
    /// - Returns: a discardable result of caller, helpful to chain.
    @discardableResult
    public mutating func set(_ param: URLQueryItem) -> Endpoint {
        self.params.append(param)
        return self
    }
    
    /// drop queryItem to `URLRequest`
    /// - Parameter name: `String`, name of the URLQueryItem.
    /// - Returns: a discardable result of caller, helpful to chain.
    @discardableResult
    public mutating func drop(_ name: String) -> Endpoint {
        self.params.removeAll { $0.name == name }
        return self
    }
}

extension Endpoint {
    public enum Method : RawRepresentable, CaseIterable{
        public init?(rawValue: String) {
            self = Method.allCases.first { method in
                method.rawValue == rawValue.lowercased()
            } ?? Method.get
        }
        
        case get, post, put, patch, delete
        
        public var rawValue: String {
            String(describing: self).uppercased()
        }
    }
}

extension Endpoint {
    public struct Header {
        let key : HeaderType
        let value: String
        
        public init(_ key: HeaderType, value: String) {
            self.key = key
            self.value = value
        }
    }
}

extension Endpoint.Header {
    public enum HeaderType {
        case wwwAuthenticate
        case authorization
        case proxyAuthenticate
        case proxyAuthorization
        case connection
        case keepAlive
        case accept
        case acceptEncoding
        case acceptLanguage
        case cookie
        case origin
        case contentLength
        case contentType
        case contentEncoding
        case contentLanguage
        case contentLocation
        case from
        case host
        case referer
        case referrerPolicy
        case userAgent
        case custom(String)
    }
}

extension Endpoint.Header.HeaderType : RawRepresentable {
    public init?(rawValue: String) {
        self = .custom(rawValue)
    }
    
    public var rawValue: String {
        switch self {
        case .wwwAuthenticate:
            return "WWW-Authenticate"
        case .custom(let string):
            return string
        default:
            return self.getHeaderKey()
        }
    }
    
    func getHeaderKey() -> String {
        String(describing: self)
            .unicodeScalars.reduce("") { CharacterSet.uppercaseLetters.contains($1) ?  $0 + " " + String($1) : $0 + String($1)}
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: "-")
    }
}
