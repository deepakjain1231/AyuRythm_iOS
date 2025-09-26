//
//  ARContentLibraryManager.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 07/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation

class ARContentLibraryManager {
    var selectedContents = [ARSelectedContent]()
    static let shared = ARContentLibraryManager()
    
    func addOrRemoveSelectContent(type: ForYouSectionType, id: String, image: String, selected: Bool) {
        if selected {
            let content = ARSelectedContent(type: type, id: id, image: image)
            if !selectedContents.contains(content) {
                selectedContents.append(content)
            }
        } else {
            if let index = selectedContents.firstIndex(where: { $0.type == type && $0.id == id }) {
                _ = selectedContents.remove(safeAt: index)
            }
            printSelectedContents()
        }
        printSelectedContents()
    }
    
    func clearSelectedItems() {
        selectedContents.removeAll()
        printSelectedContents()
    }
    
    func printSelectedContents() {
        print(selectedContents)
    }
}
