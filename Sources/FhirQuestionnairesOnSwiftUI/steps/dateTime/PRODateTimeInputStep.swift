import SwiftUI

public class PRODateTimeInputStep: PRODateTimeStep
{
    public var id: String
    public var title: String?
    public var text: String?
    
    public var required: Bool
    
    public typealias ResultType = PRODateResult
    public var result: ResultType
    
    public var titleFont: Font
    
    public var enabled: Bool
    public var enableConditions: [any PROCondition]
    
    public init(id: String, title: String? = nil, text: String? = nil, titleFont: Font = DEFAULT_TITLE_FONT, required: Bool = false, enbaled: Bool = true, enableConditions: [any PROCondition] = [])
    {
        self.id = id
        self.title = title
        self.text = text
        
        self.required = required
        self.result = ResultType(id: id, value: nil)
        
        self.titleFont = titleFont
        
        self.enabled = enbaled
        self.enableConditions = enableConditions
    }
    
    public func createView(enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalculation: (() -> ())? = nil) -> AnyView
    {
        return AnyView(PRODateTimeInputStepView(step: self, enableStateRecalculation: enableStateRecalculation, nextCompleteButtonStateRecalculation: nextCompleteButtonStateRecalculation))
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = PRODateTimeInputStep(id: id, title: title, text: text, titleFont: titleFont, enableConditions: enableConditions)
        copy.result = result.copy(with: zone) as! ResultType
        return copy
    }
}

public extension PRODateTimeInputStep
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
    
    static func getPreviewObject() -> PRODateTimeInputStep
    {
        return PRODateTimeInputStep(id: "dateTime.preview", title: getTitle(), text: getLongText(), enableConditions: [getPreviewObjectEnableOrCondition()])
    }
    
    static func getPreviewObjectWithTitle() -> PRODateTimeInputStep
    {
        return PRODateTimeInputStep(id: "dateTime.preview-with-title", title: getTitle())
    }
    
    static func getPreviewObjectWithShortText() -> PRODateTimeInputStep
    {
        return PRODateTimeInputStep(id: "dateTime.preview.preview-with-short-text", text: getShortText())
    }
    
    static func getPreviewObjectWithLongText() -> PRODateTimeInputStep
    {
        return PRODateTimeInputStep(id: "dateTime.preview.preview-with-long-text", text: getLongText())
    }
    
    static func getPreviewObjectEnableOrCondition() -> PROOrCondition
    {
        PROOrCondition(getPreviewObjectEnableOr1Condition(), getPreviewObjectEnableOr2Condition())
    }
    
    private static func getPreviewObjectEnableOr1Condition() -> PROTextCondition
    {
        return PROTextCondition(stepId: "text.preview", comperator: .equals, toCompare: "Enable3")
    }
    
    private static func getPreviewObjectEnableOr2Condition() -> PRONumberCondition
    {
        return PRONumberCondition(stepId: "question.preview-int", comperator: .lessThan, toCompare: 5)
    }
}

