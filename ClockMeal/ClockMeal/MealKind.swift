import Foundation

extension TimeInterval
{
    public func toString(_ format: String) -> String
    {
        let date = Date(timeIntervalSince1970: self)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: date)
    }
    
    /// assume that two TimeInterval is only capable of storing from 0 -> 24 * 60 * 60
    /// ex: interval between self: 23 * 60 * 60 to: 02 * 60 * 60 should be 03 * 60 * 60
    /// ex: interval between self: 06 * 60 * 60 to: 08 * 60 * 60 should be 02 * 60 * 60
    public func rangeCappedDaily(to: TimeInterval) -> TimeInterval
    {
        let capped: TimeInterval = 24 * 60 * 60
        let normalizedTo = to < self ? to + capped : to
        return normalizedTo - self
    }
}

enum MealType: Codable, CaseIterable
{
    case breakfast
    case lunch
    case dinner
    case snack
}

struct MealData: Codable
{
    var type: MealType
    var time: TimeInterval
    var skipped: Bool
}

struct MealCollection: Codable
{
    var breakfastData: MealData
    var lunchData: MealData
    var dinnerData: MealData
}

typealias MealSelection = (type: MealType, collection: MealCollection)

class MealRules
{
    typealias IntervalProblem = (prev: Bool, next: Bool)
    
    static let shortestIntervalToBreakfast: TimeInterval = 07 * 60 * 60
    static let longestIntervalToBreakfast: TimeInterval  = 14 * 60 * 60
    static let shortestIntervalToLunch: TimeInterval     = 04 * 60 * 60
    static let longestIntervalToLunch: TimeInterval      = 06 * 60 * 60
    static let shortestIntervalToDinner: TimeInterval    = 05 * 60 * 60
    static let longestIntervalToDinner: TimeInterval     = 07 * 60 * 60
    
    static func issue(collection: MealCollection, forType: MealType, forTime: TimeInterval) -> IntervalProblem
    {
        var prevScheduleLongest: TimeInterval!
        var prevScheduleShortest: TimeInterval!
        var nextScheduleLongest: TimeInterval!
        var nextScheduleShortest: TimeInterval!
        
        var prevSchedule: MealData!
        var nextSchedule: MealData!
        
        if (forType == .breakfast)
        {
            prevSchedule = collection.dinnerData
            nextSchedule = collection.lunchData
            prevScheduleLongest = MealRules.longestIntervalToBreakfast
            prevScheduleShortest = MealRules.shortestIntervalToBreakfast
            nextScheduleLongest = MealRules.longestIntervalToLunch
            nextScheduleShortest = MealRules.shortestIntervalToLunch
        }
        else if (forType == .lunch)
        {
            prevSchedule = collection.breakfastData
            nextSchedule = collection.dinnerData
            prevScheduleLongest = MealRules.longestIntervalToLunch
            prevScheduleShortest = MealRules.shortestIntervalToLunch
            nextScheduleLongest = MealRules.longestIntervalToDinner
            nextScheduleShortest = MealRules.shortestIntervalToDinner
        }
        else if (forType == .dinner)
        {
            prevSchedule = collection.lunchData
            nextSchedule = collection.breakfastData
            prevScheduleLongest = MealRules.longestIntervalToDinner
            prevScheduleShortest = MealRules.shortestIntervalToDinner
            nextScheduleLongest = MealRules.longestIntervalToBreakfast
            nextScheduleShortest = MealRules.shortestIntervalToBreakfast
        }
        
        let rangeFromPrev = prevSchedule.time.rangeCappedDaily(to: forTime)
        let rangeToNext = forTime.rangeCappedDaily(to: nextSchedule.time)
        
        let prevProblem = rangeFromPrev > prevScheduleLongest || rangeFromPrev < prevScheduleShortest
        let nextProblem = rangeToNext > nextScheduleLongest || rangeToNext < nextScheduleShortest
        
        return (prevProblem, nextProblem)
    }
    
    static func issueCount(data: MealData, collection: MealCollection) -> Int
    {
        var count: Int = 0
        if (data.skipped) { count += 1 }
        let timingIssue = issue(collection: collection, forType: data.type, forTime: data.time)
        if (timingIssue.prev) { count += 1 }
        if (timingIssue.next ) { count += 1 }
        return count
    }
}

func issueCountTotalSparta() -> Int
{
    let collection = Settings.mealDataCollection
    let a = MealRules.issueCount(data: collection.breakfastData, collection: collection)
    let b = MealRules.issueCount(data: collection.lunchData, collection: collection)
    let c = MealRules.issueCount(data: collection.dinnerData, collection: collection)
    return a + b + c
}
