//
//  NetworkSessionManagerMock.swift
//  ExampleMVVMTests
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation
import Combine

struct NetworkSessionManagerMock: NetworkSessionManager {
    let response: HTTPURLResponse?
    let data: Data?
    let error: Error?
    
    func request(_ request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        return Future<URLSession.DataTaskPublisher.Output, Error>.init({ (completion) in
            if let error = self.error {
                completion(.failure(error))
            } else {
                completion(.success((data: self.data!, response: self.response!)))
            }
        }).eraseToAnyPublisher()
    }
}
