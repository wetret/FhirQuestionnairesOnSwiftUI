import SwiftUI

public class PROGroupStep: PROStep
{
    public var id: String
    public var title: String?
    public var text: String?
    
    public var sections: [any PROStep]
    
    public var titleFont: Font
    public var compactPresentation: Bool
    public var compactPresentationWithDisplayView: Bool
    
    public var required: Bool
    
    public var enabled: Bool
    public var enableConditions: [any PROCondition]
    
    public init(id: String, title: String? = nil, text: String? = nil, sections: [any PROStep], titleFont: Font = DEFAULT_TITLE_FONT, compactPresentation: Bool = false, compactPresentationWithDisplayView: Bool = false, required: Bool = false, enabled: Bool = true, enableConditions: [any PROCondition] = [])
    {
        self.id = id
        self.title = title
        self.text = text
        
        self.sections = sections
        
        self.titleFont = titleFont
        self.compactPresentation = compactPresentation
        self.compactPresentationWithDisplayView = compactPresentationWithDisplayView
        
        self.required = required
        
        self.enabled = enabled
        self.enableConditions = enableConditions
    }
    
    public func createView(enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalculation: (() -> ())? = nil) -> AnyView
    {
        return AnyView(PROGroupStepView(step: self, enableStateRecalculation: enableStateRecalculation, nextCompleteButtonStateRecalculation: nextCompleteButtonStateRecalculation))
    }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        var sectionsCopy: [any PROStep] = []
        for section in sections
        {
            sectionsCopy.append(section.copy(with: zone) as! (any PROStep))
        }
        
        return PROGroupStep(id: id, title: title, text: text, sections: sectionsCopy, titleFont: titleFont, compactPresentation: compactPresentation, enableConditions: enableConditions)
    }
    
    public func recalculateSectionEnableStates() -> [Bool]
    {
        return sections.compactMap
        {
            let enabled = $0.enableConditions.isEmpty || $0.enableConditions.compactMap{ $0.evaluate(steps: sections) }.filter{ $0 }.first ?? false
            
            $0.enabled = enabled
            return enabled
        }
    }
}

public extension PROGroupStep
{
    static func getPreviewObject() -> PROGroupStep
    {
        return PROGroupStep(id: "form.preview", title: nil, text: nil, sections: [
            PROTextInputStep.getPreviewObject(),
            PROTextInputStep.getPreviewObjectWithTitle(),
            PROTextInputStep.getPreviewObjectWithLongText(),
            PRODateTimeInputStep.getPreviewObject(),
            PROSelectionInputStep.getPreviewObject()
        ])
    }
    
    static func getPreviewObject2() -> PROGroupStep
    {
        return PROGroupStep(id: "form.preview-with-display-heading", title: PRODisplayStep.getPreviewObject2().title, text: PRODisplayStep.getPreviewObject2().text, sections: [
            PROTextInputStep.getPreviewObject(),
            PROTextInputStep.getPreviewObjectWithTitle(),
            PROTextInputStep.getPreviewObjectWithLongText(),
            PRODateTimeInputStep.getPreviewObject(),
            PRODisplayStep.getPreviewObjectWithText(),
            PROSelectionInputStep.getPreviewObject()
        ])
    }
    
    static func getPreviewObject3() -> PROGroupStep
    {
        return PROGroupStep(id: "form.preview-with-repeat", sections: [
            PROTextInputStep.getPreviewObjectWithShortText(),
            PRODateTimeInputStep.getPreviewObjectWithShortText(),
            PROSelectionInputStep.getPreviewObjectWithShortText()
        ], compactPresentation: true)
    }
    
    static func getPreviewObject4() -> PROGroupStep
    {
        return PROGroupStep(id: "form.preview-with-repeat", title: PRODisplayStep.getPreviewObject2().title, sections: [
            PROTextInputStep.getPreviewObjectWithShortText(),
            PRODateTimeInputStep.getPreviewObjectWithShortText(),
            PROSelectionInputStep.getPreviewObjectWithShortText()
        ])
    }
    
    static func getPreviewObject5() -> PROGroupStep
    {
        return PROGroupStep(id: "form.preview-with-repeat", text: PRODisplayStep.getPreviewObject2().text, sections: [
            PROTextInputStep.getPreviewObjectWithShortText(),
            PRODateTimeInputStep.getPreviewObjectWithShortText(),
            PROSelectionInputStep.getPreviewObjectWithShortText()
        ])
    }
}

