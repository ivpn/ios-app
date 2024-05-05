//
//  ConnectionInfoView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-04-17.
//  Copyright (c) 2023 IVPN Limited.
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

struct ConnectionInfoView: View {
    
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("IP Address")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                Spacer()
                Text("Internet Provider")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                Spacer()
                Text(viewModel.getProtocolPortTitle())
                    .foregroundColor(.secondary)
                    .font(.footnote)
                Spacer()
                Text("AntiTracker")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            VStack(alignment: .trailing) {
                Text(viewModel.getIpAddress())
                    .font(.footnote)
                    .minimumScaleFactor(0.9)
                Spacer()
                Text(viewModel.getProvider())
                    .font(.footnote)
                    .minimumScaleFactor(0.9)
                Spacer()
                Text(viewModel.getProtocol())
                    .font(.footnote)
                    .minimumScaleFactor(0.9)
                Spacer()
                Text(viewModel.getAntiTracker())
                    .font(.footnote)
                    .minimumScaleFactor(0.9)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.bottom, 10)
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.UpdateWidget)) { _ in
            viewModel.update()
        }
    }
    
}

struct ConnectionInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionInfoView()
    }
}
