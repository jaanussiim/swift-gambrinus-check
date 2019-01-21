/*
 * Copyright 2019 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import TalkToCloud
import BloggerAPI
import SWLogger

private struct Known: Codable {
    let date: Date
}

internal class Check: Command, ContainerConsumer {
    var container: CloudContainer!
    
    private lazy var blogger = Blogger(blogURL: "http://tartugambrinus.blogspot.com", key: BloggerAPIKey, fetch: BloggerFetch())

    required init() {}
    
    func execute(with arguments: [String]) {
        if arguments.contains("--force") {
            Log.debug("Force update marker")
            pushUpdateMarker()
        } else {
            Log.debug("Fetch posts")
            blogger.fetchUpdates(after: Date.distantPast, completion: handlePosts(result:))
        }
    }
    
    private func handlePosts(result: PostsListResult) {
        if let error = result.error {
            Log.error("Fetch posts error: \(error)")
        } else if let post = result.posts?.last {
            Log.debug("Latest post: \(post)")
            checkHaveUpdates(post)
        } else {
            Log.debug("Wut?")
        }
    }
    
    private func checkHaveUpdates(_ post: Post) {
        let known = latestKnown()
        guard post.published > known.date else {
            Log.debug("No updates")
            return
        }
        
        Log.debug("Have new post")
        pushUpdateMarker()
    }
    
    private func pushUpdateMarker() {
        Log.debug("Push update marker")
    }
    
    private func latestKnown() -> Known {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "latest-known.json")) else {
            Log.debug("No data")
            return Known(date: Date.distantPast)
        }
        
        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode(Known.self, from: data) else {
            Log.debug("No decode")
            return Known(date: Date.distantPast)
        }
        
        return decoded
    }
}
