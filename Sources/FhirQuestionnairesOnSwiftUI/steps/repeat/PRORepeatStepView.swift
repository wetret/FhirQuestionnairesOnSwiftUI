import SwiftUI

internal struct PRORepeatStepView: View
{
    private let step: PRORepeatStep
    private let enableStateRecalculation: (() -> ())?
    private let nextCompleteButtonStateRecalculation: (() -> ())?
    
    @State private var answerSteps: [any PROStep] = []
    @State private var addButtonDisbaled: Bool = true
    
    internal init(step: PRORepeatStep, enableStateRecalculation: (() -> ())? = nil, nextCompleteButtonStateRecalculation: (() -> ())? = nil)
    {
        self.step = step
        self._answerSteps = State(wrappedValue: self.step.result.value ?? [])
        
        self.enableStateRecalculation = enableStateRecalculation
        self.nextCompleteButtonStateRecalculation = nextCompleteButtonStateRecalculation
    }
    
    internal var body: some View
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
    
    @ViewBuilder
    private var CompactContent: some View
    {
        Section
        {
            Section
            {
                RepeatInputContent
            }
            
            ForEach(0..<answerSteps.count, id: \.self)
            { index in
                RepeatInputDetailContent(index: index)
            }
            .onDelete(perform: deleteResult)
        }
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
                .listSectionSpacing(getListSectionSpacing())
                .padding(.bottom, getPadding())
            }
            
            Section
            {
                RepeatInputContent
            }
            
            ForEach(0..<answerSteps.count, id: \.self)
            { index in
                RepeatInputDetailContent(index: index)
            }
            .onDelete(perform: deleteResult)
        }
        .listSectionSpacing(.compact)
        .padding(.top, getListPadding())
        .padding(.horizontal, -17)
    }
    
    @ViewBuilder
    private var RepeatInputContent: some View
    {
        VStack(alignment: .leading)
        {
            step.repeatable.createView(
                enableStateRecalculation: enableStateRecalculation,
                nextCompleteButtonStateRecalculation: {
                    addButtonDisbaled = step.isButtonDisabled()
                }
            )
            
            Divider()
            
            Button
            {
                let copy = step.repeatable.copy() as! (any PROStep)
                answerSteps.append(copy)
                step.addResult(value: [copy])
                
                if let recalculate = enableStateRecalculation
                {
                    recalculate()
                }
                
                if let recalculate = nextCompleteButtonStateRecalculation
                {
                    recalculate()
                }
            }
            label:
            {
                Text(String(localized: "add", bundle: Bundle.module))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(addButtonDisbaled)
            .padding(.top, 5)
        }
        .onAppear()
        {
            addButtonDisbaled = step.isButtonDisabled()
        }
    }
    
    @ViewBuilder
    private func RepeatInputDetailContent(index: Int) -> some View
    {
        Section
        {
            NavigationLink
            {
                VStack(alignment: .leading)
                {
                    List
                    {
                        if (step.title != nil || step.text != nil)
                        {
                            PRODisplayStepView(step: getStepWithResetTitle(answerSteps[index]))
                                .listRowBackground(Color(.systemGray6))
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing:0))
                        }
                    
                        Section
                        {
                            answerSteps[index].createView()
                        }
                        .listSectionSpacing(getListSectionSpacing())
                    }
                    .listSectionSpacing(.compact)
                    .padding(.top, getListPadding() - 3)
                }
            }
            label:
            {
                Text(String(localized: "answer", bundle: Bundle.module) + " \(index+1)")
            }
        }
    }
    
    private func deleteResult(at offsets: IndexSet)
    {
        answerSteps.remove(atOffsets: offsets)
        step.result.value?.remove(atOffsets: offsets)
        
        addButtonDisbaled = step.isButtonDisabled()
        
        if let recalculate = nextCompleteButtonStateRecalculation
        {
            recalculate()
        }
    }
    
    private func getStepWithResetTitle(_ step: any PROStep) -> any PROStep
    {
        step.titleFont = PRODisplayStep.DEFAULT_TITLE_FONT
        return step
    }
    
    private func getPadding() -> CGFloat
    {
        if let _ = step.text
        {
            return 10
        }
        
        return 5
    }
    
    private func getListSectionSpacing() -> CGFloat
    {
        if let title = step.title
        {
            if let _ = step.text
            {
                return 0
            }
            
            let font = UIFont.boldSystemFont(ofSize: 24)
            let size = title.widthWithConstrainedHeight(16, font: font) + 10
            
            if (size > UIScreen.SCREEN_WIDTH)
            {
                return 10
            }
            
            return -5
            
        }
        
        return 0
    }
    
    private func getListPadding() -> CGFloat
    {
        if let title = step.title, step.text == nil
        {
            let font = UIFont.boldSystemFont(ofSize: 24)
            let size = title.widthWithConstrainedHeight(16, font: font) + 10
            
            if (size < UIScreen.SCREEN_WIDTH)
            {
                return -42
            }
        }
        
        return -35
    }
}

#Preview 
{
    PRORepeatStepView(step: PRORepeatStep.getPreviewObject4())
}
