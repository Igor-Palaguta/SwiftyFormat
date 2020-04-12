import Foundation

extension NSAttributedString {
    public convenience init(format: String, mapping: [String: Any]) {
        self.init(format: format, attributes: nil) { key in mapping[key] }
    }

    public convenience init(format: String, attributes: [Key: Any]?, mapping: [String: Any]) {
        self.init(format: format, attributes: attributes) { key in mapping[key] }
    }

    public convenience init(format: String, mapping: (String) -> Any?) {
        self.init(format: format, attributes: nil, mapping: mapping)
    }

    public convenience init(format: String,
                            attributes: [Key: Any]?,
                            mapping: (String) -> Any?) {

        let attributedString = NSMutableAttributedString(string: format)
        attributedString.beginEditing()
        defer {
            attributedString.endEditing()
        }

        format.interpolateParameters(
            usingMapping: mapping,
            defaultHandler: { range, defaultValue in
                attributedString.replaceCharacters(in: range, with: defaultValue)
            },
            valueHandler: { range, value, prefix, suffix in
                guard let attributedValue = value as? NSAttributedString else {
                    attributedString.replaceCharacters(in: range, with: "\(prefix)\(value)\(suffix)")
                    return
                }
                let mutableValue = NSMutableAttributedString(string: prefix)
                mutableValue.append(attributedValue)
                mutableValue.append(NSAttributedString(string: suffix))
                attributedString.replaceCharacters(in: range, with: mutableValue)
        })

        if let attributes = attributes, !attributes.isEmpty {
            let string = attributedString.string
            let range = NSRange(string.startIndex..<string.endIndex, in: string)

            for (key, value) in attributes {
                attributedString.enumerateAttribute(key, in: range) { oldValue, range, _ in
                    if oldValue == nil {
                        attributedString.addAttribute(key, value: value, range: range)
                    }
                }
            }
        }

        self.init(attributedString: attributedString)
    }
}

extension String {
    public init(format: String, mapping: [String: Any]) {
        self.init(format: format) { key in mapping[key] }
    }

    public init(format: String, mapping: (String) -> Any?) {

        let string = NSMutableString(string: format)

        format.interpolateParameters(
            usingMapping: mapping,
            defaultHandler: { range, defaultValue in
                string.replaceCharacters(in: range, with: defaultValue)
            },
            valueHandler: { range, value, prefix, suffix in
                string.replaceCharacters(in: range, with: "\(prefix)\(value)\(suffix)")
        })

        self.init(string)
    }
}

private extension String {
    func interpolateParameters(usingMapping mapping: (String) -> Any?,
                               defaultHandler: (NSRange, String) -> Void,
                               valueHandler: (NSRange, Any, String, String) -> Void) {
        let matches = regex.matches(in: self,
                                    options: [],
                                    range: NSRange(startIndex..<endIndex, in: self)).reversed()

        for match in matches {
            let parametersRange = Range(match.range(at: 1), in: self)!
            let parameters = self[parametersRange].components(separatedBy: "|")

            let keyword = parameters[.key]

            let range = match.range(at: 0)

            if let value = mapping(keyword) {
                valueHandler(range,
                             value,
                             parameters[.prefix],
                             parameters[.suffix])
            } else {
                defaultHandler(range, parameters[.defaultValue])
            }
        }
    }
}

private let regex = try! NSRegularExpression(pattern: "#\\{{2}(.+?)\\}{2}",
                                             options: .dotMatchesLineSeparators)

private enum InterpolationParameter: Int {
    case key
    case defaultValue
    case prefix
    case suffix
}

private extension Array where Element == String {
    subscript(index: InterpolationParameter, default default: String = "") -> String {
        guard index.rawValue < count else {
            return `default`
        }
        return self[index.rawValue]
    }
}
