import Foundation

struct MealData
{
    var time: TimeInterval!
    var skipped: Bool!
}

class MealRules
{
    static let shortestIntervalToBreakfast: TimeInterval = 07 * 60 * 60
    static let longestIntervalToBreakfast: TimeInterval  = 14 * 60 * 60
    static let shortestIntervalToLunch: TimeInterval     = 04 * 60 * 60
    static let longestIntervalToLunch: TimeInterval      = 06 * 60 * 60
    static let shortestIntervalToDinner: TimeInterval    = 05 * 60 * 60
    static let longestIntervalToDinner: TimeInterval     = 07 * 60 * 60
}
