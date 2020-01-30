//
//  SearchMoviesUseCaseTests.swift
//  CodeChallengeTests
//
//  Created by Oleh Kudinov on 01.10.18.
//

import XCTest
import Combine

class SearchMoviesUseCaseTests: XCTestCase {
    
    static let moviesPages: [MoviesPage] = {
        let page1 = MoviesPage(page: 1, totalPages: 2, movies: [
            Movie(id: "1", title: "title1", posterPath: "/1", overview: "overview1", releaseDate: nil),
            Movie(id: "2", title: "title2", posterPath: "/2", overview: "overview2", releaseDate: nil)])
        let page2 = MoviesPage(page: 2, totalPages: 2, movies: [
            Movie(id: "3", title: "title3", posterPath: "/3", overview: "overview3", releaseDate: nil)])
        return [page1, page2]
    }()
    
    enum MoviesRepositorySuccessTestError: Error {
        case failedFetching
    }
    
    class MoviesQueriesRepositoryMock: MoviesQueriesRepository {
        var recentQueries: [MovieQuery] = []
        
        func recentsQueries(number: Int) -> AnyPublisher<[MovieQuery], Error> {
            return Future<[MovieQuery], Error>({ [unowned self] (completion) in
                completion(.success(self.recentQueries))
            }).eraseToAnyPublisher()
        }
        func saveRecentQuery(query: MovieQuery) -> AnyPublisher<MovieQuery, Error> {
            return Future<MovieQuery, Error>({ [unowned self] (completion) in
                self.recentQueries.append(query)
                completion(.success(query))
            }).eraseToAnyPublisher()
        }
    }
    
    class MoviesRepositorySuccessMock: MoviesRepository {
        func moviesList(query: MovieQuery, page: Int) -> AnyPublisher<MoviesPage, Error> {
            return Future<MoviesPage, Error>({ (completion) in
                completion(.success(SearchMoviesUseCaseTests.moviesPages[0]))
            }).eraseToAnyPublisher()
        }
    }
    
    class MoviesRepositoryFailureMock: MoviesRepository {
        func moviesList(query: MovieQuery, page: Int) -> AnyPublisher<MoviesPage, Error> {
            return Future<MoviesPage, Error>({ (completion) in
                completion(.failure(MoviesRepositorySuccessTestError.failedFetching))
            }).eraseToAnyPublisher()
        }
    }
    
    func testSearchMoviesUseCase_whenSuccessfullyFetchesMoviesForQuery_thenQueryIsSavedInRecentQueries() {
        // given
        let expectation = self.expectation(description: "Recent query saved")
        expectation.expectedFulfillmentCount = 2
        let moviesQueriesRepository = MoviesQueriesRepositoryMock()
        let useCase = DefaultSearchMoviesUseCase(moviesRepository: MoviesRepositorySuccessMock(),
                                                  moviesQueriesRepository: moviesQueriesRepository)

        // when
        let requestValue = SearchMoviesUseCaseRequestValue(query: MovieQuery(query: "title1"),
                                                                                     page: 0)
        _ = useCase.execute(requestValue: requestValue).sink(receiveCompletion: { (_) in
        }, receiveValue: { (_) in
            expectation.fulfill()
        })
        // then
        _ = moviesQueriesRepository.recentsQueries(number: 1).sink(receiveCompletion: { (_) in
        }, receiveValue: { (recents) in
            XCTAssertTrue(recents.contains(MovieQuery(query: "title1")))
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testSearchMoviesUseCase_whenFailedFetchingMoviesForQuery_thenQueryIsNotSavedInRecentQueries() {
        // given
        let expectation = self.expectation(description: "Recent query should not be saved")
        expectation.expectedFulfillmentCount = 2
        let moviesQueriesRepository = MoviesQueriesRepositoryMock()
        let useCase = DefaultSearchMoviesUseCase(moviesRepository: MoviesRepositoryFailureMock(),
                                                moviesQueriesRepository: moviesQueriesRepository)
        
        // when
        let requestValue = SearchMoviesUseCaseRequestValue(query: MovieQuery(query: "title1"), page: 0)
        _ = useCase.execute(requestValue: requestValue).sink(receiveCompletion: { (_) in
        }, receiveValue: { (_) in
            expectation.fulfill()
        })
        // then
        _ = moviesQueriesRepository.recentsQueries(number: 1).sink(receiveCompletion: { (_) in
        }, receiveValue: { (recents) in
            XCTAssertTrue(recents.isEmpty)
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
}
