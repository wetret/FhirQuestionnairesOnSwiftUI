import SwiftUI

internal struct PRONumberInputStepView: View
{
    private let step: PRONumberInputStep
    private let enableStateRecalculation: (() -> ())?
    private let nextCompleteButtonStateRecalculation: (() -> ())?
    
    @State private var answerValue: Double
    private var viewInitialized: Bool = false
    
    internal init(step: PRONumberInputStep, enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalculation: (() -> ())? = nil)
    {
        self.step = step
        self.enableStateRecalculation = enableStateRecalculation
        self.nextCompleteButtonStateRecalculation = nextCompleteButtonStateRecalculation
        
        self._answerValue = State(wrappedValue: self.step.result.value ?? step.minValue)
        self.viewInitialized = true
    }
    
    internal var body: some View
    {
        VStack(alignment: .leading)
        {
            PRODisplayStepView(step: step)
            
            HStack
            {
                Text(step.valueText ?? "")
                
                Text(getValueText(answerValue))
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding(.top, 1)
            
            HStack
            {
                Slider(value: $answerValue, in: step.minValue...step.maxValue)
                
                Stepper("", value: $answerValue, in: step.minValue...step.maxValue, step: step.stepSize)
                    .labelsHidden()
            }
        }
        .onChange(of: answerValue)
        {
            step.addResult(value: answerValue)
            
            // Do not change result value when init sets default view value
            if (viewInitialized)
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
    
    private func getValueText(_ value: Double) -> String
    {
        let stepSize = String(step.stepSize)
        
        if let decimalPointIndex = stepSize.firstIndex(of: ".")
        {
            let decimalString = stepSize[stepSize.index(after: decimalPointIndex)..<stepSize.endIndex]
            
            let precision = decimalString == "0" ? 0 : decimalString.count
            
            
            return String(format: "%.\(precision)f", value)

        }
        else
        {
            return String(format: "%.0f", value)
        }
    }
}

#Preview
{
    PRONumberInputStepView(step: PRONumberInputStep.getPreviewObject())
}
