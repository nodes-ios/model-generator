//
//  DecodableCodeGenerator.swift
//  model-generator
//
//  Created by Dominik Hádl on 19/01/16.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation

struct DecodableCodeGenerator {
    static func decodableCode(withModel model: Model, useNativeDictionaries: Bool) -> String {
        var indent = Indentation(level: 1)

        // Create the function signature
        var code = indent.string() + (model.accessLevel == .Public ? "public " : "")
        code    += (model.type == .Class ? "convenience " : "")
        code    += (useNativeDictionaries ? "init(dictionary: [String: AnyObject]?) {\n" : "init(dictionary: NSDictionary?) {\n")

        // Increase indent level
        indent = indent.nextLevel()

        // If it's a class, don't forget to init
        if model.type == .Class {
            code += indent.string() + "self.init()\n"
        }

        // Caluclate the max property name length
        let maxPropertyLength = model.longestPropertyNameLength()

        // Generate the properties
        for property in model.properties {
            let name = property.name.escaped

            code += indent.string() + name
            code += String.repeated(character: " ", count: maxPropertyLength - name.count)

            if useNativeDictionaries {
                code += " = self.mapped(dictionary, key: \"\(property.key ?? property.name.unescaped)\")"
                code += property.hasDefaultValue ? (" ?? \(property.name)\(property.isOptional ? "!" : "")") : ""
            } else {
                code += " <== (self, dictionary, \"\(property.key ?? property.name.unescaped)\")"
            }

            code += "\n"
        }

        // Decrease indent level
        indent = indent.previousLevel()

        // Close the function
        code += indent.string() + "}"
        code += "\n\n"

        return code
    }
}
