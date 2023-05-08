//
//  LocationView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-04-12.
//  Copyright (c) 2023 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI
import WidgetKit

struct LocationView: View {
    
    @StateObject var viewModel: ViewModel
    @Environment(\.widgetFamily) var family
    
    init(viewModel: ViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Your current location")
                .foregroundColor(.secondary)
                .font(.footnote)
                .padding(.bottom, -5)
            HStack {
                Image(viewModel.getCountryCode())
                Text(viewModel.getLocation())
                    .font(.system(size: 15, weight: .medium))
            }
        }
        .padding(.horizontal)
        .padding(.top, -8)
        .padding(.bottom, 12)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.UpdateWidget)) { _ in
            viewModel.update()
        }
    }
    
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView()
    }
}
