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
            {
                return user
            }
            return defaultValue
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
    static var mealDataCollectionDefault = MealCollection(
        breakfastData:  MealData(type: .breakfast,  time: 08 * 60 * 60, scheduled: true, issues: [], date: Date()),
        lunchData:      MealData(type: .lunch,      time: 13 * 60 * 60, scheduled: true, issues: [], date: Date()),
        dinnerData:     MealData(type: .dinner,     time: 19 * 60 * 60, scheduled: true, issues: [], date: Date())
    )
    
    @UserDefault<MealCollection>(key: "0", defaultValue: mealDataCollectionDefault)
    static var mealDataCollection
    
    @UserDefault<[Response]>(key: "1", defaultValue: [])
    static var responses
    
    @UserDefault<MealCollection>(key: "2", defaultValue: mealDataCollectionDefault)
    static var upcomingSchedule
    
    @UserDefault<Date>(key: "3", defaultValue: Date())
    static var lastLogin
}
