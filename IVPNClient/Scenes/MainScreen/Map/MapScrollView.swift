//
//  MapScrollView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 20/02/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import Bamboo

class MapScrollView: UIScrollView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var mapImageView: UIImageView!
    
    // MARK: - Properties -
    
    var viewModel: ProofsViewModel! {
        didSet {
            if oldValue == nil {
                UIView.animate(withDuration: 0.5, animations: { self.alpha = 1 })
            }
            
            if !viewModel.model.isIvpnServer && Application.shared.connectionManager.status.isDisconnected() {
                updateMapPosition(animated: oldValue != nil)
            }
        }
    }
    
    private lazy var iPadConstraints = bb.left(MapConstants.Container.iPadLandscapeLeftAnchor).top(MapConstants.Container.iPadLandscapeTopAnchor).constraints.deactivate()
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        setupConstraints()
        setupView()
        placeServerLocationMarkers()
    }
    
    // MARK: - Methods -
    
    func setupConstraints() {
        if UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isLandscape {
            iPadConstraints.activate()
        } else {
            iPadConstraints.deactivate()
        }
    }
    
    func updateMapPosition(animated: Bool = false) {
        guard let viewModel = viewModel else { return }
        
        updateMapPosition(latitude: viewModel.model.latitude, longitude: viewModel.model.longitude, animated: animated)
    }
    
    func updateMapPosition(latitude: Double, longitude: Double, animated: Bool = false) {
        let halfWidth = Double(UIScreen.main.bounds.width / 2)
        let halfHeight = Double(UIScreen.main.bounds.height / 2)
        let point = getCoordinatesBy(latitude: latitude, longitude: longitude)
        let bottomOffset = Double((MapConstants.Container.getBottomAnchor() / 2) - MapConstants.Container.getTopAnchor())
        let leftOffset = Double((MapConstants.Container.getLeftAnchor()) / 2)
        
        setContentOffset(CGPoint(x: point.0 - halfWidth + leftOffset, y: point.1 - halfHeight + bottomOffset), animated: animated)
    }
    
    // MARK: - Private methods -
    
    private func setupView() {
        isUserInteractionEnabled = false
        backgroundColor = UIColor.init(named: Theme.ivpnGray19)
        mapImageView.backgroundColor = .clear
        mapImageView.tintColor = UIColor.init(named: Theme.ivpnGray20)
    }
    
    private func placeServerLocationMarkers() {
        for server in Application.shared.serverList.servers {
            placeMarker(latitude: server.latitude, longitude: server.longitude, city: server.city)
        }
    }
    
    private func placeMarker(latitude: Double, longitude: Double, city: String) {
        guard city != "Bratislava" else { return }
        guard city != "New Jersey, NJ" else { return }
        
        let point = getCoordinatesBy(latitude: latitude, longitude: longitude)
        
        let label = UILabel(frame: CGRect(x: point.0 - 50, y: point.1 - 21, width: 100, height: 20))
        label.text = city
        label.textColor = UIColor.init(named: Theme.ivpnGray21)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 10, weight: .regular)
        
        let marker = UIView(frame: CGRect(x: 50 - 3, y: 18, width: 6, height: 6))
        marker.layer.cornerRadius = 3
        marker.backgroundColor = UIColor.init(named: Theme.ivpnGray21)
        
        label.addSubview(marker)
        addSubview(label)
    }
    
    private func getCoordinatesBy(latitude: Double, longitude: Double) -> (Double, Double) {
        let bitmapWidth: Double = 3909
        let bitmapHeight: Double = 2942
        
        var y: Double
        var blackMagicCoef: Double
        
        // Using this coefficients to compensate for the curvature of the map
        let xMapCoefficient = 0.026
        let yMapCoefficient = 0.965
        
        // Logic to convert longitude, latitude into x, y
        var x: Double = (longitude + 180.0) * (bitmapWidth / 360.0)
        let latRadius: Double = latitude * Double.pi / 180
        blackMagicCoef = log(tan((Double.pi / 4) + (latRadius / 2)))
        y = (bitmapHeight / 2) - (bitmapWidth * blackMagicCoef / (2 * Double.pi))
        
        // Trying to compensate for the curvature of the map
        x -= bitmapWidth * xMapCoefficient
        if y < bitmapHeight / 2 {
            y *= yMapCoefficient
        }
        
        return (x, y)
    }
    
}
