# FhirQuestionnairesOnSwiftUI

## Getting started: minimal SwiftUI example 

```swift
import SwiftUI
import ModelsR5
import FhirQuestionnairesOnSwiftUI

struct ContentView: View {
    let task = Questionnaire.from(json: PreviewJson.get())!.toTask()
    @State var isPresented = false
    
    var body: some View {
        VStack {
            Spacer()
            Button
            {
              isPresented = true
            }
            label:
            {
                Text("Show Questionnaire")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .sheet(isPresented: $isPresented)
        {
            PROTaskView(for: task, isPresented: $isPresented, completeWith:
            { task in
                // handle results
            })
            .edgesIgnoringSafeArea(.bottom)
            .interactiveDismissDisabled()
        }
    }
}

struct PreviewJson {
    static func get() -> String {
        return """
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
    }
}

#Preview {
    ContentView()
}
```