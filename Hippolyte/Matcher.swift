//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation

public class Matcher: Hashable {

  func matches(string: String?) -> Bool {
    return false
  }

  func matches(data: Data?) -> Bool {
    return false
  }

  func isEqual(to other: Matcher) -> Bool {
    return false
  }

  public func hash(into hasher: inout Hasher) {
  }

  public static func ==(lhs: Matcher, rhs: Matcher) -> Bool {
    return lhs.isEqual(to: rhs)
  }

}

public protocol Matcheable {
  func matcher() -> Matcher
}

public final class StringMatcher: Matcher {

  let string: String

  public init(string: String) {
    self.string = string
  }

  public override func matches(string: String?) -> Bool {
    return self.string == string
  }

  public override func matches(data: Data?) -> Bool {
    return self.string.data(using: .utf8) == data
  }

  public override func hash(into hasher: inout Hasher) {
    hasher.combine(string)
  }

  override func isEqual(to other: Matcher) -> Bool {
    if let theOther = other as? StringMatcher {
      return theOther.string == string
    }
    return false
  }

}

public final class RegexMatcher: Matcher {

  let regex: NSRegularExpression

  public init(regex: NSRegularExpression) {
    self.regex = regex
  }

  public override func matches(string: String?) -> Bool {
    guard let string = string else {
      return false
    }
    return regex.numberOfMatches(in: string, options: [], range: NSRange(string.startIndex..., in: string)) > 0
  }

  public override func hash(into hasher: inout Hasher) {
    hasher.combine(regex)
  }

  override func isEqual(to other: Matcher) -> Bool {
    if let theOther = other as? RegexMatcher {
      return theOther.regex == regex
    }
    return false
  }

}

public final class DataMatcher: Matcher {

  let data: Data

  public init(data: Data) {
    self.data = data
  }

  public override func matches(data: Data?) -> Bool {
    return self.data == data
  }

  public override func hash(into hasher: inout Hasher) {
    hasher.combine(data)
  }

  override func isEqual(to other: Matcher) -> Bool {
    if let theOther = other as? DataMatcher {
      return theOther.data == data
    }
    return false
  }

}

public final class JsonMatcher<T: Decodable & Hashable>: Matcher {

  let decoder: JSONDecoder
  let object: T

  public init(object: T) {
    self.decoder = JSONDecoder()
    self.object = object
  }

  public override func matches(data: Data?) -> Bool {
    guard let data = data, let decodedObject = try? self.decoder.decode(T.self, from: data) else {
      return false
    }
    return object == decodedObject
  }

  public override func hash(into hasher: inout Hasher) {
    hasher.combine(object)
  }

  override func isEqual(to other: Matcher) -> Bool {
    if let theOther = other as? JsonMatcher<T> {
      return theOther.object == object
    }
    return false
  }

}
