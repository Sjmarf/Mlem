//
//  FeedButtonView.swift
//  Mlem
//
//  Created by Sam Marfleet on 25/08/2023.
//

import SwiftUI

struct FeedButtonView: View {
    @State var feedType: FeedType
    
    let title: String
    let iconName: String
    let iconColor: Color
    
    var body: some View {
        // The NavigationLink is done this way to remove the caret
//        Button {
//            navigationRouter.path.append(CommunityLinkWithContext(community: nil, feedType: feedType))
//        } label: {
        NavigationLink(value: CommunityLinkWithContext(community: nil, feedType: feedType)) {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .padding(7)
                    .frame(width: 36, height: 36)
                    .background(iconColor)
                    .clipShape(Circle())
                Text(title)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .padding(.leading, 15)
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .buttonStyle(.plain)
    }
}
