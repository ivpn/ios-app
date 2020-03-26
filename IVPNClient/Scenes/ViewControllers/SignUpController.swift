//
//  SignUpController.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 7/17/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

class SignUpController: UIViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var illustration: UIImageView!
    
    // MARK: - @IBActions -
    
    @IBAction func startFreeTrial(_ sender: Any) {
        view.endEditing(true)
        startSignUpProcess()
    }
    
    @IBAction func showLogin(_ sender: AnyObject) {
        navigationController?.popViewController {
            NotificationCenter.default.post(name: Notification.Name.ShowLogin, object: nil)
        }
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        
        username.delegate = self
        password.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionDismissed), name: Notification.Name.SubscriptionDismissed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActivated), name: Notification.Name.SubscriptionActivated, object: nil)
        
        hideKeyboardOnTap()
        setupView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionDismissed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionActivated, object: nil)
    }
    
    // MARK: - Methods -
    
    private func startSignUpProcess() {
        let email = username.text ?? ""
        let password = self.password.text ?? ""
        
        guard !email.isEmpty && !password.isEmpty else {
            showErrorAlert(title: "Error", message: "Please enter email and password")
            return
        }
        
        let params = [
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "password_confirmation", value: password)
        ]
        let request = ApiRequestDI(method: .post, endpoint: Config.apiValidateAccount, params: params)
        
        ProgressIndicator.shared.showIn(view: view)
        
        ApiService.shared.requestCustomError(request) { [weak self] (result: ResultCustomError<SuccessResult, ErrorResult>) in
            guard let self = self else { return }
            
            ProgressIndicator.shared.hide()
            switch result {
            case .success(let success):
                if success.statusOK {
                    KeyChain.email = email
                    KeyChain.password = password
                    
                    let viewController = NavigationManager.getSubscriptionViewController()
                    viewController.presentationController?.delegate = self
                    self.present(viewController, animated: true, completion: nil)
                    
                    log(info: "Credentials were successfully validated.")
                } else {
                    self.showErrorAlert(title: "Error", message: success.message ?? "Email validation failed")
                    log(error: "Credentials validation failed.")
                }
            case .failure(let error):
                self.showErrorAlert(title: "Error", message: error?.message ?? "Email validation failed")
                log(error: "Credentials validation failed.")
            }
        }
    }
    
    private func setupView() {
        if UIDevice.screenHeightSmallerThan(device: .iPhoneXR) {
            illustration.isHidden = true
        }
    }
    
    @objc private func subscriptionDismissed() {
        navigationController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name.AuthenticationDismissed, object: nil)
        })
    }
    
    @objc private func subscriptionActivated() {
        navigationController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name.ServiceAuthorized, object: nil)
        })
    }
    
}

// MARK: - UITextFieldDelegate -

extension SignUpController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == username {
            username.resignFirstResponder()
            password.becomeFirstResponder()
        } else if textField == password {
            password.resignFirstResponder()
            startFreeTrial(self)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate -

extension SignUpController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        navigationController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name.AuthenticationDismissed, object: nil)
        })
    }
    
}
