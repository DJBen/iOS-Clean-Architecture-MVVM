//
//  MoviesQueryListViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import Foundation
import Combine

protocol MoviesQueryListViewModelInput {
    func viewWillAppear()
    func didSelect(item: MoviesQueryListItemViewModel)
}

protocol MoviesQueryListViewModelOutput {
    var items: [MoviesQueryListItemViewModel] { get }
    var itemsPublisher: Published<[MoviesQueryListItemViewModel]>.Publisher { get }
}

protocol MoviesQueryListViewModel: MoviesQueryListViewModelInput, MoviesQueryListViewModelOutput { }

protocol MoviesQueryListViewModelDelegate: class {
    
    func moviesQueriesListDidSelect(movieQuery: MovieQuery)
}

final class DefaultMoviesQueryListViewModel: MoviesQueryListViewModel {

    private let numberOfQueriesToShow: Int
    private let fetchRecentMovieQueriesUseCase: FetchRecentMovieQueriesUseCase
    private weak var delegate: MoviesQueryListViewModelDelegate?
    
    // MARK: - OUTPUT
    @Published var items: [MoviesQueryListItemViewModel] = []
    var itemsPublisher: Published<[MoviesQueryListItemViewModel]>.Publisher {
        return $items
    }

    private var updateQueriesTask: AnyCancellable?
    
    init(numberOfQueriesToShow: Int,
         fetchRecentMovieQueriesUseCase: FetchRecentMovieQueriesUseCase,
         delegate: MoviesQueryListViewModelDelegate? = nil) {
        self.numberOfQueriesToShow = numberOfQueriesToShow
        self.fetchRecentMovieQueriesUseCase = fetchRecentMovieQueriesUseCase
        self.delegate = delegate
    }
    
    private func updateMoviesQueries() {
        let request = FetchRecentMovieQueriesUseCaseRequestValue(number: numberOfQueriesToShow)
        updateQueriesTask = fetchRecentMovieQueriesUseCase.execute(requestValue: request).receive(on: RunLoop.main).sink(receiveCompletion: { (completion) in

        }, receiveValue: { [unowned self] (result) in
            self.items = result.map { $0.query }.map ( DefaultMoviesQueryListItemViewModel.init )
        })
    }
}

// MARK: - INPUT. View event methods
extension DefaultMoviesQueryListViewModel {
        
    func viewWillAppear() {
        updateMoviesQueries()
    }
    
    func didSelect(item: MoviesQueryListItemViewModel) {
        delegate?.moviesQueriesListDidSelect(movieQuery: MovieQuery(query: item.query))
    }
}
