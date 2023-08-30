//
//  WebsiteSummaryView.swift
//  Mlem
//
//  Created by Sjmarf on 30/08/2023.
//

import SwiftUI
import SwiftSoup

class WebsiteSummaryModel: ObservableObject {
    @Published var hasLoaded = false
    
    @Published var title: String = ""
    @Published var summaryText: String = ""
    
    var doc: SwiftSoup.Document?
    
    func load(_ url: URL) async {
        let headerTitle: String
        var doc: SwiftSoup.Document?
        do {
            let html = try String(contentsOf: url, encoding: .utf8)
            doc = try SwiftSoup.parseBodyFragment(html)
            headerTitle = try doc!.title()
        } catch {
            headerTitle = "Error"
            print("ERROR", error)
        }
        
        // This is to avoid an error in Swift 6
        let doc_ = doc
        DispatchQueue.main.async {
            self.doc = doc_
            self.title = headerTitle
            self.hasLoaded = true
        }
        if let doc = doc_ {
            await generateSummary(doc)
        }
    }
    
    func generateSummary(_ doc: SwiftSoup.Document) async {
        do {
            let text = try doc.body()!.text()
            print(text)
            let summaryText = TextSummary().getSummary(text)
            DispatchQueue.main.async {
                self.summaryText = summaryText
            }
        } catch {
            DispatchQueue.main.async {
                self.summaryText = "Error2"
                print("ERROR2", error)
            }
        }
    }
}

struct WebsiteSummaryView: View {
    let url: URL
    
    @StateObject var model = WebsiteSummaryModel()
    
    var body: some View {
        ScrollView {
            VStack {
                if model.hasLoaded {
                    Text(model.title)
                    Divider()
                    Text(model.summaryText)
                } else {
                    ProgressView()
                }
            }
            .padding(10)
        }
        .onAppear {
            Task(priority: .userInitiated) {
                await model.load(url)
            }
        }
    }
}
