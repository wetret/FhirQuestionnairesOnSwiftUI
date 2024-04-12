import Foundation

public class PROBooleanResult: PROResult
{
    public var id: String
    
    public typealias ValueType = Bool
    public var value: ValueType?
    
    public init(id: String, value: ValueType? = nil)
    {
        self.id = id
        self.value = value
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        return PROBooleanResult(id: id, value: value)
    }
}
