public class nmICRedirectExtension
{
 
private static IC_Payment__c icp;
Apexpages.StandardController con;
Id icRedirectID;
List<IC_Payment__c> resultList {get;set;}

   public nmICRedirectExtension(ApexPages.StandardController controller)
   {
       con = controller;
   }
    
   public PageReference icRedirect()
   {
       icp = (IC_Payment__c)con.getRecord();
       system.debug('Center-->'+icp.Centers__c+' Month-->'+icp.Payment_Month__c+' Year-->'+icp.Payment_Year__c);
       resultList = [select id from IC_Payment__c where Centers__c = :icp.Centers__c
                     AND Pay_Month__c = :icp.Payment_Month__c
                     AND Payment_Year__c = :icp.Payment_Year__c];
       if(!resultList.isEmpty())
       {          
           for(IC_Payment__c i : resultList)
           {
               icRedirectId = i.id;
           }
           
           PageReference pgRef = new PageReference('/'+icRedirectId);
           pgRef.setRedirect(TRUE);
           return pgRef;
       }
       else
       {
           Apexpages.AddMessage(new Apexpages.Message(ApexPages.SEVERITY.INFO,'YOUR QUERY DID NOT MATCH ANY RECORDS'));
           return null;
       }
       
     
       
   }
    
    
}