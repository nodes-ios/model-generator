/*
 * StringExtensions.swift
 * Copyright (c) 2014 Ben Gollmer.
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

/* Required for localeconv(3) */
import Darwin

internal extension String {
  /* Retrieves locale-specified decimal separator from the environment
   * using localeconv(3).
   */
  private func _localDecimalPoint() -> Character {
    guard let decimalPoint = localeconv()?.pointee.decimal_point,
        let scalar = UnicodeScalar(UInt32(decimalPoint.pointee)) else {
        return "."
    }

    return Character(scalar)
  }
  
  /**
   * Attempts to parse the string value into a Double.
   *
   * - returns: A Double if the string can be parsed, nil otherwise.
   */
  func toDouble() -> Double? {
    var characteristic: String = "0"
    var mantissa: String = "0"
    var inMantissa: Bool = false
    var isNegative: Bool = false
    let decimalPoint = self._localDecimalPoint()
    
    for (i, c) in self.characters.enumerated() {
      if i == 0 && c == "-" {
        isNegative = true
        continue
      }
      
      if c == decimalPoint {
        inMantissa = true
        continue
      }
      
      if Int(String(c)) != nil {
        if !inMantissa {
          characteristic.append(c)
        } else {
          mantissa.append(c)
        }
      } else {
        /* Non-numeric character found, bail */
        return nil
      }
    }
    
    return (Double(Int(characteristic)!) +
      Double(Int(mantissa)!) / pow(Double(10), Double(mantissa.count - 1))) *
      (isNegative ? -1 : 1)
  }
  
  /**
   * Splits a string into an array of string components.
   *
   * - parameter splitBy:  The character to split on.
   * - parameter maxSplit: The maximum number of splits to perform. If 0, all possible splits are made.
   *
   * - returns: An array of string components.
   */
  func splitByCharacter(splitBy: Character, maxSplits: Int = 0) -> [String] {
    let components = self.components(separatedBy: String(splitBy))
    guard maxSplits > 0, components.count > maxSplits else {
        return components
    }

    let last = components.dropFirst(maxSplits).joined(separator: String(splitBy))
    return components.dropLast(components.count - maxSplits) + [last]
  }
  
  /**
   * Wraps a string to the specified width.
   * 
   * This just does simple greedy word-packing, it doesn't go full Knuth-Plass.
   * If a single word is longer than the line width, it will be placed (unsplit)
   * on a line by itself.
   *
   * - parameter width:   The maximum length of a line.
   * - parameter wrapBy:  The line break character to use.
   * - parameter splitBy: The character to use when splitting the string into words.
   *
   * - returns: A new string, wrapped at the given width.
   */
  func wrappedAtWidth(width: Int, wrapBy: Character = "\n", splitBy: Character = " ") -> String {
    var s = ""
    var currentLineWidth = 0
    
    for word in self.splitByCharacter(splitBy: splitBy) {
      let wordLength = word.count
      
      if currentLineWidth + wordLength + 1 > width {
        /* Word length is greater than line length, can't wrap */
        if wordLength >= width {
          s += word
        }
        
        s.append(wrapBy)
        currentLineWidth = 0
      }
      
      currentLineWidth += wordLength + 1
      s += word
      s.append(splitBy)
    }
    
    return s
  }
}
