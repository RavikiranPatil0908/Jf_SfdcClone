/**
 * @File Name          : MassEmailMBAWX.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 16-04-2024
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    21/1/2020   @BK     Initial Version
**/
global class MassEmailMBAWX Implements Schedulable
            {
                global void execute(SchedulableContext sc)
                {
                            sendmail();
                          
                }

                    //method to send mail to a list of users
public static void sendmail() {
     List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
    OrgWideEmailAddress owe = [select id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1 ];
    List <Account> accToUpdate = [select id, PersonEmail, PersonMobilePhone, nm_AccountEmail__c,ICemailaddress__c,LC_email_id__c,
                                    Name, Last_Date_for_Initial_Payment__c,
                                    Last_Date_for_Admission_Payment__c, DaysSinceForInitialPayment__c
                                    from Account where DaysSinceForInitialPayment__c > 0 and nm_StudentStatus__c != 'Confirmed'
                                    and Total_amount_received__c < 26500 limit 100];
    if (accToUpdate.size() > 0) {
        for (Account objaccount: accToUpdate) {

            Messaging.SingleEmailMessage message = getEmail(objaccount);
             message.setOrgWideEmailAddressId(owe.id);            
            lstMails.add(message);
        }
        //Sending the email list in a single call.
        Messaging.sendEmail(lstMails);
    }
}
 
public static Messaging.SingleEmailMessage getEmail(Account objaccount) {
    

                        
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            //email.setOrgWideEmailAddressId(owe.id); 
                            email.setReplyTo('ngasce@nmims.edu');              
                            List<String> toAddresses = new List<String>();
                            List<String> tocc = new List<String>();
                            tocc.add(objaccount.LC_email_id__c);
                            tocc.add(objaccount.ICemailaddress__c);
                            toAddresses.add(objaccount.nm_AccountEmail__c);
                            email.setToAddresses(toAddresses);
                            email.setCcAddresses(tocc);
                            email.setSubject('MBA (WX) - Reminder (Seat Reservation payment)');              
                           
                                String message =  '<!doctype html>'+
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
                    '                                    <a href="'+Label.Student_Portal+'" style="color: #aa1f24">'+
                    '                                        <img WIDTH=720 HEIGHT=100 alt="" src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAV&oid=00D90000000s6BL&lastMod=1603953932000" style=" display: table"></a>'+
                    '                                </td>'+
                    '                            </tr>'+
                    '                        </tbody>'+
                    '                    </table>'+
                    '                    <!-- End Template Header  -->'+
                    '                </td>'+
                    '            </tr>'+
                    '            <tr>'+
                    '                <td> </td>'+
                    '                <td style="font-size: 16px; color: #464648; line-height: 24px;" valign="top"> </td>'+
                    '                <td> </td>'+
                    '            </tr>'+
                    '            <tr>'+
                    '                <td align="center" style="border-collapse: collapse;" valign="top">'+
                    '                    <!-- Begin Template Body  -->'+
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
                    '                                                    <br>'+
                    '                                                    <br> Click <a href="'+Label.Site_Url+'nmlogin_new?&type=registration" style="color: #aa1f24">here</a> to make payment of Program fees.'+
                    '                                                    <br>'+
                    '                                                    <br> Seat Reservation amount of Rs.25000/- is to be paid on or before '+objaccount.Last_Date_for_Initial_Payment__c+', balance amount can be paid on or before '+objaccount.Last_Date_for_Admission_Payment__c+'.'+
                    '                                                    <br>'+
                    '                                                    <br> Admission will be confirmed only after the payment and documents are approved.'+
                    '                                                    <br>'+
                    '                                                    <br>'+
                    '                                                    <span style="color:red">Disclaimer</span>: If candidate adopts any unfair means in admission process and in providing any details in the admission form inclusive of supporting documents, then his/her admission will be cancelled.'+
                    '                                                    <br>'+
                    '                                                    <br> Thanks and Regards,'+
                    '                                                    <br>'+
                    '                                                    <span><b>NMIMS CDOE</b></span>'+
                    ''+
                    '                                                </td>'+
                    '                                                <td width="22"><img alt="" height="44" src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAk&oid=00D90000000s6BL&lastMod=1603954131000" width="22"></td>'+
                    ''+
                    '                                            </tr>'+
                    ''+
                    '                                            <tr>'+
                    '                                                <td> </td>'+
                    '                                                <td style="font-size: 16px; color: #464648; line-height: 24px;" valign="top"> </td>'+
                    '                                                <td> </td>'+
                    '                                            </tr>'+
                    '                                            <tr>'+
                    '                                                <td> </td>'+
                    '                                                <td colspan="3" height="20" valign="top"><img src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAk&oid=00D90000000s6BL&lastMod=1603954131000" style="display: table" width="750"></td>'+
                    '                                                <td> </td>'+
                    '                                            </tr>'+
                    '                                            <tr>'+
                    '                                                <td> </td>'+
                    '                                                <td colspan="2" id="utility" style="border-collapse: collapse;background-color: #FFFFFF;border: 0;" valign="middle">'+
                    '                                                    <div style="font-size:2;height:100px; font-family:Calibri, \'sans-serif\'; width: 700px;padding-left:10px;">'+
                    ''+
                    '                                                        You are receiving this email because you had signed up to receive emails from NMIMS CDOE.'+
                    '                                                        <br>'+
                    ''+
                    '                                                        Please do not reply to this email, as this inbox is not monitored|Toll Free:<a href="tel:18001025136" style="color: #aa1f24"> 18001025136</a>'+
                    '                                                    </div>'+
                    '                                                </td>'+
                    '                                                <td> </td>'+
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
                        
                    
                                                
                                                email.setHtmlBody(message);
                         
    
    return email;
  }
            }