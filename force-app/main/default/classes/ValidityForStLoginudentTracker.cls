/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08-01-2025
 * @last modified by  : @BK
**/
@isTest
public class ValidityForStLoginudentTracker
{
   private class RestMock implements HttpCalloutMock {
      RestMock() {
      }
      public HTTPResponse respond(HTTPRequest req) {
          String fullJson = '{ "msg" : "Success" }';
          HTTPResponse res = new HTTPResponse();
          res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
          res.setBody(fullJson);
          res.setStatusCode(200);
          return res;
      }
  }

   public static Validity_Extension__c objValEx;
   public static Account objAccount;

   @isTest
   static void UnitTest1()
   {      
      Test.setMock(HttpCalloutMock.class, new RestMock());
      // PG Validity for Batch=jan
          ValidityForStudentLogin  ValidtyFoirStud = new  ValidityForStudentLogin ();
          ValidtyFoirStud.checkValidityForPG('January',2015,2015,'Jan','1');
          ValidtyFoirStud.checkValidityForPG('January',2015,2015,'Jan','2');
          ValidtyFoirStud.checkValidityForPG('July',2015,2015,'Jan','3');
          ValidtyFoirStud.checkValidityForPG('January',2015,2015,'Jan','4');
          
          //  PG Validity for Batch=jul
          ValidtyFoirStud.checkValidityForPG('July',2015,2015,'Jul','1');
          ValidtyFoirStud.checkValidityForPG('January',2015,2015,'Jul','2');
          ValidtyFoirStud.checkValidityForPG('July',2015,2013,'Jul','3');
          ValidtyFoirStud.checkValidityForPG('January',2015,2011,'Jul','3');
          ValidtyFoirStud.checkValidityForPG('January',2015,2011,'Jul','4');
          ValidtyFoirStud.checkValidityForPG('Januar',2015,2011,'DEC','4');
         
          // Diploma Validity for Batch=jan
          ValidtyFoirStud.checkValidityForDiploma('January',2015,2015,'Jan','1');
          ValidtyFoirStud.checkValidityForDiploma('January',2015,2017,'Jan','2');
          ValidtyFoirStud.checkValidityForDiploma('July',2015,2015,'Jul','1');
        
          //Diploma Validity for Batch=jul
          ValidtyFoirStud.checkValidityForDiploma('January',2015,2015,'Jul','1');
          ValidtyFoirStud.checkValidityForDiploma('January',2015,2015,'Jul','2');
          ValidtyFoirStud.checkValidityForDiploma('January',2015,2015,'Dec','1');
          
             //  PG Validity for Batch=jul
          ValidtyFoirStud.checkValidityForPGforLogin('July',2015,2016,'Jul','');
          ValidtyFoirStud.checkValidityForPGforLogin('January',2015,2017,'Jul','2');
          ValidtyFoirStud.checkValidityForPGforLogin('July',2015,2013,'Jul','3');
          ValidtyFoirStud.checkValidityForPGforLogin('January',2015,2011,'Jul','3');
          ValidtyFoirStud.checkValidityForPGforLogin('January',2015,2011,'Jul','');
          ValidtyFoirStud.checkValidityForPGforLogin('Januar',2015,2011,'DEC','');
          
          objAccount= new Account();
             objAccount.lastname ='kumar';
             objAccount.nm_StudentNo__c='771124684458484';
             objAccount.nm_PreStudentNo__c ='77112';
             objAccount.nm_StudentStatus__c='Confirmed';
             objAccount.PersonMobilePhone='837700000985721';
             objAccount.nm_DateOfBirth__c= System.today();
             objAccount.PersonEmail='chandra@gma11il.com';
             objAccount.Validity_Extension_Count__c = 0;
             objAccount.nm_SerialNo__c=2;
             objAccount.Extend_Validity_upto_Month__c='June';
             objAccount.nm_Category__c='General';
             objAccount.Extend_Validity_Upto_Year__c=2016;
             objAccount.Extended_Validity_For_This_Session__c=false;
             objAccount.Validity_Extension_Count__c=0;
             objAccount.nmStudent_Program__c='Post Graduate Diploma in Business Management';
             //objAccount.nm_Centers__c=objCen.id;
             //objAccount.nm_Tagged_Pricebook__c = string.valueOf(objPricebook.id);
             //objAccount.nm_EligiblityCriteria__c =objEc.id;
             insert objAccount;
          
           objValEx = new Validity_Extension__c();
           objValEx.Batch_Name__c='JUL2015';
           objValEx.Expiry_Date_Of_Program__c='2020';
           objValEx.Mobile_Number__c='242343254326534';
           objValEx.Name_Of_Account__c='Fagu Babu';
           objValEx.Student_Number_Of_Account__c='77115000170';
           objValEx.Student_Program_Validity__c='Post Graduate Diploma in Supply Chain Management';
           objValEx.Related_Account__c=objAccount.id;
           insert objValEx;
           
           
          ValidtyFoirStud.makePaymentAfterResponseForValidityExtension('fgvtrf','vfgvfbgv','vfgvfbgv','CAPTURED','sdfgsdg',0.0,'xfgvb',objValEx.id);   
          
         

   
   }  
}