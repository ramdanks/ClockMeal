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

enum MealType: Int, Codable, CaseIterable
{
    case snack     = 0
    case breakfast = 1
    case lunch     = 2
    case dinner    = 3
}

struct MealData: Codable
{
    var type: MealType
    var time: TimeInterval
    var scheduled: Bool
    var issues: [MealRules.Issue]
    var date: Date
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
    enum Issue: Codable, CaseIterable { case skipSchedule, previousMeal, nextMeal }
    
    static let shortestIntervalToBreakfast: TimeInterval = 07 * 60 * 60
    static let longestIntervalToBreakfast: TimeInterval  = 14 * 60 * 60
    static let shortestIntervalToLunch: TimeInterval     = 04 * 60 * 60
    static let longestIntervalToLunch: TimeInterval      = 06 * 60 * 60
    static let shortestIntervalToDinner: TimeInterval    = 05 * 60 * 60
    static let longestIntervalToDinner: TimeInterval     = 07 * 60 * 60
    
    static func issues(collection: MealCollection, forType: MealType) -> [Issue]
    {
        var time: TimeInterval!
        if (forType == .breakfast) { time = collection.breakfastData.time }
        if (forType == .lunch) { time = collection.lunchData.time }
        if (forType == .dinner) { time = collection.dinnerData.time }
        return issues(collection: collection, forType: forType, forTime: time)
    }
    
    static func issues(collection: MealCollection, forType: MealType, forTime: TimeInterval) -> [Issue]
    {
        var prevScheduleLongest: TimeInterval!
        var prevScheduleShortest: TimeInterval!
        var nextScheduleLongest: TimeInterval!
        var nextScheduleShortest: TimeInterval!
        
        var currSchedule: MealData!
        var prevSchedule: MealData!
        var nextSchedule: MealData!
        
        if (forType == .breakfast)
        {
            currSchedule = collection.breakfastData
            prevSchedule = collection.dinnerData
            nextSchedule = collection.lunchData
            prevScheduleLongest = MealRules.longestIntervalToBreakfast
            prevScheduleShortest = MealRules.shortestIntervalToBreakfast
            nextScheduleLongest = MealRules.longestIntervalToLunch
            nextScheduleShortest = MealRules.shortestIntervalToLunch
        }
        else if (forType == .lunch)
        {
            currSchedule = collection.lunchData
            prevSchedule = collection.breakfastData
            nextSchedule = collection.dinnerData
            prevScheduleLongest = MealRules.longestIntervalToLunch
            prevScheduleShortest = MealRules.shortestIntervalToLunch
            nextScheduleLongest = MealRules.longestIntervalToDinner
            nextScheduleShortest = MealRules.shortestIntervalToDinner
        }
        else if (forType == .dinner)
        {
            currSchedule = collection.dinnerData
            prevSchedule = collection.lunchData
            nextSchedule = collection.breakfastData
            prevScheduleLongest = MealRules.longestIntervalToDinner
            prevScheduleShortest = MealRules.shortestIntervalToDinner
            nextScheduleLongest = MealRules.longestIntervalToBreakfast
            nextScheduleShortest = MealRules.shortestIntervalToBreakfast
        }
        
        let rangeFromPrev = prevSchedule.time.rangeCappedDaily(to: forTime)
        let rangeToNext = forTime.rangeCappedDaily(to: nextSchedule.time)
        
        var problems: [Issue] = []
        for problem in Issue.allCases
        {
            if (problem == .skipSchedule && currSchedule.scheduled) { continue }
            if (problem == .previousMeal && rangeFromPrev <= prevScheduleLongest && rangeFromPrev >= prevScheduleShortest) { continue }
            if (problem == .nextMeal && rangeToNext <= nextScheduleLongest && rangeToNext >= nextScheduleShortest) { continue }
            problems.append(problem)
        }
        return problems
    }
}
