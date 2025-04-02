public without sharing class nmReRegistrationLateFees_login {
public Account objAccount{get;set;}
public String strSecToShow{get;set;}
public String HeaderMessage {get;set;}
public String strBtnURL{get;set;}
public list<String> lstMsg{get;set;}
public nmReRegistrationLateFees_login ()
{
   objAccount=new Account();
   
}
public pagereference studentLogin()
{
	 lstMsg=new list<String>(); 
	if(objAccount.nm_StudentNo__c  !=null && objAccount.nm_DateOfBirth__c !=null){
		    list<Account> lstAccount = [select id, name, nm_StudentStatus__c ,nm_StudentNo__c, nm_RegistrationNumber__c, nm_DateOfBirth__c, 
		                                        ( 
		                                            Select id, nm_PendingAmount__c, nm_Semester__c 
		                                            from Opportunities
		                                            where StageName != 'Closed Won'
		                                            and nm_PendingAmount__c > 0
		                                        )
		                                        from Account 
		                                        where nm_StudentNo__c=:objAccount.nm_StudentNo__c  
		                                        and nm_DateOfBirth__c =:objAccount.nm_DateOfBirth__c];
	      if(lstAccount.size()>0)
	      {
	          pagereference redirect=new pagereference('/apex/nmLateFees?&id='+ lstAccount[0].id);
	          
	          return redirect;
	         
	      }
	      else
	      {
	          strSecToShow = 'msg';
	          HeaderMessage = 'Invalid';
	          strBtnURL = '';
	          lstMsg.add('Student Not Exist.');
	                               
	          return null;
	      }
	}
	else
	{
		strSecToShow = 'msg';
	    HeaderMessage = 'Invalid';
	    strBtnURL = '';
	    lstMsg.add('InValid Student No./ InValid Date of Birth.');                           
	   return null;
	}
 return null;
    
}

}