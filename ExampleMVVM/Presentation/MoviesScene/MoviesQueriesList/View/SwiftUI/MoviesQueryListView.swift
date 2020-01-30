//
//  MoviesQueryListView.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation
import SwiftUI
import Combine

@available(iOS 13.0, *)
extension DefaultMoviesQueryListItemViewModel: Identifiable { }

@available(iOS 13.0, *)
struct MoviesQueryListView: View {
    @ObservedObject var viewModelWrapper: MoviesQueryListViewModelWrapper
    
    var body: some View {
        List(viewModelWrapper.items) { item in
            Button(action: {
                self.viewModelWrapper.viewModel?.didSelect(item: item)
            }) {
                Text(item.query)
            }
        }
        .onAppear {
            self.viewModelWrapper.viewModel?.viewWillAppear()
        }
    }
}

@available(iOS 13.0, *)
final class MoviesQueryListViewModelWrapper: ObservableObject {
    var viewModel: MoviesQueryListViewModel?
    @Published var items: [DefaultMoviesQueryListItemViewModel] = []

    private var itemsObserver: AnyCancellable?
    
    init(viewModel: MoviesQueryListViewModel?) {
        self.viewModel = viewModel
        itemsObserver = viewModel?.itemsPublisher.sink(receiveValue: { [unowned self] (values) in
            self.items = values as! [DefaultMoviesQueryListItemViewModel]
        })
    }
}

#if DEBUG
@available(iOS 13.0, *)
struct MoviesQueryListView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesQueryListView(viewModelWrapper: previewViewModelWrapper)
    }
    
    static var previewViewModelWrapper: MoviesQueryListViewModelWrapper = {
        var viewModel = MoviesQueryListViewModelWrapper(viewModel: nil)
        viewModel.items = [DefaultMoviesQueryListItemViewModel(query: "item 1"),
                           DefaultMoviesQueryListItemViewModel(query: "item 2")
        ]
        return viewModel
    }()
}
#endif
