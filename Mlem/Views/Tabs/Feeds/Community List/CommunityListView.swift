//
//  Community List View.swift
//  Mlem
//
//  Created by Jake Shirey on 17.06.2023.
//

import Dependencies
import SwiftUI

struct CommunitySection: Identifiable {
    let id = UUID()
    let viewId: String
    let sidebarEntry: any SidebarEntry
    let inlineHeaderLabel: String?
    let accessibilityLabel: String
}

struct CommunityListView: View {
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.errorHandler) var errorHandler
    
    @EnvironmentObject var favoritedCommunitiesTracker: FavoriteCommunitiesTracker
    @EnvironmentObject var appState: AppState
    @Environment(\.openURL) var openURL
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed

    @State var subscribedCommunities = [APICommunity]()
    
    @State var searchText: String = ""

    // swiftlint:disable line_length
    private static let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    // swiftlint:enable line_length

    // Note: These are in order that they appear in the sidebar
    @State var communitySections: [CommunitySection] = []

    @Binding var selectedCommunity: CommunityLinkWithContext?

    init(selectedCommunity: Binding<CommunityLinkWithContext?>) {
        self._selectedCommunity = selectedCommunity
    }

    var body: some View {
        
        ScrollViewReader { scrollProxy in
            ZStack(alignment: .trailing) {
                List(selection: $selectedCommunity) {
                    Section("Feeds") {
                        VStack {
                            HomepageFeedRowView(
                                feedType: .subscribed,
                                iconName: AppConstants.subscribedFeedSymbolNameFill,
                                iconColor: .red,
                                description: "Subscribed communities from all servers"
                            )
                            .id("top") // For "scroll to top" sidebar item
                            HomepageFeedRowView(
                                feedType: .local,
                                iconName: AppConstants.localFeedSymbolNameFill,
                                iconColor: .green,
                                description: "Local communities from your server"
                            )
                            HomepageFeedRowView(
                                feedType: .all,
                                iconName: AppConstants.federatedFeedSymbolNameFill,
                                iconColor: .blue,
                                description: "All communities that federate with your server"
                            )
                        }
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                FeedButtonView(
                                    feedType: .subscribed,
                                    title: "Subscribed",
                                    iconName: "newspaper.fill",
                                    iconColor: .red
                                )
                                FeedButtonView(
                                    feedType: .local,
                                    title: "Local",
                                    iconName: "house.fill",
                                    iconColor: .orange
                                )
                            }
                            HStack(spacing: 12) {
                                FeedButtonView(
                                    feedType: .all,
                                    title: "All",
                                    iconName: "circle.hexagongrid.fill",
                                    iconColor: .blue
                                )
                                FeedButtonView(
                                    feedType: .subscribed,
                                    title: "Saved",
                                    iconName: "bookmark.fill",
                                    iconColor: .green
                                )
                            }
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    .listRowBackground(Color.clear)

                    ForEach(calculateVisibleCommunitySections()) { communitySection in
                        Section(header:
                            HStack {
                                Text(communitySection.inlineHeaderLabel!).accessibilityLabel(communitySection.accessibilityLabel)

                                Spacer()
                            }
                            .id(communitySection.viewId)
                        ) {
                            ForEach(
                                calculateCommunityListSections(for: communitySection),
                                id: \.id
                            ) { listedCommunity in
                                CommunityListRowView(
                                    community: listedCommunity,
                                    subscribed: subscribedCommunities.contains(listedCommunity),
                                    communitySubscriptionChanged: hydrateCommunityData
                                )
                            }
                        }
                    }
                }
                .fancyTabScrollCompatible()
                .navigationTitle("Communities")
                .navigationBarColor()
                .listStyle(.insetGrouped)
                .scrollIndicators(.hidden)
                // .padding(.trailing, 10)

                CommunityListSidebarView(proxy: scrollProxy, communitySections: communitySections)
            }
        }
        .background(Color(.systemGroupedBackground))
        .searchable(text: $searchText)
        .refreshable {
            await refreshCommunitiesList()
        }
        .onAppear {
            Task(priority: .high) {
                await refreshCommunitiesList()
            }
            // Set up sections after we body is called
            // so we can use the favorite tracker environment
            communitySections = [
                CommunitySection(
                    viewId: "top",
                    sidebarEntry: EmptySidebarEntry(
                        sidebarLabel: nil,
                        sidebarIcon: "line.3.horizontal"
                    ),
                    inlineHeaderLabel: nil,
                    accessibilityLabel: "Top of communities"
                ),
                CommunitySection(
                    viewId: "favorites",
                    sidebarEntry: FavoritesSidebarEntry(
                        account: appState.currentActiveAccount,
                        favoritesTracker: favoritedCommunitiesTracker,
                        sidebarLabel: nil,
                        sidebarIcon: "star.fill"
                    ),
                    inlineHeaderLabel: "Favorites",
                    accessibilityLabel: "Favorited Communities"
                )
            ] +
                CommunityListView.alphabet.map {
                    // This looks sinister but I didn't know how to string replace in a non-string based regex
                    CommunitySection(
                        viewId: $0,
                        sidebarEntry: RegexCommunityNameSidebarEntry(
                            communityNameRegex: (try? Regex("^[\($0.uppercased())\($0.lowercased())]"))!,
                            sidebarLabel: $0,
                            sidebarIcon: nil
                        ),
                        inlineHeaderLabel: $0,
                        accessibilityLabel: "Communities starting with the letter '\($0)'"
                    )
                } +
                [CommunitySection(
                    viewId: "non_letter_titles",
                    sidebarEntry: RegexCommunityNameSidebarEntry(
                        communityNameRegex: /^[^a-zA-Z]/,
                        sidebarLabel: "#",
                        sidebarIcon: nil
                    ),
                    inlineHeaderLabel: "#",
                    accessibilityLabel: "Communities starting with a symbol or number"
                )]
        }
    }

    private func refreshCommunitiesList() async {
        do {
            subscribedCommunities = try await communityRepository
                .loadSubscriptions()
                .map(\.community)
                .sorted()
        } catch {
            errorHandler.handle(error)
        }
    }

    private func calculateCommunityListSections(for section: CommunitySection) -> [APICommunity] {
        // Filter down to sidebar entry which wants us
        getSubscriptionsAndFavorites()
            .filter { listedCommunity -> Bool in
                section.sidebarEntry.contains(community: listedCommunity, isSubscribed: subscribedCommunities.contains(listedCommunity))
            }
    }

    private func calculateVisibleCommunitySections() -> [CommunitySection] {
        communitySections

            // Only show letter headers for letters we have in our community list
            .filter { communitySection -> Bool in
                getSubscriptionsAndFavorites()
                    .contains(where: { communitySection.sidebarEntry
                            .contains(community: $0, isSubscribed: subscribedCommunities.contains($0))
                    })
            }
            // Only show sections which have labels to show
            .filter { communitySection -> Bool in
                communitySection.inlineHeaderLabel != nil
            }
    }

    private func hydrateCommunityData(community: APICommunity, isSubscribed: Bool) {
        // Add or remove subscribed sub locally
        if isSubscribed {
            subscribedCommunities.append(community)
            subscribedCommunities = subscribedCommunities.sorted()
        } else {
            if let index = subscribedCommunities.firstIndex(where: { $0 == community }) {
                subscribedCommunities.remove(at: index)
            }
        }
    }

    func getSubscriptionsAndFavorites() -> [APICommunity] {
        var result = subscribedCommunities

        // Merge in our favorites list too just incase we aren't subscribed to our favorites
        result.append(contentsOf: favoritedCommunitiesTracker.favoriteCommunities.map(\.community))

        // Remove duplicates and sort by name
        result = Array(Set(result)).sorted()

        return result
    }
}

struct CommunityListViewPreview: PreviewProvider {
    static var appState = AppState(
        defaultAccount: .mock(),
        selectedAccount: .constant(nil)
    )
    
    static var previews: some View {
        Group {
            NavigationStack {
                CommunityListView(
                    selectedCommunity: .constant(nil)
                )
                .environmentObject(
                    FavoriteCommunitiesTracker()
                )
                .environmentObject(appState)
            }
            .previewDisplayName("Populated")
            
            NavigationStack {
                withDependencies {
                    // return no subscriptions...
                    $0.communityRepository.subscriptions = { _ in [] }
                } operation: {
                    CommunityListView(
                        selectedCommunity: .constant(nil)
                    )
                    .environmentObject(
                        FavoriteCommunitiesTracker()
                    )
                    .environmentObject(appState)
                }
            }
            .previewDisplayName("Empty")
            
            NavigationStack {
                withDependencies {
                    // return an error when calling subscriptions
                    $0.communityRepository.subscriptions = { _ in
                        throw APIClientError.response(.init(error: "Borked"), nil)
                    }
                } operation: {
                    CommunityListView(
                        selectedCommunity: .constant(nil)
                    )
                    .environmentObject(
                        FavoriteCommunitiesTracker()
                    )
                    .environmentObject(appState)
                }
            }
            .previewDisplayName("Error")
        }
    }
}
