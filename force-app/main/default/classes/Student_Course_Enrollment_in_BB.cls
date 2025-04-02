public class Student_Course_Enrollment_in_BB
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
    
    public Student_Course_Enrollment_in_BB()
    {
        lstWrapper = new List<Wrapper>(); 
        
        try
        {
            Date objDate1 = Date.Parse(ApexPages.currentpage().getparameters().get('StartDate'));
            System.debug(objDate1);
            Date objDate2 = Date.Parse(ApexPages.currentpage().getparameters().get('EndDate'));
            System.debug(objDate2);
            String Sem=ApexPages.currentpage().getparameters().get('SelectedSem');
            system.debug('objDate2'+objDate2+'objDate1'+objDate1);
            if(Sem=='1'){
            lstOpp = [select id , 
                             Account.Name , 
                             Account.nm_StudentNo__c,
                             nm_Program__c , 
                             nm_Semester__c  
                             from Opportunity
                             where (StageName='Closed Won'
                             or StageName='Emerson Student') and Account.Account_Confirm_Date__c !=null
                             and (Account.Account_Confirm_Date__c >= :objDate1 and Account.Account_Confirm_Date__c <= :objDate2)
                             and nm_semester__c ='1'];
            }
            else if(Sem=='2'){
              lstOpp = [select id , 
                             Account.Name , 
                             Account.nm_StudentNo__c,
                             nm_Program__c , 
                             nm_Semester__c  
                             from Opportunity
                             where (StageName='Closed Won'
                             or StageName='Emerson Student') and Account.Account_Confirm_Date__c !=null
                             and CloseDate >= :objDate1 and CloseDate <= :objDate2
                             and nm_semester__c ='2'];
            }
            else if(Sem=='3'){
              lstOpp = [select id , 
                             Account.Name , 
                             Account.nm_StudentNo__c,
                             nm_Program__c , 
                             nm_Semester__c  
                             from Opportunity
                             where (StageName='Closed Won'
                             or StageName='Emerson Student') and Account.Account_Confirm_Date__c !=null
                             and CloseDate >= :objDate1 and CloseDate <= :objDate2
                             and nm_semester__c ='3'];
            }
             else if(Sem=='4'){
              lstOpp = [select id , 
                             Account.Name , 
                             Account.nm_StudentNo__c,
                             nm_Program__c , 
                             nm_Semester__c  
                             from Opportunity
                             where (StageName='Closed Won'
                             or StageName='Emerson Student') and Account.Account_Confirm_Date__c !=null
                             and CloseDate >= :objDate1 and CloseDate <= :objDate2
                             and nm_semester__c ='4'];
            }
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
                                system.debug('objOpp'+objOpp);   
                                for(Product2 objProd :lstProduct )
                                {
                                    system.debug('objProd'+objProd);
                                    if(objProd.nm_Program__c == objOpp.nm_Program__c)
                                    {
                                        system.debug('objProd.Courses__r'+objProd.Courses__r.size());
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