//
//  DefaultPosterImagesRepository.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation
import Combine

final class DefaultPosterImagesRepository {
    
    private let dataTransferService: DataTransferService
    private let imageNotFoundData: Data?
    
    init(dataTransferService: DataTransferService,
         imageNotFoundData: Data?) {
        self.dataTransferService = dataTransferService
        self.imageNotFoundData = imageNotFoundData
    }
}

extension DefaultPosterImagesRepository: PosterImagesRepository {
    
    func image(with imagePath: String, width: Int) -> AnyPublisher<Data, Error> {
        
        let endpoint = APIEndpoints.moviePoster(path: imagePath, width: width)
        return dataTransferService.request(with: endpoint).catch { [unowned self] (error) -> AnyPublisher<Data, Error> in
            if case let DataTransferError.networkFailure(networkError) = error, networkError.isNotFoundError,
                let imageNotFoundData = self.imageNotFoundData {
                return Future<Data, Error>({ $0(.success(imageNotFoundData)) }).eraseToAnyPublisher()
            } else {
                return Fail<Data, Error>(error: error).eraseToAnyPublisher()
            }
        }.eraseToAnyPublisher()
    }
}
