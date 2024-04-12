import Foundation

public class PRONumberResult: PROResult
{
    public var id: String
    
    public typealias ValueType = Double
    public var value: ValueType?
    
    public init(id: String, value: ValueType? = nil)
    {
        self.id = id
        self.value = value
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        return PRONumberResult(id: id, value: value)
    }
}
