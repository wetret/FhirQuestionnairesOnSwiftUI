import SwiftUI

internal struct PRODisplayStepView: View
{
    private let step: any PROStep
    
    internal init(step: any PROStep)
    {
        self.step = step
    }
    
    internal var body: some View
    {
        VStack(alignment: .leading)
        {
            if let title = step.title
            {
                Text(title)
                    .font(step.titleFont)
                    .fontWeight(.bold)
                    .padding(.bottom, getPadding())
            }
            
            if let text = step.text
            {
                Text(text)
            }
        }
    }
    
    private func getPadding() -> CGFloat
    {
        if let _ = step.text
        {
            return 1
        }
        
        return 0
    }
}

#Preview 
{
    return PRODisplayStepView(step: PRODisplayStep.getPreviewObject2())
}
