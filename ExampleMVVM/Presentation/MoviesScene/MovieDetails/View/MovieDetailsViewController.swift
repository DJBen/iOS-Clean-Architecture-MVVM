//
//  MovieDetailsViewController.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 04.08.19.
//  Copyright (c) 2019 All rights reserved.
//

import UIKit
import Combine

final class MovieDetailsViewController: UIViewController, StoryboardInstantiable {
    
    private static let fadeTransitionDuration: CFTimeInterval = 0.4
    
    @IBOutlet private var posterImageView: UIImageView!
    @IBOutlet private var overviewTextView: UITextView!
    
    var viewModel: MovieDetailsViewModel!

    private var titleObserver: AnyCancellable?
    private var posterImageObserver: AnyCancellable?
    private var overviewObserver: AnyCancellable?

    static func create(with viewModel: MovieDetailsViewModel) -> MovieDetailsViewController {
        let view = MovieDetailsViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind(to: viewModel)
        view.accessibilityIdentifier = AccessibilityIdentifier.movieDetailsView
    }
    
    private func bind(to viewModel: MovieDetailsViewModel) {
        titleObserver = viewModel.titlePublisher.receive(on: RunLoop.main).sink(receiveCompletion: { (_) in
        }, receiveValue: { [unowned self] (title) in
            self.title = title
        })

        posterImageObserver = viewModel.posterImagePublisher.receive(on: RunLoop.main).sink(receiveCompletion: { (_) in
        }, receiveValue: { [unowned self] (imageData) in
            self.posterImageView.image = imageData.flatMap { UIImage(data: $0) }
        })

        overviewObserver = viewModel.overviewPublisher.receive(on: RunLoop.main).assign(to: \.overviewTextView.text, on: self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.updatePosterImage(width: Int(self.posterImageView.bounds.width))
    }
}
