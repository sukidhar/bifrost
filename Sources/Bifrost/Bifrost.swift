import Foundation
import Combine

/// Bifrost is inspired by the term from `Thor movie` or `Norse mythology` to connect two different places.
/// It is quite possible to get lost with plenty of errors or produce lots of repeating code across multiple projects.
/// Bifrost aims to be the generic simple reusable module to interact with your apis. It is nowhere close to Alamofire
/// and only goal of Bifrost is to reuse some basic networking layer across projects, with ease.
public class Bifrost {
    /// shared instance of Bifrost.
    public static let shared = Bifrost()
    
    private init() {}
    
    /// processing background queue for URLSession
    let backgroundQueue = DispatchQueue(label: "com.suki.bifrost", qos: .default, attributes: .concurrent)
    
    
    /// Connects to given endpoint and process the http request with all the given configuration to `Endpoint` instance.
    /// Oppurtunity to utilise the response of the request in the form of generic combine publisher.
    /// - Parameter endpoint: `Endpoint` instance
    /// - Returns: `AnyPublisher` with the provided generic object type.
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
    
    /// Connects to given endpoint and process the http request with all the given configuration to `Endpoint` instance.
    /// Oppurtunity to utilise the response of the request in the form of latest concurrency model.
    /// - Parameter endpoint: `Endpoint` instance.
    /// - Returns: `T` where T is conforming to `Decodable` protocol.
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
    
    /// Connects to given endpoint and process the http request with all the given configuration to `Endpoint` instance.
    /// Oppurtunity to utilise the response of the request in the form of latest concurrency model but with no data decoding.
    /// It is helpful in order to download image or file content whose data should be used `Raw`.
    /// - Parameter endpoint: `Endpoint` instance
    /// - Returns: `Data`
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
