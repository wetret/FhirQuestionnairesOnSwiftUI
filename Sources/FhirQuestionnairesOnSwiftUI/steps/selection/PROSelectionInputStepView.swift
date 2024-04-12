import SwiftUI

internal struct PROSelectionInputStepView: View
{
    private let step: PROSelectionInputStep
    private let enableStateRecalculation: (() -> ())?
    private let nextCompleteButtonStateRecalculation: (() -> ())?

    @State private var answerValue: String
    private var viewInitialized: Bool = false
    
    internal init(step: PROSelectionInputStep, enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalculation: (() -> ())? = nil)
    {
        self.step = step
        self.enableStateRecalculation = enableStateRecalculation
        self.nextCompleteButtonStateRecalculation = nextCompleteButtonStateRecalculation
        
        self._answerValue = State(wrappedValue: (self.step.result.value ?? step.options.first!))
        self.viewInitialized = true
    }
    
    internal var body: some View
    {
        VStack(alignment: .leading)
        {
            PRODisplayStepView(step: step)
            
            HStack
            {
                Picker("", selection: $answerValue)
                {
                    ForEach(step.options, id: \.self)
                    { option in
                        Text(option)
                    }
                }
                .pickerStyle(.menu)
                .padding(.leading, -10)
                .padding(.top, -8)
                
                Spacer()
            }
        }
        .onChange(of: answerValue)
        {
            step.addResult(value: answerValue)
            
            // Do not change result value when init sets default view value
            if(viewInitialized)
            {
                if let recalculate = enableStateRecalculation
                {
                    recalculate()
                }
                
                if let recalculate = nextCompleteButtonStateRecalculation
                {
                    recalculate()
                }
            }
        }
    }
}

#Preview 
{
    PROSelectionInputStepView(step: PROSelectionInputStep.getPreviewObject())
}
