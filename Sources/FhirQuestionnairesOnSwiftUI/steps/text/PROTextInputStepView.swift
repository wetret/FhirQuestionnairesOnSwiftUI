import SwiftUI

internal struct PROTextInputStepView: View
{
    private let step: PROTextInputStep
    private let enableStateRecalculation: (() -> ())?
    private let nextCompleteButtonStateRecalculation: (() -> ())?
    
    @State private var answerValue: String
    private var viewInitialized: Bool = false
    
    internal init(step: PROTextInputStep, enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalucation: (() -> ())? = nil)
    {
        self.step = step
        self.enableStateRecalculation = enableStateRecalculation
        self.nextCompleteButtonStateRecalculation = nextCompleteButtonStateRecalucation
        
        self._answerValue = State(wrappedValue: self.step.result.value ?? "")
        self.viewInitialized = true
    }
    
    internal var body: some View
    {
        VStack(alignment: .leading)
        {
            PRODisplayStepView(step: step)
            
            TextField(step.placeholder, text: $answerValue, axis: .vertical)
                .foregroundColor(.blue)
                .lineLimit(getLineLimit())
                .disableAutocorrection(true)
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
        .onTapGesture
        {
            // remove focus from textfield if tapped on other area
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    private func getLineLimit() -> ClosedRange<Int>
    {
        return step.minLineLimit...step.maxLineLimit
    }
}

#Preview
{
    return PROTextInputStepView(step: PROTextInputStep.getPreviewObject())
}
