//
//  PokemonResponse.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 12/30/24.
//

import Foundation

struct PokemonResponse: Decodable {
    let results: [Pokemon]
}

struct Pokemon: Decodable {
    let url: URL?
}


