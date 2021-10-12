// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: src/main/protobuf/invocation_policy.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

// Copyright 2015 The Bazel Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// The --invocation_policy flag takes a base64-encoded binary-serialized or text
/// formatted InvocationPolicy message.
public struct Blaze_InvocationPolicy_InvocationPolicy {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Order matters.
  /// After expanding policies on expansion flags or flags with implicit
  /// requirements, only the final policy on a specific flag will be enforced
  /// onto the user's command line.
  public var flagPolicies: [Blaze_InvocationPolicy_FlagPolicy] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// A policy for controlling the value of a flag.
public struct Blaze_InvocationPolicy_FlagPolicy {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The name of the flag to enforce this policy on.
  ///
  /// Note that this should be the full name of the flag, not the abbreviated
  /// name of the flag. If the user specifies the abbreviated name of a flag,
  /// that flag will be matched using its full name.
  ///
  /// The "no" prefix will not be parsed, so for boolean flags, use
  /// the flag's full name and explicitly set it to true or false.
  public var flagName: String {
    get {return _flagName ?? String()}
    set {_flagName = newValue}
  }
  /// Returns true if `flagName` has been explicitly set.
  public var hasFlagName: Bool {return self._flagName != nil}
  /// Clears the value of `flagName`. Subsequent reads from it will return its default value.
  public mutating func clearFlagName() {self._flagName = nil}

  /// If set, this flag policy is applied only if one of the given commands or a
  /// command that inherits from one of the given commands is being run. For
  /// instance, if "build" is one of the commands here, then this policy will
  /// apply to any command that inherits from build, such as info, coverage, or
  /// test. If empty, this flag policy is applied for all commands. This allows
  /// the policy setter to add all policies to the proto without having to
  /// determine which Bazel command the user is actually running. Additionally,
  /// Bazel allows multiple flags to be defined by the same name, and the
  /// specific flag definition is determined by the command.
  public var commands: [String] = []

  public var operation: Blaze_InvocationPolicy_FlagPolicy.OneOf_Operation? = nil

  public var setValue: Blaze_InvocationPolicy_SetValue {
    get {
      if case .setValue(let v)? = operation {return v}
      return Blaze_InvocationPolicy_SetValue()
    }
    set {operation = .setValue(newValue)}
  }

  public var useDefault: Blaze_InvocationPolicy_UseDefault {
    get {
      if case .useDefault(let v)? = operation {return v}
      return Blaze_InvocationPolicy_UseDefault()
    }
    set {operation = .useDefault(newValue)}
  }

  public var disallowValues: Blaze_InvocationPolicy_DisallowValues {
    get {
      if case .disallowValues(let v)? = operation {return v}
      return Blaze_InvocationPolicy_DisallowValues()
    }
    set {operation = .disallowValues(newValue)}
  }

  public var allowValues: Blaze_InvocationPolicy_AllowValues {
    get {
      if case .allowValues(let v)? = operation {return v}
      return Blaze_InvocationPolicy_AllowValues()
    }
    set {operation = .allowValues(newValue)}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum OneOf_Operation: Equatable {
    case setValue(Blaze_InvocationPolicy_SetValue)
    case useDefault(Blaze_InvocationPolicy_UseDefault)
    case disallowValues(Blaze_InvocationPolicy_DisallowValues)
    case allowValues(Blaze_InvocationPolicy_AllowValues)

  #if !swift(>=4.1)
    public static func ==(lhs: Blaze_InvocationPolicy_FlagPolicy.OneOf_Operation, rhs: Blaze_InvocationPolicy_FlagPolicy.OneOf_Operation) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.setValue, .setValue): return {
        guard case .setValue(let l) = lhs, case .setValue(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.useDefault, .useDefault): return {
        guard case .useDefault(let l) = lhs, case .useDefault(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.disallowValues, .disallowValues): return {
        guard case .disallowValues(let l) = lhs, case .disallowValues(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.allowValues, .allowValues): return {
        guard case .allowValues(let l) = lhs, case .allowValues(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  public init() {}

  fileprivate var _flagName: String? = nil
}

public struct Blaze_InvocationPolicy_SetValue {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Use this value for the specified flag, overriding any default or user-set
  /// value (unless append is set to true for repeatable flags).
  ///
  /// This field is repeated for repeatable flags. It is an error to set
  /// multiple values for a flag that is not actually a repeatable flag.
  /// This requires at least 1 value, if even the empty string.
  ///
  /// If the flag allows multiple values, all of its values are replaced with the
  /// value or values from the policy (i.e., no diffing or merging is performed),
  /// unless the append field (see below) is set to true.
  ///
  /// Note that some flags are tricky. For example, some flags look like boolean
  /// flags, but are actually Void expansion flags that expand into other flags.
  /// The Bazel flag parser will accept "--void_flag=false", but because
  /// the flag is Void, the "=false" is ignored. It can get even trickier, like
  /// "--novoid_flag" which is also an expansion flag with the type Void whose
  /// name is explicitly "novoid_flag" and which expands into other flags that
  /// are the opposite of "--void_flag". For expansion flags, it's best to
  /// explicitly override the flags they expand into.
  ///
  /// Other flags may be differently tricky: A flag could have a converter that
  /// converts some string to a list of values, but that flag may not itself have
  /// allowMultiple set to true.
  ///
  /// An example is "--test_tag_filters": this flag sets its converter to
  /// CommaSeparatedOptionListConverter, but does not set allowMultiple to true.
  /// So "--test_tag_filters=foo,bar" results in ["foo", "bar"], however
  /// "--test_tag_filters=foo --test_tag_filters=bar" results in just ["bar"]
  /// since the 2nd value overrides the 1st.
  ///
  /// Similarly, "--test_tag_filters=foo,bar --test_tag_filters=baz,qux" results
  /// in ["baz", "qux"]. For flags like these, the policy should specify
  /// "foo,bar" instead of separately specifying "foo" and "bar" so that the
  /// converter is appropriately invoked.
  ///
  /// Note that the opposite is not necessarily
  /// true: for a flag that specifies allowMultiple=true, "--flag=foo,bar"
  /// may fail to parse or result in an unexpected value.
  public var flagValue: [String] = []

  /// Whether to allow this policy to be overridden by user-specified values.
  /// When set, if the user specified a value for this flag, use the value
  /// from the user, otherwise use the value specified in this policy.
  public var overridable: Bool {
    get {return _overridable ?? false}
    set {_overridable = newValue}
  }
  /// Returns true if `overridable` has been explicitly set.
  public var hasOverridable: Bool {return self._overridable != nil}
  /// Clears the value of `overridable`. Subsequent reads from it will return its default value.
  public mutating func clearOverridable() {self._overridable = nil}

  /// If true, and if the flag named in the policy is a repeatable flag, then
  /// the values listed in flag_value do not replace all the user-set or default
  /// values of the flag, but instead append to them. If the flag is not
  /// repeatable, then this has no effect.
  public var append: Bool {
    get {return _append ?? false}
    set {_append = newValue}
  }
  /// Returns true if `append` has been explicitly set.
  public var hasAppend: Bool {return self._append != nil}
  /// Clears the value of `append`. Subsequent reads from it will return its default value.
  public mutating func clearAppend() {self._append = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _overridable: Bool? = nil
  fileprivate var _append: Bool? = nil
}

/// Use the default value of the flag, as defined by Bazel (or equivalently, do
/// not allow the user to set this flag).
///
/// Note on implementation: UseDefault sets the default by clearing the flag,
/// so that when the value is requested and no flag is found, the flag parser
/// returns the default. This is mostly relevant for expansion flags: it will
/// erase user values in *all* flags that the expansion flag expands to. Only
/// use this on expansion flags if this is acceptable behavior. Since the last
/// policy wins, later policies on this same flag will still remove the
/// expanded UseDefault, so there is a way around, but it's really best not to
/// use this on expansion flags at all.
public struct Blaze_InvocationPolicy_UseDefault {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Blaze_InvocationPolicy_DisallowValues {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// It is an error for the user to use any of these values (that is, the Bazel
  /// command will fail), unless new_value or use_default is set.
  ///
  /// For repeatable flags, if any one of the values in the flag matches a value
  /// in the list of disallowed values, an error is thrown.
  ///
  /// Care must be taken for flags with complicated converters. For example,
  /// it's possible for a repeated flag to be of type List<List<T>>, so that
  /// "--foo=a,b --foo=c,d" results in foo=[["a","b"], ["c", "d"]]. In this case,
  /// it is not possible to disallow just "b", nor will ["b", "a"] match, nor
  /// will ["b", "c"] (but ["a", "b"] will still match).
  public var disallowedValues: [String] = []

  public var replacementValue: Blaze_InvocationPolicy_DisallowValues.OneOf_ReplacementValue? = nil

  /// If set and if the value of the flag is disallowed (including the default
  /// value of the flag if the user doesn't specify a value), use this value as
  /// the value of the flag instead of raising an error. This does not apply to
  /// repeatable flags and is ignored if the flag is a repeatable flag.
  public var newValue: String {
    get {
      if case .newValue(let v)? = replacementValue {return v}
      return String()
    }
    set {replacementValue = .newValue(newValue)}
  }

  /// If set and if the value of the flag is disallowed, use the default value
  /// of the flag instead of raising an error. Unlike new_value, this works for
  /// repeatable flags, but note that the default value for repeatable flags is
  /// always empty.
  ///
  /// Note that it is an error to disallow the default value of the flag and
  /// to set use_default, unless the flag is a repeatable flag where the
  /// default value is always the empty list.
  public var useDefault: Blaze_InvocationPolicy_UseDefault {
    get {
      if case .useDefault(let v)? = replacementValue {return v}
      return Blaze_InvocationPolicy_UseDefault()
    }
    set {replacementValue = .useDefault(newValue)}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum OneOf_ReplacementValue: Equatable {
    /// If set and if the value of the flag is disallowed (including the default
    /// value of the flag if the user doesn't specify a value), use this value as
    /// the value of the flag instead of raising an error. This does not apply to
    /// repeatable flags and is ignored if the flag is a repeatable flag.
    case newValue(String)
    /// If set and if the value of the flag is disallowed, use the default value
    /// of the flag instead of raising an error. Unlike new_value, this works for
    /// repeatable flags, but note that the default value for repeatable flags is
    /// always empty.
    ///
    /// Note that it is an error to disallow the default value of the flag and
    /// to set use_default, unless the flag is a repeatable flag where the
    /// default value is always the empty list.
    case useDefault(Blaze_InvocationPolicy_UseDefault)

  #if !swift(>=4.1)
    public static func ==(lhs: Blaze_InvocationPolicy_DisallowValues.OneOf_ReplacementValue, rhs: Blaze_InvocationPolicy_DisallowValues.OneOf_ReplacementValue) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.newValue, .newValue): return {
        guard case .newValue(let l) = lhs, case .newValue(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.useDefault, .useDefault): return {
        guard case .useDefault(let l) = lhs, case .useDefault(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  public init() {}
}

public struct Blaze_InvocationPolicy_AllowValues {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// It is an error for the user to use any value not in this list, unless
  /// new_value or use_default is set.
  public var allowedValues: [String] = []

  public var replacementValue: Blaze_InvocationPolicy_AllowValues.OneOf_ReplacementValue? = nil

  /// If set and if the value of the flag is disallowed (including the default
  /// value of the flag if the user doesn't specify a value), use this value as
  /// the value of the flag instead of raising an error. This does not apply to
  /// repeatable flags and is ignored if the flag is a repeatable flag.
  public var newValue: String {
    get {
      if case .newValue(let v)? = replacementValue {return v}
      return String()
    }
    set {replacementValue = .newValue(newValue)}
  }

  /// If set and if the value of the flag is disallowed, use the default value
  /// of the flag instead of raising an error. Unlike new_value, this works for
  /// repeatable flags, but note that the default value for repeatable flags is
  /// always empty.
  ///
  /// Note that it is an error to disallow the default value of the flag and
  /// to set use_default, unless the flag is a repeatable flag where the
  /// default value is always the empty list.
  public var useDefault: Blaze_InvocationPolicy_UseDefault {
    get {
      if case .useDefault(let v)? = replacementValue {return v}
      return Blaze_InvocationPolicy_UseDefault()
    }
    set {replacementValue = .useDefault(newValue)}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum OneOf_ReplacementValue: Equatable {
    /// If set and if the value of the flag is disallowed (including the default
    /// value of the flag if the user doesn't specify a value), use this value as
    /// the value of the flag instead of raising an error. This does not apply to
    /// repeatable flags and is ignored if the flag is a repeatable flag.
    case newValue(String)
    /// If set and if the value of the flag is disallowed, use the default value
    /// of the flag instead of raising an error. Unlike new_value, this works for
    /// repeatable flags, but note that the default value for repeatable flags is
    /// always empty.
    ///
    /// Note that it is an error to disallow the default value of the flag and
    /// to set use_default, unless the flag is a repeatable flag where the
    /// default value is always the empty list.
    case useDefault(Blaze_InvocationPolicy_UseDefault)

  #if !swift(>=4.1)
    public static func ==(lhs: Blaze_InvocationPolicy_AllowValues.OneOf_ReplacementValue, rhs: Blaze_InvocationPolicy_AllowValues.OneOf_ReplacementValue) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.newValue, .newValue): return {
        guard case .newValue(let l) = lhs, case .newValue(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.useDefault, .useDefault): return {
        guard case .useDefault(let l) = lhs, case .useDefault(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "blaze.invocation_policy"

extension Blaze_InvocationPolicy_InvocationPolicy: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".InvocationPolicy"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "flag_policies"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.flagPolicies) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.flagPolicies.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.flagPolicies, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Blaze_InvocationPolicy_InvocationPolicy, rhs: Blaze_InvocationPolicy_InvocationPolicy) -> Bool {
    if lhs.flagPolicies != rhs.flagPolicies {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Blaze_InvocationPolicy_FlagPolicy: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".FlagPolicy"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "flag_name"),
    2: .same(proto: "commands"),
    3: .standard(proto: "set_value"),
    4: .standard(proto: "use_default"),
    5: .standard(proto: "disallow_values"),
    6: .standard(proto: "allow_values"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self._flagName) }()
      case 2: try { try decoder.decodeRepeatedStringField(value: &self.commands) }()
      case 3: try {
        var v: Blaze_InvocationPolicy_SetValue?
        var hadOneofValue = false
        if let current = self.operation {
          hadOneofValue = true
          if case .setValue(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.operation = .setValue(v)
        }
      }()
      case 4: try {
        var v: Blaze_InvocationPolicy_UseDefault?
        var hadOneofValue = false
        if let current = self.operation {
          hadOneofValue = true
          if case .useDefault(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.operation = .useDefault(v)
        }
      }()
      case 5: try {
        var v: Blaze_InvocationPolicy_DisallowValues?
        var hadOneofValue = false
        if let current = self.operation {
          hadOneofValue = true
          if case .disallowValues(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.operation = .disallowValues(v)
        }
      }()
      case 6: try {
        var v: Blaze_InvocationPolicy_AllowValues?
        var hadOneofValue = false
        if let current = self.operation {
          hadOneofValue = true
          if case .allowValues(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.operation = .allowValues(v)
        }
      }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._flagName {
      try visitor.visitSingularStringField(value: v, fieldNumber: 1)
    } }()
    if !self.commands.isEmpty {
      try visitor.visitRepeatedStringField(value: self.commands, fieldNumber: 2)
    }
    switch self.operation {
    case .setValue?: try {
      guard case .setValue(let v)? = self.operation else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    }()
    case .useDefault?: try {
      guard case .useDefault(let v)? = self.operation else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    }()
    case .disallowValues?: try {
      guard case .disallowValues(let v)? = self.operation else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
    }()
    case .allowValues?: try {
      guard case .allowValues(let v)? = self.operation else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
    }()
    case nil: break
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Blaze_InvocationPolicy_FlagPolicy, rhs: Blaze_InvocationPolicy_FlagPolicy) -> Bool {
    if lhs._flagName != rhs._flagName {return false}
    if lhs.commands != rhs.commands {return false}
    if lhs.operation != rhs.operation {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Blaze_InvocationPolicy_SetValue: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".SetValue"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "flag_value"),
    2: .same(proto: "overridable"),
    3: .same(proto: "append"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedStringField(value: &self.flagValue) }()
      case 2: try { try decoder.decodeSingularBoolField(value: &self._overridable) }()
      case 3: try { try decoder.decodeSingularBoolField(value: &self._append) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.flagValue.isEmpty {
      try visitor.visitRepeatedStringField(value: self.flagValue, fieldNumber: 1)
    }
    try { if let v = self._overridable {
      try visitor.visitSingularBoolField(value: v, fieldNumber: 2)
    } }()
    try { if let v = self._append {
      try visitor.visitSingularBoolField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Blaze_InvocationPolicy_SetValue, rhs: Blaze_InvocationPolicy_SetValue) -> Bool {
    if lhs.flagValue != rhs.flagValue {return false}
    if lhs._overridable != rhs._overridable {return false}
    if lhs._append != rhs._append {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Blaze_InvocationPolicy_UseDefault: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".UseDefault"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Blaze_InvocationPolicy_UseDefault, rhs: Blaze_InvocationPolicy_UseDefault) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Blaze_InvocationPolicy_DisallowValues: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".DisallowValues"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "disallowed_values"),
    3: .standard(proto: "new_value"),
    4: .standard(proto: "use_default"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedStringField(value: &self.disallowedValues) }()
      case 3: try {
        var v: String?
        try decoder.decodeSingularStringField(value: &v)
        if let v = v {
          if self.replacementValue != nil {try decoder.handleConflictingOneOf()}
          self.replacementValue = .newValue(v)
        }
      }()
      case 4: try {
        var v: Blaze_InvocationPolicy_UseDefault?
        var hadOneofValue = false
        if let current = self.replacementValue {
          hadOneofValue = true
          if case .useDefault(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.replacementValue = .useDefault(v)
        }
      }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.disallowedValues.isEmpty {
      try visitor.visitRepeatedStringField(value: self.disallowedValues, fieldNumber: 1)
    }
    switch self.replacementValue {
    case .newValue?: try {
      guard case .newValue(let v)? = self.replacementValue else { preconditionFailure() }
      try visitor.visitSingularStringField(value: v, fieldNumber: 3)
    }()
    case .useDefault?: try {
      guard case .useDefault(let v)? = self.replacementValue else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    }()
    case nil: break
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Blaze_InvocationPolicy_DisallowValues, rhs: Blaze_InvocationPolicy_DisallowValues) -> Bool {
    if lhs.disallowedValues != rhs.disallowedValues {return false}
    if lhs.replacementValue != rhs.replacementValue {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Blaze_InvocationPolicy_AllowValues: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".AllowValues"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "allowed_values"),
    3: .standard(proto: "new_value"),
    4: .standard(proto: "use_default"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedStringField(value: &self.allowedValues) }()
      case 3: try {
        var v: String?
        try decoder.decodeSingularStringField(value: &v)
        if let v = v {
          if self.replacementValue != nil {try decoder.handleConflictingOneOf()}
          self.replacementValue = .newValue(v)
        }
      }()
      case 4: try {
        var v: Blaze_InvocationPolicy_UseDefault?
        var hadOneofValue = false
        if let current = self.replacementValue {
          hadOneofValue = true
          if case .useDefault(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.replacementValue = .useDefault(v)
        }
      }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.allowedValues.isEmpty {
      try visitor.visitRepeatedStringField(value: self.allowedValues, fieldNumber: 1)
    }
    switch self.replacementValue {
    case .newValue?: try {
      guard case .newValue(let v)? = self.replacementValue else { preconditionFailure() }
      try visitor.visitSingularStringField(value: v, fieldNumber: 3)
    }()
    case .useDefault?: try {
      guard case .useDefault(let v)? = self.replacementValue else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    }()
    case nil: break
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Blaze_InvocationPolicy_AllowValues, rhs: Blaze_InvocationPolicy_AllowValues) -> Bool {
    if lhs.allowedValues != rhs.allowedValues {return false}
    if lhs.replacementValue != rhs.replacementValue {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
