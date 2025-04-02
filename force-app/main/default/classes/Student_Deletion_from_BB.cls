public class Student_Deletion_from_BB 
{
    
    public String getNewLine() 
    {
        return '\n';       
    }
    public List<Opportunity> lstOpp {get;set;}   
    public string selectedSession ;
    public integer selectedYear ;
    
    public Student_Deletion_from_BB ()
    {        
        lstOpp = new List<Opportunity>();  
        selectedYear = Integer.valueof(ApexPages.currentPage().getParameters().get('selectedYear'));
        selectedSession = ApexPages.currentPage().getParameters().get('session');
        System.debug('selectedSession'+selectedSession);
        System.debug('selectedYear'+selectedYear);
        
        
    }
    
    public void GetData()
    {     
       lstOpp = [select id, 
                        Account.nm_StudentNo__c 
                        from Opportunity where nm_Semester__c ='1' 
                        and Expiry_Session__c =:selectedSession 
                        and Expiry_Year__c = :selectedYear 
                        and Account.nm_StudentNo__c !=''
                        and Account.nm_StudentStatus__c='Confirmed'];
                        
       System.debug(lstOpp);    
         
    }  

}