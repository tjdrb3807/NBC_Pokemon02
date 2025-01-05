//
//  PokemonDetail.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 1/3/25.
//

import Foundation

struct PokemonDetail {
    let id: Int
    let imageURL: URL
    var name: String?
    var type: String?
    var height: Int?
    var weight: Int?
}

struct PokemonDetailResponse: Decodable {
    let name: String?
    let types: [PokemonTypeSlot]?
    let height: Int?
    let weight: Int?
}

//    var mainType: String? { types?.first?.type.name }


struct PokemonTypeSlot: Decodable {
    let type: PokemonType
}

struct PokemonType: Decodable {
    let name: String
}

