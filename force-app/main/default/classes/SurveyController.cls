/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 02-20-2021
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   02-20-2021   @BK   Initial Version
**/
public without sharing class SurveyController {

    public String surveyId {get;set;}
    public String caseId {get;set;}
    public String contactId {get;set;}
    public String studentNumber {get;set;}
    public Boolean thankYouRendered{get;set;}
    public String anonymousAnswer {get;set;}
    public List<SelectOption> anonymousOrUser {get;set;}
    public Boolean isInternal {get;set;}
    public Survey__c objSurvey {get;set;}
    public String message {get;set;}
    public String strSecToShow {get;set;}
    public List<question> allQuestions{get; set;}
    public Integer allQuestionsSize{get; set;}
    public Map<String,String> mapOfOrderVsId {get;set;}
    public String surveyTakerId {get;set;}
    public string strName { get; set; }
    public string strAEPName { get; set; }

    public SurveyController() {
        thankYouRendered = false;
        objSurvey = new Survey__c();
        mapOfOrderVsId = new Map<String,String>();

        // Get Params
        surveyId = Apexpages.currentPage().getParameters().get('id');
        caseId   = Apexpages.currentPage().getParameters().get('caId');
        contactId = Apexpages.currentPage().getParameters().get('cId'); 
        studentNumber = Apexpages.currentPage().getParameters().get('stnu');

        init();
    }

    public void init() {
        if(String.isNotBlank(surveyId)) {
            try {
                List<Survey__c> lstSurvey = [SELECT Name,id,URL__c,Thank_You_Text__c,thankYouText__c,thankYouLink__c,Survey_Header__c,Survey_Container_CSS__c,Hide_Survey_Name__c FROM Survey__c WHERE id=:surveyId LIMIT 1];
                if(lstSurvey.size() > 0) {
                    objSurvey = lstSurvey[0];
                    objSurvey.id = null;

                    caseId = String.isBlank(caseId) || caseId.length() < 5 ? 'none' : caseId;
                    contactId =  String.isBlank(contactId) || contactId.length() < 5 ? 'none' : contactId;
                    if(String.isBlank(studentNumber) && contactid =='none'){
                        contact cts = [SELECT id FROM Contact WHERE Account.nm_StudentNo__c=:studentNumber LIMIT 1];
                        contactId = cts.id;
                        System.debug('contactId'+contactId);
                    }
                    
                    allQuestions = new List<question>();
                    if(setupQuestionList() > 0) {
                        getUserType();
                    }
                } else {
                    ErrorMessage('No Survey Found.','PopUpError');
                }
            } catch (Exception error) {
                System.debug(error.getMessage());
                ErrorMessage('Internal Error Occured.','PopUpError');
            }
        } else {
            ErrorMessage('No Survey Found.','PopUpError');
        }
    }

    public void ErrorMessage(String msg,String secToShow){
        message = msg;
        strSecToShow = secToShow; 
    }

    public void getUserType() {
        anonymousOrUser = new List<SelectOption>();
        anonymousOrUser.add(new SelectOption('Anonymous',System.Label.LABS_SF_Anonymous));
        anonymousOrUser.add(new SelectOption('User','User ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName()));
        anonymousAnswer = 'Anonymous';
        isInternal = true;
        String urlBase = URL.getSalesforceBaseUrl().toExternalForm();
        String profileId = UserInfo.getProfileId();
        try {
            Profile p = [SELECT Id,UserType FROM Profile WHERE Id=:profileId];
            isInternal = p.UserType == 'Guest' ? false : true;
        } catch (Exception e) {
            isInternal = false;
        }
    }

    public void submitResults() {
        try {
            List <SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
            for (question q : allQuestions) {
                SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();
                System.debug('q.selectedOption ===>'+q.selectedOption);
                if (q.renderSelectRadio == 'true') {
                    if (q.required &&  (q.selectedOption == null || q.selectedOption == '')) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                        return;
                    }
                    
                    sqr.Response__c = q.selectedOption!=null && q.selectedOption!='' ? q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel() : '';
                    sqr.Survey_Question__c = mapOfOrderVsId.get(q.orderNumber);
                    sqrList.add(sqr);
                } else if (q.renderFreeText == 'true') {
                    if (q.required && q.choices == '') {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                        return;
                    }
                    System.debug('*****Select Radio ' + q.choices);
                    sqr.Response__c = q.choices;
                    sqr.Survey_Question__c = mapOfOrderVsId.get(q.orderNumber);
                    sqrList.add(sqr);
                } else if (q.renderSelectCheckboxes == 'true') {
                    if (q.required && (q.selectedOptions == null || q.selectedOptions.size() == 0)) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                        return;
                    }
                    
                    for (String opt : q.selectedOptions) {
                        sqr = new SurveyQuestionResponse__c();
                        sqr.Response__c = opt!='' && opt!=null ? q.multiOptions.get(Integer.valueOf(opt)).getLabel() : '';
                        sqr.Survey_Question__c = mapOfOrderVsId.get(q.orderNumber);
                        sqrList.add(sqr);
                    }
                } else if (q.renderSelectRow == 'true') {
                    if (q.required && (q.selectedOption == null || q.selectedOption == '')) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                        return;
                    }
                    
                    sqr.Response__c = q.selectedOption!=null && q.selectedOption!='' ? q.rowOptions.get(Integer.valueOf(q.selectedOption)).getLabel() : '';
                    sqr.Survey_Question__c = mapOfOrderVsId.get(q.orderNumber);
                    sqrList.add(sqr);
                }
            }

            if(AddSurveyTaker()) {
                for (SurveyQuestionResponse__c sqr : sqrList) {
                    sqr.SurveyTaker__c = surveyTakerId;
                }
                insert sqrList;
                thankYouRendered = true;      
            }
        } catch (Exception error) {
            System.debug(error.getMessage());
            ErrorMessage('Internal Error Occured.','PopUpError');
        }
    }

    public Integer setupQuestionList() {
        getAQuestion();
        return allQuestions.size();
    }

    public List<question> getAQuestion() {
        List<Survey_Question__c> allQuestionsObject = 
                                        [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, 
                                        s.OrderNumber__c, s.Name, s.Choices__c 
                                        From Survey_Question__c s 
                                        WHERE s.Survey__c =: surveyId ORDER BY s.OrderNumber__c];
        allQuestions = new List<question>();
        
        Double old_OrderNumber = 0;
        Double new_OrderNumber;
        Double difference = 0;
        /* Make sure that the order number follow each other (after deleting a question, orders might not do so) */
        for (Survey_Question__c q : allQuestionsObject)
        { 
            new_OrderNumber = q.OrderNumber__c;
            difference = new_OrderNumber - old_OrderNumber - 1;
            if (difference > 0)
            {
                Double dd = double.valueOf(difference);
                Integer newOrderInt = dd.intValue();
                q.OrderNumber__c -= Integer.valueOf(newOrderInt); 
            }
            old_OrderNumber = q.OrderNumber__c;
            question theQ = new question(q);
            mapOfOrderVsId.put(theQ.orderNumber,theQ.id);
            theQ.id = null;
            allQuestions.add(theQ);
        }
        allQuestionsSize = allQuestions.size();
        return allQuestions;
    }
    
    public Boolean AddSurveyTaker() {
        if (surveyId == null) {
            return false;
        }

        caseId = caseId.toUpperCase() =='NONE'|| caseId.length()<5 ? null : caseId;
        contactId = contactId.toUpperCase() =='NONE'|| contactId.length()<5 ? null : contactId;
        
        SurveyTaker__c st = new SurveyTaker__c();
        st.Contact__c = contactId;
        st.Survey__c = surveyId;
        st.Taken__c = 'false';
        st.Case__c = caseId;
        st.Name__c = strName;
        st.AEP__c =strAEPName ;
        insert st;  
        surveyTakerId = st.id;
        return true;    
    }

    public class question {
        public String name{get; set;}
        public String id{get; set;}
        public String question{get; set;}
        public String orderNumber{get; set;}
        public String choices{get; set;}
        public String selectedOption{get;set;}
        public List<String> selectedOptions{get;set;}
        public List<SelectOption> singleOptions{get; set;}
        public List<SelectOption> multiOptions {get; set;}
        public Boolean required{get; set;}
        public String questionType{get; set;}    
        public String surveyName{get; set;}
        public String renderFreeText{get; set;}
        public String renderSelectRadio{get; set;}
        public String renderSelectCheckboxes{get; set;} 
        public String renderSelectRow{get; set;}
        public List<String> responses{get; set;}
        public String singleOptionsForChart{get; set;}
        public String qResultsForChart{get; set;} 
        public List<String> strList{get; set;} // The question's option as a list of string
        public List<Integer> resultsCounts {get; set;} // The count of each response to a question's choices
        public List<SelectOption> rowOptions {get; set;}
        public boolean noData{get; set;}
   
        public question(Survey_Question__c sq) {
            name = sq.Name;
            id = sq.id;
            question = sq.Question__c;
            orderNumber = String.valueOf(sq.OrderNumber__c+1);
            choices = sq.Choices__c;
            required = sq.Required__c;
            questionType = sq.Type__c;
            singleOptionsForChart = ' ';
            selectedOption = '';
            selectedOptions = new List<String>();
            if(sq.Type__c=='Single Select--Vertical') {
                renderSelectRadio='true';
                singleOptions = stringToSelectOptions(choices);
                renderSelectCheckboxes='false';
                renderFreeText='false';
                renderSelectRow = 'false';
                selectedOption = '';
                selectedOptions = new List<String>();                               
            } else if (sq.Type__c=='Multi-Select--Vertical') {        
                renderSelectCheckboxes='true';
                multiOptions = stringToSelectOptions(choices);
                renderSelectRadio='false';
                renderFreeText='false';
                renderSelectRow = 'false';
                selectedOption = '';
                selectedOptions = new List<String>();
            } else if (sq.Type__c=='Single Select--Horizontal') {   
                renderSelectCheckboxes='false';
                rowOptions = stringToSelectOptions(choices);
                renderSelectRadio='false';
                renderFreeText='false';
                renderSelectRow = 'true';
                selectedOption = '';
                selectedOptions = new List<String>();     
            } else if (sq.Type__c=='Free Text') {
                renderFreeText='true';
                renderSelectRadio='false';
                renderSelectCheckboxes='false';
                renderSelectRow = 'false';
                choices='';
            }
        }
     
        private List<SelectOption> stringToSelectOptions(String str) {
            if (str == '') {
                return new List<SelectOption>();
            }
            strList = str.split('\n');
            List<SelectOption> returnVal = new List<SelectOption>();
            Integer i = 0;
            for(String s: strList) {
                if (s!='') {    
                    if (s != 'null' && s!= null)  {
                        String sBis = s.replace(' ', '%20');
                        singleOptionsForChart += s.trim()+'|';
                        returnVal.add(new SelectOption(String.valueOf(i),s));
                        System.debug('*****VALUES: ' + s);
                        i++;
                    }
                }
            }
            singleOptionsForChart = singleOptionsForChart.substring(0, singleOptionsForChart.length()-1);
            return returnVal;
        } 
    }
}