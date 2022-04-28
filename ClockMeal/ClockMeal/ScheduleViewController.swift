import UIKit

class ScheduleViewController: UIViewController
{
    private var selectedSchedule: MealType?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == SegueIdentifier.mealDetail)
        {
            guard let destinationVC = segue.destination as? MealDetailViewController
            else { return }
            destinationVC.type = selectedSchedule
        }
    }
    
    @IBAction func onScheduleCardButton(_ sender: ScheduleCardControl)
    {
        selectedSchedule = sender.type
        performSegue(withIdentifier: SegueIdentifier.mealDetail, sender: self)
    }
}

extension ScheduleViewController
{
    struct SegueIdentifier
    {
        static let mealDetail = "mealDetailSegue"
    }
}
