import Foundation

public protocol PROCondition
{
    func evaluate(steps: [any PROStep]) -> Bool
}

public struct PROAndCondition: PROCondition
{
    private var conditions: [any PROCondition] = []
   
    public init(_ conditions: (any PROCondition)...)
    {
        self.init(conditions)
    }
    
    public init(_ conditions: [any PROCondition])
    {
        self.conditions.append(contentsOf: conditions)
    }
    
    public func evaluate(steps: [any PROStep]) -> Bool
    {
        return !conditions.compactMap{ $0.evaluate(steps: steps)}.contains(false)
    }
}

public struct PROOrCondition: PROCondition
{
    private var conditions: [any PROCondition] = []
    private var minTrueCount: Int
   
    public init(with minTrueCount: Int? = nil, _ conditions: (any PROCondition)...)
    {
        self.init(with: minTrueCount, conditions)
    }
    
    public init(with minTrueCount: Int? = nil, _ conditions: [any PROCondition])
    {
        self.minTrueCount = minTrueCount ?? 1
        self.conditions.append(contentsOf: conditions)
    }
    
    public func evaluate(steps: [any PROStep]) -> Bool
    {
        return conditions.compactMap{ $0.evaluate(steps: steps)}.filter{ $0 }.count >= minTrueCount
    }
}

public protocol PROSingleCondition: PROCondition
{
    var stepId: String { get }
    
    associatedtype ValueType
    var toCompare: ValueType { get }
    
    func getPredicate() -> NSPredicate
}

extension PROSingleCondition
{
    public func evaluate(steps: [any PROStep]) -> Bool
    {
        return steps.flatMap { toStepArray(step: $0) }
             .filter { $0.id == stepId }
             .compactMap { checkSameValueType($0) }
             // needed for predicate to work
             .compactMap { toResultWrapper(step: $0) }
             .compactMap { getPredicate().evaluate(with: $0) }
             .filter { $0 }
             .first ?? false
    }
    
    private func checkSameValueType(_ step: any PROStep) -> (any PROStepWithResult)?
    {
        if let step = step as? (any PROStepWithResult)
        {
            // TODO check type of toCompare equals step.result.value
            return step
        }
        
        return nil
    }
    
    private func toStepArray(step: any PROStep) -> [any PROStep]
    {
        if let step = step as? PROGroupStep
        {
            return step.sections.flatMap { toStepArray(step: $0) }
        }
        
        if let step = step as? PRORepeatStep
        {
            return step.result.value ?? []
        }
        
        return [step]
    }
    
    private func toResultWrapper(step: any PROStep) -> (any ResultWrapper)?
    {
        if let step = step as? PROTextInputStep, let value = step.result.value
        {
            return TextResultWrapper(with: value)
        }
        
        if let step = step as? PRONumberInputStep, let value = step.result.value
        {
            return NumberResultWrapper(with: value)
        }
        
        if let step = step as? PROBooleanInputStep, let value = step.result.value
        {
            return BooleanResultWrapper(with: value)
        }
        
        if let step = step as? PRODateTimeInputStep, let value = step.result.value
        {
            return DateResultWrapper(with: value)
        }
        
        if let step = step as? PRODateInputStep, let value = step.result.value
        {
            return DateResultWrapper(with: value)
        }
        
        if let step = step as? PRODateInputStep, let value = step.result.value
        {
            return DateResultWrapper(with: value)
        }
        
        if let step = step as? PROSelectionInputStep, let value = step.result.value
        {
            return TextResultWrapper(with: value)
        }
        
        return nil
    }
}

fileprivate protocol ResultWrapper: NSObject
{
    associatedtype ValueType
    var result: ValueType { get }
}

fileprivate class TextResultWrapper: NSObject, ResultWrapper
{
    typealias ValueType = String
    @objc var result: ValueType
    
    init(with result: String)
    {
        self.result = result
    }
}

fileprivate class NumberResultWrapper: NSObject, ResultWrapper
{
    typealias ValueType = Double
    @objc var result: ValueType
    
    init(with result: Double)
    {
        self.result = result
    }
}

fileprivate class BooleanResultWrapper: NSObject, ResultWrapper
{
    typealias ValueType = Bool
    @objc var result: ValueType
    
    init(with result: Bool)
    {
        self.result = result
    }
}

fileprivate class DateResultWrapper: NSObject, ResultWrapper
{
    typealias ValueType = Date
    @objc var result: ValueType
    
    init(with result: Date)
    {
        self.result = result
    }
}
