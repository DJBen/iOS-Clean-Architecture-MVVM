//
//  FetchRecentMovieQueriesUseCase.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 11.08.19.
//

import Foundation
import Combine

protocol FetchRecentMovieQueriesUseCase {
    func execute(requestValue: FetchRecentMovieQueriesUseCaseRequestValue) -> AnyPublisher<[MovieQuery], Error>
}

final class DefaultFetchRecentMovieQueriesUseCase: FetchRecentMovieQueriesUseCase {
    
    private let moviesQueriesRepository: MoviesQueriesRepository
    
    init(moviesQueriesRepository: MoviesQueriesRepository) {
        self.moviesQueriesRepository = moviesQueriesRepository
    }
    
    func execute(requestValue: FetchRecentMovieQueriesUseCaseRequestValue) -> AnyPublisher<[MovieQuery], Error> {
        return moviesQueriesRepository.recentsQueries(number: requestValue.number)
    }
}

struct FetchRecentMovieQueriesUseCaseRequestValue {
    let number: Int
}
