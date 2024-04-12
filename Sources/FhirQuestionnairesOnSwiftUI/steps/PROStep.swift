import SwiftUI

public protocol PROStep: Identifiable, NSCopying
{
    var id: String { get }
    var title: String? { get }
    var text: String? { get }
    
    var required: Bool { get }
    
    var enabled: Bool { get set }
    var enableConditions: [any PROCondition] { get }
    
    var titleFont: Font { get set }
    
    func createView(enableStateRecalculation: (() -> ())?, nextCompleteButtonStateRecalculation: (() -> ())?) -> AnyView
}

public extension PROStep
{
    func createView(enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalculation: (() -> ())? = nil) -> AnyView
    {
        return createView(enableStateRecalculation: nil, nextCompleteButtonStateRecalculation: nextCompleteButtonStateRecalculation)
    }
    
    internal func expand(expandGroupStep: Bool = false, expandRepeatStep: Bool = false) -> [any PROStep]
    {
        if let step = self as? PROGroupStep, expandGroupStep == true
        {
            return step.sections.flatMap({ $0.expand(expandGroupStep: expandGroupStep, expandRepeatStep: expandRepeatStep) })
        }
        
        if let step = self as? PRORepeatStep, expandRepeatStep == true
        {
            return step.result.value ?? []
        }
        
        return [self]
    }
}

public extension PROStep
{
    static var DEFAULT_TITLE_FONT: Font { return .title2 }
    static var COMPACT_VIEW_TITLE_FONT: Font { return .headline }
}

public protocol PROStepWithResult: PROStep
{
    associatedtype ResultType: PROResult
    var result: ResultType { get }
 
    associatedtype ValueType
    func addResult(value: ValueType)
    
    func hasResult() -> Bool
}

public extension PROStepWithResult
{
    func addResult(value: ResultType.ValueType)
    {
        result.value = value
    }
    
    func hasResult() -> Bool
    {
        if let repeatStep = self as? PRORepeatStep
        {
            return !(repeatStep.result.value?.isEmpty ?? true)
        }
        
        return result.value != nil
    }
}
