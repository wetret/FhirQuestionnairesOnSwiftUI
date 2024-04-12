import Foundation

public struct PRONumberCondition: PROSingleCondition
{
    public var stepId: String
    public var comperator: Comperator
    
    public typealias ValueType = Double
    public var toCompare: ValueType
    
    public func getPredicate() -> NSPredicate
    {
        return NSPredicate(format: "result \(comperator.rawValue) %f", toCompare)
    }
}
