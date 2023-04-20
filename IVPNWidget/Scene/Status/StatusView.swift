//
//  StatusView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-04-09.
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

struct StatusView: View {
    
    @StateObject var viewModel: ViewModel
    @Environment(\.widgetFamily) var family
    
    init(viewModel: ViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Image("ivpn-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 44)
                .padding(.bottom, 2)
            switch family {
            case .systemSmall:
                Text(viewModel.statusTitle())
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .padding(.bottom, -5)
                Text(viewModel.statusText())
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Label(viewModel.buttonText(), systemImage: "lock.fill")
                    .frame(maxWidth: .infinity)
                    .labelStyle(.titleOnly)
                    .padding(14)
                    .foregroundColor(.white)
                    .background(viewModel.buttonColor())
                    .cornerRadius(10)
            default:
                HStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.statusTitle())
                            .foregroundColor(.secondary)
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, -5)
                        Text(viewModel.statusText())
                            .font(.system(size: 16, weight: .medium))
                    }
                    Spacer()
                    Link(destination: viewModel.actionLink(), label: {
                        Label(viewModel.buttonText(), systemImage: "lock.fill")
                            .frame(maxWidth: .infinity)
                            .labelStyle(.titleOnly)
                            .padding(10)
                            .foregroundColor(.white)
                            .background(viewModel.buttonColor())
                            .cornerRadius(10)
                            .frame(maxWidth: 120)
                    })
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        .widgetURL(family == .systemSmall ? viewModel.actionLink() : nil)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.UpdateWidget)) { _ in
            viewModel.update()
        }
    }
    
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView()
    }
}
