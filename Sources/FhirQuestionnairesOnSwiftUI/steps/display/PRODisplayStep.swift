import SwiftUI

public class PRODisplayStep: PROStep
{
    public var id: String
    public var title: String?
    public var text: String?
    
    public var titleFont: Font
    
    public var required: Bool
    
    public var enabled: Bool
    public var enableConditions: [any PROCondition]
    
    public init(id: String, title: String? = nil, text: String? = nil, titleFont: Font = DEFAULT_TITLE_FONT, enabled: Bool = true, enableConditions: [any PROCondition] = [])
    {
        self.id = id
        self.title = title
        self.text = text
        
        self.titleFont = titleFont
        
        self.required = true
        
        self.enabled = enabled
        self.enableConditions = enableConditions
    }
    
    public func createView(enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalculation: (() -> ())? = nil) -> AnyView
    {
        return AnyView(PRODisplayStepView(step: self))
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        return PRODisplayStep(id: id, title: title, text: text, titleFont: titleFont, enableConditions: enableConditions)
    }
}

public extension PRODisplayStep
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
    
    static func getPreviewObject() -> PRODisplayStep
    {
        return PRODisplayStep(id: "instruction.preview", title: getTitle(), text: getShortText())
    }
    
    static func getPreviewObject2() -> PRODisplayStep
    {
        return PRODisplayStep(id: "instruction.preview", title: getTitle(), text: getLongText())
    }
    
    static func getPreviewObjectWithTitle() -> PRODisplayStep
    {
        return PRODisplayStep(id: "instruction.preview-with-title", title: getTitle())
    }
    
    static func getPreviewObjectWithText() -> PRODisplayStep
    {
        return PRODisplayStep(id: "instruction.preview-with-text", text: getLongText())
    }
}
