//
//  MoviesListItemCell.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import UIKit
import Combine

final class MoviesListItemCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: MoviesListItemCell.self)
    static let height = CGFloat(130)
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var overviewLabel: UILabel!
    @IBOutlet private var posterImageView: UIImageView!
    
    private var viewModel: MoviesListItemViewModel!

    private var posterImageObserver: AnyCancellable?

    func fill(with viewModel: MoviesListItemViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        dateLabel.text = "\(NSLocalizedString("Release Date", comment: "")): \(viewModel.releaseDate)"
        overviewLabel.text = viewModel.overview
        viewModel.updatePosterImage(width: Int(posterImageView.frame.size.width * UIScreen.main.scale))
        
        bind(to: viewModel)
    }
    
    private func bind(to viewModel: MoviesListItemViewModel) {
        posterImageObserver = viewModel.posterImagePublisher.receive(on: RunLoop.main).sink(receiveCompletion: { (_) in
        }, receiveValue: { [unowned self] (imageData) in
            self.posterImageView.image = imageData.flatMap { UIImage(data: $0) }
        })
    }
}
