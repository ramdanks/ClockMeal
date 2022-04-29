import UIKit

class ScheduleViewController: UIViewController
{
    @IBOutlet weak var breakfastCard: ScheduleCardControl!
    @IBOutlet weak var lunchCard: ScheduleCardControl!
    @IBOutlet weak var dinnerCard: ScheduleCardControl!
    
    private var selectedCard: ScheduleCardControl!
    
    private var mealCollection: MealCollection! { didSet {
        breakfastCard.data  = mealCollection.breakfastData
        lunchCard.data      = mealCollection.lunchData
        dinnerCard.data     = mealCollection.dinnerData
    }}
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mealCollection = Settings.mealDataCollection
        refresh()
    }
    
    @IBAction func onScheduleCardButton(_ sender: ScheduleCardControl)
    {
        selectedCard = sender
        performSegue(withIdentifier: SegueIdentifier.mealDetail, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == SegueIdentifier.mealDetail)
        {
            guard let destinationVC = segue.destination as? MealDetailViewController
            else { return }
            destinationVC.collection = mealCollection
            destinationVC.type = selectedCard.data.type
            destinationVC.imageShowcase = selectedCard.image
        }
    }
    
    func refresh()
    {
        let bIssueCount = MealRules.issueCount(data: mealCollection.breakfastData, collection: mealCollection)
        let lIssueCount = MealRules.issueCount(data: mealCollection.lunchData, collection: mealCollection)
        let dIssueCount = MealRules.issueCount(data: mealCollection.dinnerData, collection: mealCollection)
        
        breakfastCard.info0 = "\(bIssueCount)"
        lunchCard.info0 = "\(lIssueCount)"
        dinnerCard.info0 = "\(dIssueCount)"
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue)
    {
        if (segue.identifier == SegueIdentifier.mealDetailUnwind)
        {
            let vc = segue.source as! MealDetailViewController
            mealCollection = vc.collection
            refresh()
        }
    }
}

extension ScheduleViewController
{
    struct SegueIdentifier
    {
        static let mealDetail = "mealDetailSegue"
        static let mealDetailUnwind = "unwindSegue"
    }
}
