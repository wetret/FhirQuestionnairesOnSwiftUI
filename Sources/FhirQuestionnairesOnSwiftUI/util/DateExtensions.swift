import Foundation

public extension Date
{
    private static func DEFAULT_FORMATTER() -> DateFormatter
    {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return formatter
    }
    
    private static func DATE_TIME_FORMATTER() -> DateFormatter
    {
        let formatter = DEFAULT_FORMATTER()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
        
        return formatter
    }
    
    private static func TIME_FORMATTER() -> DateFormatter
    {
        let formatter = DEFAULT_FORMATTER()
        formatter.dateFormat = "HH:mm:ss.SSSXXX"
        
        return formatter
    }
    
    private static func DATE_FORMATTER() -> DateFormatter
    {
        let formatter = DEFAULT_FORMATTER()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }
    
    private static func DISPLAY_DATE_FORMATTER() -> DateFormatter
    {
        let formatter = DEFAULT_FORMATTER()
        formatter.dateFormat = "dd.MM.yyyy"
        
        return formatter
    }
    
    func toIsoDateTimeString() -> String
    {
        return Self.DATE_TIME_FORMATTER().string(from: self)
    }
    
    static func fromIsoDateTimeString(_ string: String) -> Date?
    {
        return Self.DATE_TIME_FORMATTER().date(from: string)
    }
    
    func toIsoDateString() -> String
    {
        return Self.DATE_FORMATTER().string(from: self)
    }
    
    func toDisplayDateString() -> String
    {
        return Self.DISPLAY_DATE_FORMATTER().string(from: self)
    }
    
    static func fromIsoDateString(_ string: String) -> Date?
    {
        return DATE_FORMATTER().date(from: string)
    }
    
    func toIsoTimeString() -> String
    {
        return Self.TIME_FORMATTER().string(from: self)
    }
    
    static func fromIsoTimeString(_ string: String) -> Date?
    {
        return Self.TIME_FORMATTER().date(from: string)
    }
}
