public class Student_Course_Enrollment_in_BB_Old
{
    List<Account> lstAccount = new List<Account>();
    List<Opportunity> lstOpp = new List<Opportunity>();
    List<nm_Program__c> lstProgram = new List<nm_Program__c>();
    set<id> setAccountID = new set<id>();
    set<id> setProgramID = new set<id>();
    set<id> setProductID = new set<id>();
    set<id> setCourses = new set<id>();  
    set<string> setSemester = new set<string>();    
    List<Product2> lstProduct = new List<Product2>();    
    public List<Wrapper> lstWrapper{get;set;}
    
    public class Wrapper
    {
        public string AccountID{get;set;}
        public string CourseID{get;set;}    
        
        public Wrapper()
        {
        
        }    
    }
    
    public String getNewLine() 
    {
        return '\n';
    }
    
    public Student_Course_Enrollment_in_BB_Old()
    {
        lstWrapper = new List<Wrapper>(); 
        
        try
        {
            Date objDate1 = Date.Parse(ApexPages.currentpage().getparameters().get('StartDate'));
            System.debug(objDate1);
            Date objDate2 = Date.Parse(ApexPages.currentpage().getparameters().get('EndDate'));
            System.debug(objDate2);
            
            lstOpp = [select id , 
                             Account.Name , 
                             Account.nm_StudentNo__c,
                             nm_Program__c , 
                             nm_Semester__c  
                             from Opportunity
                             where (StageName='Payment received -Finance approval given'
                             or StageName='Emerson Student') and Account.Account_Confirm_Date__c !=null
                             and (Account.Account_Confirm_Date__c >= :objDate1 and Account.Account_Confirm_Date__c <= :objDate2)
                             and (nm_semester__c ='2' or nm_semester__c ='3')
                             and Account.Is_Lateral__c = true];
                             
            System.debug('lstOpp+++'+lstOpp.size());
            if(lstOpp.size()>0)
            {
                for(Opportunity objOpp :lstOpp )
                {                  
                    setProgramID.add(objOpp.nm_Program__c); 
                    setSemester .add(objOpp.nm_Semester__c)  ;                       
                }
                System.debug('setProgramID+++'+setProgramID.size());                
                if(setProgramID.size()>0)
                {
                    lstProduct = [select id , 
                                         nm_Program__c , 
                                         nm_Semester__c ,
                                         (select id , nm_CourseMaster__r.nm_CourseID__c from Courses__r)
                                         from Product2 
                                         where nm_Program__c in : setProgramID and nm_Semester__c in :setSemester ];               
                    
                   
                    
                    System.debug('lstProduct+++'+lstProduct.size());                    
                    if(lstProduct.size()>0)
                    {
                            for(Opportunity objOpp :lstOpp )
                            {        
                                for(Product2 objProd :lstProduct )
                                {
                                    if(objProd.nm_Program__c == objOpp.nm_Program__c)
                                    {
                                        for(nm_Courses__c objCourses : objProd.Courses__r)
                                        {                                         
                                            Wrapper obj = new Wrapper();                                            
                                            obj.AccountID = objOpp.Account.nm_StudentNo__c;
                                            obj.CourseID = objCourses.nm_CourseMaster__r.nm_CourseID__c;
                                            lstWrapper.add(obj);                                                                                  
                                        }
                                    }
                                }
                            }
                        
                        System.debug('lstWrapper+++'+lstWrapper.size()); 
                    }               
                }            
            } 
        }
        catch(Exception Ex)
        {
            System.debug('Exception++'+Ex);
        
        } 
    }
}