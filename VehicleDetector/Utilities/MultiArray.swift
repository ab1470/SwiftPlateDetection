//
//  MultiArray.swift
//  VehicleDetectorTest
//
//  Created by Andrew Balmer on 6/4/20.

//  Copyright (c) 2017-2019 M.I. Hollemans
//  Code below was copied from https://github.com/hollance/CoreMLHelpers


import Foundation
import CoreML


public protocol MultiArrayType: Comparable {
    static var multiArrayDataType: MLMultiArrayDataType { get }
    static func +(lhs: Self, rhs: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
    init(_: Int)
    var toUInt8: UInt8 { get }
}

extension Double: MultiArrayType {
    public static var multiArrayDataType: MLMultiArrayDataType { return .double }
    public var toUInt8: UInt8 { return UInt8(self) }
}

extension Float: MultiArrayType {
    public static var multiArrayDataType: MLMultiArrayDataType { return .float32 }
    public var toUInt8: UInt8 { return UInt8(self) }
}

extension Int32: MultiArrayType {
    public static var multiArrayDataType: MLMultiArrayDataType { return .int32 }
    public var toUInt8: UInt8 { return UInt8(self) }
}


/// Wrapper around MLMultiArray to make it more Swifty.
public struct MultiArray<T: MultiArrayType> {
    public let array: MLMultiArray
    public let pointer: UnsafeMutablePointer<T>
    
    private(set) public var strides: [Int]
    private(set) public var shape: [Int]
    
    /// Creates a new multi-array filled with all zeros.
    public init(shape: [Int]) {
        let m = try! MLMultiArray(shape: shape as [NSNumber], dataType: T.multiArrayDataType)
        self.init(m)
        memset(pointer, 0, MemoryLayout<T>.stride * count)
    }
    
    /// Creates a new multi-array initialized with the specified value.
    public init(shape: [Int], initial: T) {
        self.init(shape: shape)
        for i in 0..<count {
            pointer[i] = initial
        }
    }
    
    /// Creates a multi-array that wraps an existing MLMultiArray.
    public init(_ array: MLMultiArray) {
        self.init(array, array.shape as! [Int], array.strides as! [Int])
    }
    
    init(_ array: MLMultiArray, _ shape: [Int], _ strides: [Int]) {
        self.array = array
        self.shape = shape
        self.strides = strides
        pointer = UnsafeMutablePointer<T>(OpaquePointer(array.dataPointer))
    }
    
    /// Returns the number of elements in the entire array.
    public var count: Int {
        return shape.reduce(1, *)
    }
    
    public subscript(a: Int) -> T {
        get { return pointer[a] }
        set { pointer[a] = newValue }
    }
    
    public subscript(a: Int, b: Int) -> T {
        get { return pointer[a*strides[0] + b*strides[1]] }
        set { pointer[a*strides[0] + b*strides[1]] = newValue }
    }
    
    public subscript(a: Int, b: Int, c: Int) -> T {
        get { return pointer[a*strides[0] + b*strides[1] + c*strides[2]] }
        set { pointer[a*strides[0] + b*strides[1] + c*strides[2]] = newValue }
    }
    
    public subscript(a: Int, b: Int, c: Int, d: Int) -> T {
        get { return pointer[a*strides[0] + b*strides[1] + c*strides[2] + d*strides[3]] }
        set { pointer[a*strides[0] + b*strides[1] + c*strides[2] + d*strides[3]] = newValue }
    }
    
    public subscript(a: Int, b: Int, c: Int, d: Int, e: Int) -> T {
        get { return pointer[a*strides[0] + b*strides[1] + c*strides[2] + d*strides[3] + e*strides[4]] }
        set { pointer[a*strides[0] + b*strides[1] + c*strides[2] + d*strides[3] + e*strides[4]] = newValue }
    }
    
    public subscript(indices: [Int]) -> T {
        get { return pointer[offset(for: indices)] }
        set { pointer[offset(for: indices)] = newValue }
    }
    
    func offset(for indices: [Int]) -> Int {
        var offset = 0
        for i in 0..<indices.count {
            offset += indices[i] * strides[i]
        }
        return offset
    }
    
}

extension MultiArray: CustomStringConvertible {
    public var description: String {
        return description([])
    }
    
    func description(_ indices: [Int]) -> String {
        func indent(_ x: Int) -> String {
            return String(repeating: " ", count: x)
        }
        
        // This function is called recursively for every dimension.
        // Add an entry for this dimension to the end of the array.
        var indices = indices + [0]
        
        let d = indices.count - 1          // the current dimension
        let N = shape[d]                   // how many elements in this dimension
        
        var s = "["
        if indices.count < shape.count {   // not last dimension yet?
            for i in 0..<N {
                indices[d] = i
                s += description(indices)      // then call recursively again
                if i != N - 1 {
                    s += ",\n" + indent(d + 1)
                }
            }
        } else {                           // the last dimension has actual data
            s += " "
            for i in 0..<N {
                indices[d] = i
                s += "\(self[indices])"
                if i != N - 1 {                // not last element?
                    s += ", "
                    if i % 11 == 10 {            // wrap long lines
                        s += "\n " + indent(d + 1)
                    }
                }
            }
            s += " "
        }
        return s + "]"
    }
}
