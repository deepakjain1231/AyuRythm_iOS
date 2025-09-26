
import UIKit

class SeeMoreCell: UITableViewCell {

    @IBOutlet weak var btnSeeMore: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        btnSeeMore.layer.borderWidth = 2.0
        btnSeeMore.layer.borderColor = #colorLiteral(red: 0.2431372549, green: 0.5450980392, blue: 0.2274509804, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
