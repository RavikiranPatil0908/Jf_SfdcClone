/**
 * @File Name          : EduvanzTrackLoanApplicationAPI.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 03-12-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    6/4/2019, 1:12:03 PM   shubhranshu     Initial Version
**/
@RestResource(urlMapping='/eduvanzTrackLoanApp/V1.1/*')
global without sharing class EduvanzTrackLoanApplicationAPI{

    public static Boolean subventionPrograms = false;
    public static Boolean TenureSelectedForSubvention = false;
    // public static Boolean TenureSelect2PerForSubvention = false;
    
    @HttpPost
    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @return List<MessageWrapper>
    */
    global static List<MessageWrapper> TrackEduVanzLoanStaus(){

        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>();
        API_Request__c apiReq = new API_Request__c();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        //Now as you have the request string You can parse it in APex
        JsonParser parser = JSON.createParser(requestString);
        EduVanzRequestWrapper reqWrapper = new EduVanzRequestWrapper(parser);
        System.debug('reqWrapper-->'+reqWrapper.Els_response);
        apiReq.Request__c = requestString;
        Els_response els_response = reqWrapper.Els_response[0];
        System.debug(els_response);
        String current_stage_code ='';
        String current_stage_name ='';
        String orderId ='';
        String lead_id ='';
        String URL_Post_approval_process ='';
        String UTRN_number ='';
        String disbursal_amount ='';
        String tranch_amount ='';
        String document_list='';
        String final_sanction_loan_amount ='';
        String sanctioned_amount = '';
        String IPA_status ='';
        String loan_tenure = '';
        String tranch_number = '';
        String disbursal_date = '';

        MessageWrapper messageWrapper = null;
        
        if(String.isNotBlank(els_response.current_stage_code)){
        current_stage_code =els_response.current_stage_code;
        }
        if(String.isNotBlank(els_response.current_stage_name)){
        current_stage_name =els_response.current_stage_name;
        }
        if(String.isNotBlank(els_response.meta_data)){
        orderId =els_response.meta_data;
        }else{
            messageWrapper = new MessageWrapper('501','meta data is missing.');
            lstmessageWrapper.add(messageWrapper);
            apiReq.Response__c = messageWrapper.toString();
            apiReq.Type_of_Request__c= 'EduVanz';
            apiReq.Success__c = false;
            apiRequestsInsertion(apiReq);
            return lstmessageWrapper;
        }
        if(String.isNotBlank(els_response.lead_id)){
            lead_id =els_response.lead_id;
        }
        if(String.isNotBlank(els_response.URL_Post_approval_process)){
            URL_Post_approval_process=els_response.URL_Post_approval_process;
        }
        if(String.isNotBlank(els_response.UTRN_number)){
            UTRN_number=els_response.UTRN_number;
        }
        if(String.isNotBlank(els_response.disbursal_amount)){
            disbursal_amount=els_response.disbursal_amount;
        }
        if(String.isNotBlank(els_response.tranch_amount)){
            tranch_amount=els_response.tranch_amount;
        }
        if(String.isNotBlank(els_response.document_list)){
            document_list=els_response.document_list;
        }
        if(String.isNotBlank(els_response.final_sanction_loan_amount)){
            final_sanction_loan_amount = els_response.final_sanction_loan_amount;
        }
        if(String.isNotBlank(els_response.sanctioned_amount)){
            sanctioned_amount = els_response.sanctioned_amount;
        }
        if(String.isNotBlank(els_response.IPA_status)){
            IPA_status = els_response.IPA_status;
        }
        if(String.isNotBlank(els_response.loan_tenure)){
            loan_tenure = els_response.loan_tenure;
        }
        if(String.isNotBlank(els_response.tranch_number)){
            tranch_number = els_response.tranch_number;
        }
        if(String.isNotBlank(els_response.disbursal_date)){
            disbursal_date = els_response.disbursal_date;
        }
        
        System.debug('current_stage_code-->'+current_stage_code+' lead_id-->'+lead_id+' current_stage_name-->'+current_stage_name+' orderId-->'+orderId+' URL_Post_approval_process-->'+URL_Post_approval_process+' UTRN_number-->'+UTRN_number+' disbursal_amount-->'+disbursal_amount+' tranch_amount-->'+tranch_amount+' document_list-->'+document_list +' final_sanction_loan_amount'+final_sanction_loan_amount+' sanctioned_amount'+sanctioned_amount+' IPA_status'+IPA_status);
        List<Opportunity> updateLstOpp=new List<Opportunity>();
        List<Opportunity> lstOpportunity = [select Id,Specialisation__c,Loan_Application_Cancelled__c,TermRepeated__c,nm_Fee_Type__c,EduVanz_last_update_status_date__c,Tenure__c,Loan_Amount__c,EduVanz_Current_Stage_Code__c,EduVanz_Current_Stage_Name__c,EduVanz_lead_id__c,Loan_Order_Id__c,Account.nm_ChooseaProgram__c,Account.Program_Type__c,ActualPendingAmount__c,ChooseProgram__c,LiveLecturesType__c,CourseList__c  from Opportunity where Loan_Order_Id__c=:orderId and Loan_Type__c='EduVanz' limit 1];
        
        List<Lead> updateLstLead=new List<Lead>();
        List<Lead> lstLead = new List<Lead>();
        if(lstOpportunity.size()>0){
        
        for(Opportunity opp:lstOpportunity){

            apiReq.Opportunity__c = opp.Id;
            if(current_stage_code !=null && current_stage_code !=''){
                opp.EduVanz_Current_Stage_Code__c = current_stage_code;
            }else{
                messageWrapper = new MessageWrapper('501','Current stage code is missing.');
                lstmessageWrapper.add(messageWrapper);
                apiReq.Response__c = messageWrapper.toString();
                apiReq.Type_of_Request__c= 'EduVanz';
                apiReq.Success__c = false;
                apiRequestsInsertion(apiReq);
                return lstmessageWrapper;
            }
            if(lead_id !=null && lead_id != ''){
                opp.EduVanz_lead_id__c = lead_id;
            }else{
                messageWrapper = new MessageWrapper('501','Lead Id is missing.');
                lstmessageWrapper.add(messageWrapper);
                apiReq.Response__c = messageWrapper.toString();
                apiReq.Type_of_Request__c= 'EduVanz';
                apiReq.Success__c = false;
                apiRequestsInsertion(apiReq);
                return lstmessageWrapper;
            }
            if(current_stage_name !=null && current_stage_name != ''){
                opp.EduVanz_Current_Stage_Name__c = current_stage_name;
                if(current_stage_name == 'Rejected' || current_stage_name == 'Dropped'){
                    String strResult = cancelLoanApplication('Opportunity',opp.EduVanz_lead_id__c,opp.Id,'Rejected');
                   // String strResults = EduvanzTrackLoanApplicationAPI.EducancelLoan(opp.EduVanz_lead_id__c, opp.Loan_Order_Id__c,opp.Id,'Opportunity' );
                    if(strResult == 'true'){
                        System.debug('Loan application cancelled successfully...');
                        return returnMessage(apiReq,requestString,'200','Loan Application Data updated.');
                    }else{
                        System.debug('Something went wrong while cancel the loan...'+strResult);
                        return returnMessage(apiReq,requestString,'504','Internal Error Occured.');
                    }               
                }else if(current_stage_name == 'Disbursed' && UTRN_number !=null && UTRN_number !='' && disbursal_amount !=null && disbursal_amount !='' && tranch_amount!=null && tranch_amount!=''){
                    System.debug('subventionProg--'+subventionPrograms +'opp.Account.nm_ChooseaProgram__c--'+opp.Account.nm_ChooseaProgram__c);
                    Tenure__c objTenure = getTenureForSubvention(opp.nm_Fee_Type__c,opp.Account.nm_ChooseaProgram__c,opp.Specialisation__c,opp.Tenure__c);
                    opp.Loan_Sanctioned__c  = true;
                    String liveLectureType = opp.LiveLecturesType__c;
                    String courseList = opp.CourseList__c;
                    List<String> lstallTermfeeProgram = new List<String>{'MBA - X','MBA (WX)','M.Sc. (AI & ML Ops)','M.Sc. (AI)'}; 
                    if(String.isNotBlank(opp.Specialisation__c) && lstallTermfeeProgram.contains(opp.Specialisation__c) && opp.nm_Fee_Type__c != 'AnnualFee' && opp.nm_Fee_Type__c != 'FullFee'){
                        opp.nm_Fee_Type__c = 'MBAallTermfee';
                    }
                    if(objTenure!=null && objTenure.Subvention_Value__c > 0){
                        createEduvanzLoanPayment(opp.Id,'Opportunity',UTRN_number,disbursal_amount,tranch_amount,liveLectureType,opp.Account.Program_Type__c,courseList,null);
                        System.debug('opp nm_Fee_Type__c ==>'+opp.nm_Fee_Type__c);
                        createEduvanzLoanAndSubventionPayment(opp.Id,'Opportunity',disbursal_amount,tranch_amount,opp.Loan_Amount__c,opp.ActualPendingAmount__c,objTenure);
                    }else{
                        createEduvanzLoanPayment(opp.Id,'Opportunity',UTRN_number,disbursal_amount,tranch_amount,liveLectureType,opp.Account.Program_Type__c,courseList,null);
                    }
                }else if(current_stage_name =='Approved'){
                    opp.Eduvanz_final_sanction_loan_amount__c = final_sanction_loan_amount;
                    opp.Loan_Amount__c = final_sanction_loan_amount;
                    opp.Tenure__c = loan_tenure;
                    if(opp.Loan_Application_Cancelled__c){
                        opp.Loan_Application_Cancelled__c = false;
                    }
                } else if(current_stage_name =='Tranch Disbursed' && UTRN_number !=null && UTRN_number !='' && disbursal_amount !=null && disbursal_amount !='' && tranch_amount!=null && tranch_amount!='' ) {
                    if(String.isNotBlank(tranch_number) && Integer.valueOf(tranch_number)  >= 2) {

                        nm_Payment__c paymentWaivedOff = additionalPaymentWaivedOff(opp.Id, tranch_amount);
                       if(paymentWaivedOff != null) {
                            nm_Payment__c objPayment = paymentWaivedOff;
                            Decimal tranchAmount = Decimal.valueOf(tranch_amount);
                            if(tranchAmount >= objPayment.nm_Amount__c) {
                                objPayment.nm_PaymentStatus__c = 'Payment Made';
                                objPayment.Eduvanz_tranch_amount__c = tranch_amount;
                                objPayment.Eduvanz_Disbursal_amount__c = disbursal_amount;
                               if(String.isNotBlank(disbursal_date)) {
                                   objPayment.nm_TransactionDate__c = Date.valueOf(disbursal_date);
                               } 
                                update objPayment;
    
                            }else {
                                messageWrapper = new MessageWrapper('500','Amount does not match');
                                lstmessageWrapper.add(messageWrapper);
                                apiReq.Response__c = messageWrapper.toString();
                                apiReq.Type_of_Request__c= 'EduVanz';
                                apiReq.Success__c = false;
                                apiRequestsInsertion(apiReq);
                                return lstmessageWrapper;
                            }
                        } else {
                            messageWrapper = new MessageWrapper('500','Meta data not matched, please try with different one.');
                            lstmessageWrapper.add(messageWrapper);
                            apiReq.Response__c = messageWrapper.toString();
                            apiReq.Type_of_Request__c= 'EduVanz';
                            apiReq.Success__c = false;
                            apiRequestsInsertion(apiReq);
                            return lstmessageWrapper;
                        }
                    } else {
                        messageWrapper = new MessageWrapper('500','Tranch number Should be greater than 1');
                            lstmessageWrapper.add(messageWrapper);
                            apiReq.Response__c = messageWrapper.toString();
                            apiReq.Type_of_Request__c= 'EduVanz';
                            apiReq.Success__c = false;
                            apiRequestsInsertion(apiReq);
                            return lstmessageWrapper;
                    }
                }
            }else{
                messageWrapper = new MessageWrapper('501','Current stage name is missing.');
                lstmessageWrapper.add(messageWrapper);
                apiReq.Response__c = messageWrapper.toString();
                apiReq.Type_of_Request__c= 'EduVanz';
                apiReq.Success__c = false;
                apiRequestsInsertion(apiReq);
                return lstmessageWrapper;
            }
            if(sanctioned_amount !=null && sanctioned_amount !=''){
                opp.Eduvanz_final_sanction_loan_amount__c = sanctioned_amount;
            }
            
            opp.EduVanz_last_update_status_date__c = DateTime.now();
            updateLstOpp.add(opp);
        }

        if(updateLstOpp.size()>0){

                System.debug('updateLstOpp-->'+updateLstOpp);
                try{
                    update updateLstOpp;
                    messageWrapper = new MessageWrapper('200','Loan Application Data updated.');
                    apiReq.Response__c = messageWrapper.toString();
                    apiReq.Type_of_Request__c= 'EduVanz';
                    apiReq.Success__c = true;
                }catch(Exception e){
                    messageWrapper = new MessageWrapper('504',e.getMessage());
                    apiReq.Response__c = messageWrapper.toString();
                    apiReq.Type_of_Request__c= 'EduVanz';
                    apiReq.Success__c = false;
                }
            }
        
        }else if(lstOpportunity.isEmpty() || lstOpportunity.size() ==0) {
            lstLead = [select Id,EduVanz_last_update_status_date__c,Loan_Application_Cancelled__c,EduVanz_Current_Stage_Code__c,EduVanz_Current_Stage_Name__c,nm_Fee_Type__c,EduVanz_lead_id__c,Loan_Order_Id__c,nm_ChooseaProgram__c,Program_Type__c,Tenure__c,Loan_Amount__c,LiveLecturesType__c,CourseList__c,nm_InformationCenter__r.ConsumerType__c,nm_Program__c,nm_Program__r.prgst__c from Lead where Loan_Order_Id__c=:orderId and Loan_Type__c='EduVanz' and IsDeleted = false limit 1];
            for(Lead ld:lstLead){

                apiReq.Lead__c= ld.Id;
                if(current_stage_code !=null && current_stage_code !=''){
                    ld.EduVanz_Current_Stage_Code__c = current_stage_code;
                }else{
                    messageWrapper = new MessageWrapper('501','Current stage code is missing.');
                    lstmessageWrapper.add(messageWrapper);
                    apiReq.Response__c = messageWrapper.toString();
                    apiReq.Type_of_Request__c= 'EduVanz';
                    apiReq.Success__c = false;
                    apiRequestsInsertion(apiReq);
                    return lstmessageWrapper;
                }
                if(lead_id !=null && lead_id != ''){
                    ld.EduVanz_lead_id__c = lead_id;
                }else{
                    messageWrapper = new MessageWrapper('501','Lead Id is missing.');
                    lstmessageWrapper.add(messageWrapper);
                    apiReq.Response__c = messageWrapper.toString();
                    apiReq.Type_of_Request__c= 'EduVanz';
                    apiReq.Success__c = false;
                    apiRequestsInsertion(apiReq);
                    return lstmessageWrapper;
                }
                if(current_stage_name !=null && current_stage_name != ''){
                    ld.EduVanz_Current_Stage_Name__c = current_stage_name;
                    if(current_stage_name == 'Rejected' || current_stage_name == 'Dropped'){
                        String strResult = cancelLoanApplication('Lead',ld.EduVanz_lead_id__c,ld.Id,'Rejected');
                        //String strResults = EduvanzTrackLoanApplicationAPI.EducancelLoan(ld.EduVanz_lead_id__c, ld.Loan_Order_Id__c,ld.Id,'Lead' );
                        if(strResult == 'true'){
                            System.debug('Loan application cancelled successfully...');
                            return returnMessage(apiReq,requestString,'200','Loan Application Data updated.');
                        }else{
                            System.debug('Something went wrong while cancel the loan...'+strResult);
                            return returnMessage(apiReq,requestString,'504','Internal Error Occured.');
                        }
                    }else if(current_stage_name == 'Disbursed' && UTRN_number !=null && UTRN_number !='' && disbursal_amount !=null && disbursal_amount !='' && tranch_amount!=null && tranch_amount!=''){
                        ld.Loan_Sanctioned__c = true;
                        String liveLectureType = ld.LiveLecturesType__c;
                        String courseList = ld.CourseList__c;
                        List<String> lstallTermfeeProgram = new List<String>{'MBA - X','MBA (WX)','M.Sc. (AI & ML Ops)','M.Sc. (AI)'}; 
                        Tenure__c objTenure = getTenureForSubvention(ld.nm_Fee_Type__c,ld.nm_ChooseaProgram__c,ld.Program_Type__c,ld.Tenure__c);
                        if(objTenure!=null && objTenure.Subvention_Value__c > 0){
                            createEduvanzLoanPayment(ld.Id,'Lead',UTRN_number,disbursal_amount,tranch_amount,liveLectureType,ld.Program_Type__c,courseList,ld);
                            System.debug('ld nm_Fee_Type__c ==>'+ld.nm_Fee_Type__c);
                            createEduvanzLoanAndSubventionPayment(ld.Id,'Lead',disbursal_amount,tranch_amount,ld.Loan_Amount__c,0,objTenure);
                        }else{
                            createEduvanzLoanPayment(ld.Id,'Lead',UTRN_number,disbursal_amount,tranch_amount,liveLectureType,ld.Program_Type__c,courseList,ld);
                        }
                    }else if(current_stage_name =='Approved'){
                        ld.Eduvanz_final_sanction_loan_amount__c = final_sanction_loan_amount;
                        ld.Loan_Amount__c = final_sanction_loan_amount;
                        ld.Tenure__c = loan_tenure;
                        if(ld.Loan_Application_Cancelled__c){
                            ld.Loan_Application_Cancelled__c = false;
                        }
                    }
                }else{
                    messageWrapper = new MessageWrapper('501','Current stage name is missing.');
                    lstmessageWrapper.add(messageWrapper);
                    apiReq.Response__c = messageWrapper.toString();
                    apiReq.Type_of_Request__c= 'EduVanz';
                    apiReq.Success__c = false;
                    apiRequestsInsertion(apiReq);
                    return lstmessageWrapper;
                }
                if(sanctioned_amount !=null && sanctioned_amount !=''){
                    ld.Eduvanz_final_sanction_loan_amount__c = sanctioned_amount;
                }
                ld.EduVanz_last_update_status_date__c = DateTime.now();
                updateLstLead.add(ld);
            }

            if(updateLstLead.size()>0) {
                System.debug('updateLstLead-->'+updateLstLead);
                try{
                    update updateLstLead;
                    messageWrapper = new MessageWrapper('200','Loan Application Data updated.');
                    apiReq.Response__c = messageWrapper.toString();
                    apiReq.Type_of_Request__c= 'EduVanz';
                    apiReq.Success__c = true;
                }catch(Exception e){
                    messageWrapper = new MessageWrapper('504',e.getMessage());
                    apiReq.Response__c = messageWrapper.toString();
                    apiReq.Type_of_Request__c= 'EduVanz';
                    apiReq.Success__c = false;
                }
            }else{
                messageWrapper = new MessageWrapper('500','Meta data not matched, please try with different one.');
                lstmessageWrapper.add(messageWrapper);
                apiReq.Response__c = messageWrapper.toString();
                apiReq.Type_of_Request__c= 'EduVanz';
                apiReq.Success__c = false;
                apiRequestsInsertion(apiReq);
                return lstmessageWrapper;
            }
        
        }else{
            messageWrapper = new MessageWrapper('500','Meta data not matched, please try with different one.');
            lstmessageWrapper.add(messageWrapper);
            apiReq.Response__c = messageWrapper.toString();
            apiReq.Type_of_Request__c= 'EduVanz';
            apiReq.Success__c = false;
            apiRequestsInsertion(apiReq);
            return lstmessageWrapper;
        }
    
        lstmessageWrapper.add(messageWrapper);
        apiRequestsInsertion(apiReq);
        return lstmessageWrapper;
    }

    /**
    * @description ---  api request record insert
    * @author shubhranshu | 8/20/2019
    * @param API_Request__c apiRequest
    * @return void
    */
    public static void apiRequestsInsertion(API_Request__c apiRequest){
         if(apiRequest != null){
            try {
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
    }

    public static Tenure__c getTenureForSubvention(String feeType,String chooseProgram,String Program_Type,String Tenure) {
        feeType = feeType == 'MBAallTermfee' || feeType == 'ReRegistrationPayment' ? 'Admission' : feeType;
        String key = chooseProgram+'-'+Program_Type+'-EduVanz-'+feeType;
        List<Tenure__c> lstTenures = [SELECT id,Subvention_Value__c,Tranche_Payment__c FROM Tenure__c WHERE Key__c=:key AND Tenure__c=:Tenure AND IsActive__c=true LIMIT 1];
        if(lstTenures.size() > 0 && lstTenures[0].Subvention_Value__c > 0) {
            return lstTenures[0];
        }
        return null;
    }

    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param String recordId
    * @param String objectType
    * @param String UTRN_number
    * @param String disbursal_amount
    * @param String tranch_amount
    * @param String Program_Type
    * @return void
    */
    public static void createEduvanzLoanPayment(String recordId,String objectType,String UTRN_number,String disbursal_amount,String tranch_amount,String livelectureType,String Program_Type,String courseList,Lead ld){

        Boolean paymentCreated = false;
        Decimal loan_amt= 0.0;
        
        if(Decimal.valueOf(tranch_amount) > 0){
            loan_amt = Decimal.valueOf(tranch_amount);
        }else{
            loan_amt = Decimal.valueOf(disbursal_amount);
        }
        
        // Decimal loan_amt = Decimal.valueOf(disbursal_amount);
        List<nm_Payment__c> lstPaymentToInsert = new List<nm_Payment__c>();
        
        if(String.isNotBlank(liveLectureType) && liveLectureType!='No') {
            Decimal liveLectureAmount = 0;
            nm_Payment__c liveLecturePayment = createLiveLecturePayment(recordId,UTRN_number,objectType,Decimal.valueOf(disbursal_amount),liveLectureType,courseList,ld,'NEFT - EduVanz');
            loan_amt = loan_amt - liveLecturePayment.nm_Amount__c;
            lstPaymentToInsert.add(liveLecturePayment);
        }

        nm_Payment__c payment = new nm_Payment__c();
        Decimal disAmount= Decimal.ValueOf(disbursal_amount);
        Decimal tranAmount= Decimal.ValueOf(tranch_amount);
        //subventionPrograms = checkSubventionSchemePrograms(Program_Type);
        if(objectType == 'Lead'){
            payment.nm_ModeOfPayment__c = 'NEFT - EduVanz';
            payment.nm_Merchant_Track_Id__c=UTRN_number;
           
            payment.nm_Amount__c=loan_amt;
            payment.nm_ActualPaymentAmmount__c=loan_amt;
            payment.Eduvanz_Disbursal_amount__c=disbursal_amount;
            payment.Eduvanz_tranch_amount__c=tranch_amount;
            payment.nm_PaymentStatus__c ='Payment Made'; 
            payment.nm_PaymentType__c = 'Admission';
            payment.nm_Lead__c=recordId;
            
        }else if(objectType == 'Opportunity'){
            payment.nm_ModeOfPayment__c = 'NEFT - EduVanz';
            payment.nm_Merchant_Track_Id__c=UTRN_number;
          
            payment.nm_Amount__c=loan_amt;
            payment.nm_ActualPaymentAmmount__c=loan_amt;
            payment.Eduvanz_Disbursal_amount__c=disbursal_amount;
            payment.Eduvanz_tranch_amount__c=tranch_amount;
            payment.nm_PaymentStatus__c ='Payment Made'; 
            payment.nm_PaymentType__c = 'Admission';
            payment.nm_OpportunityNew__c=recordId;
        }
        if(payment.nm_Amount__c> 0 ){
            lstPaymentToInsert.add(payment);
        }

        if(lstPaymentToInsert.size() > 0 && paymentCreated == false && payment.nm_Amount__c > 0){
            System.debug('paymnet record details-->'+lstPaymentToInsert+' paymentCreated '+paymentCreated);
            try{
                List<nm_Payment__c> nm_pay = [select Id , nm_ModeOfPayment__c , nm_PaymentStatus__c , nm_PaymentType__c from nm_Payment__c where (nm_OpportunityNew__c =: recordId or nm_Lead__c =:recordId) and nm_ModeOfPayment__c ='NEFT - EduVanz' and nm_PaymentType__c!='Live Lectures' and ( nm_PaymentStatus__c ='Payment Made' or nm_PaymentStatus__c ='Payment Approved' ) limit 1];    

                if(nm_pay.size()>0){
                    paymentCreated = true;
                }
                insert lstPaymentToInsert;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }else{
            System.debug('payment already created --'+paymentCreated);
        }
    }

    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param String recordId
    * @param String objectType
    * @param String UTRN_number
    * @param String disbursal_amount
    * @param String tranch_amount
    * @param String Tenure
    * @param String Loan_amount
    * @return void
    */
    public static void createEduvanzLoanAndSubventionPayment(String recordId,String objectType,String disbursal_amount,String tranch_amount,String Loan_amount,Decimal ActualPendingAmount, Tenure__c objTenure){

        Boolean paymentCreated = false;
        Decimal loan_amt = 0.0;

        if(Decimal.valueOf(tranch_amount) > 0){
            loan_amt = Decimal.valueOf(tranch_amount);
        }else{
            loan_amt = Decimal.valueOf(disbursal_amount);
        }
        
        List<nm_Payment__c> nm_pay = [select Id , nm_ModeOfPayment__c , nm_PaymentStatus__c , nm_PaymentType__c from nm_Payment__c where (nm_OpportunityNew__c =: recordId or nm_Lead__c =:recordId) and nm_PaymentType__c = 'EduVanz Subvention' and nm_PaymentStatus__c = 'Waived Off' limit 1];    

        if(nm_pay.size()>0){
            paymentCreated = true;
        }

        nm_Payment__c payment = new nm_Payment__c();
        Decimal subvention_amt = 0.0;
        Decimal ActualLoan_amount = Decimal.ValueOf(Loan_amount);
        if(objTenure!=null) {
            subvention_amt = ((ActualLoan_amount * objTenure.Subvention_Value__c) /100);
        }
        String s = String.valueOf(subvention_amt); // assuming you meant to use d here
        if(s.contains('.')){
            String afterDecimal = s.substringAfter('.');
            if(Integer.valueOf(afterDecimal)>0.0){
                subvention_amt = subvention_amt.round(System.RoundingMode.UP);
            }
        }
        
        System.debug('subvention_amt '+subvention_amt);
        

        if(objectType == 'Lead'){
            // payment.nm_Merchant_Track_Id__c=UTRN_number;
            payment.nm_Amount__c=subvention_amt;
            payment.nm_ActualPaymentAmmount__c=subvention_amt;
            payment.Eduvanz_Disbursal_amount__c=disbursal_amount;
            payment.Eduvanz_tranch_amount__c=tranch_amount;
            payment.nm_PaymentStatus__c ='Waived Off'; 
            payment.nm_PaymentType__c = 'EduVanz Subvention';
            payment.nm_Lead__c=recordId;
            System.debug('success for subvention');
            
        }else if(objectType == 'Opportunity'){
            // payment.nm_Merchant_Track_Id__c=UTRN_number;
            payment.nm_Amount__c=subvention_amt;
            payment.nm_ActualPaymentAmmount__c=subvention_amt;
            payment.Eduvanz_Disbursal_amount__c=disbursal_amount;
            payment.Eduvanz_tranch_amount__c=tranch_amount;
            payment.nm_PaymentStatus__c ='Waived Off'; 
            payment.nm_PaymentType__c = 'EduVanz Subvention';
            payment.nm_OpportunityNew__c=recordId;
     
        }

        if(payment != null && paymentCreated == false && payment.nm_Amount__c > 0){
            System.debug('paymnet record details-->'+payment+'paymentCreated '+paymentCreated);
            try{
                insert payment;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }else{
            System.debug('payment already created --'+paymentCreated);
        }

        if(objTenure!=null && objTenure.Tranche_Payment__c && ActualPendingAmount >0){
            createAdditionalPaymentRecord(ActualPendingAmount,recordId,objectType,String.valueOf(loan_amt));
        }
        
    }

    public static void createAdditionalPaymentRecord(Decimal ActualPendingAmount,String recordId,String objectType,String disbursal_amount){
        Boolean paymentCreated = false;
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        if(objectType == 'Opportunity'){
            lstOpportunity = [select Id,Account.Program_Type__c,ActualPendingAmount__c from Opportunity where Id=:recordId and Loan_Type__c='EduVanz' limit 1];
        }
        List<nm_Payment__c> nm_pay = [select Id , nm_ModeOfPayment__c , nm_PaymentStatus__c , nm_PaymentType__c from nm_Payment__c where (nm_OpportunityNew__c =: recordId or nm_Lead__c =:recordId) and nm_PaymentType__c = 'Additional Charge' and nm_PaymentStatus__c = 'Waived Off' limit 1];    

        if(nm_pay.size()>0){
            paymentCreated = true;
        }

        nm_Payment__c payment = new nm_Payment__c();
     
        if(objectType == 'Lead'){
            payment.nm_Amount__c = Integer.valueof(disbursal_amount);
            payment.nm_ActualPaymentAmmount__c = Integer.valueof(disbursal_amount);
            payment.nm_PaymentStatus__c ='Waived Off';
            payment.nm_PaymentType__c = 'Additional Charge';
            payment.nm_Lead__c=recordId; 

        }else if(objectType == 'Opportunity'){
            payment.nm_Amount__c = Integer.valueof(disbursal_amount);
            payment.nm_ActualPaymentAmmount__c = Integer.valueof(disbursal_amount);
            payment.nm_PaymentStatus__c ='Waived Off';
            payment.nm_PaymentType__c = 'Additional Charge';
            payment.nm_OpportunityNew__c=recordId;
     
        }

        if(payment != null && paymentCreated == false  && payment.nm_Amount__c > 0){
            System.debug('paymnet record details-->'+payment+'paymentCreated '+paymentCreated);
            try{
                insert payment;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }else{
            System.debug('payment already created --'+paymentCreated);
        }
    }

    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param String programType
    * @param String Tenure
    * @return Boolean
    */
    public static Boolean checkTenureForSubvention(String programType,String Tenure,String ChooseProgram,String feeType){

        NM_Payment_Form_Configuration__c nm_paymentConfig = new NM_Payment_Form_Configuration__c();
        if(ChooseProgram == 'MBA (Distance) Programs'){
            nm_paymentConfig = [Select Id,allow_tenure_for_zero_percent__c,allow_tenure_12_for_zero_percent__c from NM_Payment_Form_Configuration__c where Program_Category__c =:programType limit 1];
        }else{
            nm_paymentConfig = [Select Id,allow_tenure_for_zero_percent__c,allow_tenure_12_for_zero_percent__c from NM_Payment_Form_Configuration__c where Program_Type__c =:programType limit 1];
        }
        if(nm_paymentConfig != null && nm_paymentConfig.id !=null ){
            String programStr = nm_paymentConfig.allow_tenure_for_zero_percent__c;
            List<String> lstOfSubventionTenure = programStr.split(',');
            System.debug('lstOfSubventionTenure '+lstOfSubventionTenure);
            if(String.isNotBlank(programType) && JSON.serialize(lstOfSubventionTenure).contains(Tenure) ){
                 return true;
            }else if(ChooseProgram == 'MBA (Distance) Programs' && feeType =='FullFeeLoan' && JSON.serialize(lstOfSubventionTenure).contains(Tenure)){
                return true;
            }else{
                return false;
            }
        }
        return false;
    }

    // public static Boolean checkSubventionWith2PerSchemePrograms(String programType,String Tenure){

    //     String checkSubventionPrograms = System.Label.Subvention_With_18_by_2;
    //     List<String> keys = checkSubventionPrograms.split(',');
    //     if(String.isNotBlank(programType) && JSON.serialize(keys).contains(programType) && Tenure == '18')
    //     {
    //       return true;
    //     }else{
    //         return false;
    //     }
    // }

    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param String programSpecialization
    * @return Boolean
    */
    public static Boolean checkSubventionSchemePrograms(String programSpecialization){

        String checkSubventionPrograms = System.Label.Subvention_Scheme_Programs;
        List<String> keys = checkSubventionPrograms.split(',');
        if(String.isNotBlank(programSpecialization) && JSON.serialize(keys).contains(programSpecialization))
        {
          return true;
        }else{
            return false;
        }
    }

    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param String errorCode
    * @param String message
    * @return class
    */
    global class MessageWrapper{

        public String errorCode;
        public String message;        
        global MessageWrapper(String errorCode,String message){
            this.errorCode = errorCode;
            this.message = message;
        }
    }

    public class EduVanzRequestWrapper {
    
        public List<Els_response> els_response {get;set;} 
        private EduvanzTrackLoanApplicationAPI eduVanzAPI;

        public EduVanzRequestWrapper(){
            
        }
        public EduVanzRequestWrapper(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'els_response') {
                                els_response = arrayOfEls_response(parser);
                            } else {
                                System.debug(LoggingLevel.WARN, 'EduVanzRequestWrapper consuming unrecognized property: '+text);
                                eduVanzAPI.consumeObject(parser);
                            }
                        }
                    }
                }
            }
                     
            // public  EduVanzRequestWrapper parse(String json) {
            //     System.JSONParser parser = System.JSON.createParser(json);
            //     return new EduVanzRequestWrapper(parser);
            // }

        private List<Els_response> arrayOfEls_response(System.JSONParser p) {
            List<Els_response> res = new List<Els_response>();
            if (p.getCurrentToken() == null) p.nextToken();
            while (p.nextToken() != System.JSONToken.END_ARRAY) {
                res.add(new Els_response(p));
            }
            return res;
        }  
    }

    public class Els_response {

        private EduvanzTrackLoanApplicationAPI eduVanzAPI;
        public String current_stage_code {get;set;} 
        public String lead_id {get;set;} 
        public String current_stage_name {get;set;} 
        public String meta_data {get;set;} 
        public String URL_Post_approval_process {get;set;}
        public String UTRN_number {get;set;}
        public String disbursal_amount {get;set;}
        public String tranch_amount {get;set;}
        public String document_list {get;set;} 
        public String final_sanction_loan_amount {get;set;}
        public String sanctioned_amount {get;set;}
        public String IPA_status {get;set;}
        public String loan_tenure {get;set;}
        public String tranch_number {get;set;}
        public String disbursal_date {get;set;}

        public Els_response() {}

        public Els_response(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'current_stage_code') {
                            current_stage_code = parser.getText();
                        } else if (text == 'lead_id') {
                            lead_id = parser.getText();
                        } else if (text == 'current_stage_name') {
                            current_stage_name = parser.getText();
                        } else if (text == 'meta_data') {
                            meta_data = parser.getText();
                        } else if (text == 'URL_Post_approval_process') {
                            URL_Post_approval_process = parser.getText();
                        } else if (text == 'UTRN_number') {
                            UTRN_number = parser.getText();
                        } else if (text == 'disbursal_amount') {
                            disbursal_amount = parser.getText();
                        } else if (text == 'tranch_amount') {
                            tranch_amount = parser.getText();
                        } else if (text == 'document_list') {
                            document_list = parser.getText();
                        } else if(text == 'final_sanction_loan_amount'){
                            final_sanction_loan_amount = parser.getText();
                        }else if(text == 'sanctioned_amount'){
                            sanctioned_amount = parser.getText();
                        }else if (text == 'IPA_status'){
                            IPA_status = parser.getText();
                        }else if (text == 'loan_tenure'){
                            loan_tenure = parser.getText();
                        }else if (text == 'tranch_number'){
                            tranch_number = parser.getText();
                        }else if (text == 'disbursal_date'){
                            disbursal_date = parser.getText();
                        }else {
                            System.debug(LoggingLevel.WARN, 'Els_response consuming unrecognized property: '+text);
                            // eduVanzAPI.consumeObject(parser);
                        }
                    }
                }
            }
        }
       
    }

    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param System.JSONParser parser
    * @return void
    */
    public void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }


    public static String cancelLoanApplication(String objectType,String loan_id,String recordId,String status){

        System.debug('loan_id ==>'+loan_id+' objectType ==>'+objectType);
        List<nm_Payment__c> downLoanPaymentLst = new List<nm_Payment__c>();
        List<Opportunity> opplst = new List<Opportunity>();
        List<Opportunity> updateOpplst = new List<Opportunity>();
        List<Lead> leadlst = new List<Lead>();
        List<Lead> updateLeadlst = new List<Lead>();
        String result = '';
        if(String.isNotBlank(loan_id) && String.isNotBlank(objectType)) {
            if(objectType == 'Opportunity'){
                downLoanPaymentLst = [SELECT id,nm_PaymentType__c,nm_Installment_Payment_Ref__c FROM nm_Payment__c WHERE nm_OpportunityNew__r.EduVanz_lead_id__c=:loan_id AND (nm_PaymentType__c LIKE '%DownPayment%') LIMIT 1];    
                opplst = [SELECT Id,Loan_Application_Cancelled__c,Down_Payment_Made__c,nm_Semester__c,Loan_Cancellation_Reason__c,nm_Fee_Type__c,Loan_Type__c,Loan_Order_Id__c,EduVanz_lead_id__c,Zest_Loan_Application_Request__c from Opportunity WHERE Id=: recordId LIMIT 1];
            }else if(objectType == 'Lead'){
                downLoanPaymentLst = [SELECT id,nm_PaymentType__c,nm_Installment_Payment_Ref__c FROM nm_Payment__c WHERE nm_Lead__r.EduVanz_lead_id__c=:loan_id AND (nm_PaymentType__c LIKE '%DownPayment%') LIMIT 1];    
                leadlst = [SELECT Id,Loan_Application_Cancelled__c,Down_Payment_Made__c,Loan_Cancellation_Reason__c,nm_Fee_Type__c,Loan_Type__c,Loan_Order_Id__c,EduVanz_lead_id__c from Lead WHERE Id=: recordId LIMIT 1];
            }
            
            System.debug('downLoanPaymentLst '+downLoanPaymentLst+' opplst '+opplst+' leadlst '+leadlst);
            if(downLoanPaymentLst.size() > 0 && (opplst.size() > 0 || leadlst.size() > 0)) {

                String installmentReference = 'Installment-admission';
                String loanType = '';
                String loanOrderId = '';
                String feeType = '';

                if(objectType == 'Lead'){
                    for(Lead objLead:leadlst){
                        System.debug('objLead-->'+objLead);
                        objLead.Down_Payment_Made__c = false;
                        objLead.Loan_Cancellation_Reason__c = 'do not want to opt for loan';
                        objLead.nm_Fee_Type__c = 'registration';
                        objLead.Loan_Order_Status__c = status;
                        loanType = objLead.Loan_Type__c;
                        loanOrderId = objLead.Loan_Order_Id__c;
                        updateLeadlst.add(objLead);
                    }
                }
                else if(objectType == 'Opportunity'){
                    for(Opportunity objOpportunity:opplst){
                        System.debug('objOpportunity -->'+objOpportunity);
                        objOpportunity.Loan_Application_Cancelled__c = true;
                        objOpportunity.Down_Payment_Made__c = false;
                        objOpportunity.Loan_Order_Status__c = status;
                        objOpportunity.Loan_Cancellation_Reason__c = 'do not want to opt for loan';
                        feeType = 'registration';
                        if(objOpportunity.nm_Semester__c != '1') {
                            feeType = 'ReRegistrationPayment';
                        }
                        if(!String.isNotBlank(objOpportunity.nm_Fee_Type__c) && !objOpportunity.nm_Fee_Type__c.equalsIgnoreCase('MBAallTermfee-Considered')) {
                            objOpportunity.nm_Fee_Type__c = feeType;
                        }
                        installmentReference = 'Installment-'+feeType;
                        loanType = objOpportunity.Loan_Type__c;
                        loanOrderId = objOpportunity.Loan_Order_Id__c;
                        if(loanType.equalsIgnoreCase('Propelld') || loanType.equalsIgnoreCase('EzCred')) {
                            objOpportunity.Zest_Loan_Application_Request__c = '';
                        }
                        updateOpplst.add(objOpportunity);
                    }
                }

                nm_Payment__c downLoanPayment = downLoanPaymentLst[0];
                downLoanPayment.nm_PaymentType__c = 'Installment';
                downLoanPayment.nm_Installment_Payment_Ref__c = installmentReference;

                try {
                    if(updateLeadlst.size() > 0) {
                        // To update Lead
                        update updateLeadlst;
                    } else if(updateOpplst.size() > 0) {
                        // To update opportunity
                        update updateOpplst;
                    }
                    // To update payment record.
                    update downLoanPayment;

                } catch (Exception e) {
                    System.debug(e.getMessage());
                    return null;
                }
                result = 'true';
            } else {
                result = 'false';
            }
        }
        return result;
    }
   
    public static String EducancelLoan(String lead_id,String meta_data ,String recordId,String recordType){    
        // to save the logs
        API_Request__c apiReq = new API_Request__c(); 
        String formDataURL = '{"lead_id":"'+lead_id +'","meta_data":"'+meta_data+'","drop_msg":"1"}';
        apiReq.Request__c = formDataURL;
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
         System.debug('formDataURL --->'+formDataURL ); 
        req.setEndpoint(System.label.EduvanzCancelLoanAPI);
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setBody(formDataURL);
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('LoanApplications_API__c:statusCode = '+statusCode);
            if(statusCode == 200){
                String result = resp.getBody();
                System.debug('result ==>'+result);
                apiReq.Response__c = result;
                apiReq.API_Name__c = 'EduvanzCancelLoanApplicationAPI';
                apiReq.Type_of_Request__c = 'EduVanz';
                if(recordType == 'Lead'){
                    apiReq.Lead__c = recordId;
                }else{
                    apiReq.Opportunity__c = recordId;
                }
                
                Map<String,Object> mapOfResponseParameters = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
                if(!mapOfResponseParameters.isEmpty()){
                    String LoanCancelled = String.valueOf(mapOfResponseParameters.get('status_code'));
                    System.debug('LoanCancelled ==>'+LoanCancelled);
                    if(LoanCancelled=='1'){
                        apiReq.Success__c = true;
                        System.debug('apiReq '+apiReq);
                        apiRequestsInsertion(apiReq);
                        return 'success';
                    }else {
                        System.debug('apiReq '+apiReq);
                        apiRequestsInsertion(apiReq);
                    }
                }
            }else{
                System.debug('LoanApplications_API__c Error :'+resp.getBody());
                apiReq.Response__c = resp.getBody();
                apiReq.API_Name__c = 'EduvanzCancelLoanApplicationAPI';
                apiReq.Type_of_Request__c = 'EduVanz';
                if(recordType == 'Lead'){
                    apiReq.Lead__c = recordId;
                }else{
                    apiReq.Opportunity__c = recordId;
                }
                apiRequestsInsertion(apiReq);
            }
        }catch(Exception e){
            System.debug('Callout Exception LoanApplications_API__c :'+e.getMessage());
        }
        return null;
    }

    public static nm_Payment__c additionalPaymentWaivedOff(String oppId, String tranch_amount) {
        List<nm_Payment__c> paymentWaivedOff =[SELECT Id, nm_Amount__c FROM nm_Payment__c WHERE nm_OpportunityNew__c=:oppId AND nm_PaymentStatus__c = 'Waived Off' AND nm_PaymentType__c = 'Additional Charge' LIMIT 1 ] ;
        if(paymentWaivedOff.size() > 0) {
            return paymentWaivedOff[0];
        } else {
            return null;
        }
    }

    webservice static nm_Payment__c createLiveLecturePayment(String recordId, String UTR,String objectType,Decimal amount,String liveLectureType,String courseList,Lead ld,String ModeOfPayment) {
        Decimal liveLectureAmount = 0;
    // List<opportunity> opp = [select Id,Specialisation__c,Loan_Application_Cancelled__c,TermRepeated__c,nm_Fee_Type__c,EduVanz_last_update_status_date__c,Tenure__c,Loan_Amount__c,EduVanz_Current_Stage_Code__c,EduVanz_Current_Stage_Name__c,EduVanz_lead_id__c,Loan_Order_Id__c,Account.nm_ChooseaProgram__c,Account.Program_Type__c,ActualPendingAmount__c,ChooseProgram__c,CourseList__c  from Opportunity where (Id=:recordId and LiveLecturesType__c!=null) and Loan_Type__c='EduVanz' limit 1];
        nm_Payment__c liveLecturePayment = new nm_Payment__c();
        if(objectType == 'Lead') {
            liveLecturePayment.nm_Lead__c = recordId;
            ProductHelper productHelper = new ProductHelper();
            Map<String,Map<String,PriceBookEntry>> getMapOfPriceBookIdProductVsPriceBookEntry = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
            Map<String,PriceBookEntry> mapOfPricebook = getMapOfPriceBookIdProductVsPriceBookEntry.get(null);
            Decimal liveLecturePrice =  mapOfPricebook.containskey('Live Lectures') ? mapOfPricebook.get('Live Lectures').UnitPrice : 0;
            if('Certificate Programs'.equalsIgnoreCase(ld.nm_ChooseaProgram__c) && liveLecturePrice > 0) {
                liveLecturePrice = liveLecturePrice + (liveLecturePrice * Decimal.valueOf(Label.Service_Tax).setScale(2));
            }
            liveLectureAmount = liveLecturePrice;
            if(liveLectureType == 'Custom') {
                liveLectureAmount = liveLecturePrice * courseList.split(',').size();
            } else {
                Decimal totalSubjects = productHelper.TotalNumberOfSubject(1,ld.nm_Program__r.prgst__c,ld.nm_Program__c,liveLectureType,'',ld.nm_InformationCenter__r.ConsumerType__c);
                liveLectureAmount = liveLecturePrice * totalSubjects;
            }
        } else {
            List<OpportunityLineItem> lstOppLineItem = [SELECT Opportunity.Name, Product2.Name, id, TotalPrice,Quantity,ActualSalePrice__c FROM OpportunityLineItem WHERE Opportunity.Id =:recordId AND Product2.Name='Live Lectures' LIMIT 1];
            if(lstOppLineItem.size() > 0) {
                liveLectureAmount = lstOppLineItem[0].ActualSalePrice__c;
            }
            liveLecturePayment.nm_OpportunityNew__c = recordId;
        }
        liveLecturePayment.nm_ModeOfPayment__c = ModeOfPayment;
        liveLecturePayment.nm_ActualPaymentAmmount__c = amount;
        liveLecturePayment.nm_Amount__c = liveLectureAmount;
        liveLecturePayment.nm_Merchant_Track_Id__c = UTR;
        liveLecturePayment.nm_PaymentType__c = 'Live Lectures';
        liveLecturePayment.nm_PaymentStatus__c = 'Payment Made';
        return liveLecturePayment;
    }

    public static List<MessageWrapper> returnMessage(API_Request__c apiReq, String requestString, String code, String msg) {
        if(apiReq==null) {
            apiReq = new API_Request__c();
        }
        MessageWrapper messageWrapper = new MessageWrapper(code,msg);
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>{messageWrapper};
        apiReq.Request__c = requestString;
        apiReq.Response__c = messageWrapper.toString();
        apiReq.Type_of_Request__c= 'EduVanz';
        apiReq.API_Name__c='EduVanzWebhookAPI';
        apiReq.Success__c = false;
        apiRequestsInsertion(apiReq);
        return lstmessageWrapper;
    }
}