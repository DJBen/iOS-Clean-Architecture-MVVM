//
//  MovieDetailsViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 04.08.19.
//  Copyright (c) 2019 All rights reserved.
//

import Foundation
import Combine

protocol MovieDetailsViewModelInput {
    func updatePosterImage(width: Int)
}

protocol MovieDetailsViewModelOutput {
    var title: String { get }
    var titlePublisher: Published<String>.Publisher { get }
    var posterImage: Data? { get }
    var posterImagePublisher: Published<Data?>.Publisher { get }
    var overview: String { get }
    var overviewPublisher: Published<String>.Publisher { get }
}

protocol MovieDetailsViewModel: MovieDetailsViewModelInput, MovieDetailsViewModelOutput { }

final class DefaultMovieDetailsViewModel: MovieDetailsViewModel {
    
    private let posterPath: String?
    private let posterImagesRepository: PosterImagesRepository
    private var imageLoadTask: AnyCancellable?
    private var alreadyLoadedImageWidth: Int?
    
    // MARK: - OUTPUT
    @Published var title: String = ""
    var titlePublisher: Published<String>.Publisher {
        return $title
    }

    @Published var posterImage: Data? = nil
    var posterImagePublisher: Published<Data?>.Publisher {
        return $posterImage
    }

    @Published var overview: String = ""
    var overviewPublisher: Published<String>.Publisher {
        return $overview
    }
    
    init(title: String,
         overview: String,
         posterPlaceholderImage: Data?,
         posterPath: String?,
         posterImagesRepository: PosterImagesRepository) {
        self.title = title
        self.overview = overview
        self.posterImage = posterPlaceholderImage
        self.posterPath = posterPath
        self.posterImagesRepository = posterImagesRepository
    }
}

// MARK: - INPUT. View event methods
extension DefaultMovieDetailsViewModel {
    
    func updatePosterImage(width: Int) {
        guard let posterPath = posterPath, alreadyLoadedImageWidth != width  else { return }
        alreadyLoadedImageWidth = width
        
        imageLoadTask = posterImagesRepository.image(with: posterPath, width: width).sink(receiveCompletion: { (completion) in

        }, receiveValue: { [unowned self] (data) in
            self.posterImage = data
        })
    }
}
