@RestResource(urlMapping='/dummy/pdfGenerator_5/*') 
global with sharing class REST_OrderPdfGenerator{

    @HttpPost
    global static void generateSignedPdfs() {
        integer regsLimit = 5;
        list<Attachment> attachmentsList = new List <Attachment>();
        Map<Id,Map<String, Id>> signatureAttachments = new Map<Id,Map<String, Id>>();
        Map<Id,Order__c> orderMap = new Map<Id,Order__c>();
        Map<Id,String> orderPsteps = new Map<Id,String>(); //**** Add Approval History ****// 
        
        set<Id> ordersPending = new set<Id>();
        
        for(Order__c ord : [ SELECT Id 
                             FROM order__c 
                             WHERE PdfSent_RSA__c = False AND Signed_RSA__c = True AND (Status_RSA__c = 'Approved' OR  Status_RSA__c = 'Closed' OR Status_RSA__c='Cancelled')
                             AND IdDevice__c!=null //Change to include only the Orders created through the iPad
                             AND CreatedDate>2014-01-01T00:00:00.000+0000
                             ORDER By CreatedDate DESC
                             LIMIT :regsLimit ])
        {
          ordersPending.add(ord.ID);
        }
         
        for(ProcessInstance pi: [Select Id,TargetObjectId From ProcessInstance WHERE TargetObjectId in: ordersPending AND Status = 'Pending' ])
        {
          ordersPending.remove(pi.TargetObjectId);
        }
        for(Attachment att:[SELECT ParentId, id, name,Body FROM attachment WHERE (name like :'%.png' ) AND parentId in: ordersPending  ORDER BY Id ])
                        
       {
           if(att.Name=='signature.png')
                attachmentsList.add(att);
           else if(signatureAttachments.get(att.ParentId)!=null)
                signatureAttachments.get(att.ParentId).put(att.Name, att.Id);
           else
           {
             Map<String, Id> signatures = new Map<String, Id>();
             signatures.put(att.Name, att.Id);
             signatureAttachments.put(att.parentId, signatures);
           }
       }
       
        map<Id,Attachment> attachmentsMap = new map<Id, Attachment>(); 
        for (Attachment element :attachmentsList){
            attachmentsMap.put(element.ParentId, element);
        }
    
        list<Order__c> ordersList = new list<Order__c>();
        
        
       for(Order__c ord :[SELECT  OwnerID, Name,RecordTypeId,RecordType.Name, AccountRef_RSA__r.Name ,SAP_Number_copy_RSA__c, AccountRef_RSA__r.GC_Email_Address__c,Status_RSA__c,Cancellation_Reason_RSA__c,Id, Buyer_Copy_RSA__r.Name, Language__c, CreatedDate, LastModifiedDate, DT_StorageDate__c, ZIPPostalCode_Copy__c, StateProvince_Copy__c, City_Copy__c, AccountRef_RSA__r.Street__c
                          ,(Select TargetObjectId, SystemModstamp, StepStatus, OriginalActor.Name, Id, Comments, Actor.name From ProcessSteps order by SystemModstamp desc)//**** Add Approval History ****//
                          FROM Order__c
                          WHERE Id IN :attachmentsMap.keySet()
                          ORDER BY Id])
        {
            ordersList.add(ord);
            orderMap.put(ord.Id,ord);
            if(ord.RecordType.Name == 'Final Order') orderPsteps.put(ord.id,BodyFormat(ord.processSteps));//**** Add Approval History ****//  
        }               
                
        //To Filter Empty Orders ( no CLI related)
        list<ID> ordersListId = new list<ID>();
        SET<ID> ordersWithCLI = new SET<ID>();
       

        for(Order__c oi : ordersList )
        {
            ordersListId.add(oi.ID);
        } 
         
        for(CampaignLineItem__c cli : [SELECT ID, PreliminaryOrderRef_RSA__c, FinalOrderRef_RSA__c from CampaignLineItem__c WHERE (PreliminaryOrderRef_RSA__c in: ordersListId OR FinalOrderRef_RSA__c in: ordersListId)] )
        {
            if(cli.PreliminaryOrderRef_RSA__c!=null)
                ordersWithCLI.add(cli.PreliminaryOrderRef_RSA__c);
            if(cli.FinalOrderRef_RSA__c!=null)
                ordersWithCLI.add(cli.FinalOrderRef_RSA__c);
        }
        

        
        list<Attachment> newAttachmentsList = new List<Attachment>();
        set<Id> ownersList = new set<Id>();
        Map<Id,String> CancelReasons = new Map<Id,String>();
        // MAP<OrderID,AccountName>
        Map<Id,String> AccountNames = new Map<Id,String>();
        
        set<id> olderPdfOrders =  new set<Id>();
        Map<Id,String>nameOlderPdfOrders= new Map<Id,String>();
        Map <ID, List<Messaging.EmailFileAttachment>> attachmentDocs = new Map <ID, List<Messaging.EmailFileAttachment>> ();
        List<Attachment> optionalAttachment = new List<Attachment>();
        system.debug('***** 4');
        for(Order__c o : ordersList) {
            CancelReasons.put(o.Id,o.Cancellation_Reason_RSA__c);
            AccountNames.put(o.Id,o.AccountRef_RSA__r.Name);
            
            PageReference pdf = Page.OrderPdfGenerator;
            pdf.getParameters().put('id',''+o.id);
            pdf.getParameters().put('renderAs', 'pdf');
            pdf.getParameters().put('core.apexpages.devmode.url','1');
            pdf.getParameters().put('save','1');
            pdf.getParameters().put('signature', ''+ attachmentsMap.get(o.Id).id);
            Attachment attach;
            /*New Development -Cancellation issue include 'Cancelled' in pdf name*/
            if(o.Status_RSA__c=='Cancelled') 
             attach = new Attachment(Name='Signed Contract - ' + o.Name+ ' Cancelled' + '.pdf', parentID = o.id, isPrivate = false, OwnerID=o.OwnerID, description = o.AccountRef_RSA__r.GC_Email_Address__c);
            else
             attach = new Attachment(Name='Signed Contract ' + o.Name + '.pdf', parentID = o.id, isPrivate = false, OwnerID=o.OwnerID, description = o.AccountRef_RSA__r.GC_Email_Address__c);
            Blob body;
            try {
                body = pdf.getContent();
            }
            catch (VisualforceException e) {
                body = Blob.valueOf('Error while generating pdf' + e);
                attach.name = 'Error.txt';
            }
            attach.body = body;
            system.debug('entra 1');
            //FIX to not send empty PDF if order is empty          
            if(ordersWithCLI.contains(o.ID))
            {
                newAttachmentsList.add(attach);
                
                Attachment tempAtt;
                Messaging.EmailFileAttachment tempContainer;
                List<Messaging.EmailFileAttachment> tempContainerList = new List<Messaging.EmailFileAttachment> ();
                tempContainer= new Messaging.EmailFileAttachment(); 
                        
                tempContainer.setFileName(attach.name);
                tempContainer.setBody(attach.body); 
                tempContainerList.add(tempContainer);
             
              if(o.RecordTypeId==Util.recordtype.get('Order__c:FinalOrder') && o.Status_RSA__c!='Cancelled')
              {
                if(signatureAttachments.get(o.ID)!=null)
                {
                     Map<String, String> mapDocTitles = new Map<String, String>();
        
                    for(EnhancedDocument__c itemDoc :[SELECT TXT_Short_Description__c, TXT_Title__c FROM EnhancedDocument__c WHERE CountryRef__r.Name='South Africa'])
                    {
                        String textMay = (itemDoc.TXT_Short_Description__c).toUpperCase();
                        mapDocTitles.put(textMay, itemDoc.TXT_Title__c);
                    }
                    for(String attName : signatureAttachments.get(o.ID).keySet())
                    {
                        String attId = signatureAttachments.get(o.ID).get(attName);
                        String docShortDesc = '';
                        docShortDesc = attName.replace('.png', '');
                        if(attName.contains('_'))
                            docShortDesc = docShortDesc.split('_')[1];
                        if(o.Language__c=='Afrikaans')
                            docShortDesc += '_za';
                        else
                            docShortDesc += '_en';
                        system.debug('recupero el name: '+docShortDesc);
                        
                        tempContainer= new Messaging.EmailFileAttachment();                 
                        tempAtt=generateAttachment(attId, docShortDesc, o, mapDocTitles); 
                        if(tempAtt != null)
                        {                  
                            optionalAttachment.add(tempAtt);
                            tempContainer.setFileName(tempAtt.name);
                            tempContainer.setBody(tempAtt.body);
                            tempContainerList.add(tempContainer);
                        }
                    }
                }
                                
            }
              attachmentDocs.put(o.ID,tempContainerList);
        
        }
        
        system.debug('***** 5');
            olderPdfOrders.add(o.Id);
            nameOlderPdfOrders.put(o.Id,o.Name);
            if(o.Status_RSA__c!='Cancelled')/*New Development -Cancellation */
               o.Status_RSA__c = 'Closed';
           
            o.PdfSent_RSA__c = true;
            ownersList.add(o.OwnerID);
        system.debug('***** 6'); 
        
            
        }
        
        //Savepoint sp = Database.setSavepoint();          
        system.debug('***** 8'); 
        update ordersList;
        system.debug('***** ordersList'+ordersList);
        /*New Development - Cancellation:  delete cancelled order's not cancelled contract.pdf */
        List<Attachment>deleteAttachment=new List<Attachment>();
        for(Attachment att: [select ParentId,id,Name from Attachment where ParentId in: olderPdfOrders and name like  '%.pdf'])
        {
            if (att.Name.contains(nameOlderPdfOrders.get(att.ParentId))){
            deleteAttachment.add(att);
            }
        }
        delete deleteAttachment;
       /* end New Development - Cancellation: delete cancelled order's not cancelled contract.pdf  */                 
        
        optionalAttachment.addAll(newAttachmentsList);
        insert optionalAttachment;
  
        map<ID, User> usersInfo = new Map<ID, User>([SELECT Name, UserRole.Name, email FROM User WHERE Id IN :ownersList]);
        
        map<String, String> paramCco = new map<String, String>();
        for(String region : Label.RSA_REGIONS_MAILS.replace('\n','').replace('\r','').split(';')) {
            if (region.split('#').size() == 2)
                paramCco.put(region.split('#')[0].replace('\n',''),region.split('#')[1]);
            else
                system.debug('Wrong config for RSA Region Mails: '+region);
        }
        Map<Id,String> finalMails = getAdditionalMails(ordersList, usersInfo);

        List<Messaging.SingleEmailMessage> emails =new List<Messaging.SingleEmailMessage>();
        
        try{  
          for(Attachment att : newAttachmentsList){
              String CcMails = '';
              String EmailBody = orderPsteps.get(att.parentID );//**** Add Approval History ****//
              String SubjectRecType = 'Preliminary';
              if(orderMap.get(att.ParentId).RecordType.Name == 'Final Order') SubjectRecType = 'Final';
              
              if (usersInfo.get(att.ownerID).UserRole.Name.split(' - RSA - ').size()==2 && 
              paramCco.get(usersInfo.get(att.ownerID).UserRole.Name.split(' - RSA - ')[1]) != null){
                  CcMails = CcMails + paramCco.get(usersInfo.get(att.ownerID).UserRole.Name.split(' - RSA - ')[1]);
                  if (finalMails.get(att.parentId) != null){
                      CcMails = CcMails + ':' + finalMails.get(att.parentId);
                  }
              }
                                  
           system.debug('cc: ' + ccMails);
              if(att.description==null || att.description=='')
                att.description=usersInfo.get(att.ownerID).email;        
              
              emails.add(sendToMail(att,usersInfo.get(att.ownerID).email,att.description,CancelReasons,AccountNames,(attachmentDocs.get(att.ParentId)!=null?attachmentDocs.get(att.ParentId):new List<Messaging.EmailFileAttachment>()),SubjectRecType));
              emails.add(sendCCMail(att,usersInfo.get(att.ownerID).email,CcMails,CancelReasons,AccountNames,(attachmentDocs.get(att.ParentId)!=null?attachmentDocs.get(att.ParentId):new List<Messaging.EmailFileAttachment>()),(orderMap.get(att.ParentId).SAP_Number_Copy_RSA__c!=null?orderMap.get(att.ParentId).SAP_Number_copy_RSA__c:'NO SAP'),EmailBody, SubjectRecType));//**** Add Approval History -- EmailBody ****// 
          }   
        }
        catch(Exception e)
        {
           //Database.rollback(sp);        
          
        }             
        try{
        	for(Messaging.SingleEmailMessage item : emails)
        	{
        		system.debug('subject: '+ item.Subject + ' - To: ' + item.toAddresses  + ' - CC: ' + item.ccAddresses+ ' - replyTo: ' + item.replyto );
        	}
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emails,true);
            
        }
        catch(Exception e) {
           //Database.rollback(sp);                  
        }
    }
    
    public static Messaging.SingleEmailMessage sendToMail( Attachment paramAttach, String paramReplyTo, String paramTo,Map<Id,String> CancelReasons, Map<Id,String> AccountNames, List <Messaging.EmailFileAttachment> attList, string SubjectRecType){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                      
        email.setFileAttachments(attList); // Sets all attachments


        /*New Development -Cancellation: include 'Cancelled' in subject email*/
        if(paramAttach.Name.contains('Cancelled')){
          email.setSubject( 'Order [' +paramAttach.name.substringBetween('Contract - ',' Cancelled')+ '] has been cancelled'); 
        }else
          email.setSubject( 'A new Monsanto '+SubjectRecType+' Contract for ['+AccountNames.get(paramAttach.parentId)+']');
        email.setToAddresses ( ((paramTo != null && paramTo != '')?paramTo:'').split(':'));
        /*New Development -Cancellation */
         if(paramAttach.Name.contains('Cancelled')){
           email.setPlainTextBody( 'Please find attached the contract that has just been cancelled. \n'+'Cancelation Reason: '+CancelReasons.get(paramAttach.parentId));
         }else
           email.setPlainTextBody( 'Please find attached the new contract that has just been created' );
           email.setOrgWideEmailAddressId(SystemSettings__c.getValues('RSA_ORDER_ORG_MAILER_ID').Value__c);
           email.setReplyTo(paramReplyTo);
        
        return email;
    }
    
    public static Messaging.SingleEmailMessage sendCCMail(Attachment paramAttach, String paramReplyTo, String paramCC,Map<Id,String> CancelReasons, Map<Id,String> AccountNames, List <Messaging.EmailFileAttachment> attList, string SapCode,string EmailBody, string SubjectRecType ){//**** Add Approval History --EmailBody  ****//
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
         
        email.setFileAttachments(attList); // Sets all attachments
        
        
    /*New Development -Cancellation: include 'Cancelled' in subject email*/
        if (paramAttach.Name.contains('Cancelled'))
          email.setSubject( 'Order [' +paramAttach.name.substringBetween('Contract - ',' Cancelled')+ '] has been cancelled');
        else                
          email.setSubject( 'A new Monsanto '+SubjectRecType+' Contract for ['+AccountNames.get(paramAttach.parentId)+']-['+SapCode+']');
        email.setToAddresses( paramReplyTo.split(':') );
        if (paramCC != NULL && paramCC!='')
            email.setCCAddresses( paramCC.split(':') );
              /*New Development -Cancellation */
        if (paramAttach.Name.contains('Cancelled'))
           email.setPlainTextBody( 'Please find attached the contract that has just been cancelled. \n'+'Cancelation Reason: '+CancelReasons.get(paramAttach.parentId));
        else            
           email.setHTMLBody( 'Please find attached the new contract that has just been created'+' <br/><br/>'+ ((EmailBody<>null)?EmailBody:''));
        email.setOrgWideEmailAddressId(SystemSettings__c.getValues('RSA_ORDER_ORG_MAILER_ID').Value__c);
        email.setReplyTo(paramReplyTo);
        
        return email;
    }
    
  public static Attachment generateAttachment(Id signature, String Type, Order__c orderRecord, Map<String, String> mapDocTitles)
  {
        PageReference pdf = Page.AttachmentGenerator;
        pdf.getParameters().put('signature',''+signature);
        pdf.getParameters().put('type',''+Type);
        pdf.getParameters().put('date',''+orderRecord.CreatedDate.format('YYYY-MM-dd')); 
    
        pdf.getParameters().put('name',''+orderRecord.Buyer_Copy_RSA__r.Name);

        if(orderRecord.DT_StorageDate__c!=null)
            pdf.getParameters().put('stordate',''+orderRecord.DT_StorageDate__c.format().replaceAll('/','-'));
        pdf.getParameters().put('ordernum',''+orderRecord.Name);
        pdf.getParameters().put('address',''+ (orderRecord.AccountRef_RSA__r.Street__c==null? '' : orderRecord.AccountRef_RSA__r.Street__c + '<br/>') + (orderRecord.ZIPPostalCode_Copy__c==null? '' : orderRecord.ZIPPostalCode_Copy__c + '<br/>') +  (orderRecord.City_Copy__c==null? '' : orderRecord.City_Copy__c + '<br/>') + (orderRecord.StateProvince_Copy__c==null? '' : orderRecord.StateProvince_Copy__c));

        pdf.getParameters().put('renderAs', 'pdf');
        pdf.getParameters().put('core.apexpages.devmode.url','1');
        pdf.getParameters().put('save','1');                                                         

        Attachment attach;
        
        if(mapDocTitles.get(Type.toUpperCase())!=null)
        {
            attach = new Attachment(Name= mapDocTitles.get(Type.toUpperCase()) + ' - ' + orderRecord.Name + '.pdf', parentID = orderRecord.id, isPrivate = false, OwnerID=orderRecord.OwnerID, description = orderRecord.AccountRef_RSA__r.GC_Email_Address__c);
        
            Blob body; 
            try {
              body = pdf.getContent();
            }
            catch (VisualforceException e) {
              body = Blob.valueOf('Error while generating pdf' + e);
              attach.name = 'Error.txt';
            }
            catch (Exception e) {
              body = Blob.valueOf('Error while generating pdf' + e);
              attach.name = 'Error.txt';
            }
            attach.body = body;
        }
        return attach;
     }    
     
     //**** Add Approval History ****//  
     public static string BodyFormat(List<ProcessInstanceHistory> lst){
       String str = '' ;
       String finalStr = '' ;
       if(lst.size() > 0){
           for(ProcessInstanceHistory o : lst)
           {
               str += '<tr><td>'+  o.SystemModstamp.format('MM/dd/yyyy HH:mm:ss', 'Africa/Johannesburg')+'</td>'
                     +'<td>'+ o.StepStatus +'</td>'
                     +'<td>'+ o.OriginalActor.Name +'</td>'
                     +'<td>'+ o.Actor.Name +'</td>'
                     +'<td>'+ o.Comments +'</td>'+'</tr>' ;
           }
           str = str.replace('null' , '') ;
           finalStr = '<br/><table cellpadding="3" cellspacing="2" border="1"> <td style="background-color: #e8edff;"><strong> Date </strong></td> <td style="background-color: #e8edff;"><strong> Status </strong></td>  <td style="background-color: #e8edff;"><strong> Assigned To </strong></td> <td style="background-color: #e8edff;"><strong> Approver </strong></td> <td style="background-color: #e8edff;"><strong> Comments</strong></td> ' + str +'</table>' ;
       }
       return finalStr;
    }
    //**** Add Approval History ****// 
     
    /*BEG - New Development. Additional Mails sent when a Final Contract is created*/
    public static map<id,string> getAdditionalMails(list<Order__c>involvedOrders, map<ID, User> usersInfo){
        map<Id,String> returned = new map<Id,String>();
        map<String,String> mailsByRegion = new map<String,String>();
        //inform mailsByRegion
        for(String region : Label.RSA_FINAL_ORDER_MAILS.replace('\n','').replace('\r','').split(';')) {
            if (region.split('#').size() == 2)
                mailsByRegion.put(region.split('#')[0].replace('\n',''),region.split('#')[1]);
            else
                system.debug('Wrong config for RSA additional mails for Final Orders: '+region);
        }
        
        
        for (Order__c o:involvedOrders){
            if (o.recordTypeId == Util.recordType.get('Order__c:FinalOrder') &&
            usersInfo.get(o.OwnerId).UserRole.Name.split(' - RSA - ').size() == 2) {
                String region = usersInfo.get(o.OwnerId).UserRole.Name.split(' - RSA - ')[1];
                returned.put(o.Id,mailsByRegion.get(region));
            }
        }
        return returned;
    }       
    
    /*END - New Development. Additional Mails sent when a Final Contract is created*/
    @isTest
    static void testRest() {
        // set up the request object
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/dummy/pdfGenerator_4/';
        RestContext.request.addHeader('email', 'sr13@fullbox.mto');
        // Invoke the method directly
        REST_OrderPdfGenerator.generateSignedPdfs();

    }
    
          
        @isTest (seeAlldata=true)
    static void testRest3() {
     

       User UserTest=new User( Alias='JGGG123', Email='everis.salesforce@gmail.com',Username='testASC43e434@everis.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='en_ZA',EmailEncodingKey='ISO-8859-1',UserRoleId='00ED0000000tJ8yMAE',ProfileId='00eD00000012lqkIAA', LanguageLocaleKey='de', 
       Division='S&T', StandardDivision__c='Corn', Country='South Africa', isActive=true,OrderPrefix_RSA__c='BEN' );
       Insert UserTest;
       
       System.runAs(UserTest)
       {
            
           Country__c toCountry= new Country__c(Name='South Africa', TacticalPlanSetting__c='RSA', DE_EnableAccountSharing__c=false);
           insert toCountry;
           Account toAccount= new Account(CountryRef__c=toCountry.ID, Name='GRANJA 234',BlankVATNumber_RSA__c=true);        
           insert toAccount;
           
            
           Order__c toOrder=new Order__c(OwnerID=UserTest.ID,Name='Order Name',RecordTypeId='012D000000037kHIAQ',AccountRef_RSA__c=toAccount.ID,Status_RSA__c='Approved',PdfSent_RSA__c = False,Signed_RSA__c = True);
            
           insert toOrder;
            
           Attachment toAttachment=new Attachment (OwnerID=UserTest.ID,ParentId=toOrder.ID,name='signature.png', body=Blob.valueOf('testing pdf'));
            
           insert toAttachment;
            
       
           generateSignedPdfs();
       }
   }
}