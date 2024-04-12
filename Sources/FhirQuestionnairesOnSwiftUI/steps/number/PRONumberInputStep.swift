import SwiftUI

public class PRONumberInputStep: PROStepWithResult
{
    public var id: String
    public var title: String?
    public var text: String?
    
    public let valueText: String?
    
    public let minValue: Double
    public let maxValue: Double
    public let stepSize: Double
    
    public let required: Bool
    
    public typealias ResultType = PRONumberResult
    public var result: ResultType
    
    public var titleFont: Font
    
    public var enabled: Bool
    public var enableConditions: [any PROCondition]
    
    public init(id: String, title: String? = nil, text: String? = nil, valueText: String? = nil, minValue: Double, maxValue: Double, stepSize: Double = 1.0, titleFont: Font = DEFAULT_TITLE_FONT, required: Bool = false, enabled: Bool = true, enableConditions: [any PROCondition] = [])
    {
        self.id = id
        self.title = title
        self.text = text
        
        self.valueText = valueText
        
        self.minValue = minValue
        self.maxValue = maxValue
        self.stepSize = stepSize
        
        self.required = required
        self.result = ResultType(id: id, value: nil)
        
        self.titleFont = titleFont
        
        self.enabled = enabled
        self.enableConditions = enableConditions
    }
    
    public func createView(enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalculation: (() -> ())?) -> AnyView
    {
        return AnyView(PRONumberInputStepView(step: self, enableStateRecalculation: enableStateRecalculation, nextCompleteButtonStateRecalculation: nextCompleteButtonStateRecalculation))
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = PRONumberInputStep(id: id, title: title, text: text, valueText: valueText, minValue: minValue, maxValue: maxValue, stepSize: stepSize, titleFont: titleFont, enableConditions: enableConditions)
        copy.result = result.copy(with: zone) as! ResultType
        return copy
    }
}

public extension PRONumberInputStep
{
    private static func getTitle() -> String
    {
        return "Lorem Ipsum"
    }
    
    private static func getShortText() -> String
    {
        return "Lorem ipsum dolor sit amet."
    }
    
    private static func getLongText() -> String
    {
        return "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
    }
    
    static func getPreviewObject() -> PRONumberInputStep
    {
        return PRONumberInputStep(id: "question.preview-int", title: getTitle(), text: getLongText(), minValue: 0, maxValue: 100, stepSize: 1, enableConditions: [
            PRONumberInputStep.getPreviewObjectEnableCondition(), PRONumberInputStep.getPreviewObject2EnableCondition()
        ])
    }
    
    static func getPreviewObject2() -> PRONumberInputStep
    {
        return PRONumberInputStep(id: "question.preview-double", title: getTitle(), text: getLongText(), minValue: 0, maxValue: 10, stepSize: 0.01)
    }
    
    static func getPreviewObjectWithTitle() -> PRONumberInputStep
    {
        return PRONumberInputStep(id: "question.preview-with-title", title: getTitle(), minValue: 0, maxValue: 100, stepSize: 1)
    }
    
    static func getPreviewObjectWithShortText() -> PRONumberInputStep
    {
        return PRONumberInputStep(id: "question.preview-with-short-text", text: getShortText(), minValue: 0, maxValue: 100, stepSize: 0.1)
    }
    
    static func getPreviewObjectWithLongText() -> PRONumberInputStep
    {
        return PRONumberInputStep(id: "question.preview-with-long-text", text: getLongText(), minValue: 0, maxValue: 100, stepSize: 0.1)
    }
    
    static func getPreviewObjectCancelCondition() -> PRONumberCondition
    {
        return PRONumberCondition(stepId: "question.preview-double", comperator: .lessThan, toCompare: 5)
    }
    
    static func getPreviewObjectEnableCondition() -> PROTextCondition
    {
        return PROTextCondition(stepId: "text.preview", comperator: .equals, toCompare: "Enable")
    }
    
    static func getPreviewObject2EnableCondition() -> PROTextCondition
    {
        return PROTextCondition(stepId: "text.preview", comperator: .equals, toCompare: "Enable2")
    }
}
