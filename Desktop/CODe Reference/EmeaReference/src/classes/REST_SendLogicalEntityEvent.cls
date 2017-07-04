@RestResource(urlMapping='/sendLogicalEntity/Event/*') 
global without sharing class REST_SendLogicalEntityEvent 
{
    private static List<String> errorMessages = new List<String>();
    private static Integer ERROR_UNKNOWN = 999;
    
    @HttpPost
    global static REST_EventObject sendActivities(REST_EventObject paramInfo)
    {
        /* Store the original request in a variable and convert it to pretty JSON string*/
        String request =System.JSON.serializePretty(paramInfo);
        REST_EventObject returned = paramInfo;
        
        /*Start gathering the objects to insert/update and put them into lists*/
     
        List<Lead> leadsToInsert = new List<Lead>();
        for(REST_LeadObject itemLead : returned.leads)
        {
            itemLead.lead.status='Confirmed';
            itemLead.lead.CHK_Consent_Accept_Terms__c = true;
            itemLead.lead.country=Util.currentUser.country;
            leadsToInsert.add(itemLead.lead);
        }
        
        List<Account> accountsToUpdate = new List<Account>();
        for(REST_AccountObject itemAccount : returned.accounts)
        {
            accountsToUpdate.add(itemAccount.account);
        }
        
        //Map to store existing accounts and check if acreages fields are changed
        Map<Id, Account> mapExistingAccounts = new Map<Id, Account>([SELECT id, CornTotalAcreagesCY__c, TotalOtherAcreagesManualCY__c, OSRTotalAcreagesCY__c, CornDekalbMarketShareCY__c, OSRDekalbMarketshareCY__c, totalAcreagesCY__c, ownerid from account where id in :accountsToUpdate]);
        
        List<Contact> contactsToUpdate = new List<Contact>();
        for(REST_ContactObject itemContact : returned.contacts)
        {
            contactsToUpdate.add(itemContact.contact);
        }
        
        
        /*  Start with lead insertion
        *   All of them will be executed with allOrNone disabled, meaning that errors will be manually handled. 
        */
       
        returned.statusCode = 100;
        returned.statusDescription = 'Processed';
        Savepoint sp = Database.setSavepoint();
        
        //Insert leads 
        Database.saveResult[] leadResults = Database.insert(leadsToInsert, false);
        for(Integer i = 0; i<leadResults.size(); i++)
        {
            if(leadResults[i].isSuccess())
            {
                returned.leads[i].statusCode = 100;
                returned.leads[i].statusDescription = 'Processed';
                returned.leads[i].lead.id = leadResults[i].getId();
            }
            else
            {
                returned.leads[i].statusCode = ERROR_UNKNOWN;
                returned.leads[i].statusDescription = 'Not Processed';
                errorMessages.add('Error insert lead: \n' +returned.leads[i].lead.name +' -Technical error detail- \n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(leadResults[i].getErrors()!=null? (leadResults[i].getErrors()[0] + '\n'):'') +'\n'); 
            }
        }
        
        /*  End of lead insertion
        *   All of them will be executed with allOrNone disabled, meaning that errors will be manually handled. 
        */
        Map<Integer, Id> idDeviceLeadmap = new Map<Integer, Id>();
        for(REST_LeadObject item : returned.leads)
        {
            idDeviceLeadmap.put(Integer.valueOf(item.lead.idDevice__c), item.lead.Id);          
        }
        
        Set<CampaignMember> attendantsToInsertSet = new Set<CampaignMember>();
        List<Event_Survey_Answer__c> surveysToInsert = new List<Event_Survey_Answer__c>();
        for(REST_SurveyAnswerObject itemSurvey : returned.surveys)
        {
            if(itemSurvey.surveyAnswer.idDeviceLead__c!= null || itemSurvey.surveyAnswer.LKP_Contact__c != null)
            { system.debug('lead assigned'+ idDeviceLeadmap.get(Integer.valueOf(itemSurvey.surveyAnswer.idDeviceLead__c)));
                itemSurvey.surveyAnswer.LKP_Lead__c = itemSurvey.surveyAnswer.idDeviceLead__c!=null?idDeviceLeadmap.get(Integer.valueOf(itemSurvey.surveyAnswer.idDeviceLead__c)) : null;
                surveysToInsert.add(itemSurvey.surveyAnswer);
                attendantsToInsertSet.add(new CampaignMember(CampaignId=returned.eventId, ContactId=itemSurvey.surveyAnswer.LKP_Contact__c, LeadId=itemSurvey.surveyAnswer.LKP_Lead__c));
             system.debug('Survey answer!:'+itemSurvey.surveyAnswer);
            }
        }
        
        
        
        List<Event_Feedback__c> feedbacksToInsert = new List<Event_Feedback__c>();
        for(REST_FeedbackObject itemFeedback : returned.feedbacks)
        {
            feedbacksToInsert.add(itemFeedback.feedback);
        }
        
        /*  Start with rest of DML operations
        *   All of them will be executed with allOrNone disabled, meaning that errors will be manually handled. 
        */      
        
        //Update Contact
        Database.saveResult[] contactResults = Database.update(contactsToUpdate, false);
        for(Integer i = 0; i<contactResults.size(); i++)
        {
            if(contactResults[i].isSuccess())
            {
                returned.contacts[i].statusCode = 100;
                returned.contacts[i].statusDescription = 'Processed';
            }
            else
            {
                returned.contacts[i].statusCode = ERROR_UNKNOWN;
                returned.contacts[i].statusDescription = 'Not Processed';
                errorMessages.add('Error insert contact: \n' +returned.contacts[i].contact.name +' -Technical error detail- \n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(contactResults[i].getErrors()!=null? (contactResults[i].getErrors()[0] + '\n'):'') +'\n'); 
            }
        }
        
        //Implement acreages change task creation if acreages summary fields are changed
        List<Task> tasksToInsert = new List<Task>();
        for(REST_AccountObject itemAcc : returned.accounts)
        {
           Task newTask=checkAccountAcreagesTask(itemAcc.account, mapExistingAccounts.get(itemAcc.account.id));
            if(newTask!=null)
            {
                tasksToInsert.add(newTask);             
            }
        }
        if(tasksToInsert.size() > 0)
        {
            Database.DMLOptions dmlOptions = new Database.DMLOptions(); 
            dmlOptions.EmailHeader.TriggerUserEmail = TRUE; 

            Database.Insert(tasksToInsert, dmlOptions);
        }
        
        //Update Account 
        Database.saveResult[] accountResults = Database.update(accountsToUpdate, false);        
        for(Integer i = 0; i<accountResults.size(); i++)
        {
            if(accountResults[i].isSuccess())
            {
                returned.accounts[i].statusCode = 100;
                returned.accounts[i].statusDescription = 'Processed';
            }
            else
            {
                returned.accounts[i].statusCode = ERROR_UNKNOWN;
                returned.accounts[i].statusDescription = 'Not Processed';
                errorMessages.add('Error update account: \n' +returned.accounts[i].account.name +' -Technical error detail- \n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(accountResults[i].getErrors()!=null? (accountResults[i].getErrors()[0] + '\n'):'') +'\n'); 
            }
        }
        
        //insert Members
        Database.saveResult[] memberResults = Database.insert(new List<CampaignMember>(attendantsToInsertSet), false);
        for(Integer i = 0; i<memberResults.size(); i++)
        {
            if(!memberResults[i].isSuccess() && String.valueOf(memberResults[i].getErrors()[0].getStatusCode()) != 'DUPLICATE_VALUE')
            {                
                errorMessages.add('Error insert member: \n' +returned.surveys[i].surveyAnswer.LKP_Contact__c  +' -Technical error detail- \n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(memberResults[i].getErrors()!=null? (memberResults[i].getErrors()[0] + '\n'):'') +'\n'); 
            }
        }
        
        
        //insert Survey Answer 
        Database.saveResult[] surveyResults = Database.insert(surveysToInsert, false);
        for(Integer i = 0; i<surveyResults.size(); i++)
        {
            system.debug(surveyResults[i].isSuccess());
            if(surveyResults[i].isSuccess())
            {
                returned.surveys[i].statusCode = 100;
                returned.surveys[i].statusDescription = 'Processed';
                returned.surveys[i].surveyAnswer.id = surveyResults[i].getId();
            }
            else
            {
                returned.surveys[i].statusCode = ERROR_UNKNOWN;
                returned.surveys[i].statusDescription = 'Not Processed';
                errorMessages.add('Error insert survey: \n' +returned.surveys[i].surveyAnswer.LKP_Contact__c +' -Technical error detail- \n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(surveyResults[i].getErrors()!=null? (surveyResults[i].getErrors()[0] + '\n'):'') +'\n'); 
            }
        }
        
        //insert Feedback 
        Database.saveResult[] feedbackResults = Database.insert(feedbacksToInsert, false);
        for(Integer i = 0; i<feedbackResults.size(); i++)
        {
            if(feedbackResults[i].isSuccess())
            {
                returned.feedbacks[i].statusCode = 100;
                returned.feedbacks[i].statusDescription = 'Processed';
                returned.feedbacks[i].feedback.id = feedbackResults[i].getId();
            }
            else
            {
                returned.feedbacks[i].statusCode = ERROR_UNKNOWN;
                returned.feedbacks[i].statusDescription = 'Not Processed';
                errorMessages.add('Error insert feedback: \n -Technical error detail- \n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(feedbackResults[i].getErrors()!=null? (feedbackResults[i].getErrors()[0] + '\n'):'') +'\n'); 
            }
        }
        try
        {
        	Attachment att = [Select id, name from attachment where id =:returned.backupFileId];
	        if(errorMessages.size() > 0)
	        {
	            att.name = 'ERROR_'+att.name;
	            update att;
	            returned.statusCode = 999;
	            returned.statusDescription = errorMessages[0];
	            sendEmailError(returned.eventId, errorMessages);
	        }
	        else
	        {
	            att.name = 'OK_'+att.name;
	            update att;
	        }
        }
        catch(Exception e)
        {
        	
        }
      generateBackupDocument(request, returned, true);
        
        return paramInfo;
    }
    
    global class REST_EventObject
    {
        public Integer statusCode;
        public String statusDescription;
        public String eventId;
        public String backupFileid;
        public List<REST_LeadObject> leads;
        public List<REST_AccountObject> accounts;
        public List<REST_ContactObject> contacts;
        public List<REST_SurveyAnswerObject> surveys;
        public List<REST_FeedbackObject> feedbacks;
    }
    
    global class REST_LeadObject
    {
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public Datetime LastModifiedDate;
        public Lead lead;
    }
    
    global class REST_AccountObject
    {
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public Datetime LastModifiedDate;
        public Account account;
    }
    
    global class REST_ContactObject
    {
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public Datetime LastModifiedDate;
        public Contact contact;
    }
    
    global class REST_SurveyAnswerObject
    {
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public Datetime LastModifiedDate;
        public Event_Survey_Answer__c surveyAnswer;
    }
    
    global class REST_FeedbackObject
    {
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public Datetime LastModifiedDate;
        public Event_Feedback__c feedback;
    }
    
    global static Task checkAccountAcreagesTask(Account p_acc, Account existing)
    {
        if(p_acc.CornTotalAcreagesCY__c != existing.CornTotalAcreagesCY__c ||
            p_acc.OSRTotalAcreagesCY__c != existing.OSRTotalAcreagesCY__c ||
            p_acc.CornDekalbMarketShareCY__c != existing.CornDekalbMarketShareCY__c ||
            p_acc.OSRDekalbMarketshareCY__c != existing.OSRDekalbMarketshareCY__c ||
            p_acc.totalAcreagesCY__c != existing.totalAcreagesCY__c ||
            p_acc.TotalOtherAcreagesManualCY__c != existing.TotalOtherAcreagesManualCY__c)
        {
            String taskDescription = 'Corn Total: '+p_acc.CornTotalAcreagesCY__c+'\n';
                    taskDescription+='OSR Total: '+p_acc.OSRTotalAcreagesCY__c+'\n';
                    taskDescription+='Corn Dekalb: '+p_acc.CornDekalbMarketShareCY__c+'\n';
                    taskDescription+='OSR Dekalb: '+p_acc.OSRDekalbMarketshareCY__c+'\n';
                    taskDescription+='Total Other: '+p_acc.TotalOtherAcreagesManualCY__c +'\n';
                    taskDescription+='Total: '+p_acc.totalAcreagesCY__c+'\n';
                    taskDescription+='-------------------------\n';
                    taskDescription+='Existing values\n';
                    taskDescription+='-------------------------\n';
                    taskDescription+='Corn Total: '+existing.CornTotalAcreagesCY__c+'\n';
                    taskDescription+='OSR Total: '+existing.OSRTotalAcreagesCY__c+'\n';
                    taskDescription+='Corn Dekalb: '+existing.CornDekalbMarketShareCY__c+'\n';
                    taskDescription+='OSR Dekalb: '+existing.OSRDekalbMarketshareCY__c+'\n';
                    taskDescription+='Total Other: '+existing.TotalOtherAcreagesManualCY__c +'\n';
                    taskDescription+='Total: '+existing.totalAcreagesCY__c+'\n';
                    
                    //Reset all acreage fields to existing values
                    p_acc.CornTotalAcreagesCY__c = existing.CornTotalAcreagesCY__c;
                    p_acc.OSRTotalAcreagesCY__c = existing.OSRTotalAcreagesCY__c;
                    p_acc.CornDekalbMarketShareCY__c = existing.CornDekalbMarketShareCY__c;
                    p_acc.OSRDekalbMarketshareCY__c = existing.OSRDekalbMarketshareCY__c;
                    p_acc.TotalOtherAcreagesManualCY__c = existing.TotalOtherAcreagesManualCY__c ;
                    p_acc.totalAcreagesCY__c = existing.totalAcreagesCY__c;
                  
            return new Task(ownerid = existing.OwnerId, Description = taskDescription, whatId=p_acc.Id, ActivityDate=System.today(), Subject='Acreages update from event');
            
        }else{
          
            return null;
            
           }
        
    }
    
    /**   Backup documents   **/

    public static void generateBackupDocument(String request, REST_EventObject response, boolean status){
        if((
            systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='all'  || 
            systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='exception' && status == false ))
        {
            String documentName='REST_SendLogicalEntityActivity'+string.valueOf(system.currentTimeMillis())+'_'+Util.currentUser.ID;
            String logFolder=systemSettings__c.getvalues(Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER').Value__c;
            
            if (status) documentName = documentName+'_OK';
            else documentName = documentName+'_ERR';
            
            documentName=documentName.remove(':').remove(' ').remove('-');
            
            System.debug('Document Name: ' + documentName);
            String body = '[REQUEST]\n'+request+'\n[RESPONSE]\n' + System.JSON.serializePretty(response) ;
            Blob documentBody= Blob.valueOf(body);
            list<Folder> destFolder = [SELECT Id FROM Folder WHERE DeveloperName =:logFolder AND Type = 'Document' AND AccessType = 'Public'];
            if (destFolder.size() == 1) {
                Document doc= new Document(Name = documentName , body=documentBody,developerName=documentName, IsPublic = true, FolderId=destFolder[0].Id, contentType='text/plain',type='json' );
                insert doc;
            }
            else {
                system.debug('SharedDocuments folder not found or returned too many values: ' + destFolder);
            }
        }
        else if (systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c!='none'){
            system.debug('Warning: Unexpected value in System Setting \'EAST_REST_SVC_JSON_SAVE\'. Expected values are \'None\', \'Exceptioin\' or \'All\'');
        }
    }
    
    public static void sendEmailError(String eventId, List<String> errors)      
    {
        try 
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'monsanto.salesforce@everis.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('monsanto.salesforce@everis.com');
            mail.setSenderDisplayName('Name');
            mail.setSubject('error importing data for event: '+eventId);
            mail.setBccSender(false);
            mail.setPlainTextBody('This is test email body. This mail is being sent from apex code');
            //mail.setHtmlBody('<b> This is HTML body </b>' );
            
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName('error.txt');
            String error = '';
            for(String item : errors)
            {
                error += item;
            }
            efa.setBody(Blob.valueOf(error));
            fileAttachments.add(efa);
            mail.setFileAttachments(fileAttachments);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception e)
        {
        }
    } 
    
}