import SwiftUI

internal struct PROGroupStepView: View
{
    private let step: PROGroupStep
    private let enableStateRecalculation: (() -> ())?
    private let nextCompleteButtonStateRecalculation: (() -> ())?
    
    @State private var sectionsEnableState: [Bool]
    @State private var enableStateRecalculationToggle = false
    
    internal init(step: PROGroupStep, enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalculation: (() -> ())? = nil)
    {
        self.step = step
        self.enableStateRecalculation = enableStateRecalculation
        self.nextCompleteButtonStateRecalculation = nextCompleteButtonStateRecalculation
        
        self.sectionsEnableState = step.recalculateSectionEnableStates()
    }
    
    internal var body: some View
    {
        VStack(alignment: .leading)
        {
            if (step.compactPresentation)
            {
                CompactContent
            }
            else
            {
                ExtendedContent
            }
        }
        .onChange(of: enableStateRecalculationToggle)
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
    
    @ViewBuilder
    private var CompactContent: some View
    {
        Section
        {
            if (hasDisplayHeader())
            {
                PRODisplayStepView(step: step)
                    .padding(.bottom, 5)
                
                Divider()
            }
            
            ForEach(0 ..< step.sections.count, id: \.self)
            { index in
                let section = step.sections[index]
                
                if(index < sectionsEnableState.count && sectionsEnableState[index])
                {
                    section.createView(
                        enableStateRecalculation:{ recalculateEnableStates() },
                        nextCompleteButtonStateRecalculation: nextCompleteButtonStateRecalculation
                    )
                    .padding(.top, ((!hasDisplayHeader() && index == 0) ? 0 : 5))
                    .padding(.bottom, 5)
                    
                    if (index < step.sections.count - 1 && index+1 < sectionsEnableState.count && sectionsEnableState[index+1])
                    {
                        Divider()
                    }
                }
            }
        }
        .labelsHidden()
    }
    
    private func hasDisplayHeader() -> Bool
    {
        return step.compactPresentationWithDisplayView && (step.title != nil || step.text != nil)
    }
    
    @ViewBuilder
    private var ExtendedContent: some View
    {
        List
        {
            if (step.title != nil || step.text != nil)
            {
                Section 
                {
                    PRODisplayStepView(step: step)
                        .listRowBackground(Color(.systemGray6))
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing:0))
                }
                .listSectionSpacing(10)
                .padding(.bottom, 10)
            }
            
            ForEach(0 ..< step.sections.count, id: \.self)
            { index in
                let section = step.sections[index]
                
                if ((index < sectionsEnableState.count) ? sectionsEnableState[index] : true)
                {
                    Section
                    {
                        section.createView(
                            enableStateRecalculation: { recalculateEnableStates() },
                            nextCompleteButtonStateRecalculation: nextCompleteButtonStateRecalculation
                        )
                        .padding(.vertical, 10)
                    }
                    .labelsHidden()
                }
            }
        }
        .listSectionSpacing(.compact)
        .padding(.top, -35)
        .padding(.horizontal, -17)
    }
    
    private func recalculateEnableStates()
    {
        sectionsEnableState = step.recalculateSectionEnableStates()
        // forces re-evaluation of parent group step enable states
        enableStateRecalculationToggle.toggle()
    }
}

#Preview 
{
    PROGroupStepView(step: PROGroupStep.getPreviewObject2())
}
