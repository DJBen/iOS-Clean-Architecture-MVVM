//
//  DefaultMoviesRepository.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation
import Combine

final class DefaultMoviesRepository {
    
    private let dataTransferService: DataTransferService
    
    init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
}

extension DefaultMoviesRepository: MoviesRepository {
    
    public func moviesList(query: MovieQuery, page: Int) -> AnyPublisher<MoviesPage, Error> {
        
        let endpoint = APIEndpoints.movies(query: query.query, page: page)
        return self.dataTransferService.request(with: endpoint)
    }
}
