import Foundation

extension NSAttributedString {
   public convenience init(format: String, mapping: [String: Any]) {
      self.init(format: format, attributes: nil) { key in mapping[key] }
   }

   public convenience init(format: String, attributes: [String: Any]?, mapping: [String: Any]) {
      self.init(format: format, attributes: attributes) { key in mapping[key] }
   }

   public convenience init(format: String, mapper: (String) -> Any?) {
      self.init(format: format, attributes: nil, mapper: mapper)
   }

   public convenience init(format: String,
                           attributes: [String: Any]?,
                           mapper: (String) -> Any?) {

      let attributedString = NSMutableAttributedString(string: format)
      attributedString.beginEditing()

      format.enumerateParameters(
         mapper: mapper,
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
         let range = NSRange(location: 0, length: (attributedString.string as NSString).length)
         for (name, value) in attributes {
            attributedString.enumerateAttribute(
               name,
               in: range,
               options: NSAttributedString.EnumerationOptions(rawValue: 0)) {
                  oldValue, range, _ in
                  if oldValue == nil {
                     attributedString.addAttribute(name, value: value, range: range)
                  }
            }
         }
      }

      attributedString.endEditing()

      self.init(attributedString: attributedString)
   }
}

extension String {
   public init(format: String, mapping: [String: Any]) {
      self.init(format: format) { key in mapping[key] }
   }

   public init(format: String, mapper: (String) -> Any?) {

      let string = NSMutableString(string: format)

      format.enumerateParameters(
         mapper: mapper,
         defaultHandler: { range, defaultValue in
            string.replaceCharacters(in: range, with: defaultValue)
         },
         valueHandler: { range, value, prefix, suffix in
            string.replaceCharacters(in: range, with: "\(prefix)\(value)\(suffix)")
      })

      self.init(string)
   }

   fileprivate func enumerateParameters(mapper: (String) -> Any?,
                                        defaultHandler: (NSRange, String) -> Void,
                                        valueHandler: (NSRange, Any, String, String) -> Void) {
      let nsFormat = self as NSString
      let matches = regex.matches(in: self,
                                  options: [],
                                  range: NSRange(location: 0, length: nsFormat.length)).reversed()

      for match in matches {
         let parametersRange = match.rangeAt(1)
         let parameters = nsFormat.substring(with: parametersRange).components(separatedBy: "|")
         let keyword = extract(parameters, .key)

         let range = match.rangeAt(0)

         if let value = mapper(keyword) {
            valueHandler(range,
                         value,
                         extract(parameters, .prefix),
                         extract(parameters, .suffix))
         } else {
            defaultHandler(range, extract(parameters, .defaultValue))
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

private func extract(_ parameters: [String], _ parameter: InterpolationParameter) -> String {
   guard parameter.rawValue < parameters.count else {
      return ""
   }
   return parameters[parameter.rawValue]
}
