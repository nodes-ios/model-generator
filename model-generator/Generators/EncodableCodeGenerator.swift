//
//  EncodableCodeGenerator.swift
//  model-generator
//
//  Created by Dominik Hádl on 19/01/16.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation

struct EncodableCodeGenerator {
    static func encodableCodeWithModel(model: Model) -> String {
        var indent = Indentation(level: 1)

        var code = indent.string() + (model.accessLevel == .Public ? "public " : "")
        code    += "func encodableRepresentation() -> NSCoding {\n"

        indent = indent.nextLevel()

        code += indent.string() + "let dict = NSMutableDictionary()\n"

        let maxPropertyLength = model.longestPropertyKeyLength()

        for property in model.properties {
            let keyCharactersCount = property.key?.characters.count ?? property.name.characters.count

            code += indent.string() + "dict[\"\(property.key ?? property.name)\"]"
            code += maxPropertyLength > keyCharactersCount ? String.repeated(" ", count: maxPropertyLength - keyCharactersCount) : ""
            code += " = \(property.name)\(property.isOptional ? "?" : "")"
            code += property.isPrimitiveType ? "" : ".encodableRepresentation()"
            code += "\n"
        }

        code += indent.string() + "return dict\n"

        indent = indent.previousLevel()

        code += indent.string() + "}"

        return code
    }
}
