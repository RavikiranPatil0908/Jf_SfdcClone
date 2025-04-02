/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08-12-2021
 * @last modified by  : @BK
**/
public class HelperClassForValidityExtension {
    string sectionToShow {
        get;
        set;
    }
    string strBtnURL {
        get;
        set;
    }

    public Map < String, String > ValidateRecord(String StudentNumber, Date DOB, Map < String, Integer > mapOfMonthAndNumber) {
        Date CurrentDate = date.Today();
        //ICValue =ApexPages.currentPage().getParameters().get('IC');  

        Map < String, String > MapOfMessages = new Map < String, String > ();
        if (StudentNumber != null && StudentNumber != '' && DOB != null) {
            List < Account > lstAccount = [select id,nmStudent_Program__c, Extend_Validity_of_Special_case__c, Extend_Validity_upto_Month__c, Batch__c, nm_Category__c, Extend_Validity_Upto_Year__c, Extended_Validity_For_This_Session__c, Validity_Month__c, Validity_Year__c,
                Validity_Extension_Count__c, nm_ChooseaProgram__c, (select id, nm_IsClosed__c from Student_Program__r) from Account where nm_StudentNo__c =: StudentNumber and nm_DateOfBirth__c =: DOB
            ];
            if (lstAccount.size() > 0) {
                Account objAccount = lstAccount[0];
           //     nm_StudentProgram__c objStudentProg = objAccount.Student_Program__r;
                // call method to check Student is valid or Not valid and also do not allowed to apply for validity extension in same drive 
                String ValidateForCurrentDrive = CheckValidityForEachBatch2(objAccount);
                // call method to check Student already make payment for current drive only approval is pending
                boolean PaymentAlreadyDone = CheckPaymentMadeForCurrrentDrive(objAccount.id);
                // call method to check Validity count for student program 
                boolean ValidForCurrentSession = GetValidityForStudent(objAccount);
                
               
                    if (ValidateForCurrentDrive == 'RedirectExtension' || objAccount.Extend_Validity_of_Special_case__c == true) {
                        // check Student Has Completed course and Applicable for current drive of validity extension
                        
                            
                                if (ValidForCurrentSession == true ) {
                                    if (PaymentAlreadyDone == false) {
                                        if (ValidateForCurrentDrive == 'RedirectExtension' ) {
                                            MapOfMessages.put('Success', objAccount.id);
                                            return MapOfMessages;
                                        } else {
                                            MapOfMessages.put('errorMessage', 'You have already applied for validity extension once in the current timeframe');
                                            return MapOfMessages;
                                        }
                                    } else {
                                        MapOfMessages.put('errorMessage', 'Your payment for Extension is under Approval.');
                                        return MapOfMessages;
                                    }

                                } else {
                                    MapOfMessages.put('errorMessage', 'You have Extended your validity limit');
                                    return MapOfMessages;
                                }
                    } else {
                        MapOfMessages.put('errorMessage', 'You are not eligible for Validity Extension in this session');
                        return MapOfMessages;
                    }
               
            } else {
                MapOfMessages.put('errorMessage', 'Record does not Exist');
                return MapOfMessages;

            }
        } else {
            MapOfMessages.put('errorMessage', 'Please Enter Student No and Date OF Birth');
            return MapOfMessages;
        }



    }

 

    public boolean CheckPaymentMadeForCurrrentDrive(String accountId) {
        list < Validity_Extension__c > lstValidity = [select id, Related_Account__c from Validity_Extension__c where Related_Account__c =: accountId];
        if (lstValidity.size() > 0) {
            list < nm_Payment__c > lstextensionPayment = [select id, nm_Type__c, nm_PaymentStatus__c from nm_Payment__c where nm_PaymentStatus__c = 'Payment Made'
                and Validity_Extension__c =: lstValidity[0].id
            ];
            if (lstextensionPayment.size() > 0) {
                system.debug('Entered in loop' + lstextensionPayment.size());
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    public boolean GetValidityForStudent(Account objAccount) {
        if (((objAccount.nm_ChooseaProgram__c.startsWith('Post') || objAccount.nm_ChooseaProgram__c.startsWith('MBA')) && objAccount.Validity_Extension_Count__c < 2) || (objAccount.nm_ChooseaProgram__c.startsWith('Diploma') && objAccount.Validity_Extension_Count__c < 1) || ((objAccount.nm_ChooseaProgram__c.startsWith('Certificate') && objAccount.nm_ChooseaProgram__c.startsWith('Advance')) || objAccount.Validity_Extension_Count__c < 1)) {
            return true;
        } else {
            return false;
        }
    }

     
     public String CheckValidityForEachBatch2(Account objAccount) {
    date validityexpireStudent;
    date CurrentDate = date.today();
    date validityexpiredate = validityexpire(objAccount.Validity_Month__c.left(3), integer.valueOf(objAccount.Validity_Year__c));

    validityexpireStudent = validityexpiredate.addMonths(13);

    if (validityexpireStudent > CurrentDate && validityexpiredate < CurrentDate && IsNullOrEmpty(objAccount.Extend_Validity_upto_Month__c)) {

        return 'RedirectExtension';
    }
    else if (!IsNullOrEmpty(objAccount.Extend_Validity_upto_Month__c)  && objAccount.Extend_Validity_Upto_Year__c!=null ) {

        date extendedvaliditydate1 = validityexpire(objAccount.Extend_Validity_upto_Month__c.left(3), integer.valueOf(objAccount.Extend_Validity_Upto_Year__c));
        system.debug('extendedvaliditydate1--->'+extendedvaliditydate1);
        date extendedvaliditydate2 = extendedvaliditydate1.addMonths(7);
        if (extendedvaliditydate2 > CurrentDate && ((objAccount.nm_ChooseaProgram__c.startsWith('Post') || objAccount.nm_ChooseaProgram__c.startsWith('MBA') || objAccount.nm_ChooseaProgram__c.startsWith('Professional')) && objAccount.Validity_Extension_Count__c < 2) && extendedvaliditydate1 < CurrentDate) {
            return 'RedirectExtension';
        } else {
            return 'Do not Redirect Extension';
        }

    } 
    else {
        return 'Do not Redirect Extension';
    }

    return null;
}
  public boolean IsNullOrEmpty(String fieldValue){
        if(fieldValue == null || fieldValue == ''){
            return true;
        }
        return false;
    }
    
  public date validityexpire(String ValidityMonth,Integer ValidityYear)
{
     Date ValidityDate;
      Map<String,Integer> MonthStringvsInteger = new Map<String,Integer> ();
     if(ValidityMonth!=null && ValidityMonth!='' && ValidityYear>0)
     {
            MonthStringvsInteger.put('Jan',01);
            MonthStringvsInteger.put('Feb',02);
            MonthStringvsInteger.put('Mar',03);
            MonthStringvsInteger.put('Apr',04);
            MonthStringvsInteger.put('May',05);
            MonthStringvsInteger.put('Jun',06);
            MonthStringvsInteger.put('Jul',07);
            MonthStringvsInteger.put('Aug',08);
            MonthStringvsInteger.put('Sep',09);
            MonthStringvsInteger.put('Oct',10);
            MonthStringvsInteger.put('Nov',11);
            MonthStringvsInteger.put('Dec',12);
            
    ValidityDate = date.newinstance(ValidityYear,MonthStringvsInteger.get(ValidityMonth),01);
      return ValidityDate;
     }
            
    
     
      return null;
}
    
       
}