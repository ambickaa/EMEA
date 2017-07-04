@RestResource(urlMapping='/dummy/FCUReportGenerator/*') 
global with sharing class REST_FCUReportGenerator {

    private static Map<Integer,FCU_Report_Generator__c> FCUGeneratorToInsert = new Map<Integer,FCU_Report_Generator__c>();
    private static List<FCU_Report_Generator__c> FCUGeneratorList = new List<FCU_Report_Generator__c>();   
    
    @HttpPost
    global static void sendFCUGenerators()
    {           
              //llamada a la generaci?n de pdf + env?o e-mail
    integer regsLimit = 5;
    Set<FieldCheckUp__c> listFCU = new Set<FieldCheckUp__c>();
    
    FCUGeneratorList = [SELECT
                        TXT_Notes__c, TXT_Observations__c, TXT_Symptoms_Causes__c, TXT_Visual_rating__c, TXT_External_Conditions__c, LKP_Field_Check_Up__c, LKP_Field_Check_Up__r.LKP_SeedsmanCampaign__r.Seedsman_report_type__c, Name, 
                        LKP_Field_Check_Up__r.LKP_SeedsmanCampaign__r.PICK_Library__c, LKP_Field_Check_Up__r.LKP_SeedsmanCampaign__r.CHK_Save_report_library__c,
                        LKP_Field_Check_Up__r.LKP_Account__r.Owner.OrderPrefix_RSA__c, LKP_Field_Check_Up__r.LKP_Account__r.Owner.Alias
                        FROM FCU_Report_Generator__c
                        WHERE CHK_isPrinted__c != true
                        LIMIT : regsLimit
                        ];
    
    for (FCU_Report_Generator__c fcugen : FCUGeneratorList)
    {
        PageReference pdf= new PageReference('/apex/'+fcugen.LKP_Field_Check_Up__r.LKP_SeedsmanCampaign__r.Seedsman_report_type__c);
        //PageReference pdf = Page.Seedsman_Report;
        String FCUId = fcugen.id;
        pdf.getParameters().put('idReport', FCUId);
            
        Blob body;
        Attachment attach;
        
         String reportName = fcugen.LKP_Field_Check_Up__r.LKP_Account__r.Owner.OrderPrefix_RSA__c != null ? fcugen.LKP_Field_Check_Up__r.LKP_Account__r.Owner.OrderPrefix_RSA__c : fcugen.LKP_Field_Check_Up__r.LKP_Account__r.Owner.Alias;
         attach = new Attachment(Name='Report-' + reportName + '-' + system.now() + '-'+fcugen.Name+'.pdf');
    
             try 
             {
                // Take the PDF content
                body = pdf.getContent();
                fcugen.CHK_isPrinted__c = true;
                fcugen.LKP_Field_Check_Up__r.PICK_Status__c = 'Sent';
                FieldCheckUp__c updateFCU = new FieldCheckUp__c (Id=fcugen.LKP_Field_Check_Up__c, PICK_Status__c = 'Sent');
                listFCU.add(updateFCU);
             }
             catch (VisualforceException e) 
             {
             body = Blob.valueOf('Error while generating pdf' + e);
              attach.name = 'Error.txt';
              fcugen.CHK_isPrinted__c = false;
             }     
         attach.body = body;
         sendTestMail(attach, FCUId);
         
         
         if(fcugen.LKP_Field_Check_Up__r.LKP_SeedsmanCampaign__r.CHK_Save_report_library__c==true)
         {
         String Library = fcugen.LKP_Field_Check_Up__r.LKP_SeedsmanCampaign__r.PICK_Library__c;
         ContentVersion doc = new ContentVersion();
         doc.VersionData = body;
         doc.Title = 'Report-' + reportName + '-' + system.now() + '-'+fcugen.Name+'.pdf';
         doc.PathOnClient = 'Report-' + reportName + '-' + system.now() + '-'+fcugen.Name+'.pdf';         
         insert doc;
         doc = [SELECT ContentDocumentId FROM ContentVersion WHERE id = :doc.id];
         
         ContentWorkspace shareWorkspace = new ContentWorkspace(); 
         
         try
        {
            shareWorkspace = [SELECT id FROM ContentWorkspace WHERE Name =: Library LIMIT 1];
        }catch(exception e){
            shareWorkspace = null;
        }   
        
         if(shareWorkspace!=null)
        {
         
             ContentWorkspaceDoc docLink = new ContentWorkspaceDoc();
             docLink.ContentDocumentId = doc.ContentDocumentId;
             docLink.ContentWorkspaceId = shareWorkspace.id;
             insert docLink;
             }
         }   
     } 
       //Savepoint sp = Database.setSavepoint();  
       update FCUGeneratorList;       
       update new List<FieldCheckUp__c>(listFCU);    
    }

    public static void sendTestMail(Attachment attach, String FCUId)
    {   
        FCU_Report_Generator__c paramTo = [SELECT LKP_Field_Check_Up__r.LKP_Account__r.GC_Email_Address__c, LKP_Field_Check_Up__r.LKP_Contact__r.Email, LKP_Field_Check_Up__r.OwnerId, LKP_Field_Check_Up__r.Owner.Email, LKP_Field_Check_Up__r.LKP_SeedsmanCampaign__r.MPCK_Language__c, LKP_Field_Check_Up__r.Owner.Id, LKP_Field_Check_Up__r.LKP_SeedsmanCampaign__r.CHK_Send_to_farmer__c FROM FCU_Report_Generator__c WHERE id=: FCUId];
                system.debug('id del user: '+paramTo.LKP_Field_Check_Up__r.OwnerId);
        User u = [SELECT CountryISOCode__c FROM User Where Id =: paramTo.LKP_Field_Check_Up__r.OwnerId]; 
        String emailAccount = paramTo.LKP_Field_Check_Up__r.LKP_Account__r.GC_Email_Address__c;
        String emailContact = paramTo.LKP_Field_Check_Up__r.LKP_Contact__r.Email;
        String emailOwner = paramTo.LKP_Field_Check_Up__r.Owner.Email;
                      
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[1]; 
        system.debug('busca la: '+'Seedsman Report Template '+paramTo.LKP_Field_Check_Up__r.LKP_SeedsmanCampaign__r.MPCK_Language__c+' '+u.CountryISOCode__c);
        
        EmailTemplate et;
        try
        {
            et = [SELECT id FROM EmailTemplate WHERE Name = : 'Seedsman Report Template '+paramTo.LKP_Field_Check_Up__r.LKP_SeedsmanCampaign__r.MPCK_Language__c+' '+u.CountryISOCode__c];
        }
        catch(Exception e)
        {
            et = [SELECT id FROM EmailTemplate WHERE Name = : 'Seedsman Report Template'];
        }
        
       // email.setSenderDisplayName('MA eCIP');
 
        email.setTargetObjectId(paramTo.LKP_Field_Check_Up__r.OwnerId); 
        email.setTemplateId(et.id);
       email.setOrgWideEmailAddressId('0D2D00000004EF3');
       // email.setWhatId(paramTo.LKP_Field_Check_Up__r.LKP_Account__c);    
        
        if(emailContact != null)
            if(paramTo.LKP_Field_Check_Up__r.LKP_SeedsmanCampaign__r.CHK_Send_to_farmer__c == true)
            {
                email.setToAddresses (new List<String>{emailContact, emailOwner});
            }    
        else if(emailAccount != null)
            if(paramTo.LKP_Field_Check_Up__r.LKP_SeedsmanCampaign__r.CHK_Send_to_farmer__c == true)
            {
                email.setToAddresses (new List<String>{emailAccount,emailOwner});
            }
        else
            email.setToAddresses (new List<String>{emailOwner});
        
        email.setSaveAsActivity(false); 
        emails[0]=email; 
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        
        efa.setFileName(attach.name);
        efa.setBody(attach.body);
        Messaging.EmailFileAttachment[] AttachedFiles = new Messaging.EmailFileAttachment[]{efa};
        // email.setPlainTextBody('PDF attached');
        email.setFileAttachments(AttachedFiles); // Sets all attachments
        
        try
        {
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emails, true);
        }
        catch(Exception e) 
        {           
        }
   }
    
    global class REST_SendLogicalEntityFCUGeneratorObject
    {
        public Integer statusCode;
        public String statusDescription;
        
        public List<REST_FCUGeneratorObject> fieldCheckUpsGenerators;
    }
    
    global class REST_FCUGeneratorObject
    {
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public Datetime LastModifiedDate;
        
        public FCU_Report_Generator__c FCUGenerator;
    }
    
}