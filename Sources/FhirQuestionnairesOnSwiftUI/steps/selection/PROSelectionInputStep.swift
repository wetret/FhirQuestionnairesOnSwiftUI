import SwiftUI

public class PROSelectionInputStep: PROStepWithResult
{
    public var id: String
    public var title: String?
    public var text: String?
    
    public var options: [String]
    
    public var required: Bool
    
    public typealias ResultType = PROTextResult
    public var result: ResultType
    
    public var titleFont: Font
    
    public var enabled: Bool
    public var enableConditions: [any PROCondition]
    
    public init(id: String, title: String? = nil, text: String? = nil, options: [String], titleFont: Font = DEFAULT_TITLE_FONT, required: Bool = false, enabled: Bool = true, enableConditions: [any PROCondition] = [])
    {
        self.id = id
        self.title = title
        self.text = text
    
        self.options = options
        
        self.required = required
        self.result = ResultType(id: id, value: nil)
        
        self.titleFont = titleFont
        
        self.enabled = enabled
        self.enableConditions = enableConditions
    }
    
    public func createView(enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalculation: (() -> ())? = nil) -> AnyView
    {
        return AnyView(PROSelectionInputStepView(step: self, enableStateRecalculation: enableStateRecalculation, nextCompleteButtonStateRecalculation: nextCompleteButtonStateRecalculation))
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = PROSelectionInputStep(id: id, title: title, text: text, options: options, titleFont: titleFont, enableConditions: enableConditions)
        copy.result = result.copy(with: zone) as! ResultType
        return copy
    }
}

public extension PROSelectionInputStep
{
    private static func getTitle() -> String
    {
        return "Lorem Ipsum"
    }
    
    private static func getShortTextText() -> String
    {
        return "Lorem ipsum dolor sit amet."
    }
    
    private static func getLongTextText() -> String
    {
        return "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
    }
    
    private static func getOptions() -> [String]
    {
        return ["Red", "Green", "Blue", "Tartan"]
    }
    
    static func getPreviewObject() -> PROSelectionInputStep
    {
        return PROSelectionInputStep(id: "selection.preview", title: getTitle(), text: getLongTextText(), options: getOptions(), enableConditions: [getPreviewObjectEnableAndCondition()])
    }
    
    static func getPreviewObjectWithTitle() -> PROSelectionInputStep
    {
        return PROSelectionInputStep(id: "selection.preview-with-title", title: getTitle(), options: getOptions())
    }
    
    static func getPreviewObjectWithShortText() -> PROSelectionInputStep
    {
        return PROSelectionInputStep(id: "selection.preview.preview-with-short-text", text: getShortTextText(), options: getOptions())
    }
    
    static func getPreviewObjectWithLongText() -> PROSelectionInputStep
    {
        return PROSelectionInputStep(id: "selection.preview.preview-with-long-text", text: getLongTextText(), options: getOptions())
    }
    
    static func getPreviewObjectCancelCondition() -> PROTextCondition
    {
        return PROTextCondition(stepId: "selection.preview", comperator: .equals, toCompare: "Green")
    }
    
    static func getPreviewObjectEnableAndCondition() -> PROAndCondition
    {
        return PROAndCondition(getPreviewObjectEnableAnd1Condition(), getPreviewObjectEnableAnd2Condition())
    }
    
    private static func getPreviewObjectEnableAnd1Condition() -> PROTextCondition
    {
        return PROTextCondition(stepId: "text.preview", comperator: .equals, toCompare: "Enable")
    }
    
    private static func getPreviewObjectEnableAnd2Condition() -> PRONumberCondition
    {
        return PRONumberCondition(stepId: "question.preview-int", comperator: .lessThan, toCompare: 5)
    }
}

