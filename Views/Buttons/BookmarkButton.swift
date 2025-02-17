//
//  BookmarkButton.swift
//  Kiwix
//
//  Created by Chris Li on 8/13/23.
//  Copyright © 2023 Chris Li. All rights reserved.
//

import SwiftUI

struct BookmarkButton: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var browser: BrowserViewModel
    @State private var isShowingBookmark = false
    
    var body: some View {
        #if os(macOS)
        Button {
            if browser.articleBookmarked {
                browser.deleteBookmark()
            } else {
                browser.createBookmark()
            }
        } label: {
            Label {
                Text(browser.articleBookmarked ? "Remove Bookmark" : "Add Bookmark")
            } icon: {
                Image(systemName: browser.articleBookmarked ? "star.fill" : "star")
                    .renderingMode(browser.articleBookmarked ? .original : .template)
            }
        }
        #elseif os(iOS)
        Menu {
            if browser.articleBookmarked {
                Button(role: .destructive) {
                    browser.deleteBookmark()
                } label: {
                    Label("Remove Bookmark", systemImage: "star.slash.fill")
                }
            } else {
                Button {
                    browser.createBookmark()
                } label: {
                    Label("Add Bookmark", systemImage: "star")
                }
            }
            Button {
                isShowingBookmark = true
            } label: {
                Label("Show Bookmarks", systemImage: "list.star")
            }
        } label: {
            Label {
                Text("Show Bookmarks")
            } icon: {
                Image(systemName: browser.articleBookmarked ? "star.fill" : "star")
                    .renderingMode(browser.articleBookmarked ? .original : .template)
            }
        } primaryAction: {
            isShowingBookmark = true
        }
        .help("Show bookmarks. Long press to bookmark or unbookmark the current article.")
        .popover(isPresented: $isShowingBookmark) {
            NavigationView {
                Bookmarks().navigationBarTitleDisplayMode(.inline).toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            isShowingBookmark = false
                        } label: {
                            Text("Done").fontWeight(.semibold)
                        }
                    }
                }
            }
            .frame(idealWidth: 360, idealHeight: 600)
            .modifier(MarkAsHalfSheet())
        }
        #endif
    }
}
