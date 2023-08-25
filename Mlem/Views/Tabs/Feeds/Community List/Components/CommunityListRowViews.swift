//
//  CommunityListRowViews.swift
//  Mlem
//
//  Created by Jake Shirley on 6/19/23.
//

import Dependencies
import SwiftUI

struct HeaderView: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
        }
    }
}

struct FavoriteStarButtonStyle: ButtonStyle {
    let isFavorited: Bool

    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: isFavorited ? "star.fill" : "star")
            .foregroundColor(.blue)
            .opacity(isFavorited ? 1.0 : 0.2)
            .accessibilityRepresentation { configuration.label }
    }
}

struct CommunityListRowView: View {
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.notifier) var notifier
    
    let community: APICommunity
    let subscribed: Bool
    let communitySubscriptionChanged: (APICommunity, Bool) -> Void
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var favoritesTracker: FavoriteCommunitiesTracker

    var body: some View {
        NavigationLink(value: CommunityLinkWithContext(community: community, feedType: .subscribed)) {
            content
        }.swipeActions {
            if subscribed {
                Button {
                    Task(priority: .userInitiated) {
                        await subscribe(communityId: community.id, shouldSubscribe: false)
                    }
                } label: {
                    Image(systemName: "person.crop.circle.fill.badge.xmark")
                }
                .accessibilityLabel("Unsubscribe")
                .tint(.red) // Destructive role seems to remove from list so just make it red
            } else {
                Button("Subscribe") {
                    Task(priority: .userInitiated) {
                        await subscribe(communityId: community.id, shouldSubscribe: true)
                    }
                }.tint(.blue)
            }
        }
        .accessibilityAction(named: "Toggle favorite") {
            toggleFavorite()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(communityLabel)
    }
    
    private var content: some View {
        HStack(spacing: 15) {
            Group {
                if let url = community.icon {
                    CachedImage(
                        url: url.withIcon64Parameters,
                        shouldExpand: false,
                        fixedSize: CGSize(width: 36, height: 36),
                        imageNotFound: defaultCommunityAvatar,
                        contentMode: .fill
                    )
                } else {
                    defaultCommunityAvatar()
                }
            }
            .clipShape(Circle())
            .overlay(Circle()
                .stroke(
                    Color(UIColor.secondarySystemBackground),
                    lineWidth: shouldClipAvatar(community: community) ? 1 : 0
                ))
            .frame(width: 36, height: 36)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                Text(community.name)
                
                if let instanceName = community.actorId.host(percentEncoded: false) {
                    Text("@\(instanceName)")
                        .font(.footnote)
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
        }
    }
    
    private func defaultCommunityAvatar() -> AnyView {
        AnyView(
            ZStack {
                VStack {
                    Spacer()
                    Image(systemName: "building.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                        .foregroundStyle(.white)
                }
                .scaledToFit()
                .mask(
                    Circle()
                        .frame(width: 30, height: 30)
                )
            }
            .frame(maxWidth: .infinity)
            .background(.tertiary)
        )
    }

    private var communityLabel: String {
        var label = community.name

        if let website = community.actorId.host(percentEncoded: false) {
            label += "@\(website)"
        }

        if isFavorited() {
            label += ", is a favorite"
        }

        return label
    }

    private func toggleFavorite() {
        if isFavorited() {
            favoritesTracker.unfavorite(community)
            UIAccessibility.post(notification: .announcement, argument: "Unfavorited \(community.name)")
            Task {
                await notifier.add(.success("Unfavorited \(community.name)"))
            }
        } else {
            favoritesTracker.favorite(community, for: appState.currentActiveAccount)
            UIAccessibility.post(notification: .announcement, argument: "Favorited \(community.name)")
            Task {
                await notifier.add(.success("Favorited \(community.name)"))
            }
        }
    }

    private func isFavorited() -> Bool {
        favoritesTracker.favoriteCommunities(for: appState.currentActiveAccount).contains(community)
    }

    private func subscribe(communityId: Int, shouldSubscribe: Bool) async {
        // Refresh the list locally immedietly and undo it if we error
        communitySubscriptionChanged(community, shouldSubscribe)

        do {
            try await communityRepository.updateSubscription(for: communityId, subscribed: shouldSubscribe)
            
            if shouldSubscribe {
                await notifier.add(.success("Subscibed to \(community.name)"))
            } else {
                await notifier.add(.success("Unsubscribed from \(community.name)"))
            }
        } catch {
            let phrase = shouldSubscribe ? "subscribe to" : "unsubscribe from"
            errorHandler.handle(
                .init(
                    title: "Unable to \(phrase) community",
                    style: .toast,
                    underlyingError: error
                )
            )
            communitySubscriptionChanged(community, !shouldSubscribe)
        }
    }
}

struct HomepageFeedRowView: View {
    let feedType: FeedType
    let iconName: String
    let iconColor: Color
    let description: String

    var body: some View {
        NavigationLink(value: CommunityLinkWithContext(community: nil, feedType: feedType)) {
            HStack {
                Image(systemName: iconName).resizable()
                    .frame(width: 36, height: 36).foregroundColor(iconColor)
                VStack(alignment: .leading) {
                    Text("\(feedType.label) Communities")
                    Text(description).font(.caption).foregroundColor(.gray)
                }
            }
            .padding(.bottom, 1)
            .accessibilityElement(children: .combine)
        }
    }
}
