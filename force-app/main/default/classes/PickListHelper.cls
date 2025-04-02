public without sharing class PickListHelper {
    public PickListHelper() {

    }
    public static List<String>  getPickListValuesForLeadCategory(){

        Schema.DescribeFieldResult fieldResult = Lead.nm_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        List<String> lst = new List<String>();
        for( Schema.PicklistEntry f : ple) {
            System.debug(f.getValue());
            lst.add(f.getValue());
        }
        System.debug('lst : '+lst.toString());
        return lst;
    }
    public static List<String>  getPickListValuesForAccountCategory(){

        Schema.DescribeFieldResult fieldResult = Account.nm_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        List<String> lst = new List<String>();
        for( Schema.PicklistEntry f : ple) {
            System.debug(f.getValue());
            lst.add(f.getValue());
        }
        System.debug('lst : '+lst.toString());
        return lst;
    }
}