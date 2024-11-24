//
//  Constants.swift
//  LoopTodo
//
//  Created by Steve Parker on 11/22/24.
//

import Foundation
import SwiftUI

class Constants: ObservableObject {
    @AppStorage("textCasing") var textCasing: TextCasing = .allWords
    @AppStorage("showSuggestions") var showSuggestions: Bool = true
    var popupBackgroundColor: Color = .white.opacity(0.25)
}

enum TextCasing: String, CaseIterable, Identifiable {
    case firstWord = "First word capitalized"
    case allWords = "Each Word Capitalized"

    var id: String { rawValue }
}
