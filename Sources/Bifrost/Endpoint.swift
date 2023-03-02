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
    var headers : [Header]?
    private var data: Data?
    
    public init(method: Method = .get, urlString: String, path: String? = nil, headers: [Header]? = []) {
        self.method = method
        self.urlString = urlString
        self.path = path
        self.headers = headers
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
            return url
        }
    }
    
    var request : URLRequest {
        get throws{
            var req = try URLRequest(url: url)
            req.httpMethod = method.rawValue
            headers?.forEach { header in
                req.setValue(header.value, forHTTPHeaderField: header.key.rawValue)
            }
            if let _ = data {
                req.httpBody = data
            }
            return req
        }
    }
    
    @discardableResult
    public mutating func set(_ data: Data) -> Endpoint {
        self.data = data
        return self
    }
    
    @discardableResult
    public mutating func set(_ dict: [String: Encodable]) throws -> Endpoint {
        self.data = try dict.json
        return self
    }
    
    @discardableResult
    public mutating func set(_ header: Header) -> Endpoint {
        self.headers?.append(header)
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
