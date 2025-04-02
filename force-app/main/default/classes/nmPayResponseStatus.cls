public class nmPayResponseStatus 
{
    public string strPaymentTrackId{get;set;}  
    public string strResTranId{get;set;}
    public String IsReRegistration {get;set;}
    public boolean isSuccess{get;set;}
    public string strMessage{get;set;}
    public string strPaymentType{get;set;}
    
    
    public nmPayResponseStatus()
    {      
        try
        { 
            strPaymentTrackId = apexpages.currentpage().getparameters().get('ResTrackId');  //Merchant Track ID 
            IsReRegistration = apexpages.currentpage().getparameters().get('type'); // IsRegistartion
            isSuccess = false;    
            if(String.isNotBlank(strPaymentTrackId))
            {
                List<nm_Payment__c> lstPayment = [select id,Online_Response_Error__c, nm_Error_Code__c,nm_PaymentStatus__c, nm_PaymentType__c, nm_PaymentGatewayResponse__c,
                                                nm_Merchant_Track_Id__c, nm_TransactionID__c 
                                                from nm_Payment__c where nm_Merchant_Track_Id__c =: strPaymentTrackId];
                system.debug('+++++lstPayment'+ lstPayment);                                
                if(lstPayment != null && lstPayment.size() > 0)
                {
                    if(lstPayment[0].nm_PaymentStatus__c != 'Transaction Failed')
                    {
                        isSuccess = true;
                        strMessage = lstPayment[0].id;
                        strPaymentType = lstPayment[0].nm_PaymentType__c;
                    }
                    else
                    {
                        if(lstPayment[0].nm_Error_Code__c != null){
                            //Added by Sanket
                            strMessage= lstPayment[0].Online_Response_Error__c;  
                        }
                        //Commented by Sanket Start
                        /*
                        strMessage = getErrorText(lstPayment[0].nm_Error_Code__c);
                        if(strMessage==null|| strMessage=='')
                        {
                            strMessage= lstPayment[0].Online_Response_Error__c;                         
                        }
                        if(strMessage != null || strMessage != '')
                        {
                            if(strMessage.toupperCase()=='IP MISSMATCH')
                              strMessage='Invalid Response From Different Server.';
                        }
                        */
                        //Commented by Sanket End
                    }           
                }
                else
                {
                    isSuccess = false;
                    strMessage = 'Transaction Failed:No Payment record found with given Track ID:'+strPaymentTrackId;
                }
            }
            else
            {
                isSuccess = false;
                strMessage = 'Transaction Failed:No Track ID found in Request';
            }
        }
        catch(Exception ex)
        {
            system.debug('NRAC:::EX::'+ex.getMessage());
        }
    }
    
    public PageReference ShowAdvise()
    {
        try
        {
            if(isSuccess == true)
            {
                if(strPaymentType == 'Registration')
                    return new Pagereference('/nmRegistrationThankYou?id='+strMessage);
                else if( strPaymentType == 'Registration + Admission')
                    return new Pagereference('/nmRegistrationThankYou?id='+strMessage);
                else
                    return new PageReference('/nmThankYou?PaymentId='+strMessage);
            }
        }       
        catch(Exception ex)
        {
            system.debug('NRAC:::EX::'+ex.getMessage());
            return null;
        }
        
        return null;
    }
   /* public String getErrorText(String strcode)
    {
       map<String,String> maperror=new map<String,String>();
       maperror.put('00','Approved oor completed successfully');
       maperror.put('02', 'Refer to special conditions Card Issuer');
       maperror.put('03', 'Invalid Merchant');
       maperror.put('04', 'Pick-Up');
       maperror.put('05', 'General Decline');
       maperror.put('06', 'Message Format Error - Switch');
       maperror.put('12', 'No support / Invalid Transaction');
       maperror.put('14', 'Invalid Card Status at Switch');
       maperror.put('15', 'No such issuer');
       maperror.put('30', 'Format Error');
       maperror.put('33', 'Expired Card');
       maperror.put('41', 'Lost Card / Stolen Card');
       maperror.put('43', 'Stolen Card,Pick Up');
       maperror.put('51', 'Not Sufficient Fund');
       maperror.put('54', 'Expired Card');
       maperror.put('55', 'Incorrect Personal Identification Number');
       maperror.put('56', 'No Record Found');
       maperror.put('57', 'Transaction Not Permitted to CardHolder');
       maperror.put('61', 'Exceeds Withdrawl Amount Limit');
       maperror.put('62', 'Restricted Card');
       maperror.put('65', 'Exceeds withdrawal Frequency Limit');
       maperror.put('68', 'Response Received too Late');
       maperror.put('75', 'Allowable number of PIN tries exceeded');
       maperror.put('77', 'Reserved for Private Use/Approved Pending Identification');
       maperror.put('82', 'Reserved for Private Use/No Security Module');
       maperror.put('83', 'No Such Card / Account in Switch');
       maperror.put('84', 'No PBF Available in Switch');
       maperror.put('85', 'PBF Update Error');
       maperror.put('86', 'Invalid Authorisation Type');
       maperror.put('87', 'Bad Track Data');
       maperror.put('88', 'PTLF Error');
       maperror.put('89', 'Invalid Route Service');
       maperror.put('91', 'Issuer Not Available');
       maperror.put('D', 'Denied by Risk - Max floor limit/$ amount');
       maperror.put('E', 'Denied by Risk - Max floor limit transaction count');
       maperror.put('F', 'Denied by Risk - Max daily processing amount');
       maperror.put('H', 'Denied by Risk - Max 24hr debit amount');
       maperror.put('I', 'Denied by Risk - Max 24hr credit amount');
       maperror.put('J', 'Denied by Risk - Max transaction count daily');
       maperror.put('K', 'Denied by Risk - Amount Less than Minimum Amount configured');
       maperror.put('N0', 'Unable to Authorise');
       maperror.put('N7', 'Customer Selected Negative File Reason');
       maperror.put('O5', 'PIN Required');
       maperror.put('O6', 'Mod 10 Check');
       maperror.put('O8', 'Bad PBF');
       maperror.put('P1', 'Over Daily Limit');
       maperror.put('Q1', 'Invalid Expiration Date');
       maperror.put('R8', 'Card on National Negative');
       maperror.put('S4', 'PTLF Full');
       maperror.put('T2', 'Invalid Transaction Date');
       maperror.put('T3', 'Card Not Supported');
       maperror.put('T5', 'CAF Status = 0 or 9');
       maperror.put('X', 'Negative BIN Card');
       maperror.put('Y', 'Negative Card');
       maperror.put('76', 'APPROVED');
       maperror.put('78', 'Approved');
       maperror.put('11', 'Approved (VIP)');
       maperror.put('79', 'Approved');
       maperror.put('80', 'Reserved for Private Use/Approved national NEG hit OK');
       maperror.put('81', 'Reserved for Private Use/Approved Commercial');
       maperror.put('5', 'General Decline');
       maperror.put('31', 'Bank not supported by Switch');
       maperror.put('T1', 'Invalid Credit Card Advance Increment');
       maperror.put('N1', 'Invalid PAN Length');
       maperror.put('N2', 'Preauthorisation Full');
       maperror.put('94', 'Duplicate Transaction');
       maperror.put('N3', 'Maximum Online Refund Reached');
       maperror.put('N4', 'Maximum Offline Refund Reached');
       maperror.put('N5', 'Maximum Credit Per Refund Reached');
       maperror.put('N6', 'Maximum Refund Credit Reached');
       maperror.put('N8', 'Over Floor Limit');
       maperror.put('N9', 'Maximum number of Refund Credit');
       maperror.put('1', 'Refer to Card Issuer');
       maperror.put('O1', 'Referral File Full');
       maperror.put('O1', 'NEG File Problem');
       maperror.put('O2', 'Advance less than Minimum');
       maperror.put('O3', 'Delinquent');
       maperror.put('O4', 'Over Limit Table');
       maperror.put('O7', 'Force Post');
       maperror.put('O9', 'NEG File Problem');
       maperror.put('P0', 'CAF Problem');
       maperror.put('T4', 'Amount Over Maximum');
       maperror.put('P2', 'CAPF Not Found');
       maperror.put('P3', 'Advance less than Minimum');
       maperror.put('P4', 'Number times used');
       maperror.put('P5', 'Deliquent');
       maperror.put('P6', 'Over Limit Table');
       maperror.put('T6', 'Bad UAF');
       maperror.put('S8', 'ADMN File Problem');
       maperror.put('S9', 'Unable to Validate PIN;Security Module Down');
       maperror.put('83', 'Invalid Account');
       maperror.put('P7', 'Advance less than Minimum');
       maperror.put('P8', 'Administrative Card Needed');
       maperror.put('P9', 'Enter Lesser Amount');
       maperror.put('13', 'Invalid Amount');
       maperror.put('Q0', 'Invalid Transaction Date');
       maperror.put('Q2', 'Invalid Transaction Code');
       maperror.put('T7', 'Cash Back Exceeds Daily Limit');
       maperror.put('38', 'Allowable PIN Tries');
       maperror.put('36', 'Restricted Card');
       maperror.put('Q3', 'Advance less than Minimum');
       maperror.put('Q4', 'Number times used');
       maperror.put('Q5', 'Delinquent');
       maperror.put('Q6', 'Over Limit Table');
       maperror.put('Q7', 'Amount Over Maximum');
       maperror.put('Q8', 'Administrative Card Not Found');
       maperror.put('Q9', 'Administrative Card Not Allowed');
       maperror.put('R0', 'Approved Administrative Request Performed in Window');
       maperror.put('R1', 'Approved Administrative Request Performed out of Window');
       maperror.put('R2', 'Approved Administrative Request Performed Anitime');
       maperror.put('R3', 'Chargeback,Customer File Updated');
       maperror.put('R4', 'Chargeback,Customer File Updated,Acquirer not Found');
       maperror.put('R5', 'Chargeback,Incorrect Prefix Number');
       maperror.put('R6', 'Chargeback,Incorrect Response Code or CPF Configuration');
       maperror.put('R7', 'Administrative Transaction Not Supported');
       maperror.put('S5', 'Chargeback Approved,Customer File Not Updated');
       maperror.put('S6', 'Chargeback Approved,Customer File Not Updated,Acquirer Not Found');
       maperror.put('S7', 'Chargeback Accepted,Incorrect Destination');
       return maperror.get(strcode);
    }*/
}