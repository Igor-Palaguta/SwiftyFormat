import Foundation

extension NSAttributedString {
   public convenience init(format: String, mapping: [String: AnyObject]) {
      self.init(format: format, attributes: nil) { key in mapping[key] }
   }

   public convenience init(format: String, attributes: [String: AnyObject]?, mapping: [String: AnyObject]) {
      self.init(format: format, attributes: attributes) { key in mapping[key] }
   }

   public convenience init(format: String, @noescape mapper: (String) -> AnyObject?) {
      self.init(format: format, attributes: nil, mapper: mapper)
   }

   public convenience init(format: String,
                           attributes: [String: AnyObject]?,
                           @noescape mapper: (String) -> AnyObject?) {

      let attributedString = NSMutableAttributedString(string: format)
      attributedString.beginEditing()

      format.enumerateParameters(
         mapper: mapper,
         defaultHandler: { range, defaultValue in
            attributedString.replaceCharactersInRange(range, withString: defaultValue)
         },
         valueHandler: { range, value, prefix, suffix in
            guard let attributedValue = value as? NSAttributedString else {
               attributedString.replaceCharactersInRange(range, withString: "\(prefix)\(value)\(suffix)")
               return
            }
            let mutableValue = NSMutableAttributedString(string: prefix)
            mutableValue.appendAttributedString(attributedValue)
            mutableValue.appendAttributedString(NSAttributedString(string: suffix))
            attributedString.replaceCharactersInRange(range, withAttributedString: mutableValue)
      })

      if let attributes = attributes where !attributes.isEmpty {
         let range = NSRange(location: 0, length: (attributedString.string as NSString).length)
         for (name, value) in attributes {
            attributedString.enumerateAttribute(
               name,
               inRange: range,
               options: NSAttributedStringEnumerationOptions(rawValue: 0)) {
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
   public init(format: String, mapping: [String: AnyObject]) {
      self.init(format: format) { key in mapping[key] }
   }

   public init(format: String, @noescape mapper: (String) -> AnyObject?) {

      var string = NSMutableString(string: format)

      format.enumerateParameters(
         mapper: mapper,
         defaultHandler: { range, defaultValue in
            string.replaceCharactersInRange(range, withString: defaultValue)
         },
         valueHandler: { range, value, prefix, suffix in
            string.replaceCharactersInRange(range, withString: "\(prefix)\(value)\(suffix)")
      })

      self.init(string)
   }

   private func enumerateParameters(@noescape mapper mapper: (String) -> AnyObject?,
                                    @noescape defaultHandler: (NSRange, String) -> Void,
                                    @noescape valueHandler: (NSRange, AnyObject, String, String) -> Void) {
      let nsFormat = self as NSString
      let matches = regex.matchesInString(self,
                                          options: [],
                                          range: NSRange(location: 0, length: nsFormat.length)).reverse()

      for match in matches {
         let parametersRange = match.rangeAtIndex(1)
         let parameters = nsFormat.substringWithRange(parametersRange).componentsSeparatedByString("|")
         let keyword = extract(parameters, .Key)

         let range = match.rangeAtIndex(0)

         if let value = mapper(keyword) {
            valueHandler(range,
                         value,
                         extract(parameters, .Prefix),
                         extract(parameters, .Suffix))
         } else {
            defaultHandler(range, extract(parameters, .Default))
         }
      }
   }
}

private let regex = try! NSRegularExpression(pattern: "#\\{{2}(.+?)\\}{2}",
                                             options: .DotMatchesLineSeparators)

private enum InterpolationParameter: Int {
   case Key
   case Default
   case Prefix
   case Suffix
}

private func extract(_ parameters: [String], _ parameter: InterpolationParameter) -> String {
   guard parameter.rawValue < parameters.count else {
      return ""
   }
   return parameters[parameter.rawValue]
}
