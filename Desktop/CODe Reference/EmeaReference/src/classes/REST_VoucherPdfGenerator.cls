@RestResource(urlMapping='/dummy/voucherGenerator/*')

global with sharing class REST_VoucherPdfGenerator{


   private static Messaging.EmailFileAttachment termsAndConditionsDoc {
        get{
            if(termsAndConditionsDoc == null){
                termsAndConditionsDoc = new Messaging.EmailFileAttachment();
                String devName=System.Label.Voucher_Terms_Name + '_' + Util.currentUser.CountryISOCode__c;                               
                Document doc = [select Name, Type, Body FROM Document WHERE DeveloperName = :devName  LIMIT 1];
                termsAndConditionsDoc.setFileName(doc.Name + '.' + doc.Type);
                termsAndConditionsDoc.setBody(doc.Body); 
            }
            return termsAndConditionsDoc;
        }set;}
    private static Messaging.EmailFileAttachment technologyStewardshipAgreement {
        get{
            if(technologyStewardshipAgreement == null){
                technologyStewardshipAgreement  = new Messaging.EmailFileAttachment();
                String devName=System.Label.Voucher_Tech_Name + '_' + Util.currentUser.CountryISOCode__c;               
                Document doc = [select Name, Type, Body FROM Document WHERE DeveloperName = :devName LIMIT 1];
                technologyStewardshipAgreement .setFileName(doc.Name + '.' + doc.Type);
                technologyStewardshipAgreement .setBody(doc.Body); 
            }
            return technologyStewardshipAgreement;
        }set;}

    private static Messaging.EmailFileAttachment dataPrivacyConsent {
        get{
            if(dataPrivacyConsent == null){
                dataPrivacyConsent  = new Messaging.EmailFileAttachment();
                String devName=System.Label.Voucher_Data_Privacy_Name + '_' + Util.currentUser.CountryISOCode__c;
                Document doc = [select Name, Type, Body FROM Document WHERE DeveloperName = :devName   LIMIT 1];
                dataPrivacyConsent .setFileName(doc.Name + '.' + doc.Type);
                dataPrivacyConsent .setBody(doc.Body); 
            }
            return dataPrivacyConsent ;
        }set;}

    @HttpPost
    global static void generateSignedPdfs() {
        integer regsLimit = 100;
        list<Attachment> attachmentsList = 
                [SELECT ParentId, id, name
                 FROM attachment
                 WHERE name = 'signature.png' AND parentId IN
                    (SELECT Id 
                     FROM Voucher__c 
                     WHERE sentMail__c = False AND Signed__c = True AND (Status__c = 'Closed'  OR Status__c='Cancelled')
                     AND VoucherCampaignRef__r.CountryRef__r.Name=:Util.currentUser.Country
                     AND VoucherCampaignRef__r.IsActive__c = true
                     AND OwnerId = :Util.currentUser.Id
                    )
                ORDER BY Id
                LIMIT :regsLimit
                ];
       
        
        map<Id,Attachment> attachmentsMap = new map<Id, Attachment>(); 
        for (Attachment element :attachmentsList){
            attachmentsMap.put(element.ParentId, element);
        }
        Map<Id,Voucher__c> vouchersMap = new Map<Id,Voucher__c>();
        List<Voucher__c> vouchersList = new List<Voucher__c>();
        List<Id> voucherCampaignToQuery = new List<ID>();
        List<Id> accountsToQuery = new List<ID>();
        Map<Id,String> DistEmails = new Map<Id,String>();
        Map<Id,List<String>> paramCco = new Map <Id,List<String>>();  // Voucher Campaign ID / mails cc
        Map<Id,List<String>> paramCcoCancel = new Map <Id,List<String>>();  // Voucher Campaign ID / mails cc

        
        for(Voucher__c v: [SELECT AccountRef__c, AccountRef__r.GC_Email_Address__c,AddressCopy__c,CampaignRef__c,CancelReason__c,
                                DiscountCopy__c,DistributorNameCopy__c,DistributorRef__c,
                                EmailCopy__c,FarmNameCopy__c,FiscalCodeCopy__c,Id,idDevice__c,
                                Name,OwnerId,Owner.Email,PhoneCopy__c,sentMail__c,isTechnicalAgreement__c,
                                Signed__c,Status__c,TotalBagsFOC__c,TotalBags__c,VoucherCampaignRef__c,
                                AccountRef__r.CountryRef__r.Name,VoucherCampaignRef__r.CHK_MAIL_CANCELLATION__c
                                FROM Voucher__c
                           WHERE Id IN :attachmentsMap.keySet()
                           ORDER BY Id
                            ])
        {
            vouchersMap.put(v.ID,v);
            vouchersList.add(v);
            voucherCampaignToQuery.add(v.VoucherCampaignRef__c);
            accountsToQuery.add(v.DistributorRef__c);   
            accountsToQuery.add(v.AccountRef__c);                               
        }
    
    
        Map<Id,VoucherCampaign__c> voucherCampaigns = new Map<ID,VoucherCampaign__c> ([ SELECT isActive__c,BagSize__c,CancelMailBody__c,CancelMailHeader__c,CancelMailToSalesRep__c,CancelMailTo__c,
                                                    CancelOtherRecipients__c,CountryRef__c,Currency__c,DivisionRef__c,EndDate__c,Id,LastModifiedDate,
                                                    MailBody__c,MailHeader__c,MailTo__c,MinProducts__c,Name,OtherRecipients__c,OwnerId,StartDate__c,Template__c,YearRef__c, isTechnology__c, isDataPrivacy__c, isTermsAndConditions__c 
                                                    FROM VoucherCampaign__c WHERE id in: voucherCampaignToQuery]);
        
        for(ID vc: voucherCampaigns.keyset())
        {       
            paramCco.put(vc,(voucherCampaigns.get(vc).OtherRecipients__c).replace('\n','').replace('\r','').split(';'));
            paramCcoCancel.put(vc,(voucherCampaigns.get(vc).CancelOtherRecipients__c).replace('\n','').replace('\r','').split(';'));
        }
                                                    
        for(Account acc: [ SELECT Id, GC_Email_Address__c FROM Account WHERE Id in :accountsToQuery])
        {
            DistEmails.put(acc.ID,acc.GC_Email_Address__c);
        }
        
        
        list<Attachment> newAttachmentsList = new List<Attachment>();
        set<Id> ownersList = new set<Id>();
        Map<Id,String> CancelReasons = new Map<Id,String>();
        set<id> olderPdfVouchers =  new set<Id>();
        Map<Id,String>nameOlderPdfVouchers= new Map<Id,String>();
        
        
        String pr;
        for(Voucher__c v : vouchersList) {
            CancelReasons.put(v.Id,v.CancelReason__c);
            if(v.AccountRef__r.CountryRef__r.Name.equalsIgnoreCase('Portugal'))
                pr=(String)voucherCampaigns.get(v.VoucherCampaignRef__c).Template__c+'PT';
            else 
                pr=(String)voucherCampaigns.get(v.VoucherCampaignRef__c).Template__c;
            PageReference pdf = new PageReference('/apex/' +pr);
            pdf.getParameters().put('id',''+v.id);
            pdf.getParameters().put('renderAs', 'pdf');
            pdf.getParameters().put('core.apexpages.devmode.url','1');
            pdf.getParameters().put('save','1');
            pdf.getParameters().put('signature', ''+ attachmentsMap.get(v.Id).id);
            Attachment attach;
            /*New Development -Cancellation issue include 'Cancelled' in pdf name*/
            if(v.Status__c=='Cancelled') {
                if(v.VoucherCampaignRef__r.CHK_MAIL_CANCELLATION__c==false) {
                    attach = new Attachment(Name=System.Label.Voucher_Template_Name + ' - ' + v.Name+' Cancelled' + '.pdf', parentID = v.id, isPrivate = false, OwnerID=v.OwnerID, description = v.EmailCopy__c);
                    system.debug('Sending Cancellation Email to ' + v.EmailCopy__c + ' (Voucher contact email address)');
                }
                else {
                    attach = new Attachment(Name=System.Label.Voucher_Template_Name + ' - ' + v.Name+' Cancelled' + '.pdf', parentID = v.id, isPrivate = false, OwnerID=v.OwnerID, description = v.Owner.Email);
                    system.debug('Sending Cancellation Email to ' + v.Owner.Email + ' (Voucher owner email address)');
                }
            }
            else {
             attach = new Attachment(Name=System.Label.Voucher_Template_Name + ' ' + v.Name + '.pdf', parentID = v.id, isPrivate = false, OwnerID=v.OwnerID, description = v.EmailCopy__c);
             system.debug('Sending Confirmation Email to ' + v.EmailCopy__c + ' (Voucher contact email address)');
            }
            Blob body;
            
            system.debug('TEST PDF PAGE ' +pdf);
        //  Savepoint sp = Database.setSavepoint();
             try {
                body = pdf.getContent();
                v.sentMail__c = true;   
       //         Savepoint sp2 = Database.setSavepoint(); //10/09/2015 Due to critical update move savepoint after the page call
             }
             catch (VisualforceException e) {
                body = Blob.valueOf('Error while generating pdf' + e );// + e);
                attach.name = 'Error.txt';
                v.sentMail__c = false;          
            }
       //            Savepoint sp = Database.setSavepoint(); //10/09/2015 Due to critical update move savepoint after the page call
            
            attach.body = body;
            newAttachmentsList.add(attach);
            olderPdfVouchers.add(v.Id);
            nameOlderPdfVouchers.put(v.Id,v.Name);

            
            ownersList.add(v.OwnerID);
        }

        update vouchersList;
        //New Development - Cancellation:  delete cancelled order's not cancelled contract.pdf */
        List<Attachment>deleteAttachment=new List<Attachment>();
        for(Attachment att: [select ParentId,id,Name from Attachment where ParentId in: olderPdfVouchers and name like  '%.pdf'])
        {
        if (att.Name.contains(nameOlderPdfVouchers.get(att.ParentId))){
            deleteAttachment.add(att);
        }
        }
        delete deleteAttachment; 
       /* end New Development - Cancellation: delete cancelled order's not cancelled contract.pdf  */
        
        insert newAttachmentsList;
     
  
        map<ID, User> usersInfo = new Map<ID, User>([SELECT Name, UserRole.Name, email FROM User WHERE Id IN :ownersList]);
        
        //map<String, String> paramCco = new map<String, String>();
        
       
       //Map<Id,String> finalMails = getAdditionalMails(vouchersList, usersInfo);
        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[newAttachmentsList.size()*2];
        Integer counter = 0;
        Boolean isData = false;
        Boolean isTech = false;
        Boolean isTerms = false;
      
        for(Attachment att : newAttachmentsList){
            
            String CcMails='';

            if(!att.Name.contains('Cancelled'))
            {      
                if(voucherCampaigns.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c).MailTo__c.containsIgnoreCase('Distributor'))
                {
                    if(DistEmails.get(vouchersMap.get(att.parentId).DistributorRef__c)!=null)
                        CcMails=CcMails+DistEmails.get(vouchersMap.get(att.parentId).DistributorRef__c) +':';
                }
                if(voucherCampaigns.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c).MailTo__c.containsIgnoreCase('Sales Representative'))
                {
                    if(CcMails+usersInfo.get(vouchersMap.get(att.parentId).OwnerId).email!=null)
                        CcMails=CcMails+usersInfo.get(vouchersMap.get(att.parentId).OwnerId).email +':';            
                }
                if(voucherCampaigns.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c).MailTo__c.containsIgnoreCase('Other recipients'))
                {
                    for(string str : paramCco.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c))
                        CcMails=CcMails + str + ':';                                    
                }           
            }else
            {
                if(voucherCampaigns.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c).CancelMailTo__c.containsIgnoreCase('Distributor'))
                {
                    if(DistEmails.get(vouchersMap.get(att.parentId).DistributorRef__c)!=null)
                        CcMails=CcMails+DistEmails.get(vouchersMap.get(att.parentId).DistributorRef__c) +':';
                }
                if(voucherCampaigns.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c).CancelMailTo__c.containsIgnoreCase('Sales Representative'))
                {
                    if(CcMails+usersInfo.get(vouchersMap.get(att.parentId).OwnerId).email!=null)
                        CcMails=CcMails+usersInfo.get(vouchersMap.get(att.parentId).OwnerId).email +':';            
                }
                if(voucherCampaigns.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c).CancelMailTo__c.containsIgnoreCase('Other recipients'))
                {
                    for(string str : paramCco.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c))
                        CcMails=CcMails + str + ':';                                    
                }           
                
            }
            
            if(voucherCampaigns.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c).isTechnology__c)
                isTech=true;
                
            if(voucherCampaigns.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c).isDataPrivacy__c)
                isData=true;
            
            if(voucherCampaigns.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c).isTermsAndConditions__c)   
                isTerms=true;
       
            
            String body='';
            String header='';
            
            if(!att.Name.contains('Cancelled'))
            {
                header=voucherCampaigns.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c).MailHeader__c;
                body=voucherCampaigns.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c).MailBody__c;
            }
            else
            {
                header=voucherCampaigns.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c).CancelMailHeader__c;
                body=voucherCampaigns.get(vouchersMap.get(att.parentId).VoucherCampaignRef__c).cancelMailBody__c;
            }
            body=body.replace('[Account]',vouchersMap.get(att.parentId).FarmNameCopy__c);
            body=body.replace('[Distributor]',vouchersMap.get(att.parentId).DistributorNameCopy__c);
            body=body.replace('[Voucher]',vouchersMap.get(att.parentId).Name);
            if(vouchersMap.get(att.parentId).FiscalCodeCopy__c!=null) body=body.replace('[VAT]',vouchersMap.get(att.parentId).FiscalCodeCopy__c);

            header=header.replace('[Account]',vouchersMap.get(att.parentId).FarmNameCopy__c);
            header=header.replace('[Distributor]',vouchersMap.get(att.parentId).DistributorNameCopy__c);
            header=header.replace('[Voucher]',vouchersMap.get(att.parentId).Name);
            if(vouchersMap.get(att.parentId).FiscalCodeCopy__c!=null) header=header.replace('[VAT]',vouchersMap.get(att.parentId).FiscalCodeCopy__c);
            
            if(vouchersMap.get(att.parentId).sentMail__c==true)
            {       
                emails[counter++]=sendToMail(att,usersInfo.get(att.ownerID).email,att.description,CancelReasons,body,header,vouchersMap.get(att.parentId).isTechnicalAgreement__c, isTech, isData, isTerms);
                emails[counter++]=sendCCMail(att,usersInfo.get(att.ownerID).email,CcMails,CancelReasons,body,header,vouchersMap.get(att.parentId).isTechnicalAgreement__c, isTech, isData, isTerms);
            }
        }
        try{
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emails,true);
        }
        catch(Exception e) {
            //Database.rollback(sp);
        }
    }
    
    public static Messaging.SingleEmailMessage sendToMail( Attachment paramAttach, String paramReplyTo, String paramTo,Map<Id,String> CancelReasons, String body, String header, Boolean techAgree, Boolean isTech, Boolean isData, Boolean isTerms){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        
        efa.setFileName(paramAttach.name);
        efa.setBody(paramAttach.body);
        
        Messaging.EmailFileAttachment[] AttachedFiles = new Messaging.EmailFileAttachment[]{efa};
        
        if(isTerms)
            AttachedFiles.add(termsAndConditionsDoc);
            
        if(techAgree && isTech)
            AttachedFiles.add(technologyStewardshipAgreement);
        
        if(isData)
            AttachedFiles.add(dataPrivacyConsent);
        
        email.setFileAttachments(AttachedFiles); // Sets all attachments
        
        
      /*  
        if(techAgree)
           email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa,termsAndConditionsDoc,technologyStewardshipAgreement,dataPrivacyConsent}); // Sets all attachments
        else
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa,termsAndConditionsDoc,dataPrivacyConsent}); // Sets all attachments
        */
        
        email.setSubject(header);
        System.debug('Sending Mail to: ' + paramTo);
        email.setToAddresses ( ((paramTo != null && paramTo != '')?paramTo:'').split(':'));

        email.setHtmlBody(body);
        
        email.setOrgWideEmailAddressId(SystemSettings__c.getValues('EAST_VOUCHER_ORG_MAILDER_ID').Value__c);
        email.setReplyTo(paramReplyTo);
        
        return email;
    }
    
    public static Messaging.SingleEmailMessage sendCCMail(Attachment paramAttach, String paramReplyTo, String paramCC,Map<Id,String> CancelReasons, String body, String header,Boolean techAgree, Boolean isTech, Boolean isData, Boolean isTerms ){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        
        efa.setFileName(paramAttach.name);
        efa.setBody(paramAttach.body);
        
        Messaging.EmailFileAttachment[] AttachedFiles = new Messaging.EmailFileAttachment[]{efa};
        
        if(isTerms)
            AttachedFiles.add(termsAndConditionsDoc);
            
        if(techAgree && isTech)
            AttachedFiles.add(technologyStewardshipAgreement);
        
        if(isData)
            AttachedFiles.add(dataPrivacyConsent);
        
        email.setFileAttachments(AttachedFiles); // Sets all attachments
        
        /*
        if(techAgree)
          email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa,termsAndConditionsDoc,technologyStewardshipAgreement,dataPrivacyConsent}); // Sets all attachments
        else
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa,termsAndConditionsDoc,dataPrivacyConsent}); // Sets all attachments
        */
        
        email.setSubject(header);
        System.debug('Sending Mail to: ' + paramReplyTo);
        email.setToAddresses( paramReplyTo.split(':') );
        System.debug('Sending Mail cc: ' + paramCC);
        if (paramCC != NULL)
            email.setCCAddresses( paramCC.split(':') );
        email.setHtmlBody(body);   
        email.setOrgWideEmailAddressId(SystemSettings__c.getValues('EAST_VOUCHER_ORG_MAILDER_ID').Value__c);
        email.setReplyTo(paramReplyTo);
        
        return email;
    }

}