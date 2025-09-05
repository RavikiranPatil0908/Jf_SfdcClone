/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 16-07-2025
 * @last modified by  : @Shailesh
**/
public without sharing class AepLeadDistributionController {
    public AepLeadDistributionController() {

    }
    @AuraEnabled(cacheable=true)
    public static List <Counsellor_Profile__c>  getcounsellorsfromuserId(String userId){
        try {
            System.debug('userId :: '+userId);
            List <Counsellor_Profile__c> lstcp = new List <Counsellor_Profile__c>();
            List <nm_UserMapping__c> usermappinglst = [Select Id, nm_Centers__c from nm_UserMapping__c where nm_User__c =: userId limit 1];
            
              if(usermappinglst.size() == 0){
                throw new AuraHandledException('no counsellor found');
              }
              nm_UserMapping__c usermapping = usermappinglst[0];
            System.debug('usermapping :: '+usermapping); 
            lstcp = [Select Id, name,Full_Name__c from Counsellor_Profile__c where IsActive__c = false and AEP_Name__c =: usermapping.nm_Centers__c ]; //'a02Ij000003daRc'

            System.debug('lstcp :: '+lstcp);
            
            if(lstcp.size()>0){
                return lstcp;
            } else {
                throw new AuraHandledException('no counsellor found');
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List <LeadStatus> getLeadStatus(){
        try {
            
            List<LeadStatus> allLeadStatuses = [SELECT Id, MasterLabel, IsConverted FROM LeadStatus];

            System.debug('allLeadStatuses :: '+allLeadStatuses);
            return allLeadStatuses;
            } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static String tranferLeadtoCounsellors(String counsellorIds, String leadStatus, String leadSource, String session, String year, String userId){
        try {
            System.debug('tranferLeadtoCounsellors :: ');
            List<Lead> lstLeads = new List<Lead>();
            List<Lead> updatelstLeads = new List<Lead>();
            //SELECT Id, Name, Counselor_Profile__c FROM Lead where  OwnerId = '005In000000jypN'
            //SELECT Id, Email, MobilePhone, Name FROM Lead where Status = leadStatus and LeadSource in :leadSource and nm_Session__c = '' and nm_Year__c = '' and ownerId = '2F005In000000jypN'
            if(counsellorIds == null || leadStatus == null || leadSource == null || session == null || year == null || userId== null ){
               // throw new AuraHandledException('please provide all required data');
                return 'please provide all required data';
            }
            lstLeads = [SELECT Id, Name, Counselor_Profile__c FROM Lead where  Counselor_Profile__c = null and Status = :leadStatus and LeadSource = :leadSource and nm_Session__c = : session and nm_Year__c = : Decimal.valueOf(year) and ownerId =: userId];

            System.debug('allLeadStatuses :: '+lstLeads);
            List<String> counsellorlst = shuffleList(counsellorIds);
             Integer i = 0; 
            for(Lead leadObj : lstLeads){
                leadObj.Counselor_Profile__c = counsellorlst[i].substring(0, counsellorlst[i].length() - 3);
                i += i >= counsellorlst.size()-1 ?  0 : 1;
                updatelstLeads.add(leadObj);
                System.debug('allLeadStatuses i:: '+i);
            }
            if(updatelstLeads.size()>0){
                update updatelstLeads;
            }
            
            return updatelstLeads.size()+' leads distributed sucessfully';
            } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // public static List<String> shuffleLst(List<String> lst){
        
    //     //List<String> lst = new List<String>{'a','b','c','d','e','f','g','h','i','j'};
    //     List<String> templst = lst;
    //     integer currentIndex = templst.size();
    //     String temporaryValue;
    //     integer randomIndex;
    //     // While there remain elements to shuffle...
    //     while (0 != currentIndex) {
    //     // Pick a remaining element...
    //         randomIndex = integer.valueOf(Math.floor(Math.random() * currentIndex));
    //         currentIndex -= 1;
    //         // And swap it with the current element.
    //         temporaryValue = templst[currentIndex];
    //         templst[currentIndex] = templst[randomIndex];   
    //         templst[randomIndex] = temporaryValue;
    //     }
    //     System.debug('lst :: '+templst);
    //     return templst;
    // }
    public static List<String> shuffleList(String shuffleStr) {
        List<String> lstOfStr = new List<String>();
        System.debug('shuffleStr--->' + shuffleStr);
        if (shuffleStr.contains(',')) {
            lstOfStr = shuffleStr.split(','); // Assign the result of split
        } else {
            lstOfStr.add(shuffleStr); // Add the single string to the list
            return lstOfStr;
        }
        Integer n = lstOfStr.size();
        Integer i = 0;
 
        while (i < n) {
            Integer j = i + (Math.random() * (n - i)).intValue();
            // Swap elements at indices i and j
            String temp = lstOfStr[i];
            lstOfStr[i] = lstOfStr[j];
            lstOfStr[j] = temp;
            i++;
        }
        return lstOfStr;
    }

}