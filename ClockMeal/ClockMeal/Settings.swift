import Foundation

@propertyWrapper
struct UserDefault<T: Codable>
{
    let key: String
    let defaultValue: T
    var wrappedValue: T
    {
        get
        {
            
            if let data = UserDefaults.standard.object(forKey: key) as? Data,
               let user = try? PropertyListDecoder().decode(T.self, from: data)
                { return user }
                return  defaultValue
        }
        set
        {
            if let encoded = try? PropertyListEncoder().encode(newValue)
                { UserDefaults.standard.set(encoded, forKey: key) }
        }
    }
}

struct Response: Codable
{
    var type: MealType
    var date: Date
    var skip: Bool
}

enum Settings
{
    @UserDefault(key: "0", defaultValue: MealCollection(
        breakfastData:  MealData(type: .breakfast,  time: 08 * 60 * 60, skipped: false),
        lunchData:      MealData(type: .lunch,      time: 13 * 60 * 60, skipped: false),
        dinnerData:     MealData(type: .dinner,     time: 19 * 60 * 60, skipped: false))
    )
    static var mealDataCollection: MealCollection
    
    @UserDefault(key: "1", defaultValue: nil)
    static var currentSession: MealType?
    
    @UserDefault(key: "2", defaultValue: [])
    static var responses: [Response]
}
