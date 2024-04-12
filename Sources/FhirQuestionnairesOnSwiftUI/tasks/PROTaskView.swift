import SwiftUI

public struct PROTaskView: View
{    
    @Binding private var task: PROTask
    @Binding private var isPresented: Bool
    
    @State private var navigationPath = NavigationPath()
    
    private let completeWith: (PROTask) -> ()
    private let cancelWith: (PROTask) -> ()
    
    public init(for task: PROTask, isPresented: Binding<Bool>, completeWith: @escaping (PROTask) -> () = { _ in return }, cancelWith: @escaping (PROTask) -> () = { _ in return })
    {
        self.init(for: .constant(task), isPresented: isPresented, completeWith: completeWith, cancelWith: cancelWith)
    }
    
    public init(for task: Binding<PROTask>, isPresented: Binding<Bool>, completeWith: @escaping (PROTask) -> () = { _ in return }, cancelWith: @escaping (PROTask) -> () = { _ in return })
    {
        self._task = task
        self._isPresented = isPresented
        self.completeWith = completeWith
        self.cancelWith = cancelWith
    }
    
    public var body: some View
    {
        NavigationStack(path: $navigationPath)
        {
            _PROTaskView(for: task, isPresented: $isPresented, completeWith: completeWith, cancelWith: cancelWith)
        }
    }
}

fileprivate struct _PROTaskView: View
{
    @Environment(\.dismiss) private var dismiss
    
    private let task: PROTask
    @Binding private var isPresented: Bool
    @State private var showNextStep: Bool = false
    
    @State private var buttonDisabled: Bool = true
    
    private let completeWith: (PROTask) -> ()
    private let cancelWith: (PROTask) -> ()
    
    fileprivate init(for task: PROTask, isPresented: Binding<Bool>, completeWith: @escaping (PROTask) -> (), cancelWith: @escaping (PROTask) -> ())
    {
        self.task = task
        self._isPresented = isPresented
        
        self.completeWith = completeWith
        self.cancelWith = cancelWith
    }
    
    fileprivate var body: some View
    {
        VStack(alignment: .leading)
        {
            task.currentStep().createView(nextCompleteButtonStateRecalculation: {
                buttonDisabled = task.isButtonDisabled()
            })
            
            Spacer()
            
            if(!task.isLastStep())
            {
                Button
                {
                    if (!task.cancel())
                    {
                        task.calculateNextIndex()
                        showNextStep = true
                    }
                    else
                    {
                        cancelWith(task)
                        dismissTask()
                    }
                }
                label:
                {
                    Text(String(localized: "next", bundle: Bundle.module))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
                .disabled(buttonDisabled)
            }
            else
            {
                Button
                {
                    task.completed = true
                    completeWith(task)
                    
                    dismissTask()
                }
                label:
                {
                    Text("complete", bundle: .module)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                 
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
                .disabled(buttonDisabled)
            }
        }
        .padding(.horizontal)
        .background(getBackground(for: task.currentStep()))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar
        {
            if(!task.isFirstStep())
            {
                ToolbarItem(placement: .topBarLeading)
                {
                    Button
                    {
                        task.calculatePreviousIndex()
                        dismiss()
                    }
                    label:
                    {
                        HStack
                        {
                            Image(systemName: "chevron.left")
                            Text(String(localized: "back", bundle: Bundle.module))
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .principal)
            {
                Text("\(String(localized: "step", bundle: Bundle.module)) \(task.displayIndex())/\(task.maxIndex())")
                    .foregroundColor(Color(.systemGray))
            }
            
            ToolbarItem(placement: .topBarTrailing)
            {
                Button(String(localized: "cancel", bundle: Bundle.module))
                {
                    dismissTask()
                }
            }
        }
        .toolbarBackground(getBackground(for: task.currentStep()), for: .bottomBar)
        .toolbarBackground(getBackground(for: task.currentStep()), for: .navigationBar)
        .navigationDestination(isPresented: $showNextStep)
        {
            _PROTaskView(for: task, isPresented: $isPresented, completeWith: completeWith, cancelWith: cancelWith)
        }
        .onAppear()
        {
            buttonDisabled = task.isButtonDisabled()
        }
    }
    
    private func dismissTask()
    {
        task.resetIndex()
        isPresented.toggle()
    }
}

#Preview 
{
    PROTaskView(for: .constant(PROTask.getPreviewObject2()), isPresented: .constant(true))
}
