//
//  MoviesListItemViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 18.02.19.
//

import Foundation
import Combine

protocol MoviesListItemViewModelInput {
    func didEndDisplaying()
    func updatePosterImage(width: Int)
}

protocol MoviesListItemViewModelOutput {
    var title: String { get }
    var overview: String { get }
    var releaseDate: String { get }
    var posterImage: Data? { get }
    var posterImagePublisher: Published<Data?>.Publisher { get }
    var posterPath: String? { get }
}

protocol MoviesListItemViewModel: MoviesListItemViewModelInput, MoviesListItemViewModelOutput {}

final class DefaultMoviesListItemViewModel: MoviesListItemViewModel {
    
    private(set) var id: MovieId

    // MARK: - OUTPUT
    let title: String
    let overview: String
    let releaseDate: String
    let posterPath: String?
    @Published var posterImage: Data? = nil
    var posterImagePublisher: Published<Data?>.Publisher {
        return $posterImage
    }

    private let posterImagesRepository: PosterImagesRepository
    private var imageLoadTask: AnyCancellable?

    init(movie: Movie,
         posterImagesRepository: PosterImagesRepository) {
        self.id = movie.id
        self.title = movie.title
        self.posterPath = movie.posterPath
        self.overview = movie.overview
        self.releaseDate = movie.releaseDate != nil ? dateFormatter.string(from: movie.releaseDate!) : NSLocalizedString("To be announced", comment: "")
        self.posterImagesRepository = posterImagesRepository
    }
}

// MARK: - INPUT. View event methods
extension DefaultMoviesListItemViewModel {
    
    func didEndDisplaying() {
        posterImage = nil
    }
    
    func updatePosterImage(width: Int) {
        posterImage = nil
        guard let posterPath = posterPath else { return }
        
        imageLoadTask = posterImagesRepository.image(with: posterPath, width: width).sink(receiveCompletion: { (completion) in

        }, receiveValue: { (data) in
            self.posterImage = data
        })
    }
}

func == (lhs: DefaultMoviesListItemViewModel, rhs: DefaultMoviesListItemViewModel) -> Bool {
    return (lhs.id == rhs.id)
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
