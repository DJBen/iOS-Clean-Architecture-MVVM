//
//  SearchMoviesUseCase.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 22.02.19.
//

import Foundation
import Combine

protocol SearchMoviesUseCase {
    func execute(requestValue: SearchMoviesUseCaseRequestValue) -> AnyPublisher<MoviesPage, Error>
}

final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {

    private let moviesRepository: MoviesRepository
    private let moviesQueriesRepository: MoviesQueriesRepository
    
    init(moviesRepository: MoviesRepository, moviesQueriesRepository: MoviesQueriesRepository) {
        self.moviesRepository = moviesRepository
        self.moviesQueriesRepository = moviesQueriesRepository
    }
    
    func execute(requestValue: SearchMoviesUseCaseRequestValue) -> AnyPublisher<MoviesPage, Error> {
        return moviesRepository.moviesList(query: requestValue.query, page: requestValue.page).map { [unowned self] (moviesPage) -> MoviesPage in
            self.moviesQueriesRepository.saveRecentQuery(query: requestValue.query)
            return moviesPage
        }.eraseToAnyPublisher()
    }
}

struct SearchMoviesUseCaseRequestValue {
    let query: MovieQuery
    let page: Int
}
