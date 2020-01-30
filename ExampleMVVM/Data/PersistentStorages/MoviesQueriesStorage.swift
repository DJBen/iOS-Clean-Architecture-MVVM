//
//  MoviesQueriesStorage.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation
import Combine

protocol MoviesQueriesStorage {
    func recentsQueries(number: Int) -> AnyPublisher<[MovieQuery], Error>
    func saveRecentQuery(query: MovieQuery) -> AnyPublisher<MovieQuery, Error>
}
