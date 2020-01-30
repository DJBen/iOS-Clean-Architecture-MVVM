//
//  MoviesRepositoryInterfaces.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation
import Combine

protocol MoviesRepository {
    @discardableResult
    func moviesList(query: MovieQuery, page: Int) -> AnyPublisher<MoviesPage, Error>
}
