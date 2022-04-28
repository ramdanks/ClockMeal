//
//  MealDetailViewController.swift
//  ClockMeal
//
//  Created by Ramadhan Kalih Sewu on 28/04/22.
//

import UIKit

class MealDetailViewController: UIViewController, TimePickerViewDelegate
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var timeScheduleControl: RichRowControl!
    
    var timePickerView: TimePickerView = {
        let view = TimePickerView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    var darkenView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    
    var type: MealType? { didSet {
        titleLabel?.text = "\(type!)".capitalized
    }}
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        type = { type }()
        timePickerView.delegate = self
        darkenView.frame = self.view.frame
        timePickerView.center = self.view.center
    }
    
    @IBAction func onHavingMealSwitch(_ sender: RichRowSwitchControl)
    {
        print(sender.rightSwitch.isOn)
    }
    
    @IBAction func onDoneButton(_ sender: Any)
    {
        dismiss(animated: true)
    }
    
    @IBAction func onTimeScheduleRow(_ sender: RichRowControl)
    {
        displayTimePicker(true)
    }
    
    func onCancelEditing()
    {
        displayTimePicker(false)
    }
    
    func onConfirmEditing(_ date: Date)
    {
        timeScheduleControl.detail = date.toString("hh:mm aa")
        displayTimePicker(false)
    }
    
    func displayTimePicker(_ display: Bool)
    {
        if (display)
        {
            UIView.transition(
                with: self.view,
                duration: 0.25,
                options: [.transitionCrossDissolve],
                animations: {
                    self.view.addSubview(self.darkenView)
                    self.view.addSubview(self.timePickerView)
                },
                completion: nil
            )
        }
        else
        {
            UIView.transition(
                with: self.view,
                duration: 0.25,
                options: [.transitionCrossDissolve],
                animations: {
                    self.timePickerView.removeFromSuperview()
                    self.darkenView.removeFromSuperview()
                },
                completion: nil
            )
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
