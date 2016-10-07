import UIKit

class onePhoto: UIViewController {
    var classUser = MoleUser()
    

    @IBOutlet var profilePhoto: UIImageView!
    
    @IBAction func backButton(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
  
    override func viewDidLoad() {

        navigationController?.topViewController?.title = classUser.username
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        profilePhoto.sd_setImage(with: classUser.profilePic)
    }
    
    
}

