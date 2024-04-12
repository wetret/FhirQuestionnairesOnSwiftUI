import SwiftUI

public class PRODateInputStep: PRODateTimeStep
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
        return AnyView(PRODateTimeInputStepView(step: self, displayedComponents: .date, enableStateRecalculation: enableStateRecalculation, nextCompleteButtonStateRecalculation: nextCompleteButtonStateRecalculation))
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = PRODateInputStep(id: id, title: title, text: text, titleFont: titleFont, enableConditions: enableConditions)
        copy.result = result.copy(with: zone) as! ResultType
        return copy
    }
}

public extension PRODateInputStep
{
    private static func getTitle() -> String
    {
        return "Lorem Ipsum"
    }
    
    private static func getText() -> String
    {
        return "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
    }
    
    static func getPreviewObject() -> PRODateInputStep
    {
        return PRODateInputStep(id: "date.preview", title: getTitle(), text: getText())
    }
    
    static func getPreviewObjectWithTitle() -> PRODateInputStep
    {
        return PRODateInputStep(id: "date.preview-with-title", title: getTitle())
    }
    
    static func getPreviewObjectWithText() -> PRODateInputStep
    {
        return PRODateInputStep(id: "date.preview.preview-with-text", text: getText())
    }
    
    static func getPreviewObjectCancelCondition() -> PRODateCondition
    {
        return PRODateCondition(stepId: "date.preview", comperator: .greaterThan, toCompare: Date.now)
    }
}

