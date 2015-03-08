import Foundation

// Singleton instance of User
class User {
    class var sharedInstance: User {
        struct Static {
            static var instance: User?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = User()
        }
        
        return Static.instance!
    }
    
    var name : String = ""           // The users name (via facebook login).
    var email : String = ""          // The email address (via facebook login) of this user.
    var profilePicture : String = "" // The URL (via facebook login) pointing to the users profile picture.
    //var checkIns = [StatusCheckIn]() // The comprehensive list of all this users check ins & statuses.
    var isCheckedIn : Bool = false   // Indicates if user is currently checked in.
}
