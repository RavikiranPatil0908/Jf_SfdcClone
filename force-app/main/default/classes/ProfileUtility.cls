/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08-05-2024
 * @last modified by  : @BK
**/
public without sharing class ProfileUtility {
    private static ProfileUtility utils { get; private set; }
    public Map<Id,Profile> profileMap {get; private set;}

    public ProfileUtility() {
        this.profileMap = new Map<Id,Profile>([SELECT Id,Name FROM Profile]);
    }

    public static ProfileUtility getInstance() {
        if(utils == null) {
            utils = new ProfileUtility();
        }
        return utils;
    }
}