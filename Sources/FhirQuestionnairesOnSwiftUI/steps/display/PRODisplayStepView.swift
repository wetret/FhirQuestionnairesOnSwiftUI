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
                    .padding(.bottom, 5)
            }
            
            if let text = step.text
            {
                Text(text)
                    .padding(.bottom, 5)
            }
        }
    }
}

#Preview 
{
    return PRODisplayStepView(step: PRODisplayStep.getPreviewObject2())
}
