//
//  AboutMlemSettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 08/07/2023.
//

import SwiftUI

struct SettingsNavigationLink<Destination: View>: View {
    
    var text: String
    var image: Image
    var color: Color
    var destination: Destination
    
    init(text: String, image: Image, color: Color, @ViewBuilder _ destination: () -> Destination) {
        self.text = text
        self.image = image
        self.color = color
        self.destination = destination()
    }
    
    var body: some View {
        NavigationLink {destination} label: {
            HStack(spacing: 16) {
                image
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
    
                Text(text)
            }
        }
    }
}

struct AboutMlemSettingsView: View {
    
    var body: some View {
        VStack(spacing: 10) {
            
            Form {
                Section {
                    VStack {
                    Image("MlemLogo")
                        // getImage()!
                            .resizable()
                            .frame(width: 100, height: 100)
                            .cornerRadius(20.0)
                        Text("Version \(getVersionString())")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color(.systemGroupedBackground))
                Section {
                    SettingsNavigationLink(
                        text: "What's New?",
                        image: Image(systemName: "sparkle"),
                        color: .purple
                    ) {EmptyView()}
                }
                Section {
                    SettingsNavigationLink(
                        text: "Official Community",
                        image: Image(systemName: "house.fill"),
                        color: .green
                    ) {EmptyView()}
                    
                    SettingsNavigationLink(
                        text: "Matrix Room",
                        image: Image(systemName: "person.2.fill"),
                        color: .blue
                    ) {EmptyView()}
                    
                    SettingsNavigationLink(
                        text: "Github Repository",
                        image: Image("github"),
                        color: .black
                    ) {EmptyView()}
                }
                
                Section {
                    SettingsNavigationLink(
                        text: "Report a Bug",
                        image: Image(systemName: "megaphone.fill"),
                        color: .red
                    ) {EmptyView()}
                    
                    SettingsNavigationLink(
                        text: "Suggest a Feature",
                        image: Image(systemName: "lightbulb.fill"),
                        color: .teal
                    ) {EmptyView()}
                }
                
                Section {
                    SettingsNavigationLink(
                        text: "Special Thanks",
                        image: Image(systemName: "face.smiling.inverse"),
                        color: .green
                    ) {EmptyView()}
                    SettingsNavigationLink(
                        text: "Privacy Policy",
                        image: Image(systemName: "hand.raised.fill"),
                        color: .blue
                    ) {EmptyView()}
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("About Mlem")
    }
    
    func getVersionString() -> String {
        var result = "n/a"

        if let releaseVersion = Bundle.main.releaseVersionNumber {
            result = releaseVersion
        }

        if let buildVersion = Bundle.main.buildVersionNumber {
            result.append(" (\(buildVersion))")
        }

        return result
    }
    
    func getImage() -> Image? {
        return Bundle.main.iconFileName
            .flatMap { UIImage(named: $0) }
            .map { Image(uiImage: $0) }
    }
}

struct AboutMlemSettingsViewPreview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AboutMlemSettingsView()
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
