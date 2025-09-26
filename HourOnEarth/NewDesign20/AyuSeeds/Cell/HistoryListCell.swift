
import UIKit

class HistoryListCell: UITableViewCell {

    @IBOutlet weak var imgSeed: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var viewRound: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewRound.layer.borderWidth = 1.0
        viewRound.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
