//
//  PosterImagesRepositoryMock.swift
//  ExampleMVVMTests
//
//  Created by Oleh Kudinov on 17.08.19.
//

import Foundation
import XCTest
import Combine

class PosterImagesRepositoryMock: PosterImagesRepository {
    var expectation: XCTestExpectation?
    var error: Error?
    var image = Data()
    var validateInput: ((String, Int) -> Void)?
    
    func image(with imagePath: String, width: Int) -> AnyPublisher<Data, Error> {
        return Future<Data, Error>({ [unowned self] (completion) in
            self.validateInput?(imagePath, width)
            if let error = self.error {
                completion(.failure(error))
            } else {
                completion(.success(self.image))
            }
            self.expectation?.fulfill()
        }).eraseToAnyPublisher()
    }
}
