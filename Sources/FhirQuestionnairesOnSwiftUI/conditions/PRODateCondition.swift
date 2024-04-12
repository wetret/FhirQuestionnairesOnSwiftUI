import Foundation

public struct PRODateCondition: PROSingleCondition
{
    public var stepId: String
    public var comperator: Comperator
    
    public typealias ValueType = Date
    public var toCompare: ValueType
    
    public func getPredicate() -> NSPredicate
    {
        NSPredicate(format: "result \(comperator.rawValue) %@", toCompare as CVarArg)
    }
}
