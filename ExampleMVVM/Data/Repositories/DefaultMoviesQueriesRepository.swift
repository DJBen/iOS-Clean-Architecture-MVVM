//
//  DefaultMoviesQueriesRepository.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 15.02.19.
//

import Foundation
import Combine

final class DefaultMoviesQueriesRepository {
    
    private let dataTransferService: DataTransferService
    private var moviesQueriesPersistentStorage: MoviesQueriesStorage
    
    init(dataTransferService: DataTransferService,
         moviesQueriesPersistentStorage: MoviesQueriesStorage) {
        self.dataTransferService = dataTransferService
        self.moviesQueriesPersistentStorage = moviesQueriesPersistentStorage
    }
}

extension DefaultMoviesQueriesRepository: MoviesQueriesRepository {
    
    func recentsQueries(number: Int) -> AnyPublisher<[MovieQuery], Error> {
        return moviesQueriesPersistentStorage.recentsQueries(number: number)
    }
    
    func saveRecentQuery(query: MovieQuery) -> AnyPublisher<MovieQuery, Error> {
        return moviesQueriesPersistentStorage.saveRecentQuery(query: query)
    }
}
