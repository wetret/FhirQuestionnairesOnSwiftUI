import Foundation
import ModelsR5

public extension Questionnaire
{
    static func from(json: String) -> Questionnaire?
    {
        if let data = json.data(using: .utf8)
        {
            return try? JSONDecoder().decode(Questionnaire.self, from: data)
        }
        
        return nil
    }
    
    func toTask() -> PROTask
    {
        let urlVersion = getTaskId()
        let title = getTaskTitle()
        let steps = getSteps(depth: 0)
        let cancelConditions = getCancelConditions()
        
        let urlVersionSplit = urlVersion.components(separatedBy: "|")
        let url = urlVersionSplit[0]
        let version = (urlVersionSplit.count > 1) ? urlVersionSplit[1] : nil
        
        return PROTask(id: urlVersion, url: url, version: version, title: title, steps: steps, cancelConditions: cancelConditions)
    }
    
    private func getTaskId() -> String
    {
        var id = "\(self.url!.value!.url)"
        
        if let version = self.version
        {
            id = "\(id)|\(version.value!.string)"
        }
        
        return id
    }
    
    private func getTaskTitle() -> String
    {
        return self.title!.value!.string
    }
    
    private func getSteps(depth: Int) -> [any PROStep]
    {
        return self.item?.compactMap({ getStep(from: $0, depth: depth) }) ?? []
    }
    
    private func getStep(from item: QuestionnaireItem, depth: Int) -> (any PROStep)?
    {
        let id = getStepId(from: item)
        
        let title = getExtensionStringValue(from: item, with: "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-title")
        let text = getStepText(from: item)
        
        let required = getRequired(from: item)
        
        let enableConditions = getEnableConditions(from: item)
        let enabled = enableConditions.isEmpty
        
        return getStep(item: item, id: id, title: title, text: text, required: required, enabled: enabled, enableConditions: enableConditions, depth: depth)
    }
    
    private func getStepId(from item: QuestionnaireItem) -> String
    {
        return item.linkId.value!.string
    }
    
    private func getStepText(from item: QuestionnaireItem) -> String?
    {
        return item.text?.value?.string
    }
    
    private func getRequired(from item: QuestionnaireItem) -> Bool
    {
        return item.required?.value?.bool ?? false
    }
    
    private func getEnableConditions(from item: QuestionnaireItem) -> [any PROCondition]
    {
        let conditions = item.enableWhen?.compactMap({ getEnableCondition(from: $0) }) ?? []
        
        if (conditions.count > 1)
        {
            if (item.enableBehavior! == EnableWhenBehavior.all)
            {
                return [PROAndCondition(conditions)]
            }
            
            if (item.enableBehavior! == EnableWhenBehavior.any)
            {
                let minTrueCount = getExtensionIntValue(from: item.enableBehavior!, with: "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/enableBehaviour/extension-any-count")
                return [PROOrCondition(with: minTrueCount, conditions)]
            }
        }
        
        return conditions
    }
    
    private func getEnableCondition(from enableWhen: QuestionnaireItemEnableWhen) -> (any PROCondition)?
    {
        let id = enableWhen.question.value!.string
        let comperator = enableWhen.operator.value!.toComerator()
        
        switch(enableWhen.answer)
        {
        case .string(let value):
            return PROTextCondition(stepId: id, comperator: comperator, toCompare: value.value!.string)
        case .integer(let value):
            return PRONumberCondition(stepId: id, comperator: comperator, toCompare: Double(value.value!.integer))
        case .decimal(let value):
            return PRONumberCondition(stepId: id, comperator: comperator, toCompare: NSDecimalNumber(decimal: value.value!.decimal).doubleValue)
        case .boolean(let value):
            return PROBooleanCondition(stepId: id, toCompare: value.value!.bool)
        case .dateTime(let value):
            let toCompare = (try? value.value!.asNSDate())!
            return PRODateCondition(stepId: id, comperator: comperator, toCompare: toCompare)
        case .date(let value):
            let toCompare = (try? value.value!.asNSDate())!
            return PRODateCondition(stepId: id, comperator: comperator, toCompare: toCompare)
        case .time(let value):
            let time = value.value!
            let toCompare = Date.fromIsoDateString("\(time.hour):\(time.minute):\(time.second)")!
            return PRODateCondition(stepId: id, comperator: comperator, toCompare: toCompare)
        case .coding(let value):
            return PROTextCondition(stepId: id, comperator: comperator, toCompare: value.code!.value!.string)
        default:
            return nil
        }
    }
    
    private func getStep(item: QuestionnaireItem, id: String, title: String?, text: String?, required: Bool, enabled: Bool, enableConditions: [any PROCondition], depth: Int) -> (any PROStep)?
    {
        var step: (any PROStep)? = nil
        let font = (depth > 0) ? PRODisplayStep.COMPACT_VIEW_TITLE_FONT : PRODisplayStep.DEFAULT_TITLE_FONT
        
        let type = item.type.value
        switch (type)
        {
        case .display:
            step = PRODisplayStep(id: id, title: title, text: text, titleFont: font, enabled: enabled, enableConditions: enableConditions)
        case .string, .text:
            let placeholder = getExtensionStringValue(from: item, with: "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-string-text-placeholder") ?? PROTextInputStep.DEFAULT_PLACEHOLDER
            let minLineLimit = getExtensionIntValue(from: item, with: "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-string-text-linelimit-min") ?? ((type == .string) ? PROTextInputStep.DEFAULT_MIN_LINE_LIMIT_STRING : PROTextInputStep.DEFAULT_MIN_LINE_LIMIT_TEXT)
            let maxLineLimit = getExtensionIntValue(from: item, with: "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-string-text-linelimit-max") ?? PROTextInputStep.DEFAULT_MAX_LINE_LIMIT
            step = PROTextInputStep(id: id, title: title, text: text, placeholder: placeholder, minLineLimit: minLineLimit, maxLineLimit: maxLineLimit, titleFont: font, required: required, enabled: enabled, enableConditions: enableConditions)
        case .integer, .decimal:
            let minValue = getExtensionDoubleValue(from: item, with: "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-integer-decimal-value-min")!
            let maxValue = getExtensionDoubleValue(from: item, with: "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-integer-decimal-value-max")!
            let stepSize = getExtensionDoubleValue(from: item, with: "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-integer-decimal-value-step-size")!
            let valueText = getExtensionStringValue(from: item, with: "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-integer-decimal-value-text")
            step = PRONumberInputStep(id: id, title: title, text: text, valueText: valueText, minValue: minValue, maxValue: maxValue, stepSize: stepSize, titleFont: font, required: required, enabled: enabled, enableConditions: enableConditions)
        case .boolean:
            step = PROBooleanInputStep(id: id, title: title, text: text, titleFont: font, required: required, enabled: enabled, enableConditions: enableConditions)
        case .dateTime:
            step = PRODateTimeInputStep(id: id, title: title, text: text, titleFont: font, required: required, enbaled: enabled, enableConditions: enableConditions)
        case .date:
            step = PRODateInputStep(id: id, title: title, text: text, titleFont: font, required: required, enabled: enabled, enableConditions: enableConditions)
        case .time:
            step = PROTimeInputStep(id: id, title: title, text: text, titleFont: font, required: required, enabled: enabled, enableConditions: enableConditions)
        case .coding:
            let options = getAnswerOptions(from: item)
            step = PROSelectionInputStep(id: id, title: title, text: text, options: options, titleFont: font, required: required, enabled: enabled, enableConditions: enableConditions)
        case .group:
            let compactPresentation = (item.repeats?.value?.bool ?? false) || depth > 0
            let compactPresentationWithDisplayView = depth > 0
            let sections = item.item?.compactMap({ getStep(from: $0, depth: depth + 1) }) ?? []
            step = PROGroupStep(id: id, title: title, text: text, sections: sections, titleFont: font, compactPresentation:  compactPresentation, compactPresentationWithDisplayView: compactPresentationWithDisplayView, required: required, enabled: enabled, enableConditions: enableConditions)
        default:
            return nil
        }
        
        if let repeats = item.repeats?.value?.bool, repeats == true
        {
            return PRORepeatStep(id: id, title: title, text: text, repeatable: step!, titleFont: font, compactPresentation: depth > 0, required: required,  enabled: enabled, enableConditions: enableConditions)
        }
        else
        {
            return step
        }
    }
    
    private func getAnswerOptions(from item: QuestionnaireItem) -> [String]
    {
        return item.answerOption?.compactMap({ answerOptionToString(from: $0.value) }) ?? []
    }
    
    private func answerOptionToString(from value: QuestionnaireItemAnswerOption.ValueX) -> String?
    {
        switch(value)
        {
        case .string(let value):
            if let string = value.value
            {
                return string.string
            }
        case .integer(let value):
            if let integer = value.value
            {
                return "\(integer.integer)"
            }
        case .date(let value):
            if let dateValue = value.value, let date = try? dateValue.asNSDate()
            {
                return date.toIsoDateString()
            }
        case .time(let value):
            if let time = value.value
            {
                return "\(time.hour):\(time.minute):\(time.second)"
            }
        case .coding(let value):
            if let code = value.code, let string = code.value
            {
                return string.string
            }
        default:
            return nil
        }
        
        return nil
    }
    
    private func getCancelConditions() -> [any PROCondition]
    {
        return self.extensions(for: "http://retwet.eu/fhir/StructureDefinition/questionnaire/extension-cancel-group").compactMap({ getCancelCondition(from: $0) })
    }
    
    private func getCancelCondition(from cancelGroup: Extension) -> (any PROCondition)?
    {
        let cancelWhens = cancelGroup.extensions(for: "http://retwet.eu/fhir/StructureDefinition/questionnaire/extension-cancel-group/cancel-when").compactMap({ doGetCancelCondition(from: $0) })
        
        if let cancelBehavior = cancelGroup.extensions(for: "http://retwet.eu/fhir/StructureDefinition/questionnaire/extension-cancel-group/cancel-behavior").first, let type = getExtensionStringValue(from: cancelBehavior, with: "http://retwet.eu/fhir/StructureDefinition/questionnaire/extension-cancel-group/cancel-behavior/type")
        {
            if (type == "all")
            {
                return PROAndCondition(cancelWhens)
            }
            
            if (type == "any")
            {
                if let anyCount = getExtensionIntValue(from: cancelBehavior, with: "http://retwet.eu/fhir/StructureDefinition/questionnaire/extension-cancel-group/cancel-behavior/any-count")
                {
                    return PROOrCondition(with: anyCount, cancelWhens)
                }
            }
        }
        
        return PROOrCondition(cancelWhens)
    }
    
    private func doGetCancelCondition(from cancelWhen: Extension) -> (any PROCondition)?
    {
        let id = getExtensionStringValue(from: cancelWhen, with: "http://retwet.eu/fhir/StructureDefinition/questionnaire/extension-cancel-group/cancel-when/question")!
        let comperator = QuestionnaireItemOperator(rawValue: getExtensionStringValue(from: cancelWhen, with: "http://retwet.eu/fhir/StructureDefinition/questionnaire/extension-cancel-group/cancel-when/operator")!)!.toComerator()
        let extensionValue = getExtension(from: cancelWhen, with: "http://retwet.eu/fhir/StructureDefinition/questionnaire/extension-cancel-group/cancel-when/answer")!.value
        
        switch(extensionValue)
        {
        case .string(let value):
            return PROTextCondition(stepId: id, comperator: comperator, toCompare: value.value!.string)
        case .integer(let value):
            return PRONumberCondition(stepId: id, comperator: comperator, toCompare: Double(value.value!.integer))
        case .decimal(let value):
            return PRONumberCondition(stepId: id, comperator: comperator, toCompare: NSDecimalNumber(decimal: value.value!.decimal).doubleValue)
        case .boolean(let value):
            return PROBooleanCondition(stepId: id, toCompare: value.value!.bool)
        case .dateTime(let value):
            let toCompare = (try? value.value!.asNSDate())!
            return PRODateCondition(stepId: id, comperator: comperator, toCompare: toCompare)
        case .date(let value):
            let toCompare = (try? value.value!.asNSDate())!
            return PRODateCondition(stepId: id, comperator: comperator, toCompare: toCompare)
        case .time(let value):
            let time = value.value!
            let toCompare = Date.fromIsoDateString("\(time.hour):\(time.minute):\(time.second)")!
            return PRODateCondition(stepId: id, comperator: comperator, toCompare: toCompare)
        case .coding(let value):
            return PROTextCondition(stepId: id, comperator: comperator, toCompare: value.code!.value!.string)
        default:
            return nil
        }
    }
    
    private func getExtension(from element: Element, with url: String) -> Extension?
    {
        return element.extensions(for: url).first
    }
    
    private func getExtensionStringValue(from element: Element, with url: String) -> String?
    {
        return element.extensions(for: url).compactMap
        {
            if case .string(let value) = $0.value
            {
                return value.value?.string
            }
            
            return nil
        }.first
    }
    
    private func getExtensionIntValue(from element: Element, with url: String) -> Int?
    {
        return getExtensionDoubleValue(from: element, with: url).map({ Int($0) })
    }
    
    private func getExtensionDoubleValue(from element: Element, with url: String) -> Double?
    {
        return element.extensions(for: url).compactMap
        {
            if case .integer(let value) = $0.value
            {
                if let integer = value.value?.integer
                {
                    return Double(integer)
                }
            }
            
            if case .decimal(let value) = $0.value
            {
                if let decimal = value.value?.decimal
                {
                    return NSDecimalNumber(decimal: decimal).doubleValue
                }
            }
            
            return nil
        }.first
    }
    
    private func getExtensionStringValue(from element: any FHIRPrimitiveProtocol, with url: String) -> String?
    {
        return element.extensions(for: url).compactMap
        {
            if case .string(let value) = $0.value
            {
                return value.value?.string
            }
            
            return nil
        }.first
    }
    
    private func getExtensionIntValue(from element: any FHIRPrimitiveProtocol, with url: String) -> Int?
    {
        return getExtensionDoubleValue(from: element, with: url).map({ Int($0) })
    }
    
    private func getExtensionDoubleValue(from element: any FHIRPrimitiveProtocol, with url: String) -> Double?
    {
        return element.extensions(for: url).compactMap
        {
            if case .integer(let value) = $0.value
            {
                if let integer = value.value?.integer
                {
                    return Double(integer)
                }
            }
            
            if case .decimal(let value) = $0.value
            {
                if let decimal = value.value?.decimal
                {
                    return NSDecimalNumber(decimal: decimal).doubleValue
                }
            }
            
            return nil
        }.first
    }
}

internal extension QuestionnaireItemOperator
{
    func toComerator() -> Comperator
    {
        switch (self)
        {
        case .equal, .exists:
            // QuestionnaireItemOperator.exists must be boolean
            // therefore return Comperator.equals
            return Comperator.equals
        case .notEqual:
            return Comperator.notEquals
        case .greaterThan:
            return Comperator.greaterThan
        case .greaterThanOrEqual:
            return Comperator.greaterOrEqualsThan
        case .lessThan:
            return Comperator.lessThan
        case .lessThanOrEqual:
            return Comperator.lessOrEqualsThan
        }
    }
}
