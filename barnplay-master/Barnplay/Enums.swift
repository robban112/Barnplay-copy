//
//  Enums.swift
//  Barnplay
//
//  A collection of the enums used in struct classes
//
//  Created by Jonas Wedin on 2016-03-05.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import Foundation


// All the languages SVT provides
enum Language: String {
    case Swedish, English, Romani, Finnish, Sami, Meänkieli, SignLanguage, Other
}

var knownLangs: [String: Language] = [
    "swe": .Swedish,
    "eng": .English,
    "fin": .Finnish,
    "rom": .Romani,
    "fiu": .Meänkieli,
    "sma": .Sami,
    "sgn": .SignLanguage
]
