//
//  PlateDetectionCell.swift
//  VehicleDetector
//
//  Created by Andrew Balmer on 6/20/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import UIKit
import Combine


class PlateDetectionCell: UICollectionViewCell {
    
    public static let reuseIdentifier = "PlateDetectionCell"
    
    @IBOutlet weak var vehiclePlateView: VehiclePlateView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private var cancellable: AnyCancellable?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hideLoadingView()
        cancelLoading()
    }
    
    func bind(to viewModel: PlateDetectorViewModel) {
        cancelLoading()
        let displayProps = DisplayProps(size: self.frame.size, scale: self.traitCollection.displayScale)
        let viewModelOutput = viewModel.detectPlates(outputProps: displayProps)
        cancellable = viewModelOutput.sink { [unowned self] state in self.render(state) }
    }
    
    private func render(_ state: PlateDetectorState) {
        switch state {
        case .loading:
            showLoadingView()
        case .success(let viewModel):
            cancelLoading()
            vehiclePlateView.displayData = viewModel
            self.hideLoadingView(animated: true)
        default:
            break
        }
    }
    
    
    private func showLoadingView() {
        self.loadingView.alpha = 1
        self.loadingView.isHidden = false
        self.loadingIndicator.isHidden = false
        self.loadingIndicator.startAnimating()
    }
    
    
    private func hideLoadingView(animated: Bool? = false) {
        guard loadingView.isHidden == false else { return }
        
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.isHidden = true
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: { [unowned self] in
                        self.loadingView.alpha = 0
        }) { [unowned self] _ in
            self.loadingView.isHidden = true
        }
    }

    
    func cancelLoading() {
        vehiclePlateView.clear()
        cancellable?.cancel()
        cancellable = nil
    }
}
