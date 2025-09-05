//This apex class takes care of returning the signing user given that it exists in Salesforce
global class MicrosoftRegistrationHandler implements Auth.RegistrationHandler{
    
    global User createUser(Id portalId, Auth.UserData data){
        User userDet = [SELECT Id,Name,Email,Username FROM User WHERE Email = :data.email LIMIT 1];
        system.debug('User '+userDet);
        return userDet;
    }
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
    }
}