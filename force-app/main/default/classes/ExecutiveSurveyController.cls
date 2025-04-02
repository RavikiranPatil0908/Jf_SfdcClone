/**
 * @File Name          : ExecutiveSurveyController.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 02-23-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    7/11/2019   @BK     Initial Version
**/
public without sharing class ExecutiveSurveyController {
    
    public String  qQuestion{get; set;}
    public String  qChoices{get; set;}
    public String surveyName{get; set;}
    public String surveyHeader{get; set;}
    public String studentNumber {get;set;}
    public String contactId {get;set;}
    public Boolean thankYouRendered{get;set;}
    public List<SurveyQuestionResponse__c> SurveyResponse{ get;set; }
    public String surveyId{get;set;}
    public List<SurveyController.question> allQuestions{get; set;}
    public Integer allQuestionsSize{get; set;}
    public Integer allRequiredQuestionSize {get;set;}
    public String  templateURL{get; set;}
    public String surveyTakerId {get;set;}
    public String  surveyThankYouText{get; set;}
    public String surveyContainerCss{get; set;}
    public String  surveyThankYouURL{get; set;}
    public Integer SurveyTime {get;set;}
    public String renderSurveyPreview{get; set;} 
    public String questionId {get;set;}
    public String otherOption {get;set;} 
    public Integer totalRespond {get;set;}
    public String LeadId {get;set;}
    public Lead objLead {get;set;}
    public String CounselorId {get;set;}
    public Counsellor_Profile__c objCounselor {get;set;}
    public Boolean AllowAddCheck {get;set;}
    public Decimal Marks { get; set; }
    public Decimal Total { get; set; }
    public Boolean returnMarks {get;set;}
    public Boolean showResponse {get;set;}
    public Boolean showResponseAfterSubmit {get;set;}
    public Boolean showAllQuestion { get;set; }
    public String type {get;set;}
    public Map<String,String> mapOfOrderVsId {get;set;}
    public Survey__c objSurvey {get;set;}
    
    public ExecutiveSurveyController() {
        otherOption = '';
        totalRespond = 0;
        SurveyTime = 0;
        AllowAddCheck = false;
        showResponse = false;
        showResponseAfterSubmit = false;
        showAllQuestion = false;
        allRequiredQuestionSize = 0;
        // By default the preview is not showing up
        renderSurveyPreview = 'false';
        SurveyResponse = new List<SurveyQuestionResponse__c>();
        mapOfOrderVsId = new Map<String,String>();
        objSurvey = new Survey__c();
        questionId = '';

        // Get url parameters
        surveyId = ApexPages.currentPage().getParameters().get('id');
        studentNumber = ApexPages.currentPage().getParameters().get('stnu');
        LeadId = ApexPages.currentPage().getParameters().get('lid');
        CounselorId = ApexPages.currentPage().getParameters().get('cpid');
        type = ApexPages.currentPage().getParameters().get('type');
        
        init();
    } 

    public void init() {
        if (String.isNotBlank(surveyId)) {
            List<Survey__c> lstSurvey = [SELECT Name,id,URL__c,Thank_You_Text__c,thankYouText__c,ShowResponseAfterSubmit__c,thankYouLink__c,Survey_Header__c,Survey_Container_CSS__c,Timer__c,Show_Result__c,Single_Question_PerPage__c FROM Survey__c WHERE id=:surveyId LIMIT 1];
            if(lstSurvey.size() > 0) {
                objSurvey = lstSurvey[0];
                objSurvey.id = null;
            }

            if(String.isNotBlank(studentNumber) && String.isNotBlank(contactid)){
                Contact cts = [SELECT id FROM Contact WHERE Account.nm_StudentNo__c=:studentNumber LIMIT 1];
                contactId = cts.id;
                System.debug('contactId'+contactId);
                if(String.isNotBlank(contactId)) AllowAddCheck = true;
            }else if(String.isNotBlank(LeadId)) {
                objLead = [SELECT id FROM Lead WHERE Id=:LeadId LIMIT 1];
                System.debug('LeadId'+objLead.id);
                if(String.isNotBlank(objLead.id)) AllowAddCheck = true;
            }else if(String.isNotBlank(CounselorId)) {
                objCounselor = [SELECT id,Exam_Done__c ,Exam_Taken__c FROM Counsellor_Profile__c WHERE id=:CounselorId LIMIT 1];
                System.debug('objCounselor'+objCounselor.id);
                if(String.isNotBlank(objCounselor.id)) AllowAddCheck = true;
            }else if(String.isNotBlank(type) && type=='test') {
                AllowAddCheck = true;
            }

            // Retrieve all necessary information to be displayed on the page
            allQuestions = new List<SurveyController.question>();
            setupQuestionList();
            setSurveyNameAndThankYou(surveyId);
            thankYouRendered=false;
            AddSurveyTaker(false);
        }       
    }


  /* Called during the setup of the page. 
       Retrieve questions and responses from DB and inserts them in 2 lists. */
    public Integer setupQuestionList() {
        getAQuestion();
        return allQuestions.size();
    }

  /* Fills up the List of questions to be displayed on the Visualforce page*/   
    public List<SurveyController.question> getAQuestion() {
        qQuestion = '';
        qChoices ='';
        
        List<Survey_Question__c> allQuestionsObject = 
                                        [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, 
                                        s.OrderNumber__c, s.Name,s.Choices__c
                                        From Survey_Question__c s 
                                        WHERE s.Survey__c =: surveyId ORDER BY s.OrderNumber__c];
        allQuestions = new List<SurveyController.question>();
        
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
            SurveyController.question theQ = new SurveyController.question(q);
            mapOfOrderVsId.put(theQ.orderNumber,theQ.id);
            theQ.id = null;
            allQuestions.add(theQ);
            if(q.Required__c) {
                allRequiredQuestionSize = allRequiredQuestionSize + 1;
            }
        }
        allQuestionsSize = allQuestions.size();
        return allQuestions;
    }   

    public void setSurveyNameAndThankYou(String sId) {
        Survey__c s = [SELECT Name, Id, URL__c, Thank_You_Text__c, thankYouText__c, ShowResponseAfterSubmit__c, thankYouLink__c, Survey_Header__c, Survey_Container_CSS__c, Timer__c,Show_Result__c, Single_Question_PerPage__c FROM Survey__c WHERE Id =:sId];
        surveyName = s.Name;
        surveyHeader = s.Survey_Header__c;
        templateURL = s.URL__c+'id='+sId;//+'&cId={!Contact.Id}'+'&caId='+'{!Case.id}';
        surveyThankYouText = s.Thank_You_Text__c;
        if (surveyThankYouText == null)
        {
            surveyThankYouText = System.Label.LABS_SF_Survey_Submitted_Thank_you;
        }
        surveyThankYouURL = s.thankYouLink__c;
        surveyContainerCss = s.Survey_Container_CSS__c;
        SurveyTime = Integer.valueOf(s.Timer__c);
        showResponse = s.Show_Result__c;
        showAllQuestion = !s.Single_Question_PerPage__c;
        showResponseAfterSubmit = s.showResponseAfterSubmit__c;
    }

    public Boolean AddSurveyTaker(Boolean checkToInsertFromSubmit) {

        if(String.isBlank(surveyId)) {
            return false;
        }else if(AllowAddCheck) {
            List<SurveyTaker__c> check = new List<SurveyTaker__c>();
            if(String.isNotBlank(contactId)){
                check = [Select Contact__c, Survey__c, Case__c, User__c, Total_Question_Respond__c, id From SurveyTaker__c Where Contact__c=:contactId and Survey__c=:surveyId];
            }else if(String.isNotBlank(LeadId) && !IsNullOrEmpty(objLead.id)) {
                check = [Select Survey__c, Case__c, User__c, Total_Question_Respond__c,Survey_Taken_By_Lead__c, id From SurveyTaker__c Where Survey_Taken_By_Lead__c=:objLead.id and Survey__c=:surveyId];
            }else if(String.isNotBlank(CounselorId) && !IsNullOrEmpty(objCounselor.id)){
                check = [Select Survey__c, Case__c, User__c, Total_Question_Respond__c,Counselor_Profile__c, id From SurveyTaker__c Where Counselor_Profile__c=:objCounselor.id and Survey__c=:surveyId];
            }  
            
            if(check != null && check.size() > 0){
                totalRespond = Integer.valueOf(check[0].Total_Question_Respond__c);
                System.debug('totalRespond-->'+totalRespond);
                if(totalRespond >= allRequiredQuestionSize){
                    if(showResponseAfterSubmit){
                        thankYouRendered = true;
                        queryResponse(String.valueOf(check[0].id),false); //To send the Survey taker id and false to update score
                    }else {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Hey! You seem to have already submitted your responses'));
                    }
                    return false; 
                }else {
                    surveyTakerId = check[0].id;
                    return true;
                }
            }else if(checkToInsertFromSubmit) {
                SurveyTaker__c st = new SurveyTaker__c();
                if(!IsNullOrEmpty(contactId)){
                    st.Contact__c = contactId;
                }else if(String.isNotBlank(LeadId) && !IsNullOrEmpty(objLead.id)) {
                    st.Survey_Taken_By_Lead__c = objLead.id;
                }else if(String.isNotBlank(CounselorId) && !IsNullOrEmpty(objCounselor.id)) {
                    st.Counselor_Profile__c = objCounselor.id;
                }
                st.Survey__c = surveyId;
                st.Taken__c = 'false';
                insert st; 
                surveyTakerId = st.Id;
                return true;    
            }
        }
        return true;
    }


    public void saveAndNext() {
        System.debug('ParamValue :'+ questionId);
        list<Counsellor_Profile__c> lstcpupdate = new list<Counsellor_Profile__c> ();
        if(String.isNotBlank(questionId) || showAllQuestion) {
            List <SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
            if(String.isBlank(surveyTakerId)) {
                AddSurveyTaker(true);
            }
            if(String.isNotBlank(surveyTakerId)) {
                Integer index = 0;
                for (SurveyController.question q : allQuestions) {
                    index++;
                    if(questionId == q.orderNumber || showAllQuestion) {
                        SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();

                        if (q.renderSelectRadio == 'true') {
                            if (q.selectedOption == null || q.selectedOption == '') {
                                sqr.Response__c = '';
                            }else {
                                sqr.Response__c = q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                                if(String.isNotBlank(otherOption)){
                                    sqr.Response_Text__c = q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel()+' : '+otherOption;
                                }else{
                                    sqr.Response_Text__c = q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                                }
                            }
                            sqr.Survey_Question__c = mapOfOrderVsId.get(q.orderNumber);
                            sqr.SurveyTaker__c = surveyTakerId;
                            sqr.OrderNumber__c = Decimal.valueOf(q.orderNumber);
                            sqrList.add(sqr);
                            if(allQuestionsSize == index) {
                                thankYouRendered = true;
                                System.debug('thankYouRendered-->'+thankYouRendered);
                                if(String.isNotBlank(CounselorId) && !IsNullOrEmpty(objCounselor.id)) {
                                        objCounselor.Exam_Done__c = true;
                                        objCounselor.Exam_Taken__c =system.today();
                                        lstcpupdate.add(objCounselor);
                                }
                            }
                            otherOption = '';
                        }else if (q.renderSelectCheckboxes == 'true') {
                            for (String opt : q.selectedOptions) {
                                sqr = new SurveyQuestionResponse__c();
                                if (opt == '' || opt == null) {
                                    sqr.Response__c = '';
                                }else {   
                                    //strSecToShow ='PopUpSuccess';
                                    sqr.Response__c = q.multiOptions.get(Integer.valueOf(opt)).getLabel();
                                    if(String.isNotBlank(otherOption) && q.multiOptions.get(Integer.valueOf(opt)).getLabel().trim() == 'Other'){
                                        sqr.Response_Text__c = q.multiOptions.get(Integer.valueOf(opt)).getLabel()+' : '+otherOption;
                                    }else{
                                        sqr.Response_Text__c = q.multiOptions.get(Integer.valueOf(opt)).getLabel();
                                    }
                                }
                                sqr.Survey_Question__c = mapOfOrderVsId.get(q.orderNumber);
                                sqr.SurveyTaker__c = surveyTakerId;
                                sqr.OrderNumber__c = Decimal.valueOf(q.orderNumber);
                                sqrList.add(sqr);
                            }
                            otherOption = '';
                        }else if(q.renderFreeText == 'true' && q.choices != null && q.choices != '') {
                            System.debug('q.choices-->'+q.choices);
                            sqr.Response__c = q.choices;
                            sqr.Response_Text__c = q.choices;
                            sqr.Survey_Question__c = mapOfOrderVsId.get(q.orderNumber);
                            sqr.SurveyTaker__c = surveyTakerId;
                            sqrList.add(sqr);
                        }
                    }
                }
                try {
                    insert sqrList;
                    System.debug('index-->'+index);
                    if(showAllQuestion){
                        thankYouRendered = true;
                    }
                    if(allQuestionsSize == index && showResponseAfterSubmit) {
                        queryResponse(surveyTakerId,true);
                    }
                    if(lstcpupdate.size()>0) {
                        update lstcpupdate;
                    }
                }catch (Exception e) {
                    Apexpages.addMessages(e);
                }
            }
        }
    }

    public void queryResponse(String surveyTakenId,Boolean checkToUpdateScore) {
        SurveyResponse = [select Marks__c,id,Survey_Question__r.Question__c,Survey_Question__r.Answer__c,Response_Text__c, Survey_Question__r.Type__c from SurveyQuestionResponse__c where SurveyTaker__c =:surveyTakenId];
        Marks = 0;
        if(SurveyResponse.size() > 0) {
            for (SurveyQuestionResponse__c objResponse : SurveyResponse) {
                // objResponse.id = null;
                System.debug('objResponse Answer==>'+objResponse.Survey_Question__r.Answer__c);
                Marks = objResponse.Survey_Question__r.Type__c == 'Multi-Select--Vertical' 
                ? Marks + (Decimal)stringToSelectOptions(objResponse) 
                : Marks + (Decimal)objResponse.Marks__c;
            }
        }
        // Marks = (Decimal) [Select Sum(Marks__c)aver  FROM SurveyQuestionResponse__c where SurveyTaker__c =:surveyTakenId][0].get('aver');
        Total = (Decimal)[Select Total_Question__c FROM SurveyTaker__c where id=:surveyTakenId][0].get('Total_Question__c');
    
        Marks = (Marks/Total)*100;
        Marks = Marks.setscale(2);
        System.debug('SurveyResponse ----->'+SurveyResponse );
        System.debug('Marks----->'+Marks);
        System.debug('Total----->'+Total);

        if(checkToUpdateScore){
            try {
                SurveyTaker__c st = new SurveyTaker__c();
                st.id = surveyTakenId;
                st.TotalMarksObtain__c = Marks;
                update st;
            }catch (Exception e) {
                Apexpages.addMessages(e);
            }
        }
    }


    public boolean IsNullOrEmpty(String fieldValue){
        if(fieldValue == null || fieldValue == ''){
            return true;
        }
        return false;
    }

    private Decimal stringToSelectOptions(SurveyQuestionResponse__c objResponse) {
        List<String> answerList = objResponse.Survey_Question__r.Answer__c.split(',');
        List<SelectOption> returnVal = new List<SelectOption>();
        Decimal marks = 0;
        Decimal optionsSize = answerList.size();
        if(objResponse.Marks__c > 0) {
            marks = (Decimal)(objResponse.Marks__c / optionsSize);
        }
        return marks;
    } 
}