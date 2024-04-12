import Foundation
import SwiftUI
import ModelsR5

public class PROTask: ObservableObject, Identifiable, Hashable
{
    public let id: String
    public let url: String
    public let version: String?
    public let title: String
    
    @Published public var completed: Bool
    
    private let steps: [any PROStep]
    private let cancelConditions: [any PROCondition]
    
    private var index: Int
    
    public init(id: String, url: String, version: String? = nil, title: String, steps: [any PROStep], cancelConditions: [any PROCondition] = [], completed: Bool = false)
    {
        self.id = id
        self.url = url
        self.version = version
        self.title = title
            
        self.completed = completed
        
        self.steps = steps
        self.cancelConditions = cancelConditions
        
        self.index = 0
    }
    
    internal func currentStep() -> any PROStep
    {
        return steps[index]
    }
    
    internal func isFirstStep() -> Bool
    {
        return index == 0
    }
    
    internal func isLastStep() -> Bool
    {
        return displayIndex() >= maxIndex()
    }
    
    internal func currentIndex() -> Int
    {
        return index
    }
    
    internal func displayIndex() -> Int
    {
        return currentIndex() + 1
    }
    
    internal func maxIndex() -> Int
    {
        return steps.count
    }
    
    internal func isButtonDisabled() -> Bool
    {
        let step = currentStep()
        
        if let groupStep = step as? PROGroupStep
        {
            var groupDisabled = false
            var sectionsDisabled = false
            
            let resultSteps = groupStep.sections.filter({ $0.enabled }).flatMap({ $0.expand(expandGroupStep: true).compactMap({ $0 as? (any PROStepWithResult) }) })
            
            if (groupStep.required)
            {
                let hasResultsArray = resultSteps.map({ $0.hasResult() })
                groupDisabled = groupStep.enabled && hasResultsArray.allSatisfy({ $0 == false })
            }
            
            let requiredSections = resultSteps.filter({ $0.required && $0.enabled })
            if (requiredSections.isEmpty)
            {
                sectionsDisabled = false
            }
            else
            {
                sectionsDisabled = requiredSections.map({ $0.hasResult() }).contains(false)
            }
            
            return (groupDisabled || sectionsDisabled)
        }
        
        if let resultStep = step as? (any PROStepWithResult)
        {
            return resultStep.enabled && resultStep.required && !resultStep.hasResult()
        }
        
        return false
    }
    
    internal func calculateNextIndex()
    {
        repeat
        {
            index = index + 1
        }
        while (!isEnabled(step: steps[index]) || index == maxIndex())
    }
    
    internal func calculatePreviousIndex()
    {
        repeat
        {
            index = index - 1
        }
        while (index > 0 && !isEnabled(step: steps[index]))
    }
    
    internal func resetIndex()
    {
        index = 0
    }
    
    private func isEnabled(step: any PROStep) -> Bool
    {
        if step.enableConditions.isEmpty
        {
            step.enabled = true
            return true
        }
        
        let enabled = step.enableConditions.compactMap({ $0.evaluate(steps: steps) }).filter({ $0 }).first ?? false
        step.enabled = enabled
        
        return enabled
    }
    
    internal func cancel() -> Bool
    {
        let stepUntilCurrentStep = Array(steps[0...currentIndex()])
        return cancelConditions.compactMap({ $0.evaluate(steps: stepUntilCurrentStep) }).filter({ $0 }).first ?? false
    }
    
    internal func getSteps(expandGroupSteps: Bool = false, expandRepeatSteps: Bool = false) -> [any PROStep]
    {
        if (expandGroupSteps || expandRepeatSteps)
        {
            return steps.flatMap({ $0.expand(expandGroupStep: expandGroupSteps, expandRepeatStep: expandRepeatSteps) })
        }
        
        return steps
    }
    
    public func getResults() -> [any PROResult]
    {
        return steps.flatMap({ $0.expand(expandGroupStep: true, expandRepeatStep: true) }).compactMap({ $0 as? (any PROStepWithResult) }).compactMap({ $0.result })
    }
    
    public func saveResults(for owner: String)
    {
        guard let questionnaireResponse = self.toQuestionnaireResponse()?.toJson() else
        {
            // TODO handle unparsable task
            return
        }
        
        let result = PROResultModelWrapper(owner: owner, task: id, results: questionnaireResponse, completed: completed)
        PROPersistenceController.shared.save(result: result)
    }
    
    public func loadResults(for owner: String)
    {
        guard let proResultModel = PROPersistenceController.shared.load(for: owner, and: id) else
        {
            // TODO no response found
            return
        }
        
        guard let json = proResultModel.results, let questionnaireResponse = QuestionnaireResponse.from(json: json) else
        {
            // TODO empty result
            return
        }
        
        parseStepResults(from: questionnaireResponse)
    }
    
    public func deleteResults(for owner: String)
    {
        PROPersistenceController.shared.delete(for: owner, and: id)
    }
    
    public static func == (lhs: PROTask, rhs: PROTask) -> Bool 
    {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher)
    {
        return hasher.combine(id)
    }
}

public extension PROTask
{
    static func getPreviewObject() -> PROTask
    {
        return PROTask(
            id: "task-preview",
            url: "http://retwet.eu/fhir/Questionnaire/task-preview",
            version: "1.0",
            title: "Preview Task",
            steps: [
                PRODisplayStep.getPreviewObject2(),
                PROTextInputStep.getPreviewObject(),
                PRONumberInputStep.getPreviewObject(),
                PROSelectionInputStep.getPreviewObject(),
                PRODateTimeInputStep.getPreviewObject(),
                PRODateInputStep.getPreviewObject(),
                PROTimeInputStep.getPreviewObject(),
                PROBooleanInputStep.getPreviewObject(),
                PRORepeatStep.getPreviewObject3(),
                PROGroupStep.getPreviewObject(),
                PROGroupStep.getPreviewObject2(),
                PROTextInputStep.getPreviewObject()
            ],
            cancelConditions: [
                PROTextInputStep.getPreviewCancelCondition(),
                //PRONumberInputStep.getPreviewObjectCancelCondition(),
                PRODateInputStep.getPreviewObjectCancelCondition(),
                PROBooleanInputStep.getPreviewObjectCancelCondition(),
                PROSelectionInputStep.getPreviewObjectCancelCondition()
            ]
        )
    }
    
    static func getPreviewObject2() -> PROTask
    {
        let questionnaire = """
        {
            "resourceType": "Questionnaire",
            "id": "overview",
            "meta": {
                "profile": [
                    "http://retwet.eu/fhir/StructureDefinition/questionnaire|1.0.0"
                ]
            },
            "url": "http://retwet.eu/fhir/Questionnaire/task-preview",
            "version": "1.1",
            "title": "Übersicht",
            "status": "draft",
            "date": "2024-01-01",
            "extension": [
                {
                    "url": "http://retwet.eu/fhir/StructureDefinition/questionnaire/extension-cancel-group",
                    "extension": [
                        {
                            "url": "http://retwet.eu/fhir/StructureDefinition/questionnaire/extension-cancel-group/cancel-when",
                            "extension": [
                                {
                                    "url": "http://retwet.eu/fhir/StructureDefinition/questionnaire/extension-cancel-group/cancel-when/question",
                                    "valueString": "preview-4"
                                },
                                {
                                    "url": "http://retwet.eu/fhir/StructureDefinition/questionnaire/extension-cancel-group/cancel-when/operator",
                                    "valueString": ">="
                                },
                                {
                                    "url": "http://retwet.eu/fhir/StructureDefinition/questionnaire/extension-cancel-group/cancel-when/answer",
                                    "valueInteger": 18
                                }
                            ]
                        }
                    ]
                }
            ],
            "item": [
                {
                    "linkId": "preview-1",
                    "extension": [
                        {
                            "url": "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-title",
                            "valueString": "Welcome"
                        }
                    ],
                    "text": "Do you have allergies?",
                    "type": "boolean",
                    "required": true
                },
                {
                    "linkId": "preview-2",
                    "extension": [
                        {
                            "url": "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-title",
                            "valueString": "General Questions"
                        }
                    ],
                    "text": "Here are some general questions for you to answer in the beginning.",
                    "repeats": true,
                    "type": "group",
                    "required": false,
                    "item": [
                        {
                            "linkId": "2.1",
                            "text": "What is your gender?",
                            "type": "string"
                        },
                        {
                            "linkId": "2.2",
                            "text": "What is your date of birth?",
                            "type": "date"
                        },
                        {
                            "linkId": "2.3",
                            "text": "What is your country of birth?",
                            "type": "string"
                        },
                        {
                            "linkId": "2.4",
                            "text": "What is your marital status?",
                            "type": "string"
                        }
                    ],
                    "enableWhen": [
                        {
                            "question": "preview-1",
                            "operator": "=",
                            "answerBoolean": true
                        }
                    ]
                },
                {
                    "linkId": "preview-3",
                    "extension": [
                        {
                            "url": "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-title",
                            "valueString": "Intoxications"
                        }
                    ],
                    "type": "group",
                    "item": [
                        {
                            "linkId": "3.1",
                            "text": "Do you smoke?",
                            "type": "boolean"
                        },
                        {
                            "linkId": "3.2",
                            "text": "Do you drink alchohol?",
                            "type": "boolean"
                        }
                    ]
                },
                {
                    "linkId": "preview-4",
                    "text": "How old are you?",
                    "type": "integer",
                    "extension": [
                        {
                            "url": "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-integer-decimal-value-min",
                            "valueInteger": 0
                        },
                        {
                            "url": "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-integer-decimal-value-max",
                            "valueInteger": 120
                        },
                        {
                            "url": "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-integer-decimal-value-step-size",
                            "valueInteger": 1
                        }
                    ]
                },
                {
                    "linkId": "preview-5",
                    "text": "How tall are you in meters?",
                    "type": "decimal",
                    "extension": [
                        {
                            "url": "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-integer-decimal-value-min",
                            "valueDecimal": 0.8
                        },
                        {
                            "url": "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-integer-decimal-value-max",
                            "valueDecimal": 2.5
                        },
                        {
                            "url": "http://retwet.eu/fhir/StructureDefinition/questionnaire/item/extension-integer-decimal-value-step-size",
                            "valueDecimal": 0.01
                        }
                    ]
                }
            ]
        }
        """
        
        return Questionnaire.from(json: questionnaire)!.toTask()
    }
}

