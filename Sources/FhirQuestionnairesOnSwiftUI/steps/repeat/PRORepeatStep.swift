import SwiftUI

public class PRORepeatStep: PROStepWithResult
{
    public var id: String
    public var title: String?
    public var text: String?
    
    public var repeatable: any PROStep
    
    public var required: Bool
    
    public typealias ResultType = PRORepeatResult
    public var result: ResultType
    
    public var titleFont: Font
    public var compactPresentation: Bool
    
    public var enabled: Bool
    public var enableConditions: [any PROCondition]
    
    public init(id: String, title: String? = nil, text: String? = nil, repeatable: any PROStep, titleFont: Font = DEFAULT_TITLE_FONT, compactPresentation: Bool = false, required: Bool = false, enabled: Bool = true, enableConditions: [any PROCondition] = [])
    {
        self.id = id
        self.title = title
        self.text = text
        
        self.repeatable = repeatable
        
        self.required = required
        self.result = ResultType(id: id, value: [])
        
        self.titleFont = titleFont
        self.compactPresentation = compactPresentation
        
        self.enabled = enabled
        self.enableConditions = enableConditions
    }
    
    public func addResult(value: [any PROStep])
    {
        result.value?.append(contentsOf: value)
    }
    
    public func setResult(value: [any PROStep])
    {
        result.value? = value
    }
    
    public func createView(enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalculation: (() -> ())? = nil) -> AnyView
    {
        return AnyView(PRORepeatStepView(step: self, enableStateRecalculation: enableStateRecalculation, nextCompleteButtonStateRecalculation: nextCompleteButtonStateRecalculation))
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let resultCopy = result.copy(with: zone) as! ResultType
        let repeatableCopy = repeatable.copy(with: zone) as! (any PROStep)
        
        let copy = PRORepeatStep(id: id, title: title, text: text, repeatable: repeatableCopy, titleFont: titleFont, enableConditions: enableConditions)
        copy.result = resultCopy
        return copy
    }
    
    internal func isButtonDisabled() -> Bool
    {
        if let groupStep = repeatable as? PROGroupStep
        {
            var groupDisabled = false
            var sectionsDisabled = false
            
            let resultSteps = groupStep.expand(expandGroupStep: true).compactMap({ $0 as? (any PROStepWithResult) })
            
            if (groupStep.required)
            {
                let hasResultsArray = resultSteps.map({ $0.hasResult() })
                groupDisabled = groupStep.enabled && hasResultsArray.allSatisfy({ $0 == false })
            }
            
            let requiredSections = resultSteps.filter({ $0.required && $0.enabled })
            if (requiredSections.isEmpty)
            {
                sectionsDisabled = false
            }
            else
            {
                sectionsDisabled = requiredSections.map({ $0.hasResult() }).contains(false)
            }
            
            return (groupDisabled || sectionsDisabled)
        }
        
        if let resultStep = repeatable as? (any PROStepWithResult)
        {
            return enabled && resultStep.required && !resultStep.hasResult()
        }
        
        return false
    }
}

public extension PRORepeatStep
{
    private static func getTitle() -> String
    {
        return "Lorem Ipsum"
    }
    
    private static func getShortText() -> String
    {
        return "Lorem ipsum dolor sit amet, consetetur sadipscing elitr."
    }
    
    private static func getLongText() -> String
    {
        return "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
    }
    
    static func getPreviewObject() -> PRORepeatStep
    {
        return PRORepeatStep(id: "repeat.preview-text-input", title: nil, text: nil, repeatable: PROTextInputStep.getPreviewObject())
    }
    
    static func getPreviewObject2() -> PRORepeatStep
    {
        return PRORepeatStep(id: "repeat.preview-number-input", title: nil, text: nil, repeatable: PRONumberInputStep.getPreviewObject())
    }
    
    static func getPreviewObject3() -> PRORepeatStep
    {
        return PRORepeatStep(id: "repeat.preview-group-input", title: getTitle(), text: getLongText(), repeatable: PROGroupStep.getPreviewObject3(), enableConditions: [getPreviewObjectEnableOrCondition()])
    }
    
    static func getPreviewObject4() -> PRORepeatStep
    {
        return PRORepeatStep(id: "repeat.preview-group-input-no-text", title: getTitle(), text: nil, repeatable: PROGroupStep.getPreviewObject3(), enableConditions: [getPreviewObjectEnableOrCondition()])
    }
    
    static func getPreviewObjectEnableOrCondition() -> PROOrCondition
    {
        return PROOrCondition(getPreviewObjectEnableOr1Condition(), getPreviewObjectEnableOr2Condition())
    }
    
    static func getPreviewObjectEnableOr1Condition() -> PROBooleanCondition
    {
        return PROBooleanCondition(stepId: "boolean.preview", toCompare: true)
    }
    
    static func getPreviewObjectEnableOr2Condition() -> PROAndCondition
    {
        return PROAndCondition(getPreviewObjectEnableAnd1Condition(), getPreviewObjectEnableAnd2Condition())
    }
    
    private static func getPreviewObjectEnableAnd1Condition() -> PRODateCondition
    {
        return PRODateCondition(stepId: "date.preview", comperator: .greaterOrEqualsThan, toCompare: Date.fromIsoDateString("2023-12-01")!)
    }
    
    private static func getPreviewObjectEnableAnd2Condition() -> PRODateCondition
    {
        return PRODateCondition(stepId: "time.preview", comperator: .greaterThan, toCompare: Date.fromIsoTimeString("12:00:00.000Z")!)
    }
}

