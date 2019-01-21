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

@available(OSX 10.12, *)
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
        var modification: Modification? = nil
        let fetchHandler: ((CloudResult<Modification>) -> Void) = {
            result in
            
            if let error = result.error {
                Log.error("Fetch modification record error: \(error)")
                
                return
            }
            
            modification = result.records.first
        }
        
        container.fetch(completion: fetchHandler)
        
        
        var saved: Modification
        if let remote = modification {
            Log.debug("Updating existing marker")
            saved = remote
        } else {
            Log.debug("Creating new marker")
            saved = Modification()
        }
        
        saved.markedAt = Date()
        
        let saveHandler: ((CloudResult<Modification>) -> Void) = {
            result in
            
            if let error = result.error {
                Log.error("Marker save error: \(error)")
            } else if let record = result.records.first {
                Log.debug("Marker saved")
                self.mark(lastKnown: record.markedAt!)
            } else {
                Log.debug("Wut?")
            }
        }
        
        container.save(records: [saved], completion: saveHandler)
    }
    
    private func latestKnown() -> Known {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "latest-known.json")) else {
            Log.debug("No data")
            return Known(date: Date.distantPast)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let decoded = try? decoder.decode(Known.self, from: data) else {
            Log.debug("No decode")
            return Known(date: Date.distantPast)
        }
        
        return decoded
    }
    
    private func mark(lastKnown: Date) {
        let known = Known(date: lastKnown)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(known)
            try data.write(to: URL(fileURLWithPath: "latest-known.json"))
        } catch {
            Log.error("Mark known error: \(error)")
        }
    }
}
