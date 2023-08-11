//
//  Embedded Post.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-23.
//

import SwiftUI

struct EmbeddedPost: View {
    // used to handle the lazy load embedded post--speed doesn't matter because it's not a "real" post tracker
    @StateObject var postTracker: PostTracker = .init(internetSpeed: .slow)
    
    let community: APICommunity
    let post: APIPost
    let comment: APIComment

    @State var loadedPostDetails: APIPostView?

    // TODO:
    // - beautify
    // - enrich info
    // - navigation link to post
    var body: some View {
        NavigationLink(value: LazyLoadPostLinkWithContext(
            post: post,
            postTracker: postTracker,
            scrollTarget: comment.id
        )) {
            postLinkButton()
        }
    }
    
    @ViewBuilder
    private func postLinkButton() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(post.embedTitle ?? post.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.secondary)
                .font(.subheadline)
                .bold()
            HStack(alignment: .center, spacing: 0.0) {
                Text(community.name)
                    .foregroundColor(.secondary)
                    .font(.footnote)
                
                if let serverHost = community.actorId.host() {
                    Text("@\(serverHost)")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .opacity(0.5)
                }
                Spacer()
            }
        }.padding(10)
        .background(RoundedRectangle(cornerRadius: 8)
        .foregroundColor(Color(UIColor.secondarySystemBackground)))
    }
}

struct EmbeddedPostPreview: PreviewProvider {
    static let previewAccount = SavedAccount(
        id: 0,
        instanceLink: URL(string: "lemmy.com")!,
        accessToken: "abcdefg",
        username: "Test Account"
    )
    
    static func generateFakeCommunity(id: Int, namePrefix: String) -> APICommunity {
        APICommunity(
            id: id,
            name: "\(namePrefix) Fake Community \(id)",
            title: "\(namePrefix) Fake Community \(id) Title",
            description: "This is a fake community (#\(id))",
            published: Date.now,
            updated: nil,
            removed: false,
            deleted: false,
            nsfw: false,
            actorId: URL(string: "https://lemmy.google.com/c/\(id)")!,
            local: false,
            icon: nil,
            banner: nil,
            hidden: false,
            postingRestrictedToMods: false,
            instanceId: 0
        )
    }
    
    static var previews: some View {
        EmbeddedPost(
            community: EmbeddedPostPreview.generateFakeCommunity(id: 1, namePrefix: ""),
            post: APIPost(
                id: 1,
                name: "Test Post",
                url: nil,
                body: nil,
                creatorId: 0,
                communityId: 0,
                deleted: false,
                embedDescription: nil,
                embedTitle: nil,
                embedVideoUrl: nil,
                featuredCommunity: false,
                featuredLocal: false,
                languageId: 0,
                apId: "foo.bar",
                local: false,
                locked: false,
                nsfw: false,
                published: Date.now,
                removed: false,
                thumbnailUrl: nil,
                updated: nil
            ),
            comment: APIComment(
                id: 0,
                creatorId: 0,
                postId: 0,
                content: "",
                removed: false,
                deleted: false,
                published: Date.now,
                updated: Date.now,
                apId: "",
                local: false,
                path: "",
                distinguished: false,
                languageId: 0
            )
        )
    }
}
