//
//  Infinite loader.swift
//  Mlem
//
//  Created by David Bureš on 18.06.2022.
//

import Foundation
import SwiftUI

func loadInfiniteFeed(postTracker: PostTracker, appState: AppState, instanceAddress: URL, community: Community?) async
{
    var loadingCommand: String = ""
    
    if let community
    {
        print("Will be in COMMUNITY scope")
        
        loadingCommand = """
        {"op": "GetPosts", "data": {"type_": "All", "sort": "Hot", "page": \(postTracker.page), "community_id": \(community.id)}}
        """
    }
    else
    {
        print("Will be in GLOBAL scope")
        
        loadingCommand = """
        {"op": "GetPosts", "data": {"type_": "All", "sort":"Hot", "page": \(postTracker.page)}}
        """
    }

    print("Page counter value: \(postTracker.page)")
    
    print("Will try to send command: \(loadingCommand)")
    
    let apiResponse = try! await sendCommand(maintainOpenConnection: false, instanceAddress: instanceAddress, command: loadingCommand)
    
    print("API Response: \(apiResponse)")
    
    let parsedNewPosts: [Post] = try! await parsePosts(postResponse: apiResponse, instanceLink: instanceAddress)
    
    DispatchQueue.main.async {
        for post in parsedNewPosts
        {
            postTracker.posts.append(post)
        }
        
        postTracker.page += 1
    }
}