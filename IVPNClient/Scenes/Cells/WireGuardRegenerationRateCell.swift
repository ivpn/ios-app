//
//  WireGuardRegenerationRateCell.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 09/04/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit

class WireGuardRegenerationRateCell: UITableViewCell {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var regenerationLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    // MARK: - @IBActions -
    
    @IBAction func updateRegenerateRate(_ sender: UIStepper) {
        UserDefaults.shared.set(Int(sender.value), forKey: UserDefaults.Key.wgRegenerationRate)
        regenerationLabel.text = regenerationLabelText(days: Int(sender.value))
    }
    
    // MARK: - View Lifecycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        regenerationLabel.text = regenerationLabelText(days: UserDefaults.shared.wgRegenerationRate)
        stepper.value = Double(UserDefaults.shared.wgRegenerationRate)
    }
    
    // MARK: - Methods -
    
    private func regenerationLabelText(days: Int) -> String {
        if days == 1 { return "Regenerate key every \(days) day" }
        return "Regenerate key every \(days) days"
    }
    
}
