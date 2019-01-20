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

import TalkToCloud
import SWLogger

class CloudLogger: TalkToCloud.Logger {
    func error<T>(_ object: T, file: String, function: String, line: Int) {
        Log.error(object, file: file, function: function, line: line)
    }
    
    func verbose<T>(_ object: T, file: String, function: String, line: Int) {
        Log.verbose(object, file: file, function: function, line: line)
    }
    
    func log<T>(_ object: T, file: String, function: String, line: Int) {
        Log.debug(object, file: file, function: function, line: line)
    }
}

Log.add(output: ConsoleOutput())
Log.logLevel = .debug

TalkToCloud.Logging.set(logger: CloudLogger())

let commander = Commander<Check>(containerId: "com.coodly.gambrinus", arguments: CommandLine.arguments)
commander.run()

