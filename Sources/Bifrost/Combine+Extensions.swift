//
//  Combine+Extensions.swift
//  
//
//  Created by sukidhar on 02/03/23.
//

import Foundation
import UIKit
import Combine

extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    func parseResponse() -> AnyPublisher<Data, Error> {
        tryMap { (data: Data, urlResponse: URLResponse) in
            try urlResponse.parse()
            return data
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func decode<T: Decodable>(
        as type: T.Type = T.self,
        using decoder: JSONDecoder = .snakeCaseConverting
    ) -> Publishers.Decode<Self, T, JSONDecoder> {
        decode(type: type, decoder: decoder)
    }
}

extension URLResponse {
    func parse() throws {
        guard let response = self as? HTTPURLResponse else {
            throw Bifrost.BiFrostError.badResponse
        }
        guard 200...299 ~= response.statusCode else {
            throw Bifrost.BiFrostError.badResponseCode(response.statusCode)
        }
    }
}


extension JSONDecoder {
    static let snakeCaseConverting: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    static let normal: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
}


extension Data {
    public func makeImage() -> UIImage? {
        return UIImage(data: self)
    }
}

extension Dictionary {
    var json: Data {
        get throws {
            return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        }
    }
}
