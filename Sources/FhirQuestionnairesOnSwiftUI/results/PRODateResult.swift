import Foundation

public class PRODateResult: PROResult
{
    public var id: String
    
    public typealias ValueType = Date
    public var value: ValueType?
    
    public init(id: String, value: ValueType? = nil)
    {
        self.id = id
        self.value = value
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        return PRODateResult(id: id, value: value)
    }
}

public extension PRODateResult
{
    static var DEFAULT_DATE: ValueType { return Date.now }
}
