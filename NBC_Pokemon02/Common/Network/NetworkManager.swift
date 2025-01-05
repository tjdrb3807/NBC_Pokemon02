//
//  NetworkManager.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 12/30/24.
//

import Foundation
import RxSwift

enum NetworkError: Error {
    case invalidURL
    case dataFetchFail
    case decodingFail
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() { }
    
    func fetch<T: Decodable>(url: URL) -> Single<T> {
        Single.create { observer in
            let session = URLSession(configuration: .default)
            
            session.dataTask(with: URLRequest(url: url)) { data, response, error in
                if let error = error { return observer(.failure(error)) }
                
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode) else { return observer(.failure(NetworkError.dataFetchFail)) }
                
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    observer(.success(decodedData))
                } catch {
                    observer(.failure(NetworkError.decodingFail))
                }
            }.resume()
            
            return Disposables.create()
        }
    }
}
