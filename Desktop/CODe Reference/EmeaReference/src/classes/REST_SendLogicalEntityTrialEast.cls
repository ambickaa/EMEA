@RestResource(urlMapping='/sendLogicalEntity/Trial/*')
global with sharing class REST_SendLogicalEntityTrialEast{

    private static Map<Integer,CampaignLineItemGroup__c> groupsToInsert = new Map<Integer,CampaignLineItemGroup__c>();
    private static List<CampaignLineItemGroup__c> groupsToUpdate = new List<CampaignLineItemGroup__c>();
    private static List<CampaignLineItemGroup__c> groupsToDelete = new List<CampaignLineItemGroup__c>();
    private static Map<Id,CampaignLineItemGroup__c> groupsToReassign = new Map<Id,CampaignLineItemGroup__c>();
     
    private static Map<Integer,CampaignLineItem__C> trialsToInsert = new Map<Integer,CampaignLineItem__C>();
    private static List<CampaignLineItem__C> trialsToUpdate = new List<CampaignLineItem__C>();
    private static List<CampaignLineItem__C> trialsToDelete = new List<CampaignLineItem__C>();
        
    @HttpPost
    global static REST_SendLogicalEntityTrial sendTrials(REST_SendLogicalEntityTrial paramInfo)
    {
        String request = System.JSON.serializePretty(paramInfo);
        REST_SendLogicalEntityTrial returned = paramInfo;

        // Init_Of    TimeStamp check
        Set<ID> trialsIdToCheck = new Set<ID>();
        for(REST_TrialObject rto : returned.trials){
          rto.trial.OwnerId=Util.currentUser.Id;        
            if(!'Insert'.equalsIgnoreCase(rto.action)){
                trialsIdToCheck.add(rto.trial.ID);
            }
        }
        Set<ID> groupsIdToCheck = new Set<ID>();
        for(REST_GroupObject rgo : returned.groups){
          rgo.cligroup.OwnerId=Util.currentUser.Id;  
            if(!'Insert'.equalsIgnoreCase(rgo.action)){
                groupsIdToCheck.add(rgo.cligroup.ID);
            }
        }
        Map<ID,CampaignLineItem__c> trialsToCheck = new Map<ID,CampaignLineItem__c>([SELECT LastModifiedDate FROM CampaignLineItem__C WHERE ID IN :trialsIdToCheck]);
        Map<ID,CampaignLineItemGroup__c> groupsToCheck = new Map<ID,CampaignLineItemGroup__c>([SELECT LastModifiedDate FROM CampaignLineItemGroup__c WHERE ID IN :groupsIdToCheck]);
        
        String accountCLIsTimestamp = '';
        String accountCLIsDelete = '';
        returned.statusDescription = '';
        for(REST_TrialObject rto : returned.trials){
            if(!'Insert'.equalsIgnoreCase(rto.action)){
                if(trialsToCheck.get(rto.trial.id) == null){
                    returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                    accountCLIsDelete += rto.trial.FarmName__c+'\n';
                    rto.statusCode = returned.statusCode;
                    rto.statusDescription = returned.statusDescription;
                }else if(rto.trial.LastModifiedDate != trialsToCheck.get(rto.trial.id).LastModifiedDate){
                    returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    accountCLIsTimestamp += rto.trial.FarmName__c+'\n';
                    rto.statusCode = returned.statusCode;
                    rto.statusDescription = returned.statusDescription;
                }
                if('Update'.equalsIgnoreCase(rto.action)){
                    trialsToUpdate.add(rto.trial);
                }else{
                    if(CampaignLineItem__c.sObjectType.getDescribe().isDeletable()){
                        trialsToDelete.add(rto.trial);
                    }else{
                        returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        returned.statusDescription = getErrorDescription(returned.statusCode);
                        rto.statusCode = returned.statusCode;
                        rto.statusDescription = returned.statusDescription;
                    }
                }
            }else{
                trialsToInsert.put(Integer.valueof(rto.trial.idDevice__c),rto.trial);
            }
        }
        if(accountCLIsTimestamp != '')
        {
            returned.statusDescription += 'Campaign Line Items for the next accounts have been overwritten because of online changes: \n'+accountCLIsTimestamp;
        }
        if(accountCLIsDelete != '')
        {
            returned.statusDescription += '\n\nCampaign Line Items for the next accounts have been deleted from the online: \n'+accountCLIsDelete;         
        }
        List <Id> accountCLIGsTimestampList = new List<Id>();
        List <Id> accountCLIGsDeleteList = new List<Id>();
        for(REST_GroupObject rgo : returned.groups){
            if(!'Insert'.equalsIgnoreCase(rgo.action)){
                if(groupsToCheck.get(rgo.cligroup.id) == null){
                    returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                    accountCLIGsDeleteList.add(rgo.cligroup.AccountRef__c);
                    rgo.statusCode = returned.statusCode;
                    rgo.statusDescription = returned.statusDescription;
                }else if(rgo.cligroup.LastModifiedDate != groupsToCheck.get(rgo.cligroup.id).LastModifiedDate){
                    returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    accountCLIGsTimestampList.add(rgo.cligroup.AccountRef__c);
                    rgo.statusCode = returned.statusCode;
                    rgo.statusDescription = returned.statusDescription;
                }
                if('Update'.equalsIgnoreCase(rgo.action)){
                    groupsToUpdate.add(rgo.cligroup);
                }else if('Delete'.equalsIgnoreCase(rgo.action)){
                    if(CampaignLineItemGroup__c.sObjectType.getDescribe().isDeletable()){
                        groupsToDelete.add(rgo.cligroup);
                    }else{
                        returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        returned.statusDescription = getErrorDescription(returned.statusCode);
                        rgo.statusCode = returned.statusCode;
                        rgo.statusDescription = returned.statusDescription;
                    }
                }
            }else{
                groupsToInsert.put(Integer.valueOf(rgo.cligroup.idDevice__c),rgo.cligroup);
                groupsToUpdate.add(rgo.cligroup);
            }
        }
        
         List<Account> accountNameCLIGsDeleteList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountCLIGsDeleteList
                                                        ];
        List<Account> accountNameCLIGsTimestampList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountCLIGsTimestampList
                                                        ];
        String accountCLIGsDelete = '';
        String accountCLIGsTimestamp = '';
        
        for(account acc : accountNameCLIGsDeleteList )
        {
            accountCLIGsDelete += acc.Name +'\n';
        }
        for(account acct : accountNameCLIGsTimestampList )
        {
            accountCLIGsTimestamp += acct.Name +'\n';
        }
        if(accountCLIGsTimestamp != '')
        {
            returned.statusDescription += 'Campaign Line Item Groups for the next accounts have been overwritten because of online changes: \n'+accountCLIGsTimestamp;
        }
        if(accountCLIGsDelete != '')
        {
            returned.statusDescription += '\n\nCampaign Line Item Groups for the next accounts have been deleted from the online: \n'+accountCLIGsDelete;          
        }
        if(returned.statusCode == ERROR_TIMESTAMP_MISMATCH || returned.statusCode == ERROR_RECORD_PREVIOUSLY_DELETED || returned.statusCode == ERROR_USER_HAS_NO_RIGHTS){
             generateBackupDocument(request,paramInfo,false);
             return returned;
        }
        // End_Of    TimeStamp Check
        
        returned.statusCode = 100;
        returned.statusDescription = 'Processed';
        Savepoint sp = Database.setSavepoint();
        Integer punto = 0;
        try{
            delete groupsToDelete;
            
            punto = 1;
            
            insert groupsToInsert.values();
            
            punto = 2;
            
            update groupsToUpdate;
            
            punto = 3;
            
            delete trialsToDelete;

            
            for(REST_TrialObject rto : returned.trials){
                if(rto.GroupIdIdDevice != 0 && rto.trial.CampaignLineItemGroupRef__c == null){
                    rto.trial.CampaignLineItemGroupRef__c = groupsToInsert.get(rto.GroupIdIdDevice).id;
                    
                }
            }
            
            punto = 4;
            
            insert trialsToInsert.values();
            
            punto = 5;
            
            update trialsToUpdate;
            
            punto = 6;
     
            update groupsToReassign.values();

            
            Map<id,CampaignLineItemGroup__c> groupsToGet = new Map<ID,CampaignLineItemGroup__c>([SELECT LastModifiedDate FROM CampaignLineItemGroup__c WHERE ID IN :groupsToUpdate]);
             //Set all the error codes to 100 and fill LastModifiedDate if possible
            for(REST_GroupObject rgo : returned.groups){
                rgo.statusCode = returned.statusCode;
                rgo.statusDescription = returned.statusDescription;
                if(!'Delete'.equalsIgnoreCase(rgo.action)){
                    rgo.LastModifiedDate = groupsToGet.get(rgo.cligroup.id).LastModifiedDate;
                }
            }
            Map<ID,CampaignLineItem__C> trialsToGet = new Map<ID,CampaignLineItem__C>([SELECT LastModifiedDate FROM CampaignLineItem__C WHERE ID IN :trialsToInsert.values() OR ID IN :trialsToUpdate]);
            for(REST_TrialObject rto : returned.trials){
                rto.statusCode = returned.statusCode;
                rto.statusDescription = returned.statusDescription;
                if(!'Delete'.equalsIgnoreCase(rto.action)){
                    rto.LastModifiedDate = trialsToGet.get(rto.trial.id).LastModifiedDate;
                }
            }
            generateBackupDocument(request,paramInfo,true);
            
        }catch(DMLException e){
          String errorMsg ='';
            String accId;
            String ItemProdId;
            String CLIGType;
            String CLIG;
            for(Integer i = 0; i<e.getNumDMl(); i++){
              errorMsg += e.getDmlMessage(i);
            if(e.getDmlFields(i)!=null &&  e.getDmlFields(i).size()>0)
                errorMsg += ' : ' + e.getDmlFields(i)[0].getDescribe().getLabel() + ' ';  
              
            if(punto == 0 && groupsToDelete[e.getDmlIndex(i)]!= null && groupsToDelete[e.getDmlIndex(i)].AccountRef__c != null && groupsToDelete[e.getDmlIndex(i)].Type__c != null)
                {
                  accId = groupsToDelete[e.getDmlIndex(i)].AccountRef__c;
                  CLIGType = groupsToDelete[e.getDmlIndex(i)].Type__c;                  
                }
            if(punto == 1 && groupsToInsert.values()[e.getDmlIndex(i)]!= null && groupsToInsert.values()[e.getDmlIndex(i)].AccountRef__c != null && groupsToInsert.values()[e.getDmlIndex(i)].Type__c != null)
                {
                  accId = groupsToInsert.values()[e.getDmlIndex(i)].AccountRef__c;
                  CLIGType = groupsToInsert.values()[e.getDmlIndex(i)].Type__c;
                }  
            if(punto == 2 && groupsToUpdate[e.getDmlIndex(i)]!= null && groupsToUpdate[e.getDmlIndex(i)].AccountRef__c != null && groupsToUpdate[e.getDmlIndex(i)].Type__c != null)
                {
                  accId = groupsToUpdate[e.getDmlIndex(i)].AccountRef__c;
                  CLIGType = groupsToUpdate[e.getDmlIndex(i)].Type__c;
                  system.debug('entra por el punto 2');
                }  
            if(punto == 3 && trialsToDelete[e.getDmlIndex(i)]!= null && trialsToDelete[e.getDmlIndex(i)].FarmRef__c != null && trialsToDelete[e.getDmlIndex(i)].ProductRef__c != null && trialsToDelete[e.getDmlIndex(i)].CampaignLineItemGroupRef__c!=null)
                {
                  accId = trialsToDelete[e.getDmlIndex(i)].FarmRef__c;
                  ItemProdId = trialsToDelete[e.getDmlIndex(i)].ProductRef__c;
                  CLIG = trialsToDelete[e.getDmlIndex(i)].CampaignLineItemGroupRef__c;
                }  
            if(punto == 4 && trialsToInsert.values()[e.getDmlIndex(i)]!= null && trialsToInsert.values()[e.getDmlIndex(i)].FarmRef__c != null && trialsToInsert.values()[e.getDmlIndex(i)].ProductRef__c != null && trialsToInsert.values()[e.getDmlIndex(i)].CampaignLineItemGroupRef__c!=null)
                {
                  accId = trialsToInsert.values()[e.getDmlIndex(i)].FarmRef__c;
                  ItemProdId = trialsToInsert.values()[e.getDmlIndex(i)].ProductRef__c;
                  CLIG = trialsToInsert.values()[e.getDmlIndex(i)].CampaignLineItemGroupRef__c;
                  system.debug('CLIG: ' + CLIG);
                }
             if(punto == 5 && trialsToUpdate[e.getDmlIndex(i)]!= null && trialsToUpdate[e.getDmlIndex(i)].FarmRef__c != null && trialsToUpdate[e.getDmlIndex(i)].ProductRef__c != null && trialsToUpdate[e.getDmlIndex(i)].CampaignLineItemGroupRef__c!=null)
                {
                  accId = trialsToUpdate[e.getDmlIndex(i)].FarmRef__c;
                  ItemProdId = trialsToUpdate[e.getDmlIndex(i)].ProductRef__c;
                  CLIG = trialsToUpdate[e.getDmlIndex(i)].CampaignLineItemGroupRef__c;
                }
             if(punto == 6 && groupsToReassign.values()[e.getDmlIndex(i)]!= null && groupsToReassign.values()[e.getDmlIndex(i)].AccountRef__c != null && groupsToReassign.values()[e.getDmlIndex(i)].Type__c != null)
                {
                  accId = groupsToReassign.values()[e.getDmlIndex(i)].AccountRef__c;
                  CLIGType = groupsToReassign.values()[e.getDmlIndex(i)].Type__c;
                }     
            }
          
            system.debug('entra en exception'+e);


            Database.rollback(sp);
            ID itemFailed;
            String ee ='' + e;
            if((''+e).contains(';'))
                if((''+e).split(';')[0].contains('id '))
                    itemFailed = (''+e).split(';')[0].split('id ')[1];
            
            Account acc;
            Product2 prod;
            CampaignLineItemGroup__c campaignLIG;
                        
            if(accId!=null && ItemProdId!=null && CLIG!=null){
                       acc = [SELECT name FROM Account WHERE id=:accId];
                       prod = [SELECT name FROM Product2 WHERE id=:ItemProdId];
                       try{
                         campaignLIG = [SELECT Type__c FROM CampaignLineItemGroup__c WHERE id=:CLIG];
                       }
                       catch(Exception exc)
                         {
                           CLIG ='';
                         }
                        errorMsg = e.getDmlMessage(0)+'\n\n' + 'account: ' +acc.name + '\n' +'product: ' + prod.name + '\n\n' + (campaignLIG!=null?'Type: '+campaignLIG.Type__c+ '\n\n':'')  +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                    }        
            if(accId!=null && CLIGType!=null){
                       acc = [SELECT name FROM Account WHERE id=:accId];
                        errorMsg = e.getDmlMessage(0)+'\n\n' + 'account: ' +acc.name + '\n\n' + 'type: '+ CLIGType + '\n\n' +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                    }        
            system.debug('mensaje: '+ errorMsg);          
                      
            returned.statusDescription = '';
            if((''+e).contains('to review the status of this')){
                returned.statusCode = ERROR_STATUS_CHANGE_NOT_ALLOWED;
            }else{
                returned.statusCode = ERROR_UNKNOWN;
                returned.statusDescription = errorMsg;
            }
            
            returned.statusDescription =  (returned.statusCode==ERROR_UNKNOWN ? '' : (getErrorDescription(returned.statusCode)))+ returned.statusDescription;
            
            if(itemFailed!=null){
                for(REST_GroupObject rgo : returned.groups){
                    if(rgo.cligroup.id == itemFailed){
                        rgo.statusCode = returned.statusCode;
                        rgo.statusDescription = returned.statusDescription;
                    }else{
                        rgo.statusCode = ERROR_NOT_PROCESSED;
                        rgo.statusDescription = getErrorDescription(rgo.statusCode);
                    }
                }
                for(REST_TrialObject rto : returned.trials){
                    if(rto.trial.id == itemFailed){
                        rto.statusCode = returned.statusCode;
                        rto.statusDescription = returned.statusDescription;
                    }else{
                        rto.statusCode = ERROR_NOT_PROCESSED;
                        rto.statusDescription = getErrorDescription(rto.statusCode);
                    }
                }
            }
            generateBackupDocument(request,paramInfo,false);
            
            
//        to review the status of this 
        }catch(Exception e){
            system.debug('EXCEPTION FOUND!!! ' + e);
            Database.rollback(sp);
            
            returned.statusCode = ERROR_UNKNOWN;
            returned.statusDescription = '' + e;
            returned.statusDescription = getErrorDescription(returned.statusCode) + returned.statusDescription;
            generateBackupDocument(request,paramInfo,false);
        }
        
        
        system.debug('EXIT: '+returned);
        return returned;
    }
    
    global class REST_SendLogicalEntityTrial{
        public Integer statusCode;
        public String statusDescription;
        
        public List<REST_GroupObject> groups;
        public List<REST_TrialObject> trials;
    }
    
    global class REST_GroupObject{
        public String action;
        public Integer statusCode;
        public String statusDescription;
        
        public DateTime LastModifiedDate;    
        
        public CampaignLineItemGroup__c cligroup;
    }
    
    global class REST_TrialObject{
        public String action;
        public Integer statusCode;
        public String statusDescription;
        
        public DateTime LastModifiedDate;
        
        public Integer GroupIdIdDevice;
        
        public CampaignLineItem__C trial;
    }
    
    
    // Errors Description
    private static Integer ERROR_STATUS_CHANGE_NOT_ALLOWED = 105;
    
    private static Integer ERROR_TIMESTAMP_MISMATCH = 200;
    private static Integer ERROR_RECORD_PREVIOUSLY_DELETED = 201;
    private static Integer ERROR_USER_HAS_NO_RIGHTS = 202;
    
    private static Integer ERROR_NOT_PROCESSED = 998;
    private static Integer ERROR_UNKNOWN = 999;
    
    private static String getErrorDescription(Integer paramError){
        if(paramError == ERROR_STATUS_CHANGE_NOT_ALLOWED) return 'You are not allowed to change Status field';
        
        if(paramError == ERROR_TIMESTAMP_MISMATCH) return 'Record was updated on the server before sync';
        if(paramError == ERROR_RECORD_PREVIOUSLY_DELETED) return 'Record was deleted on the server before sync';
        if(paramError == ERROR_USER_HAS_NO_RIGHTS) return 'This user does not have enougth rights to perform this operation';
        
        if(paramError == ERROR_NOT_PROCESSED) return 'Item Not Processed or no Error Found';
        if(paramError == ERROR_UNKNOWN) return 'Unknown Error: ';
        
        return 'Unknown Error2: ';
    }
    
    
    /**Generate Backup Document according to the system settings logging value
    *
    * @param status: false when an error happens. True if everything is ok
    * 
    *
    * None: No documents are generated.
    * Exception: Documents are generated only when an exception is thrown
    * All: A document is generated always.
    * 
    */
    private static void generateBackupDocument(String request, REST_SendLogicalEntityTrial response, boolean status){
        if((
            systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='exception' && status == false ) || 
            systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='all'
        ) {
            String documentName='REST_SendLogicalEntityTrial'+string.valueOf(system.currentTimeMillis())+'_'+Util.currentUser.ID;
            String logFolder=systemSettings__c.getvalues(Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER').Value__c;
            
            if (status){
                documentName = documentName+'_OK';
            }
            else{
                documentName = documentName+'_ERR';
            }
            
             
            documentName=documentName.remove(':').remove(' ').remove('-');
            
            System.debug('Document Name: ' + documentName);
            String body = '[REQUEST]\n'+request+'\n[RESPONSE]\n'+System.JSON.serializePretty(response);
            Blob documentBody= Blob.valueOf(body);
            list<Folder> destFolder = [SELECT Id FROM Folder WHERE DeveloperName =:logFolder  AND Type = 'Document'];
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