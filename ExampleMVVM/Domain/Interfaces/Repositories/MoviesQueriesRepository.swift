//
//  MoviesQueriesRepositoryInterface.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 15.02.19.
//

import Foundation
import Combine

protocol MoviesQueriesRepository {
    func recentsQueries(number: Int) -> AnyPublisher<[MovieQuery], Error>
    @discardableResult func saveRecentQuery(query: MovieQuery) -> AnyPublisher<MovieQuery, Error>
}
