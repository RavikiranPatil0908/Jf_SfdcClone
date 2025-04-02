/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 18-12-2023
 * @last modified by  : @BK
**/
public class ApplyForValidityExtensionController 
{
    public String StudentNo { get; set; }
    public Account objAccount{get;set;}
    public Calender__c objCalender{get;set;}
    public String sectionToShow{get;set;}
    public String headerMessage{get;set;}
    public String message{get;set;}
    public String strBtnURL{get;set;}
    public string ICValue {get;set;}
    map<String,integer> mapOfMonthAndNumber = new map<String,integer>();
    List<String> monthList = new List<String>{'January','February','March','April','May','June','July','August','September','October','November','December'};
    
    public ApplyForValidityExtensionController()
    {
        for(integer i=0;i<monthList.size();i++)
        {
            integer s = i;
            mapOfMonthAndNumber.put(monthList[i],s+1);
            s++;
        }   
        ICValue =ApexPages.currentPage().getParameters().get('IC');   
        objAccount = new Account();
        
        if(ApexPages.currentPage().getParameters().get('studentNo') != Null && ApexPages.currentPage().getParameters().get('studentNo') != '')
        {
            objAccount.nm_StudentNo__c = ApexPages.currentPage().getParameters().get('studentNo');
        }
        
        if(ApexPages.currentPage().getParameters().get('dob') != Null && ApexPages.currentPage().getParameters().get('dob') != '')
        {
            objAccount.nm_DateOfBirth__c = Date.parse(ApexPages.currentPage().getParameters().get('dob'));
        }
        sectionToShow ='';
        strBtnURL ='';
    }
    public void ShowMessageBlock(String messageToBeShown,String headerValue,String url)
    {
    sectionToShow = 'msg';
    headerMessage = headerValue;
    message = messageToBeShown;
    strBtnURL = url;
    }
   
    public PageReference RedirectToValidityPage()
    {
        HelperClassForValidityExtension objHelperclass=new HelperClassForValidityExtension();
        map<string,string>MapOfValidRecord = objHelperclass.ValidateRecord(objAccount.nm_StudentNo__c,objAccount.nm_DateOfBirth__c,mapOfMonthAndNumber);
        if(MapOfValidRecord.get('Success') != null) {
            String urlToRedirect = 'ValidityExtension?&id='+MapOfValidRecord.get('Success')+'&IC='+ICValue;
            System.debug('--urltoredirect----  '+urlToRedirect);
            ShowMessageBlock('Do you wish to extend your Validity ?','EXTEND VALIDITY',urlToRedirect); 
            return null;
        }
        else if(MapOfValidRecord.get('errorMessage')!=null)
        {
            ShowMessageBlock(MapOfValidRecord.get('errorMessage'),'IMPORTANT MESSAGE','');
            return null;
        }
        return null;
    }
}