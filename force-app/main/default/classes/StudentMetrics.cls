/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 19-04-2023
 * @last modified by  : @BK
**/
public class StudentMetrics
{
    public Account objAccount{get;set;}
    public string strAccountID{get;set;}
    public string Sem1Drive{get;set;}
    public string Sem2Drive{get;set;}
    public string Sem3Drive{get;set;}
    public string Sem4Drive{get;set;}
    public String token {get;set;}
    private final ApexPages.StandardController cntr;
     
    public StudentMetrics(ApexPages.StandardController controller) 
    {
        objAccount = new Account();
        token = '';
        strAccountID = ApexPages.currentPage().getParameters().get('id');
        GetAccountDetails();
        cntr =  (ApexPages.StandardController)controller;
    }
    public void GetAccountDetails()
    {
       
        List<Account> lstAccount =[select id,sem1NoOfANS__c,nm_StudentNo__c,sem1NoOfAssignSubmitted__c,sem2NoOfANS__c,sem2NoOfAssignSubmitted__c,sem3NoOfANS__c,sem3NoOfAssignSubmitted__c,sem4NoOfANS__c,sem4NoOfAssignSubmitted__c,totalNoOfANS__c,totalNoOfAssignSubmitted__c
                                   from Account where id=:strAccountID];
        if(lstAccount.size()>0)
        {
            objAccount = lstAccount[0];
            
             // generate Time Token
            DateTime myDateTime = DateTime.now();
            Blob key = EncodingUtil.base64Decode(Label.studentZone_PrivateKey); // privateKey
            Blob data = Blob.valueOf(objAccount.nm_StudentNo__c+'~'+myDateTime.getTime());
            Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key, data);
            token = EncodingUtil.base64Encode(encryptedData);
        }
        List<Opportunity> lstOpportunity = [select id,Session_for_Student_Zone__c,nm_Year__c,nm_Semester__c,StageName,nm_StudentProgram__c,nm_StudentProgram__r.nm_FeesPaidofSemester__c 
                                           from Opportunity where StageName = 'Closed Won' and AccountId =:strAccountID];
        if(lstOpportunity.size()>0)
        {
            for(Opportunity objOpp:lstOpportunity)
            {
                if(objOpp.nm_Semester__c =='1')
                {
                    Sem1Drive = objOpp.Session_for_Student_Zone__c +'-'+objOpp.nm_Year__c;
                }
                else if(objOpp.nm_Semester__c =='2')
                {
                    Sem2Drive = objOpp.Session_for_Student_Zone__c +'-'+objOpp.nm_Year__c;
                }
                else if(objOpp.nm_Semester__c =='3')
                {
                    Sem3Drive = objOpp.Session_for_Student_Zone__c +'-'+objOpp.nm_Year__c;
                }
                else if(objOpp.nm_Semester__c =='4')
                {
                    Sem4Drive = objOpp.Session_for_Student_Zone__c +'-'+objOpp.nm_Year__c;
                }
            }
        }
    } 
    
    public PageReference navigateTo360(){
        // generate Time Token
        DateTime myDateTime = DateTime.now();
        String studentno = objAccount.nm_StudentNo__c;
        studentno = String.isNotBlank(studentno) && studentno.contains('_') ? studentno.split('_')[1] : studentno;
        Blob key = EncodingUtil.base64Decode(Label.studentZone_PrivateKey); // privateKey
        Blob data = Blob.valueOf(studentno+'~'+myDateTime.getTime());
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key, data);
        String token = EncodingUtil.base64Encode(encryptedData);
        
        String urlEncodedToken = EncodingUtil.urlEncode(token, 'UTF-8');
        urlEncodedToken = EncodingUtil.urlDecode(urlEncodedToken, 'UTF-8');
        
        PageReference page = new PageReference(Label.Student_Portal + 'viewStudentDetailsDashBoard');
        page.getParameters().put('sapId', studentno);
        page.getParameters().put('token', urlEncodedToken);

        return page;
            
    }
}