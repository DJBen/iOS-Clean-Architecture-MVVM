//
//  PosterImagesRepositoryInterface.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation
import Combine

protocol PosterImagesRepository {
    func image(with imagePath: String, width: Int) -> AnyPublisher<Data, Error>
}
