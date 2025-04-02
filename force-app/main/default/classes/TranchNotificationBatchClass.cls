/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
**/
public class TranchNotificationBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    public List<nm_Payment__c> lstPaymentForGrayQuests = new List<nm_Payment__c>();
    public List<nm_Payment__c> lstPaymentForLiquiloans = new List<nm_Payment__c>();
    public List<nm_Payment__c> lstPaymentForEduvanz = new List<nm_Payment__c>();
    public List<nm_Payment__c> lstUpdatePayment = new List<nm_Payment__c>();
     public void execute(SchedulableContext sc) {
        TranchNotificationBatchClass b = new TranchNotificationBatchClass();
        Database.executebatch(b, 200);
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
      String query ='';
      Date todayDate = Date.today();
        if(!Test.isRunningTest()) {
            query = 'SELECT id,Candidate_Name__c, nm_StudentEmail__c, nm_OpportunityNew__r.Account.PersonMobilePhone, MobilePhone__c, nm_TransactionDate__c, Tranch_Date__c, nm_Amount__c, Tranch_Date_Notification__c, nm_OpportunityNew__r.Tenure__c, nm_OpportunityNew__r.Loan_Type__c, nm_OpportunityNew__r.Down_Payment_Made__c FROM nm_Payment__c WHERE nm_OpportunityNew__c != Null AND nm_PaymentStatus__c = \'Waived Off\' AND nm_PaymentType__c = \'Additional Charge\' AND Tranch_Date_Notification__c = 1' ;
        } else {
            query = 'SELECT id,Candidate_Name__c, nm_StudentEmail__c, nm_OpportunityNew__r.Account.PersonMobilePhone, MobilePhone__c, nm_TransactionDate__c, Tranch_Date__c, nm_Amount__c, Tranch_Date_Notification__c, nm_OpportunityNew__r.Tenure__c, nm_OpportunityNew__r.Loan_Type__c, nm_OpportunityNew__r.Down_Payment_Made__c FROM nm_Payment__c' ;
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        system.debug('scope.size() ==> ' + scope.size());
        if(scope.size() > 0) { 
            system.debug('started ---> ');
            for(SObject sc : scope){
                nm_Payment__c payment = (nm_Payment__c)sc;
                if( String.isNotBlank(payment.nm_OpportunityNew__r.Tenure__c)
                    && String.isNotBlank(payment.nm_OpportunityNew__r.Loan_Type__c)
                    && payment.nm_OpportunityNew__r.Down_Payment_Made__c) {
                        if(payment.nm_OpportunityNew__r.Loan_Type__c == 'LiquiLoans') {
                            lstPaymentForLiquiloans.add(payment);
                        } else if(payment.nm_OpportunityNew__r.Loan_Type__c == 'EduVanz') {
                            lstPaymentForEduvanz.add(payment);
                        } else if(payment.nm_OpportunityNew__r.Loan_Type__c == 'GrayQuest') {
                            lstPaymentForGrayQuests.add(payment);
                        }
                }
            }
        }
    }

       public void finish(Database.BatchableContext bc) {
        
        if(lstPaymentForEduvanz.size() > 0) {
            String result = sendMailForLoanDisbursed(lstPaymentForEduvanz, 'EduVanz' );
        }
        if(lstPaymentForGrayQuests.size() > 0) {
            String result = sendMailForLoanDisbursed(lstPaymentForGrayQuests, 'GrayQuest' );
        }
        if(lstPaymentForLiquiloans.size() > 0) {
            String result = sendMailForLoanDisbursed(lstPaymentForLiquiloans, 'LiquiLoans' );
        }
    }


    public String sendMailForLoanDisbursed(List<nm_Payment__c> lstOfPayments, String loanType) {
        String result = '';
            System.debug('lstOfPayments.....=>'+lstOfPayments);
            OrgWideEmailAddress owe = [select id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE'LIMIT 1 ];
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddress;
            String[] sendingToCCAddress;
            if(System.Label.Environment == 'Sandbox') {
                 toAddress =  new List<String>{'suyog.deshmukh.ext@nmims.edu'};
                 sendingToCCAddress =  new List<String>{'suyog.deshmukh.ext@nmims.edu'};
                } else if(System.Label.Environment == 'Production') {
                sendingToCCAddress =  new List<String>{'manasvi.malve@nmims.edu','harshad.kasliwal@nmims.edu'};
                if(loanType == 'EduVanz') {
                    toAddress =  new List<String>{'suresh.g@eduvanz.com', 'shiji.nair@eduvanz.com'};
                } else if(loanType == 'GrayQuest') {
                    toAddress =  new List<String>{'shrijit@grayquest.com','rishika.jain@grayquest.com'};
                } else if(loanType == 'LiquiLoans') {
                    //toAddress =  new List<String>{'rishabh@liquiloans.com', 'komal.sidhwani@liquiloans.com'};
                    toAddress =  new List<String>{'rishabh@liquiloans.com', 'sovan.biswas@liquiloans.com'};
                        
                }
            }
            
            email.setToAddresses(toAddress);
            email.setCcAddresses(sendingToCCAddress);
            System.debug('toAddress '+toAddress);
            email.setSubject('2nd Tranche Disbursement due');
            email.setOrgWideEmailAddressId(owe.id);
            email.setHtmlBody(tableRepeat(lstOfPayments));
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                result = 'success';
            }catch(exception e){
                result = e.getMessage();
                System.debug('error occured '+e.getMessage());
            }
            system.debug(result);
            return result;
    }

    public String tableRepeat(List<nm_Payment__c> lstPaymentRecords) {

        String table = '';
        for (Integer i = 0; i < lstPaymentRecords.size(); i++) {
            Integer dTranche = lstPaymentRecords[i].Tranch_Date__c.day();
            Integer moTranche = lstPaymentRecords[i].Tranch_Date__c.month();
            Integer yrTranche = lstPaymentRecords[i].Tranch_Date__c.year();
            DateTime DTTranche = DateTime.newInstance(yrTranche, moTranche, dTranche);

            Integer dTDate = lstPaymentRecords[i].nm_TransactionDate__c.day();
            Integer moDate = lstPaymentRecords[i].nm_TransactionDate__c.month();
            Integer yrDate = lstPaymentRecords[i].nm_TransactionDate__c.year();
            DateTime DTTDate = DateTime.newInstance(yrDate, moDate, dTDate);
            Integer srNo =Integer.valueOf(i) + 1;
            table = table +  '<tr>'+
            '        <td class="td" align="center">' + srNo + '</td>'+
            '        <td class="td">'+ lstPaymentRecords[i].Candidate_Name__c +'</td>'+
            '        <td class="td">'+ lstPaymentRecords[i].nm_StudentEmail__c +'</td>'+
            '        <td class="td">'+ lstPaymentRecords[i].nm_OpportunityNew__r.Account.PersonMobilePhone +'</td>'+
            '        <td class="td">'+ DTTDate.format('MMMM dd, yyyy') +'</td>'+
            '        <td class="td">'+ DTTranche.format('MMMM dd, yyyy') +'</td>'+
            '        <td class="td">'+ lstPaymentRecords[i].nm_Amount__c +'</td>'+
            '      </tr>';
        }

        String emailContent = '<html>'+
                ''+
                '<head>'+
                '    <meta charset="UTF-8" />'+
                '    <meta http-equiv="X-UA-Compatible" content="IE=edge" />'+
                '    <meta name="viewport" content="width=device-width, initial-scale=1.0" />'+
                '    <title>Document</title>'+
                '    <style>'+
                '        .table,'+
                '        .th,'+
                '        .td {'+
                '            border: solid 1px #000;'+
                '            padding: 10px;'+
                '        }'+
                ''+
                '        .table {'+
                '            border-collapse: collapse;'+
                '            caption-side: bottom;'+
                '        }'+
                ''+
                '        .th,.td {'+
                '            width: 14.28%;'+
                '        }'+
                '    </style>'+
                '</head>'+
                ''+
                '<body>'+
                '    <table width="700" border="0" align="center" cellpadding="0" cellspacing="0"'+
                '        style="border: 1px solid #A09999; display:table">'+
                '        <tbody>'+
                '            <tr>'+
                '                <td width="700">'+
                '                    <table width="700" border="0" align="left" cellpadding="0" cellspacing="0"'+
                '                        style="font-family:\'Helvetica Neue\', Helvetica, Arial, \'sans-serif\'">'+
                '                        <tbody>'+
                '                            <tr>'+
                '                                <td width="5" height="100" align="left">'+
                '                                    <a href="http://studentzone-ngasce.nmims.edu/studentportal/" style="color: #aa1f24">'+
                '                                        <img WIDTH="720" HEIGHT="100" alt=""'+
                '                                            src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAV&oid=00D90000000s6BL"'+
                '                                            style=" display: table" /></a>'+
                '                                </td>'+
                '                            </tr>'+
                '                        </tbody>'+
                '                    </table>'+
                '                </td>'+
                '            </tr>'+
                '            <tr>'+
                '                <td> </td>'+
                '                <td style="font-size: 16px; color: #464648; line-height: 24px;" valign="top"> </td>'+
                '                <td> </td>'+
                '            </tr>'+
                '            <tr>'+
                '                <td align="center" style="border-collapse: collapse;" valign="top">'+
                '                    <table border="0" cellpadding="0" cellspacing="0" id="templateBody" width="600">'+
                '                        <tbody>'+
                '                            <tr>'+
                '                                <td height="200" valign="top">'+
                '                                    <table border="0" cellpadding="0" cellspacing="0" width="600">'+
                '                                        <tbody>'+
                '                                            <tr>'+
                '                                                <td>&emsp;</td>'+
                '                                                <!-- <td></td> -->'+
                '                                                <td style="font-size: 16px; color: #333333; line-height: 16px;"'+
                '                                                    valign="top">'+
                '                                                    Hi Team,'+
                '                                                    <br />'+
                '                                                    <br />'+
                '                                                    Please find mentioned below the details of the 2nd tranche disbursement due:'+
                '                                                    <br />'+
                '                                                    <br />'+
                '                                                    <table class="table" style="table-layout:fixed;" align="center">'+
                '                                                        <thead>'+
                '                                                            <tr>'+
                '                                                                <th class="th">S.No.</th>'+
                '                                                                <th class="th">Name of the student</th>'+
                '                                                                <th class="th">Email id</th>'+
                '                                                                <th class="th">Mobile Number</th>'+
                '                                                                <th class="th">1st tranche received date</th>'+
                '                                                                <th class="th">2nd tranche due date</th>'+
                '                                                                <th class="th">2nd tranche amount due</th>'+
                '                                                            </tr>'+
                '                                                        </thead>'+
                '                                                        <tbody>'+
                                                                            table +
                '                                                        </tbody>'+
                '                                                    </table>'+
                '                                                    <br />'+
                '                                                    Kindly process the disbursement and inform the same to NMIMS once the payment is disbursed.'+
                '                                                    <p>'+
                '                                                        Regards,<br />'+
                '                                                        NMIMS CDOE'+
                ''+
                '                                                    </p>'+
                '                                                    <br />'+
                '                                                </td>'+
                '                                                <td>&emsp;</td>'+
                '                                            </tr>'+
                '                                            <tr>'+
                '                                                <td> </td>'+
                '                                                <td colspan="3" height="20" valign="top"><img'+
                '                                                        src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAp&oid=00D90000000s6BL&lastMod=1603954244000"'+
                '                                                        style="display: table" width="750" /></td>'+
                '                                                <td> </td>'+
                '                                            </tr>'+
                '                                            <tr>'+
                '                                                <td> </td>'+
                '                                                <td colspan="2" id="utility"'+
                '                                                    style="border-collapse: collapse;background-color: #FFFFFF;border: 0;"'+
                '                                                    valign="middle">'+
                '                                                </td>'+
                '                                                <td> </td>'+
                '                                            </tr>'+
                '                                        </tbody>'+
                '                                    </table>'+
                '                                </td>'+
                '                            </tr>'+
                '                        </tbody>'+
                '                    </table>'+
                '                </td>'+
                '            </tr>'+
                '        </tbody>'+
                '    </table>'+
                '</body>'+
                ''+
                '</html>';
                    
        return emailContent;
    }

    
}