//
//  PokemonSectionModel.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 1/2/25.
//

import Foundation
import Differentiator

struct PokemonSectionModel {
    var items: [URL]
}

extension PokemonSectionModel: SectionModelType {
    init(original: PokemonSectionModel, items: [URL]) {
        self = original
        self.items = items
    }
}
