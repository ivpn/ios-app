//
//  WireGuardRegenerationRateCell.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-04-09.
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
