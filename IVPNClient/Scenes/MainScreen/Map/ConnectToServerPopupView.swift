//
//  ConnectToServerPopupView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-06-24.
//  Copyright (c) 2020 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import SnapKit

class ConnectToServerPopupView: UIView {
    
    // MARK: - View components -
    
    lazy var container: UIView = {
        let container = UIView(frame: .zero)
        container.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
        container.layer.cornerRadius = 8
        container.clipsToBounds = false
        return container
    }()
    
    lazy var arrow: UIView = {
        let arrow = UIView(frame: .zero)
        arrow.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
        arrow.rotate(angle: 45)
        return arrow
    }()
    
    lazy var flagImage = FlagImageView()
    
    lazy var locationLabel: UILabel = {
        let locationLabel = UILabel()
        locationLabel.font = UIFont.systemFont(ofSize: 16)
        locationLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
        locationLabel.isAccessibilityElement = true
        return locationLabel
    }()
    
    lazy var errorLabel: UILabel = {
        let locationLabel = UILabel()
        locationLabel.font = UIFont.systemFont(ofSize: 12)
        locationLabel.textColor = UIColor.init(named: Theme.ivpnLabel5)
        locationLabel.isHidden = true
        locationLabel.numberOfLines = 0
        locationLabel.text = "Please select a different entry or exit server."
        locationLabel.isAccessibilityElement = true
        return locationLabel
    }()
    
    lazy var actionButton: UIButton = {
        let actionButton = UIButton()
        actionButton.setTitle("CONNECT TO SERVER", for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        actionButton.backgroundColor = UIColor.init(named: Theme.ivpnBlue)
        actionButton.layer.cornerRadius = 8
        actionButton.addTarget(self, action: #selector(connectAction), for: .touchUpInside)
        actionButton.isAccessibilityElement = true
        return actionButton
    }()
    
    lazy var prevButton: UIButton = {
        let prevButton = UIButton()
        prevButton.setImage(UIImage.init(named: "icon-arrow-left-gray"), for: .normal)
        prevButton.addTarget(self, action: #selector(prevAction), for: .touchUpInside)
        prevButton.isAccessibilityElement = true
        prevButton.accessibilityLabel = "Previous server"
        return prevButton
    }()
    
    lazy var nextButton: UIButton = {
        let nextButton = UIButton()
        nextButton.setImage(UIImage.init(named: "icon-arrow-right-gray"), for: .normal)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        nextButton.isAccessibilityElement = true
        nextButton.accessibilityLabel = "Next server"
        return nextButton
    }()
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.init(named: Theme.ivpnGray4)
        pageControl.currentPageIndicatorTintColor = UIColor.init(named: Theme.ivpnBlue)
        return pageControl
    }()
    
    // MARK: - Properties -
    
    var vpnServer: VPNServer! {
        didSet {
            let serverViewModel = VPNServerViewModel(server: vpnServer)
            flagImage.image = serverViewModel.imageForCountryCode
            locationLabel.icon(text: serverViewModel.formattedServerNameForMainScreen, imageName: serverViewModel.imageNameForPingTime)
            locationLabel.accessibilityLabel = serverViewModel.server.city
            
            if !Application.shared.connectionManager.status.isDisconnected() && Application.shared.settings.selectedServer == vpnServer {
                actionButton.setTitle("DISCONNECT", for: .normal)
            } else {
                actionButton.setTitle("CONNECT TO SERVER", for: .normal)
            }
            
            if !VPNServer.validMultiHop(Application.shared.settings.selectedServer, vpnServer) {
                actionButton.isHidden = true
                errorLabel.isHidden = false
            } else {
                actionButton.isHidden = false
                errorLabel.isHidden = true
            }
        }
    }
    
    var displayMode: DisplayMode = .hidden {
        didSet {
            switch displayMode {
            case .hidden:
                UIView.animate(withDuration: 0.20, animations: {
                    self.alpha = 0
                }, completion: { _ in
                    self.isHidden = true
                })
            case .content:
                container.isHidden = false
                locationLabel.isHidden = false
                flagImage.isHidden = false
                scrollView.isHidden = true
                pageControl.isHidden = true
                prevButton.isHidden = true
                nextButton.isHidden = true
                isHidden = false
                UIView.animate(withDuration: 0.20, animations: { self.alpha = 1 })
            case .contentSelect:
                container.isHidden = false
                locationLabel.isHidden = true
                flagImage.isHidden = true
                scrollView.isHidden = false
                pageControl.isHidden = false
                prevButton.isHidden = false
                nextButton.isHidden = false
                isHidden = false
                UIView.animate(withDuration: 0.20, animations: { self.alpha = 1 })
            }
        }
    }
    
    var servers: [VPNServer] = []
    var currentPage = 0
    
    // MARK: - View lifecycle -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func updateConstraints() {
        setupConstraints()
        super.updateConstraints()
    }
    
    // MARK: - Methods -
    
    func show() {
        displayMode = servers.count > 1 ? .contentSelect : .content
        setupScrollView()
        updateLayout()
    }
    
    func hide() {
        displayMode = .hidden
    }
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        setupLayout()
    }
    
    private func setupView() {
        backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
        layer.cornerRadius = 8
        layer.masksToBounds = false
        clipsToBounds = false
        isHidden = true
        alpha = 0
        
        container.addSubview(flagImage)
        container.addSubview(locationLabel)
        container.addSubview(errorLabel)
        container.addSubview(actionButton)
        container.addSubview(scrollView)
        container.addSubview(pageControl)
        container.addSubview(prevButton)
        container.addSubview(nextButton)
        addSubview(arrow)
        addSubview(container)
        
        displayMode = .hidden
        initGestures()
    }
    
    private func setupLayout() {
        snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.width.equalTo(270)
            make.height.equalTo(servers.count > 1 ? 125 : 110)
        }
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        arrow.snp.makeConstraints { make in
            make.size.equalTo(14)
            make.centerX.equalToSuperview()
            make.top.equalTo(-7)
        }
        
        flagImage.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.top.equalTo(17)
            make.width.equalTo(20)
            make.height.equalTo(15)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.left.equalTo(45)
            make.top.equalTo(15)
            make.right.equalTo(-18)
            make.height.equalTo(19)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.right.equalTo(-18)
            make.bottom.equalTo(-10)
            make.height.equalTo(60)
        }
        
        actionButton.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.right.equalTo(-18)
            make.height.equalTo(44)
            make.bottom.equalTo(servers.count > 1 ? -33 : -18)
        }
        
        scrollView.snp.makeConstraints { make in
            make.left.equalTo(33)
            make.top.equalTo(8)
            make.right.equalTo(-33)
            make.height.equalTo(30)
        }
        
        prevButton.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(13)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.top.equalTo(13)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        
        pageControl.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.bottom.equalTo(-10)
            make.right.equalTo(-18)
            make.height.equalTo(15)
        }
    }
    
    private func updateLayout() {
        snp.updateConstraints { make in
            make.height.equalTo(servers.count > 1 ? 125 : 110)
        }
        
        actionButton.snp.updateConstraints { make in
            make.bottom.equalTo(servers.count > 1 ? -33 : -18)
        }
    }
    
    private func setupScrollView() {
        let width: CGFloat = 204
        let height: CGFloat = 30
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = servers.count
        scrollView.contentSize = CGSize(width: width * CGFloat(servers.count), height: height)
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        scrollView.delegate = self
        scrollToPage(page: 0, animated: false)
        
        for (index, server) in servers.enumerated() {
            let viewModel = VPNServerViewModel(server: server)
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
            locationLabel.font = UIFont.systemFont(ofSize: 13)
            label.textAlignment = .center
            label.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
            label.icon(text: viewModel.formattedServerNameForMainScreen, imageName: viewModel.imageNameForCountryCode, alignment: .left)
            
            let slide = UIView(frame: CGRect(x: CGFloat(index) * width, y: 0, width: width, height: height))
            slide.addSubview(label)
            
            scrollView.addSubview(slide)
        }
    }
    
    @objc private func connectAction() {
        if !Application.shared.connectionManager.status.isDisconnected() && Application.shared.settings.selectedServer == vpnServer {
            Application.shared.connectionManager.disconnect()
            return
        }
        
        if UserDefaults.shared.isMultiHop {
            Application.shared.settings.selectedExitServer = vpnServer
            Application.shared.settings.selectedExitHost = nil
        } else {
            Application.shared.settings.selectedServer = vpnServer
            Application.shared.settings.selectedHost = nil
        }
        
        Application.shared.connectionManager.needsToUpdateSelectedServer()
        
        if Application.shared.connectionManager.status.isDisconnected() {
            NotificationCenter.default.post(name: Notification.Name.Connect, object: nil)
        } else {
            Application.shared.connectionManager.reconnect()
            NotificationCenter.default.post(name: Notification.Name.ServerSelected, object: nil)
        }
        
        hide()
    }
    
    @objc private func prevAction() {
        scrollToPage(page: currentPage - 1)
    }
    
    @objc private func nextAction() {
        scrollToPage(page: currentPage + 1)
    }
    
    private func scrollToPage(page: Int, animated: Bool = true) {
        guard page >= 0, page <= servers.count else { return }
        
        var frame = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        scrollView.scrollRectToVisible(frame, animated: animated)
        currentPage = page
    }
    
    private func initGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        
    }
    
}

// MARK: - ConnectToServerPopupView extension -

extension ConnectToServerPopupView {
    
    enum DisplayMode {
        case hidden
        case content
        case contentSelect
    }
    
}

// MARK: - UIScrollViewDelegate -

extension ConnectToServerPopupView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard servers.count > 1 else { return }
        
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        pageControl.currentPage = index
        vpnServer = servers[index]
        
        if Application.shared.connectionManager.status.isDisconnected() && VPNServer.validMultiHop(Application.shared.settings.selectedServer, vpnServer) {
            
            if UserDefaults.shared.isMultiHop {
                Application.shared.settings.selectedExitServer = vpnServer
                Application.shared.settings.selectedExitServer.fastest = false
            } else {
                Application.shared.settings.selectedServer = vpnServer
                Application.shared.settings.selectedServer.fastest = false
            }
            
            NotificationCenter.default.post(name: Notification.Name.ServerSelected, object: nil)
        }
    }
    
}
