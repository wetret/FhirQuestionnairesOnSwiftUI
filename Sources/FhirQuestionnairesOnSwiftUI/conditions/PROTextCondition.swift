import Foundation

public struct PROTextCondition: PROSingleCondition
{
    public var stepId: String
    public var comperator: Comperator
    
    public typealias ValueType = String
    public var toCompare: ValueType
    
    public func getPredicate() -> NSPredicate
    {
        return NSPredicate(format: "result \(comperator.rawValue) %@", toCompare)
    }
}
