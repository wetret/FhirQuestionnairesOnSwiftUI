import Foundation

public struct PROBooleanCondition: PROSingleCondition
{
    public var stepId: String
    
    public typealias ValueType = Bool
    public var toCompare: ValueType
    
    public func getPredicate() -> NSPredicate
    {
        return NSPredicate(format: "result == %@", NSNumber(value: toCompare))
    }
}
