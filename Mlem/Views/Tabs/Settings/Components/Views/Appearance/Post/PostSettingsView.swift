//
//  CustomizePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-08.
//

import Foundation
import SwiftUI

struct PostSettingsView: View {
    @EnvironmentObject var appState: AppState
    
    @AppStorage("postSize") var postSize: PostSize = PostSize.headline
    @AppStorage("voteComplexOnRight") var shouldShowVoteComplexOnRight: Bool = false
    
    // Thumbnails
    @AppStorage("shouldShowPostThumbnails") var shouldShowPostThumbnails: Bool = true
    @AppStorage("thumbnailsOnRight") var shouldShowThumbnailsOnRight: Bool = false
    
    // Community
    @AppStorage("shouldShowCommunityServerInPost") var shouldShowCommunityServerInPost: Bool = true
    
    // Author
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = true
    
    // Complications
    @AppStorage("postVoteComplexStyle") var postVoteComplexStyle: VoteComplexStyle = .standard
    @AppStorage("shouldShowScoreInPostBar") var shouldShowScoreInPostBar: Bool = false
    @AppStorage("shouldShowTimeInPostBar") var shouldShowTimeInPostBar: Bool = true
    @AppStorage("shouldShowSavedInPostBar") var shouldShowSavedInPostBar: Bool = false
    @AppStorage("shouldShowRepliesInPostBar") var shouldShowRepliesInPostBar: Bool = true
    
    // website previews
    @AppStorage("shouldShowWebsitePreviews") var shouldShowWebsitePreviews: Bool = true
    @AppStorage("shouldShowWebsiteFaviconAtAll") var shouldShowWebsiteFaviconAtAll: Bool = true
    @AppStorage("shouldShowWebsiteHost") var shouldShowWebsiteHost: Bool = true
    @AppStorage("shouldShowWebsiteIcon") var shouldShowWebsiteIcon: Bool = true
    
    // These exist because certain animations are broken in ios 16 when using AppStorage.
    // https://stackoverflow.com/a/73715427/17629371
    @State var shouldShowPostThumbnailsState: Bool = false
    @State var shouldShowPostCreatorState: Bool = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    PostDisplayModeView(postSize: .large, imageName: "LargePost", selected: $postSize)
                    PostDisplayModeView(postSize: .headline, imageName: "HeadlinePost", selected: $postSize)
                    PostDisplayModeView(postSize: .compact, imageName: "CompactPost", selected: $postSize)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .padding(10)

            } header: {
                Text("Display As")
            } footer: {
                Text("You can change this setting quickly from the top-right of the Feeds tab.")
            }
            
            Section("Post Preview") {
                VStack {
                    DragAndDropTest()
//                    PostPreviewView()
//                        .padding(10)
//                        .shadow(radius: 10, x: 5, y: 5)
                }
                // .frame(height: postSize == .large ? 440 : 204)
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color(uiColor: .systemGray4))
            }
            .listRowBackground(Color(.systemGroupedBackground))
            .listRowInsets(EdgeInsets())
            .accessibilityHidden(true)
            
            if postSize != .large {
                Section {
                    Toggle("Show Thumbnails", isOn: $shouldShowPostThumbnailsState.animation())
                    if shouldShowPostThumbnailsState {
                        HStack {
                            Text("Side")
                            Spacer(minLength: 150)
                            Picker("Thumbnail Side", selection: $shouldShowThumbnailsOnRight) {
                                Text("Left")
                                    .tag(false)
                                Text("Right")
                                    .tag(true)
                            }
                            .pickerStyle(.segmented)
                        }
                        // Toggle("Show Thumbnails on Right", isOn: $shouldShowThumbnailsOnRight)
                    }
                }
                .onAppear {
                    shouldShowPostThumbnailsState = shouldShowPostThumbnails
                }
                .onChange(of: shouldShowPostThumbnailsState) { newValue in
                    shouldShowPostThumbnails = newValue
                }
            }
            
            Section {
                Toggle("Show Community Instance", isOn: $shouldShowCommunityServerInPost)
            }
            
            Section {
                Toggle("Show Author", isOn: $shouldShowPostCreatorState.animation())
                    if shouldShowPostCreatorState {
                        Toggle("Show Author Instance", isOn: $shouldShowUserServerInPost)
                }
            }
            .onAppear {
                shouldShowPostCreatorState = shouldShowPostCreator
            }
            .onChange(of: shouldShowPostCreatorState) { newValue in
                shouldShowPostCreator = newValue
            }
            
            Section {
                SettingsPickerButton(isOn: $shouldShowScoreInPostBar) {
                    Label("Upvotes", systemImage: AppConstants.emptyUpvoteSymbolName)
                }
                SettingsPickerButton(isOn: $shouldShowTimeInPostBar) {
                    Label("Time Posted", systemImage: "clock")
                }
                SettingsPickerButton(isOn: $shouldShowSavedInPostBar) {
                    Label("Save Status", systemImage: "bookmark")
                }
                SettingsPickerButton(isOn: $shouldShowRepliesInPostBar) {
                    Label("Replies", systemImage: "bubble.right")
                }
            } header: {
                Text("Complications")
            } footer: {
                Text("Display additional information at the bottom of a post.")
            }
            
//                Section("Interactions and Info") {
//                    SelectableSettingsItem(
//                        settingIconSystemName: "arrow.up.arrow.down.square",
//                        settingName: "Vote complex style",
//                        currentValue: $postVoteComplexStyle,
//                        options: VoteComplexStyle.allCases
//                    )

//                }
//
//                Section("Website Previews") {
//                    WebsiteIconComplex(post:
//                                        APIPost(
//                                            id: 0,
//                                            name: "",
//                                            url: URL(string: "https://lemmy.ml/post/1011734")!,
//                                            body: "",
//                                            creatorId: 0,
//                                            communityId: 0,
//                                            deleted: false,
//                                            embedDescription: nil,
//                                            embedTitle: "I am an example of a website preview.\nCustomize me!",
//                                            embedVideoUrl: nil,
//                                            featuredCommunity: false,
//                                            featuredLocal: false,
//                                            languageId: 0,
//                                            apId: "https://lemmy.ml/post/1011068",
//                                            local: true,
//                                            locked: false,
//                                            nsfw: false,
//                                            published: .now,
//                                            removed: false,
//                                            thumbnailUrl: URL(string: "https://lemmy.ml/pictrs/image/1b759945-6651-497c-bee0-9bdb68f4a829.png"),
//                                            updated: nil
//                                        )
//                    )
//
//                    .padding(.horizontal)
//
//                    SwitchableSettingsItem(
//                        settingPictureSystemName: "network",
//                        settingPictureColor: .pink,
//                        settingName: "Show website address",
//                        isTicked: $shouldShowWebsiteHost
//                    )
//                    SwitchableSettingsItem(
//                        settingPictureSystemName: "globe",
//                        settingPictureColor: .pink,
//                        settingName: "Show website icon",
//                        isTicked: $shouldShowWebsiteIcon
//                    )
//                    .disabled(!shouldShowWebsiteHost)
//                    SwitchableSettingsItem(
//                        settingPictureSystemName: "photo.circle.fill",
//                        settingPictureColor: .pink,
//                        settingName: "Show website preview",
//                        isTicked: $shouldShowWebsitePreviews
//                    )
//                }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Posts")
        .navigationBarTitleDisplayMode(.inline)
    }
}
