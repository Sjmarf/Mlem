//
//  PostPreviewView.swift
//  Mlem
//
//  Created by Sam Marfleet on 15/07/2023.
//

import SwiftUI

private struct PostPreviewContentView: View {
    @Binding var postSize: PostSize
    @Binding var shouldShowPostThumbnails: Bool
    
    @AppStorage("thumbnailsOnRight") var shouldShowThumbnailsOnRight: Bool = false
    
    var postTitle: String = "ITAP of some beautiful flowers!"
    var postBody: String = "Saw these while out on a walk. Does anyone know what they're called?"
    
    var thumbnail: some View {
        Image("SampleImage")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
    }
    
    var body: some View {

        Group {
            if postSize == .large {
                VStack(spacing: AppConstants.postAndCommentSpacing) {
                    Text(postTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image("SampleImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius))
                    
                    MarkdownView(text: postBody, isNsfw: false)
                        .font(.subheadline)
                }
                
            } else {
                HStack(spacing: AppConstants.postAndCommentSpacing) {
                    
                    if shouldShowPostThumbnails && !shouldShowThumbnailsOnRight {
                        thumbnail
                    }
                    
                    Text(postTitle)
                        .font(.headline)
                    
                    if shouldShowPostThumbnails && shouldShowThumbnailsOnRight {
                        Spacer()
                        thumbnail
                    }
                }
            }
        }
        .animation(.default, value: shouldShowThumbnailsOnRight)
    }
}

struct PostPreviewView: View {
    
    @AppStorage("postSize") var postSize: PostSize = PostSize.headline
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = false
    @AppStorage("shouldShowCommunityServerInPost") var shouldShowCommunityServerInPost: Bool = false
    @AppStorage("shouldShowPostThumbnails") var shouldShowPostThumbnails: Bool = false
    
    @Namespace var animation
    
    var ellipsis: some View {
        Image(systemName: "ellipsis")
            .frame(width: 24, height: 24)
            .foregroundColor(.primary)
            .background(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(.clear))
    }
    
    var userName: some View {
        Text("John Doe")
            .bold()
            .font(.footnote)
            .foregroundStyle(.gray)
    }
    
    var userInstance: some View {
        Text("@lemm.ee")
            .opacity(0.6)
            .font(.caption)
    }
    
    var communityName: some View {
        Text("Pics")
            .bold()
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
    
    var communityInstance: some View {
        Text("@lemmy.ml")
            .opacity(0.6)
            .font(.caption)
    }
    
    var body: some View {
            VStack {
                VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
                    HStack {
                        HStack {
                            HStack(spacing: AppConstants.largeAvatarSpacing) {
                                Image("SampleThumbnail")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
                                    .clipShape(Circle())
                                    .overlay(Circle()
                                        .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
                                
                                if shouldShowCommunityServerInPost {
                                    VStack(alignment: .leading) {
                                        communityName
                                            .matchedGeometryEffect(id: "CommunityName", in: animation)
                                        communityInstance
                                    }
                                } else {
                                    communityName
                                        .matchedGeometryEffect(id: "CommunityName", in: animation)
                                }
                            }
                        }
                        Spacer()
                        ellipsis
                    }
                    PostPreviewContentView(postSize: $postSize, shouldShowPostThumbnails: $shouldShowPostThumbnails)
                    
                    if shouldShowPostCreator {
                        HStack(alignment: .center, spacing: 5) {
                            Image(systemName: "person.circle")
                                .resizable()
                                .scaledToFill()
                                .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
                                .foregroundStyle(.secondary)
                            
                            if shouldShowUserServerInPost {
                                VStack(alignment: .leading) {
                                    userName
                                        .matchedGeometryEffect(id: "Username", in: animation)
                                    userInstance
                                }
                            } else {
                                userName
                                    .matchedGeometryEffect(id: "Username", in: animation)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            // .animation(.default, value: postSize)
            .animation(.default, value: shouldShowPostCreator)
            .animation(.default, value: shouldShowUserServerInPost)
            .animation(.default, value: shouldShowCommunityServerInPost)
            .animation(.default, value: shouldShowPostThumbnails)
    }
}
