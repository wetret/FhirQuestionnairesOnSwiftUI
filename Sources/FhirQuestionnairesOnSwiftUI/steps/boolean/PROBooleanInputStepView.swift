import SwiftUI

internal struct PROBooleanInputStepView: View
{
    private let step: PROBooleanInputStep
    private let options = [Bool.YES, Bool.NO]
    private let enableStateRecalculation: (() -> ())?
    private let nextCompleteButtonStateRecalculation: (() -> ())?
    
    @State private var answerValue: String
    private var viewInitialized: Bool = false
    
    internal init(step: PROBooleanInputStep, enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStepRecalculation: (() -> ())? = nil)
    {
        UISegmentedControl.appearance().selectedSegmentTintColor = .tintColor
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
        
        self.step = step
        self.enableStateRecalculation = enableStateRecalculation
        self.nextCompleteButtonStateRecalculation = nextCompleteButtonStepRecalculation
        
        self._answerValue = State(wrappedValue: self.step.result.value?.asString ?? "")
        self.viewInitialized = true
    }
    
    internal var body: some View
    {
        VStack(alignment: .leading)
        {
            PRODisplayStepView(step: step)
         
            Picker("", selection: $answerValue)
            {
                ForEach(options, id: \.self)
                { option in
                    Text(option)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 250)

        }
        .onChange(of: answerValue)
        {
            if (Bool.YES == answerValue)
            {
                step.addResult(value: true)
            }
            
            if (Bool.NO == answerValue)
            {
                step.addResult(value: false)
            }
            
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
}

#Preview 
{
    PROBooleanInputStepView(step: PROBooleanInputStep.getPreviewObject())
}
