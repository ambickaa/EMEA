@RestResource(urlMapping='/sendLogicalEntity/Activity/*') 
global without sharing class REST_SendLogicalEntityActivity{
    
    private static Map<Integer,Task> tasksToInsert = new Map<Integer,Task>();
    private static List<Task> tasksToUpdate = new List<Task>();
    private static List<Task> tasksToDelete = new List<Task>();
    
    private static Map<Integer,Event> eventsToInsert = new Map<Integer,Event>();
    private static List<Event> eventsToUpdate = new List<Event>();
    private static List<Event> eventsToDelete = new List<Event>();
         
    @HttpPost
    global static REST_ActivityObject sendActivities(REST_ActivityObject paramInfo){
        
        String request = System.JSON.serializePretty(paramInfo);
        REST_ActivityObject returned = paramInfo;
        
        /* Begin - Timestamp checking*/
        Set<Id> eventsIdToCheck = new Set<Id>();
        for(REST_EventObject reo : returned.events){
            if(!'Insert'.equalsIgnoreCase(reo.action)){
                eventsIdToCheck.add(reo.event.Id);
            }
        }
        Set<ID> tasksIdToCheck = new Set<ID>();
        for(REST_taskObject rto : returned.tasks){
            if(!'Insert'.equalsIgnoreCase(rto.action)){
                tasksIdToCheck.add(rto.task.ID);
            }
        }
        
        Map<ID,Event> eventsToCheck = new Map<ID,Event>([SELECT LastModifiedDate FROM Event WHERE ID IN :eventsIdToCheck]);
        Map<ID,Task> tasksToCheck = new Map<ID,Task>([SELECT LastModifiedDate FROM Task WHERE ID IN :tasksIdToCheck]); 
        
        List<Id> accountIdEventsDeleteList = new List<Id>();
        List<Id> accountIdEventsTimestampList = new List<Id>();
        returned.statusDescription = '';
        for(REST_EventObject reo : returned.events){
            if(!'Insert'.equalsIgnoreCase(reo.action)){
                if(eventsToCheck.get(reo.event.id) == null){                    
                    returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                    accountIdEventsDeleteList.add(reo.event.whatId);
                    reo.statusCode = returned.statusCode;
                    reo.statusDescription = returned.statusDescription;
                }else if(reo.event.LastModifiedDate != eventsToCheck.get(reo.event.id).LastModifiedDate){
                    returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    accountIdEventsTimestampList.add(reo.event.whatId);
                    reo.statusCode = returned.statusCode;
                    reo.statusDescription = returned.statusDescription;
                }
                if('Update'.equalsIgnoreCase(reo.action)) {

            		reo.event.whatId = reo.event.whatId;
            		reo.event.whoId = reo.event.whoId;
            		reo.event.LKP_TOUCHPOINT_PROG__c = reo.event.LKP_TOUCHPOINT_PROG__c;
                	
                   reo.event.activitydatetime = reo.event.startdatetime;
                   
                   eventsToUpdate.add(reo.event);

                }else{
                    if(Event.sObjectType.getDescribe().isDeletable()){
                        eventsToDelete.add(reo.event);
                    }else{
                        returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        returned.statusDescription = getErrorDescription(returned.statusCode);
                        reo.statusCode = returned.statusCode;
                        reo.statusDescription = returned.statusDescription;
                    }
                }
            }else{
                //BEGIN 15/07/2015 Update field TXT_Comments_Copy__c with null value before insert.It is filled through a workflow rule
                reo.event.TXT_Comments_Copy__c = null;
                reo.event.activitydatetime = reo.event.startdatetime;
                //END 15/07/2015
                eventsToInsert.put(Integer.valueof(reo.event.idDevice__c),reo.event);
            }

        }
        
       List<Account> accountNameEventsDeleteList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountIdEventsDeleteList
                                                        ];
        List<Account> accountNameEventsTimestampList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountIdEventsTimestampList
                                                        ];
        String accountEventsDelete = '';
        String accountEventsTimestamp = '';
        
        for(account acc : accountNameEventsDeleteList)
        {
            accountEventsDelete += acc.Name +'\n';
        }
        for(account acct : accountNameEventsTimestampList)
        {
            accountEventsTimestamp += acct.Name +'\n';
        }
        
        if(accountEventsTimestamp != '')
        {
            returned.statusDescription += 'Events for the next accounts have been overwritten because of online changes: \n'+accountEventsTimestamp;
        }
        if(accountEventsDelete != '')
        {
            returned.statusDescription += '\n\nEvents for the next accounts have been deleted from the online: \n'+accountEventsDelete;            
        }
        
        List<Id> accountIdTasksDeleteList = new List<Id>();
        List<Id> accountIdTasksTimestampList = new List<Id>();
        for(REST_TaskObject rto : returned.tasks){
            if(!'Insert'.equalsIgnoreCase(rto.action)){
                if(tasksToCheck.get(rto.task.id) == null){
                    returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                    accountIdTasksDeleteList.add(rto.task.whatId);
                    rto.statusCode = returned.statusCode;
                    rto.statusDescription = returned.statusDescription;
                }else if(rto.task.LastModifiedDate != tasksToCheck.get(rto.task.id).LastModifiedDate){
                    returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    accountIdTasksTimestampList.add(rto.task.whatId);
                    rto.statusCode = returned.statusCode;
                    rto.statusDescription = returned.statusDescription;
                }
                if('Update'.equalsIgnoreCase(rto.action)){
                	
            		rto.task.whatId = rto.task.whatId;
            		rto.task.whoId = rto.task.whoId;
            		rto.task.LKP_TOUCHPOINT_PROG__c = rto.task.LKP_TOUCHPOINT_PROG__c;
                	
                    tasksToUpdate.add(rto.task);
                    
                }else if('Delete'.equalsIgnoreCase(rto.action)){
                    if(Task.sObjectType.getDescribe().isDeletable()){
                        tasksToDelete.add(rto.task);
                    }else{
                        returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        returned.statusDescription = getErrorDescription(returned.statusCode);
                        rto.statusCode = returned.statusCode;
                        rto.statusDescription = returned.statusDescription;
                    }
                }
            }else{
                //BEGIN 15/07/2015 Update field TXT_Comments_Copy__c with null value before insert.It is filled through a workflow rule
                rto.task.TXT_Comments_Copy__c = null;
                //END 15/07/2015
                tasksToInsert.put(Integer.valueOf(rto.task.idDevice__c),rto.task);
            }
        }
                List<Account> accountNameTasksDeleteList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountIdEventsDeleteList
                                                        ];
        List<Account> accountNameTasksTimestampList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountIdEventsTimestampList
                                                        ];
        String accountTasksDelete = '';
        String accountTasksTimestamp = '';
        
        for(account acc : accountNameTasksDeleteList)
        {
            accountTasksDelete += acc.Name +'\n';
        }
        for(account acct : accountNameTasksTimestampList)
        {
            accountTasksTimestamp += acct.Name +'\n';
        }
        
        if(accountTasksTimestamp != '')
        {
            returned.statusDescription += 'Tasks for the next accounts have been overwritten because of online changes: \n'+accountTasksDelete;
        }
        if(accountTasksDelete != '')
        {
            returned.statusDescription += '\n\nTasks for the next accounts have been deleted from the online: \n'+accountTasksDelete;          
        }
        if(returned.statusCode == ERROR_TIMESTAMP_MISMATCH || returned.statusCode == ERROR_RECORD_PREVIOUSLY_DELETED || returned.statusCode == ERROR_USER_HAS_NO_RIGHTS){
             generateBackupDocument(request,paramInfo,false);
             return returned;
        }  
        /* End - Timestamp checking // Begin - Database commitments*/
           
        returned.statusCode = 100;
        returned.statusDescription = 'Processed';
        Savepoint sp = Database.setSavepoint();
        //punto indicates the last DML operation that was completed correctly
        Integer punto = 0; 
        try{
            if(tasksToDelete.size()>0)
            {
                punto = 0;
                delete tasksToDelete;   
            }
            
            
            if(tasksToInsert.values().size()>0)
            {
                punto = 1;
                insert tasksToInsert.values();
            }
            
            if(tasksToUpdate.size()>0)
            {
                punto = 2;
                update tasksToUpdate;
            }
            
            if(eventsToDelete.size()>0)
            {
                punto = 3;
                delete eventsToDelete;
            }
            
            if(eventsToInsert.values().size()>0)
            {
                punto = 4;

                insert eventsToInsert.values();
            }
            
            if(eventsToUpdate.size()>0)
            {
                punto = 5;
                update eventsToUpdate;
            }   
           
           Map<id,Task> TasksToGet = new Map<ID,Task>([SELECT LastModifiedDate, TXT_Comments_Copy__c FROM Task WHERE ID IN :tasksToInsert.values() OR ID IN :tasksToUpdate]);
           for(REST_TaskObject rto : returned.tasks)
           {
                rto.statusCode = returned.statusCode;
                rto.statusDescription = returned.statusDescription;
                if(!'Delete'.equalsIgnoreCase(rto.action))
                {
                    rto.LastModifiedDate = tasksToGet.get(rto.task.id).LastModifiedDate;
                    rto.task.TXT_Comments_Copy__c = tasksToGet.get(rto.task.id).TXT_Comments_Copy__c;
                }
           }
           
           Map<id,Event> EventsToGet = new Map<ID,Event>([SELECT LastModifiedDate, TXT_Comments_Copy__c FROM Event WHERE ID IN :eventsToInsert.values() OR ID IN :eventsToUpdate]);
           for(REST_EventObject reo : returned.events)
           {
                reo.statusCode = returned.statusCode;
                reo.statusDescription = returned.statusDescription;
                if(!'Delete'.equalsIgnoreCase(reo.action))
                {
                    reo.LastModifiedDate = eventsToGet.get(reo.event.id).LastModifiedDate;
                    reo.event.TXT_Comments_Copy__c = eventsToGet.get(reo.event.id).TXT_Comments_Copy__c;
                }
           }
              
           generateBackupDocument(request,paramInfo,true);
            
        }catch(DMLException e){
            String errorMsg ='';
            String accId;
            String errorType;
            for(Integer i = 0; i<e.getNumDMl(); i++){
                errorMsg += e.getDmlMessage(i);
                if(e.getDmlFields(i)!=null &&  e.getDmlFields(i).size()>0)
                    errorMsg += ' : ' + e.getDmlFields(i)[0].getDescribe().getLabel() + ' ';
                if(punto == 0 && tasksToDelete[e.getDmlIndex(i)]!= null && tasksToDelete[e.getDmlIndex(i)].Whatid != null)
                {
                  accId = tasksToDelete[e.getDmlIndex(i)].WhatId ;
                  errorType='Task ';
                }
                if(punto == 1 && tasksToInsert.values()[e.getDmlIndex(i)]!= null && tasksToInsert.values()[e.getDmlIndex(i)].Whatid != null)
                {
                  accId = tasksToInsert.values()[e.getDmlIndex(i)].WhatId ;
                  errorType='Task ';
                }
                if(punto == 2 && tasksToUpdate[e.getDmlIndex(i)]!= null && tasksToUpdate[e.getDmlIndex(i)].Whatid != null)
                {
                  accId = tasksToUpdate[e.getDmlIndex(i)].WhatId ;
                  errorType='Task ';
                }
                if(punto == 3 && eventsToDelete[e.getDmlIndex(i)]!= null && eventsToDelete[e.getDmlIndex(i)].Whatid != null)
              {
                 accId = eventsToDelete[e.getDmlIndex(i)].WhatId ;
                 errorType='Event ';
              }
                if(punto == 4 && eventsToInsert.values()[e.getDmlIndex(i)]!= null && eventsToInsert.values()[e.getDmlIndex(i)].Whatid != null)
                {
                  accId = eventsToInsert.values()[e.getDmlIndex(i)].WhatId ;
                  errorType='Event ';
                }
                if(punto == 5 && eventsToUpdate[e.getDmlIndex(i)]!= null && eventsToUpdate[e.getDmlIndex(i)].Whatid != null)
                {
                  accId = eventsToUpdate[e.getDmlIndex(i)].WhatId ;
                  errorType='Event ';
                }
                if(e.getDmlId(i)!=null)
                    errorMsg += e.getDmlId(i);

            }

            
            Database.rollback(sp);
            ID itemFailed;
            String ee ='' + e;
            if((''+e).contains(';'))
                if((''+e).split(';')[0].contains('id '))
                    itemFailed = (''+e).split(';')[0].split('id ')[1];
            Account acc;
                    if(accId!=null){
                       acc = [SELECT name FROM Account WHERE id=:accId];
                        errorMsg = e.getDmlMessage(0)+'\n\n' + errorType +'account: ' +acc.name + '\n\n' + '-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                    }
                    else{
                        errorMsg = e.getDmlMessage(0)+'\n\n' + errorType + '\n\n' + '-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                    }
                   
            returned.statusDescription = '';
            if((''+e).contains('to review the status of this')){
                returned.statusCode = ERROR_STATUS_CHANGE_NOT_ALLOWED;
            }
     /*       else if(errorMsg.length()>0){
                returned.statusCode = ERROR_EMPTY;
                returned.statusDescription = errorMsg;
            }
        */       
            else{

                returned.statusCode = ERROR_UNKNOWN;
                returned.statusDescription = errorMsg;
            }
            
            returned.statusDescription =  (returned.statusCode==ERROR_UNKNOWN ? '' : (getErrorDescription(returned.statusCode)))+ returned.statusDescription;
            
            if(itemFailed!=null){
                for(REST_TaskObject rto : returned.tasks){
                    if(rto.task.id == itemFailed){
                        rto.statusCode = returned.statusCode;
                        rto.statusDescription = returned.statusDescription;
                    }else{
                        rto.statusCode = ERROR_NOT_PROCESSED;
                        rto.statusDescription = getErrorDescription(rto.statusCode);
                    }
                }
                for(REST_EventObject reo : returned.events){
                    if(reo.event.id == itemFailed){
                        reo.statusCode = returned.statusCode;
                        reo.statusDescription = returned.statusDescription;
                    }else{
                        reo.statusCode = ERROR_NOT_PROCESSED;
                        reo.statusDescription = getErrorDescription(reo.statusCode);
                    }
                }
            }

            generateBackupDocument(request,paramInfo,false);
            
        }catch(Exception e){
            Database.rollback(sp);
            returned.statusCode = ERROR_UNKNOWN;
            returned.statusDescription = (e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') + (e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'') + Userinfo.getUserName() +'-' + System.now() ;


            returned.statusDescription = getErrorDescription(returned.statusCode) + ' ' + returned.statusDescription;
            generateBackupDocument(request,paramInfo,false);
        }
        return returned;
    }
    /**   End - Database commitments   **/
    
    /** Internal objects  **/
    global class REST_ActivityObject{
        public Integer statusCode;
        public String statusDescription;
        
        public List<REST_TaskObject> tasks;
        public List<REST_EventObject> events;
    }
    global class REST_TaskObject{
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public Datetime LastModifiedDate;
        
        public Task task;
    }
    
    global class REST_eventObject{
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public Datetime LastModifiedDate;
        
        public Event event;
    }
        
    /**   Error messages   **/
    private static Integer ERROR_EMPTY = 100;
    
    private static Integer ERROR_STATUS_CHANGE_NOT_ALLOWED = 105;
    
    private static Integer ERROR_TIMESTAMP_MISMATCH = 200;
    private static Integer ERROR_RECORD_PREVIOUSLY_DELETED = 201;
    private static Integer ERROR_USER_HAS_NO_RIGHTS = 202;
    
    private static Integer ERROR_NOT_PROCESSED = 998;
    private static Integer ERROR_UNKNOWN = 999;
    
    private static String getErrorDescription(Integer paramError){
        if(paramError == ERROR_STATUS_CHANGE_NOT_ALLOWED) return 'You are not allowed to change Status field';
        else if(paramError == ERROR_EMPTY) return '';
        else if(paramError == ERROR_TIMESTAMP_MISMATCH) return 'Record was updated on the server before sync';
        else if(paramError == ERROR_RECORD_PREVIOUSLY_DELETED) return 'Record was deleted on the server before sync';
        else if(paramError == ERROR_USER_HAS_NO_RIGHTS) return 'This user does not have enougth rights to perform this operation';
        else if(paramError == ERROR_NOT_PROCESSED) return 'Item Not Processed or no Error Found';
        else if(paramError == ERROR_UNKNOWN) return 'Unknown Error: ';
        else return 'Unknown Error2: ';
    }
    /**   Backup documents   **/
    private static void generateBackupDocument(String request, REST_ActivityObject response, boolean status){
        if((
            systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='exception' && status == false ) || 
            systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='all'  ) {
            String documentName='REST_SendLogicalEntityActivity'+string.valueOf(system.currentTimeMillis())+'_'+Util.currentUser.ID;
            String logFolder=systemSettings__c.getvalues(Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER').Value__c;
            
            if (status) documentName = documentName+'_OK';
            else documentName = documentName+'_ERR';
            
            documentName=documentName.remove(':').remove(' ').remove('-');
            
            System.debug('Document Name: ' + documentName);
            String body = '[REQUEST]\n'+request+'\n[RESPONSE]\n'+System.JSON.serializePretty(response);
            Blob documentBody= Blob.valueOf(body);
            list<Folder> destFolder = [SELECT Id FROM Folder WHERE DeveloperName =:logFolder AND Type = 'Document'];
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
}