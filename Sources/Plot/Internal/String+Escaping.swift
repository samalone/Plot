/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal extension String {
    /// Strips characters that are not valid in XML/HTML element or attribute
    /// names, preventing malformed markup when a name contains unexpected
    /// characters. Per the XML specification, names may start with a letter,
    /// underscore, colon, or exclamation mark (for declarations like
    /// `!DOCTYPE`), and may continue with those characters plus digits,
    /// hyphens, and periods.
    func sanitizedForName() -> String {
        var result = ""

        for character in self {
            if character.isLetter || character == "_" || character == ":" || character == "!" {
                result.append(character)
            } else if !result.isEmpty && (character.isNumber || character == "-" || character == ".") {
                result.append(character)
            }
        }

        return result
    }

    func escaped() -> String {
        var pendingAmpersandString: String?

        func flushPendingAmpersandString(
            withSuffix suffix: String? = nil,
            resettingTo newValue: String? = nil
        ) -> String {
            let pending = pendingAmpersandString
            pendingAmpersandString = newValue
            return pending.map { "&amp;\($0)\(suffix ?? "")" } ?? suffix ?? ""
        }

        return String(flatMap { character -> String in
            switch character {
            case "<":
                return flushPendingAmpersandString(withSuffix: "&lt;")
            case ">":
                return flushPendingAmpersandString(withSuffix: "&gt;")
            case "&":
                return flushPendingAmpersandString(resettingTo: "")
            case ";":
                let pending = pendingAmpersandString.map { "&\($0);" }
                pendingAmpersandString = nil
                return pending ?? ";"
            case "#" where pendingAmpersandString?.isEmpty == true:
                pendingAmpersandString = "#"
                return ""
            default:
                if let pending = pendingAmpersandString {
                    guard character.isLetter || character.isNumber else {
                        return flushPendingAmpersandString(withSuffix: String(character))
                    }

                    pendingAmpersandString = "\(pending)\(character)"
                    return ""
                }

                return "\(character)"
            }
        }) + flushPendingAmpersandString()
    }
}
