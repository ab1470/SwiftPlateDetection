//
//  MainViewController.swift
//  VehicleDetector
//
//  Created by Andrew Balmer on 6/20/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<ImageViewModel, PlateDetectorViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<ImageViewModel, PlateDetectorViewModel>
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var cancellables = [AnyCancellable]()
    private var viewModel: VehicleDetectorViewModelType!
    private let detectVehicles = PassthroughSubject<[URL], Never>()
    private lazy var dataSource = makeDataSource()
    
    private let imageDirectory = "sample_images"
    var imageUrls = [URL]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        
        imageUrls = getImageUrls(inDirectory: imageDirectory)
                
        loadingView.layer.cornerRadius = 24
        hideLoadingView()
        
        let vehicleDetector = VehicleDetectorService()
        let useCase = VehicleDetectorUseCase(vehicleDetectorService: vehicleDetector)
        viewModel = VehicleDetectorViewModel(useCase: useCase)
        bind(to: viewModel)
    }
    
    
    private func bind(to viewModel: VehicleDetectorViewModelType) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        let input = VehicleDetectorViewModelInput(detectVehicles: detectVehicles.eraseToAnyPublisher())
        
        let output = viewModel.transform(input: input)
        
        output.sink(receiveValue: {[unowned self] state in
            self.render(state)
        }).store(in: &cancellables)
    }
    
    
    @IBAction func didTapButton(_ sender: Any) {
        detectVehicles.send(imageUrls)
    }
    
    
    private func render(_ state: VehicleDetectorState) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingView()
        case .noResults:
            hideLoadingView()
            loadingView.isHidden = true
        case .success(let imageModels):
            hideLoadingView()
            update(with: imageModels, animate: true)
        }
    }
    
}


// MARK: - CollectionView
extension MainViewController: UICollectionViewDelegate {

    func makeDataSource() -> DataSource {
        return UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, vehicleViewModel in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PlateDetectionCell.reuseIdentifier,
                    for: indexPath) as? PlateDetectionCell else {
                        assertionFailure("Failed to dequeue \(PlateDetectionCell.self)!")
                        return UICollectionViewCell()
                }
                cell.bind(to: vehicleViewModel)
                cell.layer.cornerRadius = 16
                cell.clipsToBounds = true
                return cell
        })
    }

    
    func update(with imageViewModels: [ImageViewModel], animate: Bool = true) {
        DispatchQueue.main.async {
            var snapshot = Snapshot()
                    
            snapshot.appendSections(imageViewModels)
            imageViewModels.forEach { imageViewModel in
                snapshot.appendItems(imageViewModel.plateDetectorVMs, toSection: imageViewModel)
            }
            self.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }

}


// MARK: - Loading View
extension MainViewController {
    
    private func showLoadingView(animated: Bool? = false) {
        loadingView.isHidden = false
        loadingIndicator.startAnimating()
        
        if animated == true {
            UIView.animate(withDuration: 0.3) {
                self.loadingView.alpha = 1
            }
        } else {
            loadingView.alpha = 1
        }
    }
    
    
    private func hideLoadingView(animated: Bool? = false) {
        loadingIndicator.stopAnimating()
        
        if animated == true {
            UIView.animate(withDuration: 0.3, animations: {
                self.loadingView.alpha = 0
            }) { _ in
                self.loadingView.isHidden = true
            }
        } else {
            loadingView.alpha = 0
            self.loadingView.isHidden = true
        }
    }
    
}
