//
//  ChooseInstanceView.swift
//  Mlem
//
//  Created by Sjmarf on 22/07/2023.
//

import SwiftUI
import CachedAsyncImage

private struct InstanceRowView: View {
    @State var siteView: APISiteView
    
    var body: some View {
        HStack(spacing: 13) {
            CachedAsyncImage(url: siteView.site.icon, urlCache: AppConstants.urlCache) { image in
                image
                    .resizable()
            } placeholder: {
                Color(UIColor.systemGroupedBackground)
            }
            .frame(width: 28, height: 28)
            .clipShape(RoundedRectangle(cornerRadius: 3))
            Text(siteView.site.name)
                .fontWeight(.semibold)
                .padding(.vertical, 15)
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 2, y: 2)
    }
}

struct ChooseInstanceView: View {
    
    @EnvironmentObject var accountsTracker: SavedAccountTracker
    
    // swiftlint:disable line_length
    private let recommendedInstances = ["lemmy.world", "lemmy.ml", "feddit.de", "sh.itjust.works", "Lemmy.one", "lemm.ee", "beehaw.org", "lemmy.blahaj.zone", "lemmy.dbzer0.com", "Lemmy.ca"]
    // swiftlint:enable line_length
    
    @State var mySites = [APISiteView]()
    @State var popularSites = [APISiteView]()
    
    @State var instance = ""

    var body: some View {
        VStack(spacing: 30) {
            Text("Select an instance")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    TextField("Instance URL", text: $instance)
                        .textFieldStyle(LargeTextFieldStyle())
                        .controlSize(.large)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .accessibilityLabel("Instance URL")
                        .padding(.vertical, 10)
                    
                    Divider()
                    
                    if !mySites.isEmpty {
                        Text("My Instances")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 10)
                        
                        ForEach(mySites, id: \.self) { siteView in
                            InstanceRowView(siteView: siteView)
                        }
                        Divider()
                            .padding(.top, 10)
                    }
                    
                    Text("Popular Instances")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 10)

                    ForEach(popularSites, id: \.self) { siteView in
                        InstanceRowView(siteView: siteView)
                    }
                }
                .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(UIColor.systemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onAppear {
                Task {
                    let client = APIClient()
                    
                    var visitedSites = [URL]()
                    
                    for account in accountsTracker.savedAccounts {
                        if visitedSites.contains(account.instanceLink) {
                            continue
                        }
                        // swiftlint:disable force_try
                        let getRequest = try! await GetSiteRequest(instanceURL: account.instanceLink)
                        let response = try! await client.perform(request: getRequest)
                        mySites.append(response.siteView)
                        // swiftlint:enable force_try
                    }
                   
                    for instance in recommendedInstances {
                        // swiftlint:disable force_try
                        let getRequest = try! await GetSiteRequest(instanceURL: getCorrectURLtoEndpoint(baseInstanceAddress: instance))
                        let response = try! await client.perform(request: getRequest)
                        popularSites.append(response.siteView)
                        // swiftlint:enable force_try
                    }
                }
            }
            .animation(.default, value: popularSites)

            VStack {
                NavigationLink {
                    EmptyView()
                } label: {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                
                NavigationLink {
                    EmptyView()
                } label: {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .buttonStyle(.bordered)
            }
        }
        .padding(10)
        .padding(.bottom, 20)
        .modifier(TabSafeScrollView())
    }
}
