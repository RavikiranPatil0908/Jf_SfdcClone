/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-04-2024
 * @last modified by  : @BK
**/
global class MassEmailIndiaPostMoreThan30 Implements Schedulable
            {
                global void execute(SchedulableContext sc)
                {
                          
                            sendmail2();
                }

                    public static void sendmail2()
                        {
                               List<Dispatch_Order__c> lstDispatchUpdate = new List<Dispatch_Order__c>();
                               List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
                               
                                 List<Dispatch_Order__c> lstDispatch = [SELECT id,StudyKitConfirmation_1__c,CreatedDate,StudyKitConfirmation_2__c,StudyKitConfirmation_3__c,name,Student_Email__c,Name_Of_Other_Courier_Service__c,Delivery_Date__c,
                                                                       Status_Of_Dispatch__c,Shipment_Date__c ,Semester__c,From_Address__c,
                                                                       Address__c,Tracking_Number__c,Program__c ,Delivered__c
                                                                       FROM Dispatch_Order__c 
                                                                       where Opportunity__c!=null
                                                                        and Semester__c!=null and Tracking_Number__c !=null and Student_Email__c!=null and 
                        ((Name_Of_Other_Courier_Service__c='Indian Post' and Status_Of_Dispatch__c = 'Transit') 
                        OR (Name_Of_Other_Courier_Service__c='Fedex' and Status_Of_Dispatch__c = 'Delivered')) 
                        and Student_Response_No__c=null and Student_Response_Yes__c=null
                        and Send_out_Reminder__c=1 ];
                                                         
                             OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1]; 
                             
                                if (lstDispatch.size() > 0) {
                                    for (Dispatch_Order__c objDispatch: lstDispatch) {

                                        Messaging.SingleEmailMessage message = getEmail(objDispatch);
                                         message.setOrgWideEmailAddressId(owe.id); 
                                         message.setReplyTo(owe.Address);
                                          //message.setSenderDisplayName(owe.DisplayName);            
                                        lstMails.add(message);
                                        if(objDispatch.StudyKitConfirmation_1__c==null)
                                        {
                                            objDispatch.StudyKitConfirmation_1__c = DateTime.Now();
                                            lstDispatchUpdate.add(objDispatch);
                                            
                                        }else if(objDispatch.StudyKitConfirmation_2__c==null)                                       
                                        {
                                            objDispatch.StudyKitConfirmation_1__c = DateTime.Now();
                                            lstDispatchUpdate.add(objDispatch);
                                            
                                        }else if(objDispatch.StudyKitConfirmation_3__c==null)                                       
                                        {
                                            objDispatch.StudyKitConfirmation_1__c = DateTime.Now();
                                            lstDispatchUpdate.add(objDispatch);
                                            
                                        }
                                    }
                                    //Sending the email list in a single call.
                                    Messaging.sendEmail(lstMails);
                                    
                                }
                            if(lstDispatchUpdate.size()>0)
                                {
                                    update lstDispatchUpdate;
                                }

                        }
                                                        
                        public static Messaging.SingleEmailMessage getEmail(Dispatch_Order__c objDispatch) {
                       //     string LastDateInitial = DateTime.newInstance(objaccount.Last_Date_for_Initial_Payment__c.year(),objaccount.Last_Date_for_Initial_Payment__c.month(),objaccount.Last_Date_for_Initial_Payment__c.day()).format('d-MM-YYYY'); 
                    string ShipmentDate = objDispatch.Shipment_Date__c!=null ? DateTime.newInstance(objDispatch.Shipment_Date__c.year(),objDispatch.Shipment_Date__c.month(),objDispatch.Shipment_Date__c.day()).format('d-MM-YYYY'):objDispatch.CreatedDate.format('d-MM-YYYY');  
 
 string DeliveryDate1 = objDispatch.Delivered__c!=null? DateTime.newInstance(objDispatch.Delivered__c.year(),objDispatch.Delivered__c.month(),objDispatch.Delivered__c.day()).format('d-MM-YYYY'):null;
 
                    string DeliveryDate = objDispatch.Delivery_Date__c!=null? objDispatch.Delivery_Date__c :DeliveryDate1;

                    String dateCour  = objDispatch.Name_Of_Other_Courier_Service__c =='Indian Post'?ShipmentDate:DeliveryDate;
                    
                    String ShipvsDelivrey = objDispatch.Name_Of_Other_Courier_Service__c =='Indian Post'?'Shipment' : 'Delivery';

                             Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                  //  email.setOrgWideEmailAddressId(owe.id); 
                                    List<String> toAddresses = new List<String>();
                                     List<String> tocc = new List<String>();
                                    // tocc.add(objaccount.LC_email_id__c);
                                     //tocc.add(objaccount.ICemailaddress__c);
                                    toAddresses.add(objDispatch.Student_Email__c);
                                    email.setToAddresses(toAddresses);
                                    email.setSubject(objDispatch.Tracking_Number__c+' - Dispatch Status');
                                   
                                         String message =   '<!DOCTYPE html PUBLIC >'+
                                            '<html xmlns="http://www.w3.org/1999/xhtml">'+
                                            '   <head>'+
                                            '      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'+
                                            '      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">'+
                                            '      <style type="text/css">'+
                                            '         body {'+
                                            '         padding-top: 0 !important;'+
                                            '         padding-bottom: 0 !important;'+
                                            '         padding-top: 0 !important;'+
                                            '         padding-bottom: 0 !important;'+
                                            '         margin:0 !important;'+
                                            '         width: 100% !important;'+
                                            '         -webkit-text-size-adjust: 100% !important;'+
                                            '         -ms-text-size-adjust: 100% !important;'+
                                            '         -webkit-font-smoothing: antialiased !important;'+
                                            '         }'+
                                            '         .tableContent img {'+
                                            '         border: 0 !important;'+
                                            '         display: block !important;'+
                                            '         outline: none !important;'+
                                            '         }'+
                                            '         a{'+
                                            '         color:#382F2E;'+
                                            '         }'+
                                            '         p, h1,h2,ul,ol,li,div{'+
                                            '         margin:0;'+
                                            '         padding:0;'+
                                            '         }'+
                                            '         h1,h2{'+
                                            '         font-weight: normal;'+
                                            '         background:transparent !important;'+
                                            '         border:none !important;'+
                                            '         }'+
                                            '         .contentEditable h2.big,.contentEditable h1.big{'+
                                            '         font-size: 26px !important;'+
                                            '         }'+
                                            '         .contentEditable h2.bigger,.contentEditable h1.bigger{'+
                                            '         font-size: 37px !important;'+
                                            '         }'+
                                            '         td,table{'+
                                            '         vertical-align: top;'+
                                            '         }'+
                                            '         td.middle{'+
                                            '         vertical-align: middle;'+
                                            '         }'+
                                            '         a.link1{'+
                                            '         display:inline-block;'+
                                            '         font-size:13px;'+
                                            '         color:#d15d4d;'+
                                            '         line-height: 24px;'+
                                            '         text-decoration:none;'+
                                            '         }'+
                                            '         a{'+
                                            '         text-decoration: none;'+
                                            '         }'+
                                            '         .link2{'+
                                            '         display:inline-block;'+
                                            '         color:#ffffff;'+
                                            '         border-top:10px solid #d15d4d;'+
                                            '         border-bottom:10px solid #d15d4d;'+
                                            '         border-left:18px solid #d15d4d;'+
                                            '         border-right:18px solid #d15d4d;'+
                                            '         border-radius:3px;'+
                                            '         -moz-border-radius:3px;'+
                                            '         -webkit-border-radius:3px;'+
                                            '         background:#d15d4d;'+
                                            '         }'+
                                            '         .link3{'+
                                            '         display:inline-block;'+
                                            '         color:#555555;'+
                                            '         border:1px solid #cccccc;'+
                                            '         padding:10px 18px;'+
                                            '         border-radius:3px;'+
                                            '         -moz-border-radius:3px;'+
                                            '         -webkit-border-radius:3px;'+
                                            '         background:#ffffff;'+
                                            '         }'+
                                            '         .link4{'+
                                            '         display:inline-block;'+
                                            '         color:#d15d4d;'+
                                            '         line-height: 24px;'+
                                            '         }'+
                                            '         h2,h1{'+
                                            '         line-height: 20px;'+
                                            '         }'+
                                            '         p{'+
                                            '         font-size: 14px;'+
                                            '         line-height: 21px;'+
                                            '         color:#777575;'+
                                            '         }'+
                                            '         .button{display:inline-block;width:115px;height:25px;padding:10px;text-align:center;border-radius:5px;color:white;font-weight:bold;line-height:25px;line-height:25px;}'+
                                            '         .contentEditable li{'+
                                            '         }'+
                                            '         .appart p{'+
                                            '         }'+
                                            '         .bgItem{'+
                                            '         background: #ffffff;'+
                                            '         }'+
                                            '         .bgBody{'+
                                            '         background: #f8e5d1;'+
                                            '         }'+
                                            '         a:hover{'+
                                            '         color: #d15d4d;'+
                                            '         }'+
                                            '         img { '+
                                            '         outline:none; '+
                                            '         text-decoration:none; '+
                                            '         -ms-interpolation-mode: bicubic;'+
                                            '         width: auto;'+
                                            '         max-width: 100%; '+
                                            '         clear: both; '+
                                            '         display: block;'+
                                            '         float: none;'+
                                            '         }'+
                                            '         div{'+
                                            '         line-height: 120%;'+
                                            '         }'+
                                            '         @media only screen and (max-width:480px)'+
                                            '         {'+
                                            '         table[class="MainContainer"], td[class="cell"] '+
                                            '         {'+
                                            '         width: 100% !important;'+
                                            '         height:auto !important; '+
                                            '         }'+
                                            '         td[class="specbundle"] '+
                                            '         {'+
                                            '         width: 100% !important;'+
                                            '         float:left !important;'+
                                            '         font-size:13px !important;'+
                                            '         line-height:17px !important;'+
                                            '         display:block !important;'+
                                            '         padding-bottom:15px !important;'+
                                            '         } '+
                                            '         td[class="specbundle2"] '+
                                            '         {'+
                                            '         width:90% !important;'+
                                            '         float:left !important;'+
                                            '         font-size:13px !important;'+
                                            '         line-height:17px !important;'+
                                            '         display:block !important;'+
                                            '         padding-bottom:10px !important;'+
                                            '         padding-left:5% !important;'+
                                            '         padding-right:5% !important;'+
                                            '         }'+
                                            '         td[class="spechide"] '+
                                            '         {'+
                                            '         display:none !important;'+
                                            '         }'+
                                            '         img[class="banner"] '+
                                            '         {'+
                                            '         width: 100% !important;'+
                                            '         height: auto !important;'+
                                            '         }'+
                                            '         td[class="left_pad"] '+
                                            '         {'+
                                            '         padding-left:15px !important;'+
                                            '         padding-right:15px !important;'+
                                            '         }'+
                                            '         }'+
                                            '         @media only screen and (max-width:540px) '+
                                            '         {'+
                                            '         table[class="MainContainer"], td[class="cell"] '+
                                            '         {'+
                                            '         width: 100% !important;'+
                                            '         height:auto !important; '+
                                            '         }'+
                                            '         td[class="specbundle"] '+
                                            '         {'+
                                            '         width: 100% !important;'+
                                            '         float:left !important;'+
                                            '         font-size:13px !important;'+
                                            '         line-height:17px !important;'+
                                            '         display:block !important;'+
                                            '         padding-bottom:15px !important;'+
                                            '         } '+
                                            '         td[class="specbundle2"] '+
                                            '         {'+
                                            '         width:90% !important;'+
                                            '         float:left !important;'+
                                            '         font-size:13px !important;'+
                                            '         line-height:17px !important;'+
                                            '         display:block !important;'+
                                            '         padding-bottom:10px !important;'+
                                            '         padding-left:5% !important;'+
                                            '         padding-right:5% !important;'+
                                            '         }'+
                                            '         td[class="spechide"] '+
                                            '         {'+
                                            '         display:none !important;'+
                                            '         }'+
                                            '         img[class="banner"] '+
                                            '         {'+
                                            '         width: 100% !important;'+
                                            '         height: auto !important;'+
                                            '         }'+
                                            '         td[class="left_pad"] '+
                                            '         {'+
                                            '         padding-left:15px !important;'+
                                            '         padding-right:15px !important;'+
                                            '         }'+
                                            '         .font{'+
                                            '         font-size:18px !important;'+
                                            '         line-height:23px !important;'+
                                            '         text-align:center !important;'+
                                            '         }'+
                                            '         }'+
                                            '      </style>'+
                                            '      <script type="colorScheme" class="swatch active">'+
                                            '         {'+
                                            '           "name":"Default",'+
                                            '           "bgBody":"f8e5d1",'+
                                            '           "link":"d15d4d",'+
                                            '           "color":"AAAAAA",'+
                                            '           "bgItem":"ffffff",'+
                                            '           "title":"444444"'+
                                            '         }'+
                                            '      </script>'+
                                            '   </head>'+
                                            '   <body paddingwidth="0" paddingheight="0" bgcolor="f8e5d1"  style="padding-top: 0; padding-bottom: 0; padding-top: 0; padding-bottom: 0; background-repeat: repeat; width: 100% !important; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased;" offset="0" toppadding="0" leftpadding="0">'+
                                            '      <table width="100%" bgcolor="f8e5d1" border="0" cellspacing="0" cellpadding="0" class="tableContent" align="center"  style=\'font-family:Helvetica, sans-serif;\'>'+
                                            '      <tbody>'+
                                            '         <tr>'+
                                            '            <td align=\'center\' height="10" style="background-color: #d15d4d"></td>'+
                                            '         </tr>'+
                                            '         <tr>'+
                                            '            <td height=\'15\'></td>'+
                                            '         </tr>'+
                                            '         <tr>'+
                                            '            <td class=\'movableContentContainer\'>'+
                                            '               <div class="movableContent" style="border: 0px; padding-top: 0px; position: relative;">'+
                                            '               <table width="100%" border="0" cellpadding="0" cellspacing="0" align="center">'+
                                            '                  <tr>'+
                                            '                     <td height=\'20\'></td>'+
                                            '                  </tr>'+
                                            '                  <tr>'+
                                            '                     <td align="center">'+
                                            '                        <table width="600" border="0" cellpadding="0" cellspacing="0" align="center" bgcolor="#ffffff" style=\'\' class="MainContainer">'+
                                            '                           <tr>'+
                                            '                              <td align="center">'+
                                            '                                 <table width="100%" border="0" cellspacing="0" cellpadding="0">'+
                                            '                                    <tr>'+
                                            '                                       <td valign="top">'+
                                            '                                          <table width="100%" border="0" cellpadding="0" cellspacing="0" align="center">'+
                                            '                                             <tr>'+
                                            '                                                <!---<td height=\'20\' colspan="3" ></td> -->'+
                                            '                                             </tr>'+
                                            '                                             <tr>'+
                                            '                                                <td width=\'100%\' align="center" class="specbundle2">'+
                                            '                                                   <div class=\'contentEditableContainer contentImageEditable\'>'+
                                            '                                                      <div class=\'contentEditable\'>'+
                                            '                                                         <a target=\'_blank\' href="#">'+
                                            '                                                         <img src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAQ&oid=00D90000000s6BL&lastMod=1603953535000" alt="Logo" valign="top" width=\'100%\' data-default="placeholder" data-max-width="100" ></a>'+
                                            '                                                      </div>'+
                                            '                                                   </div>'+
                                            '                                                </td>'+
                                            '                                             </tr>'+
                                            '                                             <tr>'+
                                            '                                                <!--- <td height=\'20\' colspan="3" ></td> -->'+
                                            '                                             </tr>'+
                                            '                                          </table>'+
                                            '                                       </td>'+
                                            '                                    </tr>'+
                                            '                                 </table>'+
                                            '                              </td>'+
                                            '                           </tr>'+
                                            '                        </table>'+
                                            '                     </td>'+
                                            '                  </tr>'+
                                            '               </table>'+
                                            '         <tr>'+
                                            '            <td>'+
                                            '               <table width="600" border="0" cellpadding="0" cellspacing="0" bgcolor="#ffffff" align="center" style=\'\' class="MainContainer">'+
                                            '                  <tr>'+
                                            '                     <td align=\'left\'>'+
                                            '                        <table width="100%" border="0" cellspacing="0" cellpadding="0">'+
                                            '                           <tr>'+
                                            '                              <td valign="top" width="20" style="background-color: #E0D7B8;"> </td>'+
                                            '                              <td>'+
                                            '                                 <table width="100%" border="0" cellpadding="0" cellspacing="0" align="center">'+
                                            '                                    <tr>'+
                                            '                                       <td align="left">'+
                                            '                                          <table width="100%" border="0" cellpadding="0" cellspacing="0" style=\'border-radius:6px;-moz-border-radius:6px;-webkit-border-radius:6px; \'>'+
                                            '                                             <tr>'+
                                            '                                                <td>'+
                                            '                                                   <div class=\'contentEditableContainer contentTextEditable\'>'+
                                            '                                                      <div class=\'contentEditable\' style=\'text-align: left;\'>'+
                                            '                                                         <div style=\' margin: 20px;\'>'+
                                            '                                                            <p>Dear <span style=\'color:#36183E;\'><b> Student, </b></p>'+
                                            '                                                            <br>'+
                                            '                                                            <p>Greetings from NMIMS Center For Distance And Online Education!</p>'+
                                            '                                                            <br>'+
                                            '                                                            <p>'+
                                            '                                                               Kindly confirm if you have received the Study Kit of Semester - '+objDispatch.Semester__c+' sent via '+objDispatch.Name_Of_Other_Courier_Service__c+'.'+
                                            '                                                            </p>'+
                                            '                                                            <br>'+
                                            '                                                            <p>Tracking No: - ' +objDispatch.Tracking_Number__c+' </p>'+
                                            '                                                            <br>'+
                                            '                                                            <p> '+ShipvsDelivrey+' Date: - '+dateCour +'</p>'+
                                            '                                                            <br> '+
                                            '<table align="center" border="0" cellpadding="0" cellspacing="0" style="padding-bottom: 20px;" width="330">'+
                                            '   <tbody>'+
                                            '      <tr>'+
                                            '         <td align="center" bgcolor="#378805" height="30" style="padding:10px;cursor: pointer;">'+
                                            ' <font color="#fffff" face="verdana" size="4"><a href="'+system.label.Site_Url+
                                            'DispatchOrder?trackingNo='+objDispatch.Tracking_Number__c+'&isOrderReceived=Yes" style="color:#ffffff"><strong>Yes</strong></a></font>'+
                                            '         </td>'+
                                            '         <td> </td>'+
                                            '         <td style="font-size: 16px; color: #333333; line-height: 24px;" valign="top"> </td>'+
                                            '         <td> </td>'+
                                            '         <td align="center" bgcolor="#aa1f24" height="30" style="padding:10px;cursor: pointer;">'+
                                            '            <font color="#ffffff" face="verdana" size="4"><a href=" '+system.label.Site_Url+'DispatchOrder?trackingNo='+objDispatch.Tracking_Number__c+'&isOrderReceived=No" style="color:#ffffff"><strong>No</strong></a></font>'+
                                            '         </td>'+
                                            '      </tr>'+
                                            '   </tbody>'+
                                            '</table>'+
                                                                                       
                                            '                                                            <p>In case you have any queries, kindly call us on our Toll Free no.1800 1025 136 (Monday to Saturday between 9:00 AM to 7.00 PM)</p>'+
                                            '                                                            <br>'+
                                            '                                                            <p><b>Thanks & Regards,</b><br/>'+
                                            '                                                               Team NMIMS CDOE'+
                                            '                                                               <br/>'+
                                            '                                                            </p>'+
                                            '                                                            <br/>'+
                                            '                                                         </div>'+
                                            '                                                         <img src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAG&oid=00D90000000s6BL&lastMod=1603952774000" alt="Logo" valign="top" width=\'100%\' data-default="placeholder" data-max-width="100" ></a>'+
                                            '                                                         <p  style=\'background-color: #E0D7B8;\'>  </p>'+
                                            '                                                         <img src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAL&oid=00D90000000s6BL&lastMod=1603953322000" alt="Logo" valign="top" width=\'100%\' data-default="placeholder" data-max-width="100" style=\'background-color:#e0d7b8;\'></a>'+
                                            '                                                         <div style=\' margin: 20px;\'>'+
                                            '                                                            <p style="font-size:11px;line-height: 14px;">You are receiving this email because you had signed up to receive emails from NMIMS CDOE. If you prefer not to receive future emails of this type, you can unsubscribe <a href="'+Label.Site_Url+'UnsubscribeEmail?l={!Lead.Id}&cid={!Contact.Id}&e={!Lead.Email}&ei={!Contact.Email}" target="_blank" style=\'color:#36183E;\'><b>here</b></a> | Please do not reply to this email, as this inbox is not monitored.</p>'+
                                            '                                                         </div>'+
                                            '                                                      </div>'+
                                            '                                                   </div>'+
                                            '                                                </td>'+
                                            '                                             </tr>'+
                                            '                                          </table>'+
                                            '                                       </td>'+
                                            '                                    </tr>'+
                                            '                                 </table>'+
                                            '                              </td>'+
                                            '                              <td valign="top" width="20" style=\'background-color: #E0D7B8;\'> </td>'+
                                            '                           </tr>'+
                                            '                        </table>'+
                                            '                     </td>'+
                                            '                  </tr>'+
                                            '               </table>'+
                                            '   </body>'+
                                            '</html>';
    


                                   
                                   // email.setCcAddresses(tocc);
                                    email.setHtmlBody(message);
                                    return email;
                        }
                        public static Messaging.SingleEmailMessage getEmail2() {
    Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
    mailMessage.setSaveAsActivity(false);
    return mailMessage;
  }
            }