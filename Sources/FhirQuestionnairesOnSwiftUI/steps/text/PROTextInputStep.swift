import SwiftUI

public class PROTextInputStep: PROStepWithResult
{
    public static let DEFAULT_PLACEHOLDER = String(localized: "placeholder", bundle: Bundle.module)
    public static let DEFAULT_MIN_LINE_LIMIT_STRING = 1
    public static let DEFAULT_MIN_LINE_LIMIT_TEXT = 2
    public static let DEFAULT_MAX_LINE_LIMIT = 5
    
    public var id: String
    public var title: String?
    public var text: String?
    
    public var placeholder: String
    
    public let minLineLimit: Int
    public let maxLineLimit: Int
    
    public let required: Bool
    
    public typealias ResultType = PROTextResult
    public var result: ResultType
    
    public var titleFont: Font
    
    public var enabled: Bool
    public var enableConditions: [any PROCondition]
    
    public init(id: String, title: String? = nil, text: String? = nil, placeholder: String = DEFAULT_PLACEHOLDER, minLineLimit: Int = DEFAULT_MIN_LINE_LIMIT_STRING, maxLineLimit: Int = DEFAULT_MAX_LINE_LIMIT, titleFont: Font = DEFAULT_TITLE_FONT, required: Bool = false, enabled: Bool = true, enableConditions: [any PROCondition] = [])
    {
        self.id = id
        self.title = title
        self.text = text
        
        self.placeholder = placeholder
        
        self.minLineLimit = minLineLimit
        self.maxLineLimit = maxLineLimit
        
        self.required = required
        self.result = ResultType(id: id, value: nil)
        
        self.titleFont = titleFont
        
        self.enabled = enabled
        self.enableConditions = enableConditions
    }
    
    public func createView(enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalculation: (() -> ())? = nil) -> AnyView
    {
        return AnyView(PROTextInputStepView(step: self, enableStateRecalculation: enableStateRecalculation, nextCompleteButtonStateRecalucation: nextCompleteButtonStateRecalculation))
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = PROTextInputStep(id: id, title: title, text: text, placeholder: placeholder, minLineLimit: minLineLimit, maxLineLimit: maxLineLimit, titleFont: titleFont, enableConditions: enableConditions)
        copy.result = result.copy(with: zone) as! PROTextResult
        return copy
    }
}

public extension PROTextInputStep
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
    
    static func getPreviewObject() -> PROTextInputStep
    {
        return PROTextInputStep(id: "text.preview", title: getTitle(), text: getLongText())
    }
    
    static func getPreviewObjectWithTitle() -> PROTextInputStep
    {
        return PROTextInputStep(id: "text.preview-with-title", title: getTitle())
    }
    
    static func getPreviewObjectWithShortText() -> PROTextInputStep
    {
        return PROTextInputStep(id: "text.preview-with-short-text", text: getShortText())
    }
    
    static func getPreviewObjectWithLongText() -> PROTextInputStep
    {
        return PROTextInputStep(id: "text.preview-with-text", text: getLongText())
    }
    
    static func getPreviewCancelCondition() -> PROTextCondition
    {
        return PROTextCondition(stepId: "text.preview", comperator: .equals, toCompare: "Terminate")
    }
}
