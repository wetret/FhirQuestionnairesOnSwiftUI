import SwiftUI

public protocol PROResult: Identifiable, NSCopying
{
    var id: String { get }
    
    associatedtype ValueType
    var value: ValueType? { get set }
}
