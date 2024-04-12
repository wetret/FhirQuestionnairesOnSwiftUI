import Foundation
import ModelsR5

public extension PROTask
{
    func toQuestionnaireResponse() -> QuestionnaireResponse?
    {
        let url = getUrl()
        let status = getStatus()
        let items = getItems()
        
        return QuestionnaireResponse(item: items, questionnaire: url, status: status)
    }
    
    internal func parseStepResults(from questionnaireResponse: QuestionnaireResponse)
    {
        let steps = getSteps(expandGroupSteps: true)
        let items = questionnaireResponse.expandItems()
        
        setStatus(from: questionnaireResponse)
        setResults(steps: steps, results: items)
    }
    
    private func getUrl() -> FHIRPrimitive<Canonical>
    {
        return Canonical(URL(string: self.url)!, version: self.version).asPrimitive()
    }
    
    private func getStatus() -> FHIRPrimitive<QuestionnaireResponseStatus>
    {
        if (self.completed)
        {
            return QuestionnaireResponseStatus.completed.asPrimitive()
        }
        
        return QuestionnaireResponseStatus.inProgress.asPrimitive()
    }
    
    private func getItems() -> [QuestionnaireResponseItem]
    {
        var items: [QuestionnaireResponseItem] = []
        self.getSteps().forEach({ items.append(contentsOf: getItems(step: $0)) })
        return items
    }
    
    private func getItems(step: any PROStep) -> [QuestionnaireResponseItem]
    {
        let id = FHIRString(step.id).asPrimitive()
        
        var items: [QuestionnaireResponseItem]? = nil
        var answers: [QuestionnaireResponseItemAnswer]? = nil

        // display steps do not have items nor answers
        
        if let stepWithType = step as? PRORepeatStep
        {
            return stepWithType.result.value?.flatMap({ getItems(step: $0) }) ?? []
        }
        
        if let stepWithType = step as? PROTextInputStep
        {
            if let result = stepWithType.result.value
            {
                let answer = FHIRString(result).asPrimitive()
                let valueX = QuestionnaireResponseItemAnswer.ValueX.string(answer)
                answers = [QuestionnaireResponseItemAnswer(value: valueX)]
            }
        }
        
        if let stepWithType = step as? PRONumberInputStep
        {
            if let result = stepWithType.result.value
            {
                // TODO distinguish between integer and decimal
                let answer = FHIRDecimal(floatLiteral: result).asPrimitive()
                let valueX = QuestionnaireResponseItemAnswer.ValueX.decimal(answer)
                answers = [QuestionnaireResponseItemAnswer(value: valueX)]
            }
        }
        
        if let stepWithType = step as? PROBooleanInputStep
        {
            if let result = stepWithType.result.value
            {
                let answer = FHIRBool(result).asPrimitive()
                let valueX = QuestionnaireResponseItemAnswer.ValueX.boolean(answer)
                answers = [QuestionnaireResponseItemAnswer(value: valueX)]
            }
        }
        
        if let stepWithType = step as? PRODateTimeInputStep
        {
            if let result = stepWithType.result.value, let answer = try? DateTime(result.toIsoDateTimeString()).asPrimitive()
            {
                let valueX = QuestionnaireResponseItemAnswer.ValueX.dateTime(answer)
                answers = [QuestionnaireResponseItemAnswer(value: valueX)]
            }
        }
        
        if let stepWithType = step as? PRODateInputStep
        {
            if let result = stepWithType.result.value, let answer = try? FHIRDate(result.toIsoDateString()).asPrimitive()
            {
                let valueX = QuestionnaireResponseItemAnswer.ValueX.date(answer)
                answers = [QuestionnaireResponseItemAnswer(value: valueX)]
            }
        }
        
        if let stepWithType = step as? PROTimeInputStep
        {
            if let result = stepWithType.result.value, let answer = try? FHIRTime(result.toIsoTimeString()).asPrimitive()
            {
                let valueX = QuestionnaireResponseItemAnswer.ValueX.time(answer)
                answers = [QuestionnaireResponseItemAnswer(value: valueX)]
            }
        }
        
        if let stepWithType = step as? PROSelectionInputStep
        {
            if let result = stepWithType.result.value
            {
                let answer = FHIRString(result).asPrimitive()
                let valueX = QuestionnaireResponseItemAnswer.ValueX.string(answer)
                answers = [QuestionnaireResponseItemAnswer(value: valueX)]
            }
        }
        
        if let stepWithType = step as? PROGroupStep
        {
            items = stepWithType.sections.flatMap({ getItems(step: $0) })
        }
        
        return [QuestionnaireResponseItem(answer: answers, item: items, linkId: id)]
    }
    
    private func setStatus(from questionnaireResponse: QuestionnaireResponse)
    {
        if (questionnaireResponse.status.value == .completed)
        {
            self.completed = true
        }
    }
    
    private func setResults(steps: [any PROStep], results: [QuestionnaireResponseItem])
    {
        steps.compactMap({ $0 as? PRORepeatStep }).forEach({ $0.setResult(value: []) })
        steps.compactMap({ toPROStepWithResult(step: $0) }).forEach({ setResultFromItems(step: $0, results: results) })
    }
    
    private func toPROStepWithResult(step: any PROStep) -> (any PROStepWithResult)?
    {
        return step as? (any PROStepWithResult)
    }
    
    private func setResultFromItems(step: any PROStepWithResult, results: [QuestionnaireResponseItem])
    {
        results.filter({ idsMatch(step: step, result: $0) }).forEach({ setResultFromItem(step: step, result: $0) })
    }
    
    private func idsMatch(step: any PROStep, result: QuestionnaireResponseItem) -> Bool
    {
        return result.linkId.value?.string == step.id
    }
    
    private func setResultFromItem(step: any PROStepWithResult, result: QuestionnaireResponseItem)
    {
        if let stepTyped = step as? PRORepeatStep
        {
            let copy = stepTyped.repeatable.copy() as! any PROStep
            stepTyped.addResult(value: [copy])
            
            let subresults = result.expandItems()
            let substeps = copy.expand(expandGroupStep: true, expandRepeatStep: true)
            setResults(steps: substeps, results: subresults)
        }
        else
        {
            setResultFromAnswer(result: step.result, answer: result.answer?.first?.value)
        }
    }

    private func setResultFromAnswer(result: any PROResult, answer: QuestionnaireResponseItemAnswer.ValueX?)
    {
        switch(answer)
        {
        case .string(let value): // includes coding results
            if let typedResult = result as? PROTextResult
            {
                typedResult.value = value.value?.string
            }
        case .integer(let value):
            if let typedResult = result as? PRONumberResult
            {
                typedResult.value = Double(value.value!.integer)
            }
        case .decimal(let value):
            if let typedResult = result as? PRONumberResult
            {
                typedResult.value = NSDecimalNumber(decimal: value.value!.decimal).doubleValue
            }
        case .boolean(let value):
            if let typedResult = result as? PROBooleanResult
            {
                typedResult.value = value.value?.bool
            }
        case .dateTime(let value):
            if let typedResult = result as? PRODateResult, let date = value.value
            {
                typedResult.value = try? date.asNSDate()
            }
        case .date(let value):
            if let typedResult = result as? PRODateResult, let date = value.value
            {
                typedResult.value = try? date.asNSDate()
            }
        case .time(let value):
            if let typedResult = result as? PRODateResult, let time = value.value
            {
                typedResult.value = Date.fromIsoDateString("\(time.hour):\(time.minute):\(time.second)")!
            }
        default:
            break
        }
    }
}
