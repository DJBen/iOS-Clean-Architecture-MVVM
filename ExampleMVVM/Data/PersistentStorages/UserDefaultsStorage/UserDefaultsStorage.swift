//
//  DefaultMoviesRecentQueriesStorage.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import Foundation
import Combine

final class UserDefaultsStorage {
    private let maxStorageLimit: Int
    private let recentsMoviesQueriesKey = "recentsMoviesQueries"
    private var userDefaults: UserDefaults { return UserDefaults.standard }
    
    private var moviesQuries: [MovieQuery] {
        get {
            if let queriesData = userDefaults.object(forKey: recentsMoviesQueriesKey) as? Data {
                let decoder = JSONDecoder()
                if let movieQueryList = try? decoder.decode(MovieQueriesListUDS.self, from: queriesData) {
                    return movieQueryList.list.map ( MovieQuery.init )
                }
            }
            return []
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(MovieQueriesListUDS(list: newValue.map ( MovieQueryUDS.init ))) {
                userDefaults.set(encoded, forKey: recentsMoviesQueriesKey)
            }
        }
    }
    
    init(maxStorageLimit: Int) {
        self.maxStorageLimit = maxStorageLimit
    }
    
    fileprivate func removeOldQueries(_ queries: [MovieQuery]) -> [MovieQuery] {
        return queries.count <= maxStorageLimit ? queries : Array(queries[0..<maxStorageLimit])
    }
}

extension UserDefaultsStorage: MoviesQueriesStorage {
    func recentsQueries(number: Int) -> AnyPublisher<[MovieQuery], Error> {
        return Future<[MovieQuery], Error> { (completion) in
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let strongSelf = self else { return }
                var queries = strongSelf.moviesQuries
                queries = queries.count < strongSelf.maxStorageLimit ? queries : Array(queries[0..<number])
                completion(.success(queries))
            }
        }.eraseToAnyPublisher()
    }

    func saveRecentQuery(query: MovieQuery) -> AnyPublisher<MovieQuery, Error> {
        return Future<MovieQuery, Error> { (completion) in
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let strongSelf = self else { return }
                var queries = strongSelf.moviesQuries
                queries = queries.filter { $0 != query }
                queries.insert(query, at: 0)
                strongSelf.moviesQuries = strongSelf.removeOldQueries(queries)
                completion(.success(query))
            }
        }.eraseToAnyPublisher()
    }
}
