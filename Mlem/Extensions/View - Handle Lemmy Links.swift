//
//  View - Handle Lemmy Links.swift
//  Mlem
//
//  Created by tht7 on 23/06/2023.
//

import Dependencies
import Foundation
import SwiftUI

struct HandleLemmyLinksDisplay: ViewModifier {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var filtersTracker: FiltersTracker
    @EnvironmentObject var favoriteCommunitiesTracker: FavoriteCommunitiesTracker
    @EnvironmentObject var savedAccounts: SavedAccountTracker
    
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    
    // swiftlint:disable function_body_length
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: APICommunityView.self) { context in
                FeedView(community: context.community, feedType: .all, sortType: defaultPostSorting)
                    .environmentObject(appState)
                    .environmentObject(filtersTracker)
                    .environmentObject(CommunitySearchResultsTracker())
                    .environmentObject(favoriteCommunitiesTracker)
            }
            .navigationDestination(for: APICommunity.self) { community in
                FeedView(community: community, feedType: .all, sortType: defaultPostSorting)
                    .environmentObject(appState)
                    .environmentObject(filtersTracker)
                    .environmentObject(CommunitySearchResultsTracker())
                    .environmentObject(favoriteCommunitiesTracker)
            }
            .navigationDestination(for: CommunityLinkWithContext.self) { context in
                FeedView(community: context.community, feedType: context.feedType, sortType: defaultPostSorting)
                    .environmentObject(appState)
                    .environmentObject(filtersTracker)
                    .environmentObject(CommunitySearchResultsTracker())
                    .environmentObject(favoriteCommunitiesTracker)
            }
            .navigationDestination(for: CommunitySidebarLinkWithContext.self) { context in
                CommunitySidebarView(
                    community: context.community,
                    communityDetails: context.communityDetails)
                .environmentObject(appState)
                .environmentObject(filtersTracker)
                .environmentObject(CommunitySearchResultsTracker())
                .environmentObject(favoriteCommunitiesTracker)
            }
            .navigationDestination(for: APIPostView.self) { post in
                ExpandedPost(post: post)
                .environmentObject(
                    PostTracker(shouldPerformMergeSorting: false, internetSpeed: internetSpeed, initialItems: [post])
                )
                .environmentObject(appState)
            }
            .navigationDestination(for: APIPost.self) { post in
                LazyLoadExpandedPost(post: post)
                    .environmentObject(appState)
            }
            .navigationDestination(for: PostLinkWithContext.self) { post in
                ExpandedPost(post: post.post, scrollTarget: post.scrollTarget)
                    .environmentObject(post.postTracker)
                    .environmentObject(appState)
            }
            .navigationDestination(for: LazyLoadPostLinkWithContext.self) { post in
                LazyLoadExpandedPost(post: post.post, scrollTarget: post.scrollTarget)
                    .environmentObject(post.postTracker)
                    .environmentObject(appState)
            }
            .navigationDestination(for: APIPerson.self) { user in
                UserView(userID: user.id)
                    .environmentObject(appState)
            }
            .navigationDestination(for: UserModeratorLink.self) { user in
                UserModeratorView(userDetails: user.user, moderatedCommunities: user.moderatedCommunities)
                    .environmentObject(appState)
            }
    }
    // swiftlint:enable function_body_length
}

struct HandleLemmyLinkResolution: ViewModifier {
    
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var savedAccounts: SavedAccountTracker
    let navigationPath: Binding<NavigationPath>

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
    }

    @MainActor
    func didReceiveURL(_ url: URL) -> OpenURLAction.Result {
        let account = appState.currentActiveAccount
        // let's try keep peps in the app!
        if url.absoluteString.contains(["lem", "/c/", "/u/", "/post/", "@"]) {
            // this link is sus! let's go
            // but first let's let the user know what's happning!
            Task {
                await notifier.performWithLoader({
                    var lookup = url.absoluteString
                    lookup = lookup.replacingOccurrences(of: "mlem://", with: "https://")
                    if lookup.contains("@") && !lookup.contains("!") {
                        // SUS I think this might be a community link
                        let processedLookup = lookup
                            .replacing(/.*\/c\//, with: "")
                            .replacingOccurrences(of: "mailto:", with: "")
                        lookup = "!\(processedLookup)"
                    }
                    
                    print("lookup: \(lookup) (original: \(url.absoluteString))")
                    // Wooo this is a lemmy server we're talking to! time to parse this url and push it to the stack
                    do {
                        let resolution = try await APIClient().perform(request: ResolveObjectRequest(account: account, query: lookup))
                        
                        await MainActor.run {
                            // this is gonna be a bit of an ugly if switch but oh well for now
                            if let post = resolution.post {
                                // wop wop that was a post link!
                                return navigationPath.wrappedValue.append(post)
                            } else if let community = resolution.community {
                                return navigationPath.wrappedValue.append(community)
                            } else if let user = resolution.person?.person {
                                return navigationPath.wrappedValue.append(user)
                            }
                            // else if let d = resolution.comment {
                            // hmm I don't think we can do that right now!
                            // so I'll skip and let the system open it instead
                            // }
                        }
                        
                        // as the link was handled we return, else it would also be passed to the default URL handling below
                        return
                    } catch {
                        guard case let APIClientError.response(apiError, _) = error,
                              apiError.error == "couldnt_find_object",
                              url.scheme == "https" else {
                            await errorHandler.handle(
                                .init(underlyingError: error)
                            )
                            
                            return
                        }
                    }
                    
                    // if all else fails fallback!
                    let outcome = URLHandler.handle(url)
                    if outcome.action != nil {
                        if url.scheme == "mlem" {
                            // if we got here then someone intentionally wanted to open this in mlem but now we need to tell him we have no idea how to open it
                            await notifier.add(.failure("Couldn't resolve link"))
                        } else {
                            // if we failed to open it let the system try!
                            OpenURLAction(handler: { _ in .systemAction }).callAsFunction(url)
                        }
                    }
                })
            }

            // since this is a sus link we need to ask the lemmy servers about it, so for now we ask the system to forget-'bout-itt
            return .discarded
        }
        
        let outcome = URLHandler.handle(url)
        return outcome.result
    }
}

extension View {
    func handleLemmyViews() -> some View {
        modifier(HandleLemmyLinksDisplay())
    }

    func handleLemmyLinkResolution(navigationPath: Binding<NavigationPath>) -> some View {
        modifier(HandleLemmyLinkResolution(navigationPath: navigationPath))
    }
}
