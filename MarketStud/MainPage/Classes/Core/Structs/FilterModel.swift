import Foundation

struct SearchFilter: Codable {
    var itemName: String? = nil
    var category: Category? = nil
    var location: Location? = nil
    var seller:   Int64? = nil
    
    private enum CodingKeys : String, CodingKey {
        case itemName = "item_name"
        case category, seller, location
    }
    
    func toQuery() -> String {
        var result = ""
        if itemName != nil { result += "itemName=\(itemName!)" }
        if category != nil && category!.id != -1 { result += "&categoryId=\(category!.id)" }
        if location != nil && location!.id != -1 { result += "&locationId=\(location!.id)" }
        if seller != nil { result += "&sellerId=\(seller!)" }
        return result
    }
    
    func jsonRepresentation() -> [String: Any] {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return [ : ]
            }
            
            return dictionary
        } catch {
            return [ : ]
        }
    }
}
