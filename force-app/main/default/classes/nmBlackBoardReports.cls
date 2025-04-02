public class nmBlackBoardReports
{
public String strSelectSemister{get;set;}
    public PageReference GetData() 
    {        
        System.debug(selectedSession);
        System.debug(selectedYear);
        PageReference p = new PageReference('/apex/Student_Deletion_from_BB?session='+selectedSession+'&selectedYear='+selectedYear);
        p.setredirect(true) ;
        return p;        
    }
    
    public PageReference GetData1() 
    {        
        System.debug(objAccount.Account_Confirm_Date__c);
        System.debug(objAccount1.Account_Confirm_Date__c);
        PageReference p = new PageReference('/apex/Student_Course_Enrollment_in_BB?StartDate='+objAccount.Account_Confirm_Date__c+'&EndDate='+objAccount1.Account_Confirm_Date__c);
        p.setredirect(true) ;
        return p;
        
    }

    public List<Opportunity> lstOpp {get;set;}
    public List<SelectOption> lstSession{get;set;}
    public List<SelectOption> lstYear{get;set;}
    public String selectedSession{get;set;}
    public String selectedYear{get;set;}
    public string render{get;set;}
    public boolean show1{get;set;}
    public boolean show2{get;set;}
    public Account objAccount{get;set;}
    public Account objAccount1{get;set;}
    public nmBlackBoardReports()
    {
        render ='';
        show1=true;
        show2=false;
        lstOpp = new List<Opportunity>();  
        lstSession = new List<SelectOption>();
        lstYear = new List<SelectOption>();
        objAccount = new Account ();
        objAccount1 = new Account ();
        lstSession.add(new SelectOption('January','January'));
        lstSession.add(new SelectOption('July','July'));
        for(integer i=2014;i<3000;i++)
        {
            lstYear.add(new SelectOption(String.valueof(i),String.valueof(i)));
        }
    }

}