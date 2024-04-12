import SwiftUI

public class PROBooleanInputStep: PROStepWithResult
{
    public var id: String
    public var title: String?
    public var text: String?
    
    public let required: Bool
    
    public typealias ResultType = PROBooleanResult
    public var result: ResultType
    
    public var titleFont: Font
    
    public var enabled: Bool
    public var enableConditions: [any PROCondition]
    
    public init(id: String, title: String? = nil, text: String? = nil, titleFont: Font = DEFAULT_TITLE_FONT, required: Bool = false, enabled: Bool = true, enableConditions: [any PROCondition] = [])
    {
        self.id = id
        self.title = title
        self.text = text
        
        self.required = required
        self.result = ResultType(id: id, value: nil)
        
        self.titleFont = titleFont
        
        self.enabled = enabled
        self.enableConditions = enableConditions
    }
    
    public func createView(enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalculation: (() -> ())? = nil) -> AnyView
    {
        return AnyView(PROBooleanInputStepView(step: self, enableStateRecalculation: enableStateRecalculation, nextCompleteButtonStepRecalculation: nextCompleteButtonStateRecalculation))
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = PROBooleanInputStep(id: id, title: title, text: text, titleFont: titleFont, enableConditions: enableConditions)
        copy.result = result.copy(with: zone) as! ResultType
        return copy
    }
}

public extension PROBooleanInputStep
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
    
    static func getPreviewObject() -> PROBooleanInputStep
    {
        return PROBooleanInputStep(id: "boolean.preview", title: getTitle(), text: getLongText())
    }
    
    static func getPreviewObjectWithTitle() -> PROBooleanInputStep
    {
        return PROBooleanInputStep(id: "boolean.preview-with-title", title: getTitle())
    }
    
    static func getPreviewObjectWithShortText() -> PROBooleanInputStep
    {
        return PROBooleanInputStep(id: "boolean.preview-with-short-text", text: getShortText())
    }
    
    static func getPreviewObjectWithLongText() -> PROBooleanInputStep
    {
        return PROBooleanInputStep(id: "boolean.preview-with-long-text", text: getLongText())
    }
    
    static func getPreviewObjectCancelCondition() -> PROBooleanCondition
    {
        return PROBooleanCondition(stepId: "boolean.preview", toCompare: false)
    }
}

