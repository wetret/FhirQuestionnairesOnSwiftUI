import SwiftUI

internal struct PRODateTimeInputStepView: View
{
    private let step: any PRODateTimeStep
    private let displayedComponents: DatePickerComponents?
    private let enableStateRecalculation: (() -> ())?
    private let nextCompleteButtonStateRecalculation: (() -> ())?
    
    @State private var answerValue: Date
    private var viewInitialized: Bool = false
    
    internal init(step: some PRODateTimeStep, displayedComponents: DatePickerComponents? = nil, enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalculation: (() -> ())? = nil)
    {
        self.step = step
        self.displayedComponents = displayedComponents
        self.enableStateRecalculation = enableStateRecalculation
        self.nextCompleteButtonStateRecalculation = nextCompleteButtonStateRecalculation
        
        self._answerValue = State(wrappedValue: self.step.result.value ?? PRODateResult.DEFAULT_DATE)
        self.viewInitialized = true
    }
    
    internal var body: some View
    {
        VStack(alignment: .leading)
        {
            PRODisplayStepView(step: step)
            
            DateTimeContent
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
    
    @ViewBuilder
    private var DateTimeContent: some View
    {
        if let components = displayedComponents
        {
            DatePicker("", selection: $answerValue, displayedComponents: components)
                .labelsHidden()
        }
        else
        {
            DatePicker("", selection: $answerValue)
                .labelsHidden()
        }
    }
}

#Preview 
{
    PRODateTimeInputStepView(step: PRODateTimeInputStep.getPreviewObject())
}
