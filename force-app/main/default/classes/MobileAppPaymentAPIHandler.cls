/**
 * @description       : 
 * @author            : @Ravi
 * @group             : @Self
 * @last modified on  : 13--02--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   29--09--2025   @Ravi   Initial Version
**/
public without sharing class MobileAppPaymentAPIHandler {

    public string reqURL='';
    public string recId ='';
    public string loanDetailresult;
    public boolean isSuccess =false;
    public string strMessage = '';
    public string strPaymentType ='';
    public string userAgent='';
    public string ipAddress ='';

    /**
    * @description 
    * @author @Ravi | 16--10--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob getPaymentDetails(String url, String jsonString) {
        Map<String,Object> mapOfRequestParameters =(Map<String,Object>)JSON.deserializeUntyped(jsonString);
        Set<String> setRequiredParameters = new Set<String>{'recordId'};
        recId = String.valueOf(mapOfRequestParameters.get('recordId'));

       try {
            if(!validateRequest(setRequiredParameters, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }

            if(System.Label.Disabled_Payment_Option_on_the_Admission_App == 'TRUE') {
                return  buildResponse('Error','Payment option is temporarily unavailable.Please try again after some time', null);
            }
            PaymentPageController controller =new PaymentPageController();
            PaymentDataWrapper wrapper =new PaymentDataWrapper();
            controller.setObjectId(recId);
            wrapper.objPaymentFormConfiguration = controller.objPaymentFormConfiguration;
            wrapper.objPayment = controller.objPayment;
            wrapper.objLoanDetails = controller.objLoanDetails;
            wrapper.objDetails = controller.objDetails;
            wrapper.objStudentDetails = controller.objStudentDetails;
            wrapper.objCoursera = controller.objCoursera;
            wrapper.objfee = controller.objfee;
            wrapper.objLiveLecturePayment = controller.objLiveLecturePayment;
            wrapper.objAdmissionAmount = controller.objAdmissionAmount;
            // wrapper.objReReg =controller.objReReg;
            wrapper.programSpecialization =controller.programSpecialization;
            wrapper.programCategory =controller.programCategory; 
            wrapper.semester = wrapper.semester;
            wrapper.setOfApplicablePaymentOptionForStudent = controller.setOfApplicablePaymentOptionForStudent;
            // wrapper.jsonMapOfProductAndAmount = controller.mapOfProductAndAmount;   // setting map as itis 
            // wrapper.jsonMapOfLectureTypeAndSubjects =controller.jsonMapOfLectureTypeAndSubjects;
            wrapper.mapOfCourseKeyVsCurrentCourseObj =controller.mapOfCourseKeyVsCurrentCourseObj;
            wrapper.sizeOfMapOfBacklogCourseIdVsBacklogObject =controller.sizeOfMapOfBacklogCourseIdVsBacklogObject;
            wrapper.mapOfBacklogCourseIdVsBacklogObject =controller.mapOfBacklogCourseIdVsBacklogObject;
            wrapper.paymentFor =controller.paymentFor;
            wrapper.mapOfProductAndAmount=controller.mapOfProductAndAmount;  //jsonMapOfProductAndAmount
            wrapper.setOfPaymentOptionsAvailable =controller.setOfPaymentOptionsAvailable;
            wrapper.isReregistartion =controller.IsReregistartion;
            wrapper.paymentGateWayName =controller.paymentGateWayName;
            wrapper.depositAmount =controller.depositAmount;
            wrapper.isHOForMakingPayment= controller.IsHOForMakingPayment;
            wrapper.isICForMakingPayment =controller.IsICForMakingPayment;

            wrapper.strSecToShow =controller.strSecToShow;
            wrapper.errMessages =controller.errMessages;
            wrapper.isFormSubmitted =controller.isFormSubmitted;
            wrapper.returnUrl =controller.returnUrl;
            wrapper.gatewayMessages =controller.gatewayMessages;
            loanDetailresult=GetLoanDetailsService.getLoanDetails(controller.programCategory);
            if(String.isNotBlank(loanDetailresult)){
                wrapper.loanDetailsobject =JSON.deserializeUntyped(loanDetailresult);
            }else {
                wrapper.loanDetailsobject =null;
            }
            return buildResponse('Success','Fetched payment details.',wrapper);

       } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error :' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recId);
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
       }
    }
  
    /**
    * @description 
    * @author @Ravi | 16--10--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob proceedDirectToLoan(String url , String jsonString) {
        Map<String,Object> mapOfRequestParameters =(Map<String,Object>)JSON.deserializeUntyped(jsonString);
        Set<String> setRequiredParameters = new Set<String>{'recordId','objLoanDetails','paymentFor'};
        recId = String.valueOf(mapOfRequestParameters.get('recordId'));
        try {
            if(!validateRequest(setRequiredParameters, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            PaymentPageController controller =new PaymentPageController();
            controller.setObjectId(recId);
            controller.paymentFor = String.valueOf(mapOfRequestParameters.get('paymentFor'));
            controller.objLoanDetails = (PaymentPageController.LoanRequestWrapper)JSON.deserialize(JSON.serialize(mapOfRequestParameters.get('objLoanDetails')),PaymentPageController.LoanRequestWrapper.class);
            // controller.objDetails = (PaymentPageController.RequestWrapper)JSON.deserialize(JSON.serialize(mapOfRequestParameters.get('objDetails')),PaymentPageController.RequestWrapper.class);
            Object merchantId =controller.proceedToDirectLoanOnMobile();
            return buildResponse('Success','Proceed to loan.',merchantId);
        } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error :' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recId);
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }

    /**
    * @description 
    * @author @Ravi | 16--10--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob makeOnlinePayment(String url , String jsonString,Map<String,String> mapOfDevice) {
        Map<String, Object> mapOfRequestParameters =(Map<String,Object>)JSON.deserializeUntyped(jsonString);
        Set<String> setRequiredParameters = new Set<String>{'recordId','paymentFor','paymentGateWayName'};
        map<String,Object> mapOfResponseParameters = new Map<String, Object>();
        recId = String.valueOf(mapOfRequestParameters.get('recordId'));
        try {
            PaymentPageController controller =new PaymentPageController();
            controller.paymentFor = String.valueOf(mapOfRequestParameters.get('paymentFor'));

            if(String.isNotBlank(controller.paymentFor) && controller.paymentFor.contains('DownPayment-')) {
                setRequiredParameters.add('depositAmount');
                setRequiredParameters.add('objLoanDetails');
            } else if(String.isNotBlank(controller.paymentFor) && controller.paymentFor.contains('Installment-')) {
                setRequiredParameters.add('depositAmount');
            }

            if(!validateRequest(setRequiredParameters, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            controller.setObjectId(recId);
            controller.paymentFor = String.valueOf(mapOfRequestParameters.get('paymentFor'));
            controller.paymentGateWayName = String.valueOf(mapOfRequestParameters.get('paymentGateWayName'));
            
            if(controller.paymentFor.contains('DownPayment-') || controller.paymentFor.contains('Installment-')) {
                controller.depositAmount = (Decimal)mapOfRequestParameters.get('depositAmount');
            }

            if(controller.paymentFor.contains('DownPayment-')) {
                controller.objLoanDetails = (PaymentPageController.LoanRequestWrapper)JSON.deserialize(JSON.serialize(mapOfRequestParameters.get('objLoanDetails')),PaymentPageController.LoanRequestWrapper.class);
                  if (String.isBlank(controller.objLoanDetails.Tenure) || String.isBlank(controller.objLoanDetails.LoanType) || String.isBlank(controller.objLoanDetails.InterestRate)) {
                    return  buildResponse('Error','Internal error occured. Missing required data', null);
                  }
            }

            Map<String,Object> resultmap = controller.makeOnlinePaymentMobileAPI(mapOfDevice);

            if(resultmap == null){
                return buildResponse('Error','Unable to get payment details.',null);
            } else if(resultmap.containsKey('paymentUrl') && String.isNotBlank((String)resultmap.get('paymentUrl'))) {
                return buildResponse('Success','Payment request created.', new Map<String, Object>{ 'paymentUrl' => resultmap.get('paymentUrl') });
            } else if(resultmap.containsKey('paymentUrl') && !String.isNotBlank((String)resultmap.get('paymentUrl'))) {
                return buildResponse('Error','Unable to get payment details.',null);
            }
            Blob result = Blob.valueOf(JSON.serialize(resultmap));
            return result;
        } catch (Exception e) {
               insertAPIRequest2(reqURL,'Error :' + e.getMessage()+'Line ==>'+e.getLineNumber(),url,false, recId);
               return  buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }

    // /**
    // * @description 
    // * @author @Ravi | 15--10--2025 
    // * @param String url 
    // * @param String jsonString 
    // * @return Blob 
    // **/
    // public Blob getPaymentStatus(String url, String jsonString) {
    //     Map<String, Object> mapOfRequestParameters = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
    //     Set<String> setRequiredParameters = new Set<String>{'recordId'};

    //     recId = String.valueOf(mapOfRequestParameters.get('recordId'));
    //     try {
    //         // Validate required parameters
    //         if (!validateRequest(setRequiredParameters, mapOfRequestParameters)) {
    //             return buildResponse('Error', 'Required parameters are missing', null);
    //         }
    //         String resTrackId = mapOfRequestParameters.containsKey('resTrackId') ? String.valueOf(mapOfRequestParameters.get('resTrackId')): '';
    //         Map<String, Object> data = getPayStatus(resTrackId);
    //         return buildResponse('Success', 'Processed Successfully', data);
    //         // Build success response  
    //     } catch (Exception e) {
    //         insertAPIRequest2(reqURL, 'Error ==> ' + e.getMessage() + ' Line ==> ' + e.getLineNumber(), url, false, recId);
    //         return buildResponse('Error', 'Error: ' + e.getMessage() + ' Line ==> ' + e.getLineNumber(), null);
    //     }
    // }

    // /**
    // * @description 
    // * @author @Ravi | 15--10--2025 
    // * @param String resTrackId 
    // * @return Map<String, String> 
    // **/
    // public Map<String,Object> getPayStatus(String resTrackId) {
    //     Map<String,Object> resp= new Map<String,Object>();
    //     Boolean isSuccess = false;
    //     String strMessage = '';
    //     String strPaymentType = '';

    //     if (String.isNotBlank(resTrackId)) {
    //         List<nm_Payment__c> lstPayment = [ SELECT Id, Online_Response_Error__c, nm_Error_Code__c, nm_PaymentStatus__c, nm_PaymentType__c, nm_PaymentGatewayResponse__c, nm_Merchant_Track_Id__c, nm_TransactionID__c 
    //                                              FROM nm_Payment__c 
    //                                              WHERE nm_Merchant_Track_Id__c = :resTrackId ];
    //         System.debug('+++++lstPayment: ' + lstPayment);
    //         if (lstPayment != null && lstPayment.size() > 0) {
    //             nm_Payment__c payment = lstPayment[0];
    
    //             if (payment.nm_PaymentStatus__c != 'Transaction Failed') {
    //                 isSuccess = true;
    //                 strMessage = payment.Id;
    //                 strPaymentType = payment.nm_PaymentType__c;
    //             } else {
    //                 if (payment.nm_Error_Code__c != null) {
    //                     strMessage = payment.Online_Response_Error__c+'. -'+'Payment is not successfully completed, Please contact your Information Center or try after some time.';
    //                 }
    //             }
    //         } else {
    //             isSuccess = false;
    //             strMessage = 'Transaction Failed: No Payment record found with given Track ID: ' + resTrackId;
    //         }
    //     } else {
    //         isSuccess = false;
    //         strMessage = 'Transaction Failed: No Track ID found in Request.';
    //     }
    //     // return or log isSuccess, strMessage, strPaymentType here
    //     resp.put('isSuccess',isSuccess);
    //     resp.put('strMessage', strMessage);
    //     resp.put('strPaymentType', strPaymentType);
    //     return resp;

    // }

    /**
    * @description 
    * @author @Ravi | 16--10--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob handlePaymentResponse(String url, String jsonString) {
       Map<String,Object>mapOfRequestParameters = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
       Set<String> setRequiredParameters = new Set<String>{'recordId'};
       recId = mapOfRequestParameters.containsKey('recordId') ? String.valueOf(mapOfRequestParameters.get('recordId')): '';
       PostPaymentWrapper responseWrapper = new PostPaymentWrapper();
       try {
            // Validate required parameters
            if (!validateRequest(setRequiredParameters, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            String resTrackId =String.valueOf(mapOfRequestParameters.get('resTrackId'));
            PostPaymentController response = new PostPaymentController(resTrackId);
            responseWrapper.errMessages = response.errMessages;
            responseWrapper.paymentSuccessInstructions = response.paymentSuccessInstructions;
            responseWrapper.paymentErrorInstructions = response.paymentErrorInstructions;
            responseWrapper.IsReRegistration = response.IsReRegistration;
            responseWrapper.semester = response.semester;
            responseWrapper.recordId = response.recordId;
            responseWrapper.opportunityId = response.opportunityId;
            responseWrapper.AccountId = response.AccountId;
            responseWrapper.isApplicant = response.isApplicant;
            responseWrapper.documentAvailable = response.documentAvailable;
            responseWrapper.LoanSanctioned = response.LoanSanctioned;
            responseWrapper.loanApproved = response.loanApproved;
            responseWrapper.LoanType = response.LoanType;
            responseWrapper.IsRegistrationPayment = response.IsRegistrationPayment;
            responseWrapper.paymentmessage = response.paymentmessage;
            responseWrapper.programType = response.programType;
            responseWrapper.trackingLeadId = response.trackingLeadId;
            responseWrapper.isLoanTermAgreed = response.isLoanTermAgreed;
            responseWrapper.paymentTrackId = response.paymentTrackId;
            responseWrapper.siteUrl = System.Label.Site_Url;
            return buildResponse('Success', 'Successfully Processed', responseWrapper);
       } catch (Exception e) {
          insertAPIRequest2(reqURL, 'Error :' + e.getMessage() + ' Line ==> ' + e.getLineNumber(), url, false, recId);
          return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
       }
    }

    /**
    * @description :: Redirect to the loan Provider 
    * @author @Ravi | 31--10--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob proceedWithLoanApplication (String url, String jsonString) {
        Map<String,Object>mapOfRequestParameters = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
        Set<String> setRequiredParameters = new Set<String>{'recordId','resTrackId','loanProvider'};
        recId = mapOfRequestParameters.containsKey('recordId') ? String.valueOf(mapOfRequestParameters.get('recordId')): '';
        String redirectUrl ='';
        try {
            // Validate required parameters
            if (!validateRequest(setRequiredParameters, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            String resTrackId =String.valueOf(mapOfRequestParameters.get('resTrackId'));
            String loanProvider =String.valueOf(mapOfRequestParameters.get('loanProvider'));
            PostPaymentController contoller = new PostPaymentController(resTrackId);
            if(loanProvider.equalsIgnoreCase('Avanse')){
                 redirectUrl =contoller.avanseApplicationRequestFromMobile();
            } else if(loanProvider.equalsIgnoreCase('Propelld')) {
                 redirectUrl =contoller.propelldApplicationReqestFromMobile();
            } 
              if(String.isBlank(redirectUrl)) {
                return buildResponse('Error', '', new Map<String, String>{ 'redirectUrl' => redirectUrl });
              } 
              return buildResponse('Success', 'Successfully Processed', new Map<String, String>{ 'redirectUrl' => redirectUrl });
       } catch (Exception e) {
          insertAPIRequest2(reqURL, 'Error :' + e.getMessage() + ' Line ==> ' + e.getLineNumber(), url, false, recId);
          return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
       }
    }

    /**
    * @description 
    * @author @Ravi | 31--10--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob cancelLoanApplication( String url, String jsonString){
       Map<String , Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
       Set<String> setRequiredParameters = new Set<String>{'recordId','resTrackId'};
       recId = mapOfRequestParameters.containsKey('recordId') ? String.valueOf(mapOfRequestParameters.get('recordId')): '';
       try {
        if(!validateRequest(setRequiredParameters, mapOfRequestParameters)) {
            return  buildResponse('Error','Internal error occured. Missing required data', null);
        } 
        String resTrackId =String.valueOf(mapOfRequestParameters.get('resTrackId'));
        PostPaymentController contoller = new PostPaymentController(resTrackId);
                   map<String, String> mapofRespnse =contoller.cancelLoanApplicationMobileApp();
        return buildResponse(mapofRespnse.get('Status'), mapofRespnse.get('errMessages'), null);
       } catch (Exception e) {
        insertAPIRequest2(reqURL, 'Error : ' + e.getMessage() + ' Line ==> ' + e.getLineNumber(), url, false, recId);
        return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
       }
    }
    /**
    * @description 
    * @author @Ravi | 16--10--2025 
    * @param String status 
    * @param String message 
    * @param Object data 
    * @return Blob 
    **/
    private Blob buildResponse(String status, String message, Object data) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('status', status);
        response.put('message', message);
        response.put('data', data);
        System.debug('==>'+response);
        return Blob.valueOf(JSON.serialize(response));
    }

    private static void insertAPIRequest2(String req, String res, String apiName, Boolean isSuccess, Id recordId) {
        if(!Test.isRunningTest()) {
            String objectName=APIRequestHandler.getObjName(recordId);
            APIRequestHandler.insertAPIRequest(req, res, apiName, isSuccess, recordId, objectName, 'MobileApp');
        } 
    }

    private Boolean validateRequest(Set<String> requiredParams, Map<String,Object> requestParams) {
        for (String param : requiredParams) {
            if (!requestParams.containsKey(param) ||  requestParams.get(param) == null || String.valueOf(requestParams.get(param)).trim().length() == 0) {
                return false;
            }
        }
        return true;
    }

    public class PaymentDataWrapper {
        public NM_Payment_Form_Configuration__c objPaymentFormConfiguration ;
        public nm_Payment__c objPayment ;
        public PaymentPageController.LoanRequestWrapper objLoanDetails ;
        public PaymentPageController.RequestWrapper objDetails ;
        public StudentDetails objStudentDetails ;
        public PaymentPageController.Coursera objCoursera ;
        public PaymentPageController.AlreadyPaidFee objfee ;
        public PaymentPageController.LiveLecturePayment objLiveLecturePayment ;
        public PaymentPageController.AdmissionAmount objAdmissionAmount ;

        // --------ReRegistration -------------------
        //  public PaymentPageController.ReRegistration objReReg ;

        // need fields to be global
        public String programCategory ;
        public String programSpecialization  ;
        public String semester ;
        public Set<String> setOfApplicablePaymentOptionForStudent ;// Map for Showing Payment Option

        public Map<Id,nm_Courses__c> mapOfCourseKeyVsCurrentCourseObj ;
        public Map<String , Object> mapOfBacklogCourseIdVsBacklogObject ;
        public integer sizeOfMapOfBacklogCourseIdVsBacklogObject ;
        public Map<String,Decimal> mapOfProductAndAmount ;
        public Set<String> setOfPaymentOptionsAvailable ;
        public String paymentFor ;
        public Decimal depositAmount ;
        public String paymentGateWayName ;
        public boolean isReregistartion ;
        public boolean isICForMakingPayment ;
        public boolean isHOForMakingPayment ;  
        public Boolean isFormSubmitted ;

        //---- Stores error messages --- //
        public string errMessages ;
        public string strSecToShow ;
        public String returnUrl ;
        public String gatewayMessages ;

        //loan details
        public Object loanDetailsobject;
    
    }

    public class PostPaymentWrapper {
        public String errMessages;
        public String paymentSuccessInstructions ;
        public String paymentErrorInstructions ;
        public Boolean IsReRegistration ;
        public String semester ;
        public String recordId ;
        public String opportunityId ;
        public String AccountId ;
        public Boolean isApplicant ;
        public Boolean documentAvailable ;
        public Boolean LoanSanctioned ;
        public Boolean loanApproved ;
        public String LoanType ;
        public Boolean IsRegistrationPayment ;
        public String paymentmessage ;
        public String programType ;
        public String trackingLeadId ;
        public Boolean isLoanTermAgreed ;
        public String paymentTrackId ;
        public String siteUrl;
    }
    
}