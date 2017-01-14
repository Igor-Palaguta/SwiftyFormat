# SwiftyFormat

[![CI Status](http://img.shields.io/travis/Igor Palaguta/SwiftyFormat.svg?style=flat)](https://travis-ci.org/Igor Palaguta/SwiftyFormat)
[![Version](https://img.shields.io/cocoapods/v/SwiftyFormat.svg?style=flat)](http://cocoapods.org/pods/SwiftyFormat)
[![License](https://img.shields.io/cocoapods/l/SwiftyFormat.svg?style=flat)](http://cocoapods.org/pods/SwiftyFormat)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyFormat.svg?style=flat)](http://cocoapods.org/pods/SwiftyFormat)

SwiftyFormat has simple syntax, inside string you can add #{{key|default value|prefix|suffix}}.

1. *key* (required) is used for identifying parameter inside mapping
2. *default value* (optional)  is used when when mapping returns nil for key
3. *prefix* (optional) is added before value. Not added for default value
4. *suffix* (optional) is added after value. Not added for default value

## Example

```
  let format = "#{{user}} mentioned you in a comment. #{{comment}}"
  let result = NSAttributedString(format: format, mapping: ["user": "Jack", "comment": "How are you Jill?"])
```


Closure can be passed instead of dictionary. It is useful, when format can be changed, and not all parameters required for every format.

```
  let result = NSAttributedString(format: someFormat) { key in
     switch key {
     case "name":
        return NSAttributedString(string: "Jack", attributes: nameAttributes)
     case "cookies":
        return cookies
     default:
        return nil
     }
  }
```


You can also specify default value, prefix and suffix

```
  let format ="#{{name|Your friend}} mentioned you in a comment#{{comment|| \"|\"}"
  let result1 = NSAttributedString(format: format, mapping: [:])
  //result1 == Your friend mentioned you in a comment
  let result2 = NSAttributedString(format: format, mapping: ["name": "Jack", comment: "How are you?"])
  //result2 == Jack mentioned you in a comment "How are you?"
```


Same format syntax can be used for String

```
  let format = "#{{user}} mentioned you in a comment. #{{comment}}"
  let result = String(format: format, mapping: ["user": "Jack", "comment": "How are you Jill?"])
```

## Requirements

SwiftyFormat supports Swift 2 and Swift 3. Use 'swift-2.3' branch for Swift 2

## Installation

Cocoapods:
```
pod "SwiftyFormat"
```
`

Carthage:
```
github "Igor-Palaguta/SwiftyFormat"
```

## Author

Igor Palaguta, igor.palaguta@gmail.com

## License

SwiftyFormat is available under the MIT license. See the LICENSE file for more info.
