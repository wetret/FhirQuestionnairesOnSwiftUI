import Foundation
import ModelsR5

internal extension QuestionnaireResponse
{
    static func from(json: String) -> QuestionnaireResponse?
    {
        if let data = json.data(using: .utf8)
        {
            return try? JSONDecoder().decode(QuestionnaireResponse.self, from: data)
        }
        
        return nil
    }
    
    func toJson() -> String?
    {
        if let json = try? JSONEncoder().encode(self)
        {
            return String(data: json, encoding: .utf8)
        }
        
        return nil
    }
    
    func expandItems() -> [QuestionnaireResponseItem]
    {
        return item?.flatMap({ $0.expandItems() }) ?? []
    }
}

internal extension QuestionnaireResponseItem
{
    func expandItems() -> [QuestionnaireResponseItem]
    {
        var expandedItem = [self]
        let subitems = self.item?.flatMap({ $0.expandItems() }) ?? []
        expandedItem.append(contentsOf: subitems)
        
        return expandedItem
    }
}
