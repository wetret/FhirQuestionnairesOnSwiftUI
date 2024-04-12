import Foundation

public extension Bool
{
    static var YES: String
    {
        get { return String(localized: "yes", bundle: Bundle.module) }
    }
    
    static var NO: String
    {
        get { return String(localized: "no", bundle: Bundle.module) }
    }
    
    var asString: String
    {
        get
        {
            if (self == true) 
            {
                return Bool.YES
            }
            else 
            {
                return Bool.NO
            }
        }
    }
}
