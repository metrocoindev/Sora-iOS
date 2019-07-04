/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: Apache-2.0
*/

import UIKit

enum ProjectOneOfViewModel {
    case open(viewModel: OpenProjectViewModel)
    case finished(viewModel: FinishedProjectViewModel)

    var identifier: String {
        switch self {
        case .open(let viewModel):
            return viewModel.identifier
        case .finished(let viewModel):
            return viewModel.identifier
        }
    }

    var isFavorite: Bool {
        set {
            switch self {
            case .open(let viewModel):
                viewModel.content.isFavorite = newValue
            case .finished(let viewModel):
                viewModel.content.isFavorite = newValue
            }
        }

        get {
            switch self {
            case .open(let viewModel):
                return viewModel.content.isFavorite
            case .finished(let viewModel):
                return viewModel.content.isFavorite
            }
        }
    }

    var itemSize: CGSize {
        switch self {
        case .open(let viewModel):
            return viewModel.layout.itemSize
        case .finished(let viewModel):
            return viewModel.layout.itemSize
        }
    }

    var imageViewModel: ProjectImageViewModelProtocol? {
        switch self {
        case .open(let viewModel):
            return viewModel.imageViewModel
        case .finished(let viewModel):
            return viewModel.imageViewModel
        }
    }
}

protocol ProjectViewModelDelegate: OpenProjectViewModelDelegate & FinishedProjectViewModelDelegate {}

protocol ProjectViewModelFactoryProtocol {
    func create(from project: ProjectData,
                layoutMetadata: ProjectLayoutMetadata,
                delegate: ProjectViewModelDelegate?) -> ProjectOneOfViewModel

    func create(from projectDetails: ProjectDetailsData,
                delegate: ProjectDetailsViewModelDelegate?) -> ProjectDetailsViewModel
}

final class ProjectViewModelFactory: ProjectViewModelFactoryProtocol {
    private(set) var openProjectViewModelFactory: OpenProjectViewModelFactoryProtocol
    private(set) var finishedProjectViewModelFactory: FinishedProjectViewModelFactoryProtocol

    init(openProjectViewModelFactory: OpenProjectViewModelFactoryProtocol,
         finishedProjectViewModelFactory: FinishedProjectViewModelFactoryProtocol) {
        self.openProjectViewModelFactory = openProjectViewModelFactory
        self.finishedProjectViewModelFactory = finishedProjectViewModelFactory
    }

    func create(from project: ProjectData,
                layoutMetadata: ProjectLayoutMetadata,
                delegate: ProjectViewModelDelegate?) -> ProjectOneOfViewModel {
        switch project.status {
        case .open:
            let viewModel = openProjectViewModelFactory
                .create(from: project,
                        layoutMetadata: layoutMetadata.openProjectLayoutMetadata,
                        delegate: delegate)
            return .open(viewModel: viewModel)
        case .closed, .failed:
            let viewModel = finishedProjectViewModelFactory
                .create(from: project,
                        layoutMetadata: layoutMetadata.finishedProjectLayoutMetadata,
                        delegate: delegate)
            return .finished(viewModel: viewModel)
        }
    }

    func create(from projectDetails: ProjectDetailsData,
                delegate: ProjectDetailsViewModelDelegate?) -> ProjectDetailsViewModel {
        switch projectDetails.status {
        case .open:
            return openProjectViewModelFactory.create(from: projectDetails,
                                                      delegate: delegate)
        case .closed, .failed:
            return finishedProjectViewModelFactory.create(from: projectDetails,
                                                          delegate: delegate)
        }
    }
}

extension ProjectViewModelFactory {
    static func createDefault() -> ProjectViewModelFactoryProtocol {
        let votesFormatter = NumberFormatter.vote
        let integerFormatter = NumberFormatter.anyInteger
        let dateFormatter = DateFormatter.finishedProject

        let open = OpenProjectViewModelFactory(votesFormatter: votesFormatter,
                                               integerFormatter: integerFormatter)
        let finished = FinishedProjectViewModelFactory(votesFormatter: votesFormatter,
                                                       integerFormatter: integerFormatter,
                                                       dateFormatter: dateFormatter)

        return ProjectViewModelFactory(openProjectViewModelFactory: open,
                                       finishedProjectViewModelFactory: finished)
    }
}