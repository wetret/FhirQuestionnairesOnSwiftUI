import Foundation
import SwiftUI

public extension View
{
    func getBackground(for colorScheme: ColorScheme) -> Color
    {
        if (colorScheme == .dark)
        {
            return Color(UIColor.systemBackground)
        }
        else
        {
            return Color(.systemGray6)
        }
    }
    
    func getBackground(for step: any PROStep) -> Color
    {
        return Color(UIColor.systemGray6)
    }
}
