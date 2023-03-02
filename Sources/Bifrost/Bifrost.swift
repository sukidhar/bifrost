import Foundation
import Combine

public class Bifrost {
    
    public static let shared = Bifrost()
    
    private init() {}
    
    
    let backgroundQueue = DispatchQueue(label: "com.suki.bifrost", qos: .default, attributes: .concurrent)
    
    public func connect<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, BiFrostError> {
        guard let request = try? endpoint.request else {
            return Fail(error: BiFrostError.invalidURLRequest).eraseToAnyPublisher()
        }
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .subscribe(on: backgroundQueue)
            .parseResponse()
            .tryMap({ data in
                guard data.count > 0 else {
                    throw BiFrostError.noData
                }
                return data
            })
            .decode()
            .mapError({ error in
                switch error {
                case is BiFrostError:
                    return error as! BiFrostError
                default:
                    return .unknownError(error)
                }
            })
            .eraseToAnyPublisher()
    }
    
    public func connect<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: try endpoint.request)
        try response.parse()
        guard data.count > 0 else {
            throw BiFrostError.noData
        }
        do {
            return try JSONDecoder.normal.decode(T.self, from: data)
        }catch{
            throw BiFrostError.failedToDecode
        }
    }
    
    public func download(endpoint: Endpoint) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: try endpoint.request)
        try response.parse()
        guard data.count > 0 else {
            throw BiFrostError.noData
        }
        return data
    }
}

extension Bifrost{
    public enum BiFrostError : Error {
        case invalidURLRequest
        case badResponse
        case badResponseCode(Int)
        case failedToDecode
        case noData
        case unknownError(Error)
    }
}
