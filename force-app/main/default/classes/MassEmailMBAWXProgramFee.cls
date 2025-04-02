/**
 * @File Name          : MassEmailMBAWXProgramFee.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 10-04-2024
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    21/1/2020   @BK     Initial Version
**/
global class MassEmailMBAWXProgramFee Implements Schedulable
            {
                global void execute(SchedulableContext sc)
                {
                          
                            sendmail2();
                }

                    public static void sendmail2()
                        {
                               List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
                                List<Account> accToUpdate = [select id,PersonEmail,PersonMobilePhone,nm_AccountEmail__c,ICemailaddress__c,LC_email_id__c,Program_Type__c,
                                                         Name,Last_Date_for_Initial_Payment__c,Total_amount_received__c,nmStudent_Program__c,
                                                         Last_Date_for_Admission_Payment__c,DaysSinceForInitialPayment__c 
                                                         from Account where Days_Since_For_Admission_Payment__c >0 and nm_StudentStatus__c !='Confirmed' and nmCaptureOpportuntiyStage__c!='Closed' and  nmCaptureOpportuntiyStage__c!='Payment Made' and Total_amount_received__c >= 41500 limit 100];
                                                         
                             OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1]; 
                             
                                if (accToUpdate.size() > 0) {
                                    for (Account objaccount: accToUpdate) {

                                        Messaging.SingleEmailMessage message = getEmail(objaccount);
                                         message.setOrgWideEmailAddressId(owe.id);
                                        message.setReplyTo(owe.Address);                   
                                        lstMails.add(message);
                                    }
                                    //Sending the email list in a single call.
                                    Messaging.sendEmail(lstMails);
                                }

                        }
                                                        
                        public static Messaging.SingleEmailMessage getEmail(Account objaccount) {
                       //     string LastDateInitial = DateTime.newInstance(objaccount.Last_Date_for_Initial_Payment__c.year(),objaccount.Last_Date_for_Initial_Payment__c.month(),objaccount.Last_Date_for_Initial_Payment__c.day()).format('d-MM-YYYY'); 
    string LastDateAdmission = DateTime.newInstance(objaccount.Last_Date_for_Admission_Payment__c.year(),objaccount.Last_Date_for_Admission_Payment__c.month(),objaccount.Last_Date_for_Admission_Payment__c.day()).format('d-MM-YYYY');  
    
                             Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                  //  email.setOrgWideEmailAddressId(owe.id);    
                                    List<String> toAddresses = new List<String>();
                                     List<String> tocc = new List<String>();
                                     tocc.add(objaccount.LC_email_id__c);
                                     tocc.add(objaccount.ICemailaddress__c);
                                    toAddresses.add(objaccount.nm_AccountEmail__c);
                                    email.setToAddresses(toAddresses);
                                    email.setSubject(objaccount.Program_Type__c+' - Reminder (Program Fee payment)');              
                               
                                
                                    String message = '<!doctype html>'+
                                    '<html>'+
                                    ''+
                                    '<head>'+
                                    '    <meta charset="utf-8">'+
                                    '    <meta http-equiv="Content-Type" content="text/html charset=UTF-8" />'+
                                    '    <title>Untitled Document</title>'+
                                    '    <link href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" type="text/css" />'+
                                    '</head>'+
                                    ''+
                                    '<body>'+
                                    ''+
                                    '    <table width="700" border="0" align="center" cellpadding="0" cellspacing="0" style="border: 1px solid #A09999; display:table">'+
                                    '        <tbody>'+
                                    '            <tr>'+
                                    '                <td width="700">'+
                                    '                    <table width="700" border="0" align="left" cellpadding="0" cellspacing="0" style="font-family:\'Helvetica Neue\', Helvetica, Arial, \'sans-serif\'">'+
                                    '                        <tbody>'+
                                    '                            <tr>'+
                                    '                                <td width="5" height="100" align="left">'+
                                    '                                    <a href="'+Label.Student_Zone_Base_Url+'studentportal/" style="color: #aa1f24">'+
                                    '                                        <img WIDTH=720 HEIGHT=100 alt="" src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAV&oid=00D90000000s6BL&lastMod=1603953932000" style=" display: table"></a>'+
                                    '                                </td>'+
                                    '                            </tr>'+
                                    '                        </tbody>'+
                                    '                    </table>'+
                                    '                    <!--End Template Header -->'+
                                    '                </td>'+
                                    '            </tr>'+
                                    '            <tr>'+
                                    '                <td> </td>'+
                                    '                <td style="font-size: 16px; color: #464648; line-height: 24px;" valign="top"> </td>'+
                                    '                <td> </td>'+
                                    '            </tr>'+
                                    '            <tr>'+
                                    '                <td align="center" style="border-collapse: collapse;" valign="top">'+
                                    '                    <!--Begin Template Body -->'+
                                    '                    <table border="0" cellpadding="0" cellspacing="0" id="templateBody" width="600">'+
                                    '                        <tbody>'+
                                    '                            <tr>'+
                                    '                                <td height="200" valign="top">'+
                                    '                                    <table border="0" cellpadding="0" cellspacing="0" width="600">'+
                                    '                                        <tbody>'+
                                    '                                            <tr>'+
                                    '                                                <td width="20"><img alt="" height="44" src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAk&oid=00D90000000s6BL&lastMod=1603954131000" width="22"></td>'+
                                    '                                                <td pardot-region="" style="font-size: 16px; color: #464648; line-height: 24px;" valign="top" width="708">Dear '+objaccount.Name+','+
                                    '                                                    <br>'+
                                    '                                                    <br> Greetings from NMIMS Center For Distance And Online Education'+
                                    ''+
                                    '                                                    <br>'+
                                    '                                                    <br> We acknowledge the payment of Rs.'+objaccount.Total_amount_received__c+' towards Program fee for our '+objaccount.nmStudent_Program__c+' program.Balance Amount need to be paid.'+
                                    '                                                    <br>'+
                                    '                                                    <br> Last date for payment of program fee is '+LastDateAdmission +'.'+
                                    '                                                    <br>'+
                                    '                                                    <br> Admission will be confirmed only after the payment and documents are approved.'+
                                    '                                                    <br>'+
                                    '                                                    <br>'+
                                    '                                                    <span style="color:red">Disclaimer</span>: If candidate adopts any unfair means in admission process and in providing any details in the admission form inclusive of supporting documents, then his/her admission will be cancelled.'+
                                    '                                                    <br>'+
                                    '                                                    <br> Thanks and Regards,'+
                                    '                                                    <br>'+
                                    '                                                    <span><b>NMIMS CDOE</span>'+
                                    ''+
                                    '                                                </td>'+
                                    '                                                <td width="22"><img alt="" height="44" src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAk&oid=00D90000000s6BL&lastMod=1603954131000" width="22"></td>'+
                                    ''+
                                    '                                            </tr>'+
                                    ''+
                                    '                                            <tr>'+
                                    '                                                <td> </td>'+
                                    '                                                <td style="font-size: 16px; color: #464648; line-height: 24px;" valign="top"> </td>'+
                                    '                                                <td> </td>'+
                                    '                                            </tr>'+
                                    '                                            <tr>'+
                                    '                                                <td> </td>'+
                                    '                                                <td colspan="3" height="20" valign="top"><img src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAp&oid=00D90000000s6BL&lastMod=1603954244000" style="display: table" width="750"></td>'+
                                    '                                                <td> </td>'+
                                    '                                            </tr>'+
                                    '                                            <tr>'+
                                    '                                                <td> </td>'+
                                    '                                                <td colspan="2" id="utility" style="border-collapse: collapse;background-color: #FFFFFF;border: 0;" valign="middle">'+
                                    '                                                    <div style="font-size:2;height:100px; font-family:Calibri, \'sans-serif\'; width: 700px;padding-left:10px;">'+
                                    ''+
                                    '                                                        You are receiving this email because you had signed up to receive emails from NMIMS CDOE.'+
                                    '                                                        <br>'+
                                    '                                                        Please do not reply to this email, as this inbox is not monitored'+
                                    '                                                    </div>'+
                                    '                                                </td>'+
                                    '                                                <td> </td>'+
                                    '                                            </tr>'+
                                    ''+
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
                                    ''+
                                    '</body>'+
                                    ''+
                                    '</html>';

                                   
                                    email.setCcAddresses(tocc);
                                    email.setHtmlBody(message);
                                    return email;
                        }
                        public static Messaging.SingleEmailMessage getEmail2() {
    Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
    mailMessage.setSaveAsActivity(false);
    return mailMessage;
  }
            }