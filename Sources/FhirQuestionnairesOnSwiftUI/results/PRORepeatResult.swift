import Foundation

public class PRORepeatResult: PROResult
{
    public var id: String
    
    public typealias ValueType = [any PROStep]
    public var value: ValueType?
    
    public init(id: String, value: ValueType? = nil)
    {
        self.id = id
        self.value = value
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        return PRORepeatResult(id: id, value: value)
    }
}
