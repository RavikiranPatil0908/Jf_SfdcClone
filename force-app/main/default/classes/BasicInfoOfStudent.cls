/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 30-04-2024
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   01-04-2021   shubhranshu   Initial Version
**/
public class BasicInfoOfStudent
{

    public String Lead { get; set; }
    public Referral__c objReferral{get;set;}
    public String displayMessage {get;set;}
    public boolean IsDuplicate {get;set;}
    public String utm_source{get;set;}
    public String utm_medium{get;set;}
    public String utm_campaign{get;set;}
    public string webid {get;set;}
    public Webinar__c objWebinar {get;set;}
    public String imageURL {get;set;}
    public List<Youtube_Link__c> YoutubeLinks {get;set;}

    public BasicInfoOfStudent()
    {
        objWebinar = new Webinar__c();
        objReferral = new Referral__c();
        webid = ApexPages.currentPage().getParameters().get('webinar');
        utm_source =ApexPages.currentPage().getParameters().get('utm_source');
        utm_medium =ApexPages.currentPage().getParameters().get('utm_medium');
        utm_campaign =ApexPages.currentPage().getParameters().get('utm_campaign');
        displayMessage = '';
        IsDuplicate = false;
        YoutubeLinks = new List<Youtube_Link__c>();
        
        if(webid!=null && webid!='')
        {
            objWebinar = [select Show_circular_image__c,Label_name_for_button__c,Note__c,show_image_rectangular__c,Show_City__c,Page_Title__c,Heading__c,Event_Date__c,Start_Time__c,End_Time__c,Description__c,Content__c,Logo__c,Thankyou_Message__c,Duplicate_Message__c,Send_Confirmation_Mail__c,Closure_Messge__c,Active__c from Webinar__c where id=:webid  Limit 1]; 
            ImageUrl();
            getYoutubeLinks();
        }
      

    }
    public PageReference Save()
    {
        if(webid != null && webid != '')
        {                                                        
            List<Referral__c> lst = [select Email__c,Lead__c,Mobile_Number__c,Source__c,Medium__c,Campaign__c,Webinar__c from Referral__c where (Email__c =:objReferral.Email__c  or Mobile_Number__c =:objReferral.Mobile_Number__c) and Mobile_Number__c !=null and Webinar__c=:webid ];
            if(lst.size()>0)
            {
                //system.debug('List size'+lst.size());
                IsDuplicate = true;
            }else{
                objReferral.Medium__c =utm_medium;
                objReferral.Source__c =utm_source;
                objReferral.Campaign__c = utm_campaign;
                objReferral.Webinar__c = webid;
                insert objReferral;
                //displayMessage = ' Thank you for registering for NMIMS-SAS Live Webinar to be conducted by Dr Sunil Bhardwaj scheduled on 20th January 2018 at 4:00 PM. Confirmation mail will be sent to your registered email id shortly.';
                objReferral = null;  
            }
        }
        
        PageReference pg = new PageReference('/apex/ThankYou?isDuplicate='+IsDuplicate+'&webinar='+webid);
        pg.setRedirect(true);
        return pg;
        
    }

   
    public void ImageUrl()
    {
        imageURL='/servlet/servlet.FileDownload?file=';
        List<Attachment> documentList=[select name from attachment where ParentId=:webid];
    
        if(documentList.size()>0)
        {
            imageURL=imageURL+documentList[0].id;
        }
    }

    public void getYoutubeLinks()
    {
        if(!String.isBlank(objWebinar.Id)){
            YoutubeLinks = [select Id, Title__c, Youtube_Link__c, Webinar__c from Youtube_Link__c where Webinar__c =: objWebinar.Id ];
            System.debug('YoutubeLinks--'+YoutubeLinks);
        }
        
    }



}