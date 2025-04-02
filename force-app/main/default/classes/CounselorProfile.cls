/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 28-02-2023
 * @last modified by  : @BK
**/
public without sharing class CounselorProfile {

    public Boolean isExists {get;set;}
    public String recordId {get;set;}
    public Counsellor_Profile__c objCP { get; set; }

    public CounselorProfile() {
        isExists = false;
        recordId = null;
        objCP = new Counsellor_Profile__c();

        if (ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '') {
            recordId = ApexPages.currentPage().getParameters().get('id');
        }

        if(String.isNotBlank(recordId)) {
            QueryCPData();
        }
    }

    public void QueryCPData() {
        List<String> lstprofiles = new List<String>{'Information Center Executive Community User','Information Center Partner Community User','pp profile'};
        List<Counsellor_Profile__c> listCP = [SELECT id,First_Name__c,IsActive__c,Name,Profile_name__c,Last_Name__c FROM Counsellor_Profile__c WHERE id=:recordId AND Profile_name__c IN :lstprofiles LIMIT 1];
        if(listCP.size() > 0) {
            isExists = true;
            objCP = listCP[0];
        }
    }
}