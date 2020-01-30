//
//  MoviesListViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation
import Combine

enum MoviesListViewModelRoute {
    case initial
    case showMovieDetail(title: String, overview: String, posterPlaceholderImage: Data?, posterPath: String?)
    case showMovieQueriesSuggestions(delegate: MoviesQueryListViewModelDelegate)
    case closeMovieQueriesSuggestions
}

enum MoviesListViewModelLoading {
    case none
    case fullScreen
    case nextPage
}

protocol MoviesListViewModelInput {
    func viewDidLoad()
    func didLoadNextPage()
    func didSearch(query: String)
    func didCancelSearch()
    func showQueriesSuggestions()
    func closeQueriesSuggestions()
    func didSelect(item: MoviesListItemViewModel)
}

protocol MoviesListViewModelOutput {
    var route: MoviesListViewModelRoute { get }
    var routePublisher: Published<MoviesListViewModelRoute>.Publisher { get }

    var items: [MoviesListItemViewModel] { get }
    var itemsPublisher: Published<[MoviesListItemViewModel]>.Publisher { get }

    var loadingType: MoviesListViewModelLoading { get }
    var loadingTypePublisher: Published<MoviesListViewModelLoading>.Publisher { get }

    var query: String { get }
    var queryPublisher: Published<String>.Publisher { get }

    var error: String { get }
    var errorPublisher : Published<String>.Publisher { get }

    var isEmpty: Bool { get }
}

protocol MoviesListViewModel: MoviesListViewModelInput, MoviesListViewModelOutput {}

final class DefaultMoviesListViewModel: MoviesListViewModel {
    
    private(set) var currentPage: Int = 0
    private var totalPageCount: Int = 1
    
    var hasMorePages: Bool {
        return currentPage < totalPageCount
    }
    var nextPage: Int {
        guard hasMorePages else { return currentPage }
        return currentPage + 1
    }
    
    private let searchMoviesUseCase: SearchMoviesUseCase
    private let posterImagesRepository: PosterImagesRepository
    
    private var moviesLoadTask: AnyCancellable?
    
    // MARK: - OUTPUT
    @Published var route: MoviesListViewModelRoute = .initial
    var routePublisher: Published<MoviesListViewModelRoute>.Publisher {
        return $route
    }

    @Published var items: [MoviesListItemViewModel] = []
    var itemsPublisher: Published<[MoviesListItemViewModel]>.Publisher {
        return $items
    }

    @Published var loadingType: MoviesListViewModelLoading = .none
    var loadingTypePublisher: Published<MoviesListViewModelLoading>.Publisher {
        return $loadingType
    }

    @Published var query: String = ""
    var queryPublisher: Published<String>.Publisher {
        return $query
    }

    @Published var error: String = ""
    var errorPublisher: Published<String>.Publisher {
        return $error
    }

    var isEmpty: Bool { return items.isEmpty }
    
    @discardableResult
    init(searchMoviesUseCase: SearchMoviesUseCase,
         posterImagesRepository: PosterImagesRepository) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.posterImagesRepository = posterImagesRepository
    }
    
    private func appendPage(moviesPage: MoviesPage) {
        self.currentPage = moviesPage.page
        self.totalPageCount = moviesPage.totalPages
        self.items = items + moviesPage.movies.map {
            DefaultMoviesListItemViewModel(movie: $0,
                                           posterImagesRepository: posterImagesRepository)
        }
    }
    
    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        items.removeAll()
    }
    
    private func load(movieQuery: MovieQuery, loadingType: MoviesListViewModelLoading) {
        self.loadingType = loadingType
        self.query = movieQuery.query
        
        let moviesRequest = SearchMoviesUseCaseRequestValue(query: movieQuery, page: nextPage)
        moviesLoadTask = searchMoviesUseCase.execute(requestValue: moviesRequest).receive(on: RunLoop.main).sink(receiveCompletion: { [unowned self] (completion) in
            switch completion {
                case .failure(let error):
                    self.handle(error: error)
                case .finished: break
            }
            self.loadingType = .none
        }, receiveValue: { [unowned self] (moviesPage) in
            self.appendPage(moviesPage: moviesPage)
        })
    }
    
    private func handle(error: Error) {
        self.error = error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading movies", comment: "")
    }
    
    private func update(movieQuery: MovieQuery) {
        resetPages()
        load(movieQuery: movieQuery, loadingType: .fullScreen)
    }
}

// MARK: - INPUT. View event methods
extension DefaultMoviesListViewModel {

    func viewDidLoad() { }
    
    func didLoadNextPage() {
        guard hasMorePages, loadingType == .none else { return }
        load(movieQuery: MovieQuery(query: query),
             loadingType: .nextPage)
    }
    
    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        update(movieQuery: MovieQuery(query: query))
    }
    
    func didCancelSearch() {
        moviesLoadTask?.cancel()
    }

    func showQueriesSuggestions() {
        route = .showMovieQueriesSuggestions(delegate: self)
    }
    
    func closeQueriesSuggestions() {
        route = .closeMovieQueriesSuggestions
    }
    
    func didSelect(item: MoviesListItemViewModel) {
        route = .showMovieDetail(title: item.title,
                                       overview: item.overview,
                                       posterPlaceholderImage: item.posterImage,
                                       posterPath: item.posterPath)
    }
}

// MARK: - Delegate method from another model views
extension DefaultMoviesListViewModel: MoviesQueryListViewModelDelegate {
    func moviesQueriesListDidSelect(movieQuery: MovieQuery) {
        update(movieQuery: movieQuery)
    }
}
