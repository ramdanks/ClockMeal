import Foundation

class Settings
{
    enum Key
    {
        case breakfastMealData
        case lunchMealData
        case dinnerMealData
    }
    
    static public func set(_ key: Key, _ value: Any?) -> Void
    {
        UserDefaults.standard.set(value, forKey: "\(key)")
    }
    
    static public func get(_ key: Key) -> Any?
    {
        let value = UserDefaults.standard.object(forKey: "\(key)")
        if (value != nil) { return value }
        /// default value for user settings
        if (key == .breakfastMealData) { return MealData(time: 08 * 60 * 60, skipped: false) }
        if (key == .lunchMealData)     { return MealData(time: 13 * 60 * 60, skipped: false) }
        if (key == .dinnerMealData)    { return MealData(time: 19 * 60 * 60, skipped: false) }
        return nil
    }
}
