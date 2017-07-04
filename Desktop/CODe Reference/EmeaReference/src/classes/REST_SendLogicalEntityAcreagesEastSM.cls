@RestResource(urlMapping='/sendLogicalEntity/AcreageSM/*')
global without sharing class REST_SendLogicalEntityAcreagesEastSM{

    private static Map<Integer,Acreage__c> acreagesToInsert = new Map<Integer,Acreage__c>();
    private static List<Acreage__c> acreagesToUpdate = new List<Acreage__c>();
    private static List<Acreage__c> acreagesToDelete = new List<Acreage__c>();
    private static Map<Id,Acreage__c> acreagesToReassign = new Map<Id,Acreage__c>();
    
    private static Map<Integer, Field__c> fieldsToInsert = new Map<Integer, Field__c>();
    private static List<Field__c> fieldsToUpdate = new List<Field__c>();
    private static List<Field__c> fieldsToDelete = new List<Field__c>();
            
    @HttpPost
    global static REST_SendLogicalEntityAcreage sendAcreages(REST_SendLogicalEntityAcreage paramInfo)
    {
        String request = System.JSON.serializePretty(paramInfo);
        
        REST_SendLogicalEntityAcreage returned = paramInfo;
        
        // Init_Of TimeStamp check
        Set<ID> acreagesIdToCheck = new Set<Id>();
        Set<Id> fieldsIdToCheck = new Set<Id>();
        
        //ACREAGE
        if(returned.acreages != null)
        {
          for(REST_AcreageObject rao : returned.acreages){
              if(!'Insert'.equalsIgnoreCase(rao.action)){
                  system.debug('!insert...');
                  acreagesIdToCheck.add(rao.acreage.Id);
              }
          }
        }
        //FIELD
        if(returned.fields != null)
        {
          for(REST_FieldObject rfo: returned.fields)
          {
              system.debug(rfo.field.Id);
              if(!'Insert'.equalsIgnoreCase(rfo.action))
              {
                  fieldsIdToCheck.add(rfo.field.Id);
              }
          }
        }
       Map<Id,Acreage__c> acreagesToCheck = new Map<Id,Acreage__c>([SELECT Id, LastModifiedDate FROM Acreage__c WHERE ID IN :acreagesIdToCheck]);
       
       List<Id> accountAcreagesTimestampList = new List<Id>();
       List<Id> accountAcreagesDeleteList = new List<Id>();
       returned.statusDescription = '';
       if(returned.acreages != null)
       {
         for(REST_AcreageObject rao : returned.acreages){
              if(!'Insert'.equalsIgnoreCase(rao.action)){
                  if(acreagesToCheck.get(rao.acreage.id) == null){
                      returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                      accountAcreagesDeleteList.add(rao.acreage.AcrFarmRef__c);
                      rao.statusCode = returned.statusCode;
                      rao.statusDescription = returned.statusDescription;
                  }                  
                  else if(rao.LastModifiedDate != (acreagesToCheck.get(rao.acreage.id)).LastModifiedDate){
                      
                    System.debug(rao.LastModifiedDate + 'fecha objeto REST_AcreageObject');
                    System.debug(acreagesToCheck.get(rao.acreage.id).LastModifiedDate + 'fecha objecto Acreage');
                      returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                      returned.statusDescription = getErrorDescription(returned.statusCode);
                      accountAcreagesTimestampList.add(rao.acreage.AcrFarmRef__c);
                      rao.statusCode = returned.statusCode;
                      rao.statusDescription = returned.statusDescription;
                  }
                  if('Update'.equalsIgnoreCase(rao.action)){
                      acreagesToUpdate.add(rao.acreage);
                  }else if('Delete'.equalsIgnoreCase(rao.action)){        
                      if(Acreage__c.sObjectType.getDescribe().isDeletable()){
                          acreagesToDelete.add(rao.acreage);                        
                      }else{
                          returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                          returned.statusDescription = getErrorDescription(returned.statusCode);
                          rao.statusCode = returned.statusCode;
                          rao.statusDescription = returned.statusDescription;
                      }
                  }
              }
              else
              {
                  acreagesToInsert.put(Integer.valueOf(rao.acreage.idDevice__c),rao.acreage);
              }
          }
       }
       
        List<Account> accountNameAcreagesDeleteList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountAcreagesDeleteList 
                                                        ];
        List<Account> accountNameAcreagesTimestampList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountAcreagesTimestampList 
                                                        ];
        String accountAcreagesDelete = '';
        String accountAcreagesTimestamp = '';
        
        for(account acc : accountNameAcreagesDeleteList)
        {
            accountAcreagesDelete += acc.Name +'\n';
        }
        for(account acct : accountNameAcreagesTimestampList)
        {
            accountAcreagesTimestamp += acct.Name +'\n';
        }
              
       if(accountAcreagesTimestamp != '')
        {
            returned.statusDescription += 'Acreages for the next accounts have been overwritten because of online changes: \n'+accountAcreagesTimestamp;
        }
        if(accountAcreagesDelete != '')
        {
            returned.statusDescription += '\n\nAcreages for the next accounts have been deleted from the online: \n'+accountAcreagesDelete;            
        }
        
        Map<ID, Field__c> fieldsToCheck = new Map<ID,Field__c>([SELECT Id, LastModifiedDate FROM Field__c WHERE ID IN :fieldsIdToCheck]);
        List<Id> accountFieldsTimestampList = new List<Id>();
        List<Id> accountFieldsDeleteList = new List<Id>();
        if(returned.fields != null)
        {
          for(REST_FieldObject rfo: returned.fields)
          {
              if(!'Insert'.equalsIgnoreCase(rfo.action))
              {
                  if(fieldsToCheck.get(rfo.field.id) == null)
                  {
                      returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                      accountFieldsDeleteList.add(rfo.field.LKP_Acreage__c);
                      rfo.statusCode = returned.statusCode;
                      rfo.statusDescription = returned.statusDescription;
                      
                      system.debug('statuscode l 134: '+ rfo.statusCode);
                  }
                  else if(rfo.LastModifiedDate != (fieldsToCheck.get(rfo.field.id)).LastModifiedDate)
                  {
                      returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                      returned.statusDescription = getErrorDescription(returned.statusCode);
                      accountFieldsTimestampList.add(rfo.field.LKP_Acreage__c);
                      system.debug('id de la farm: ' +rfo.field.LKP_Acreage__c);
                      rfo.statusCode = returned.statusCode;
                      rfo.statusDescription = returned.statusDescription;
                      
                      system.debug('statuscode l 143: '+ rfo.statusCode);
                      system.debug('lista de fields timestamp: ' + accountFieldsTimestampList);
                  }
                  if('Update'.equalsIgnoreCase(rfo.action)){
                      fieldsToUpdate.add(rfo.field);
                  }else if('Delete'.equalsIgnoreCase(rfo.action)){        
                      if(Field__c.sObjectType.getDescribe().isDeletable()){
                          fieldsToDelete.add(rfo.field);                        
                      }else{
                          returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                          returned.statusDescription = getErrorDescription(returned.statusCode);
                          rfo.statusCode = returned.statusCode;
                          rfo.statusDescription = returned.statusDescription;
                          
                          system.debug('statuscode l 155: '+ rfo.statusCode);
                      }
                  }
              }
              else
              {                            
                  fieldsToInsert.put(Integer.valueOf(rfo.field.idDevice__c), rfo.field);
                  system.debug('fieldsToInsert:' + Integer.valueOf(rfo.field.idDevice__c));
              }
          }
        }
        List<Acreage__c> accountNameFieldsDeleteList = [SELECT
                                                acrFarmRef__r.name
                                                FROM
                                                Acreage__c
                                                WHERE id IN : accountFieldsDeleteList
                                                        ];
        List<Acreage__c> accountNameFieldsTimestampList = [SELECT
                                                acrFarmRef__r.name
                                                FROM
                                                Acreage__c
                                                WHERE id IN : accountFieldsTimestampList
                                                        ];
        String accountFieldsDelete = '';
        String accountFieldsTimestamp = '';
        
        for(Acreage__c acc : accountNameFieldsDeleteList)
        {
            accountFieldsDelete += acc.acrFarmRef__r.name +'\n';
        }
        for(Acreage__c acct : accountNameFieldsTimestampList)
        {
            accountFieldsTimestamp += acct.acrFarmRef__r.name +'\n';
        }
        
        if(accountFieldsTimestamp != '')
        {
            returned.statusDescription += '\n\nFields for the next accounts have been overwritten because of online changes: \n'+accountFieldsTimestamp;
        }
        if(accountFieldsDelete != '')
        {
            returned.statusDescription += '\n\nFields for the next accounts have been deleted from the online: \n'+accountFieldsDelete;            
        }  
        
        if(returned.statusCode == ERROR_TIMESTAMP_MISMATCH || returned.statusCode == ERROR_RECORD_PREVIOUSLY_DELETED || returned.statusCode == ERROR_USER_HAS_NO_RIGHTS){
            system.debug('statuscode error' + returned.statusCode);
            generateBackupDocument(request,paramInfo,false);
            return returned;
        }
        // End_Of    TimeStamp Check
        
        returned.statusCode = 100;
        returned.statusDescription = 'Processed';
        Savepoint sp = Database.setSavepoint();
        Integer punto;
        try
        {                      
            if(acreagesToInsert.size() > 0)
            {
              punto = 1;            
              insert acreagesToInsert.values();
              system.debug('acreages size' + returned.acreages);
            }
            if(acreagesToUpdate.size() > 0)
            {
              punto = 2;            
              update acreagesToUpdate;
            }
            if(fieldsToUpdate.size() > 0)
            {
                punto = 3;
                update fieldsToUpdate;
            }
            if(fieldsToInsert.size() > 0)
            {
                punto = 4;                
                
                for(Integer i = 0; i < fieldsToInsert.size(); i++)
                {
                  if(fieldsToInsert.values()[i].LKP_Acreage__c == null && acreagesToInsert.get(Integer.valueOf(fieldsToInsert.values()[i].idDeviceParent__c)) != null) 
                  {
                    fieldsToInsert.values()[i].LKP_Acreage__c = acreagesToInsert.get(Integer.valueOf(fieldsToInsert.values()[i].idDeviceParent__c)).Id;
                  }                  
                }
                insert fieldsToInsert.values();                
            }            
            if(fieldsToDelete.size() > 0)
            {
                punto = 5;
                delete fieldsToDelete;
            }
            if(acreagesToDelete.size() > 0)
          {
            punto = 0;
            delete acreagesToDelete;
          }      
            
            if(returned.acreages != null)
            {
              Map<id,Acreage__c> acreagesToGet = new Map<ID,Acreage__c>([SELECT LastModifiedDate FROM Acreage__c WHERE Id IN :acreagesToInsert.values() OR Id IN :acreagesToUpdate]);
               //Set all the error codes to 100 and fill LastModifiedDate if possible
              for(REST_AcreageObject rao : returned.acreages){
                  rao.statusCode = returned.statusCode;
                  rao.statusDescription = returned.statusDescription;
                  if(!'Delete'.equalsIgnoreCase(rao.action)){
                      rao.LastModifiedDate = acreagesToGet.get(rao.acreage.id).LastModifiedDate;
                  }
              }              
            }                     
            if(returned.fields != null)
            {
              Map<Id, Field__c> fieldsToGet = new Map<Id, Field__c>([SELECT LastModifiedDate FROM Field__c WHERE Id IN :fieldsToInsert.values() OR Id IN :fieldsToUpdate]);
              for(REST_FieldObject rfo: returned.fields)
              {
                rfo.statusCode = returned.statusCode;
                rfo.statusDescription = returned.statusDescription;
                if(!'Delete'.equalsIgnoreCase(rfo.action))
                {
                  rfo.LastModifiedDate = fieldsToGet.get(rfo.field.Id).LastModifiedDate;
                }
              }
            }
            
            acreagesToInsert.clear();
            acreagesToUpdate.clear();
            acreagesToUpdate.clear();
            
            fieldsToInsert.clear();
            fieldsToUpdate.clear();
            fieldsToDelete.clear();            
            
            generateBackupDocument(request,paramInfo,true);
            
        }
        catch(DMLException e){
            String errorMsg ='';
            String accId;
            String prodGroupId;
            String prodTypeId;
            String acrId;
            String fieldId;
            String fieldName;
            for(Integer i = 0; i < e.getNumDMl(); i++)
            {
                    errorMsg += e.getDmlMessage(i);
                if(e.getDmlFields(i)!=null &&  e.getDmlFields(i).size()>0)
                        errorMsg += ' : ' + e.getDmlFields(i)[0].getDescribe().getLabel() + ' ';
                if(punto == 0 && acreagesToDelete[e.getDmlIndex(i)]!= null && acreagesToDelete[e.getDmlIndex(i)].AcrFarmRef__c != null && acreagesToDelete[e.getDmlIndex(i)].AcrProductGroupRef__c != null && acreagesToDelete[e.getDmlIndex(i)].AcrProductTypeRef__c != null)
                {
                    accId = acreagesToDelete[e.getDmlIndex(i)].AcrFarmRef__c;
                    prodGroupId = acreagesToDelete[e.getDmlIndex(i)].AcrProductGroupRef__c;
                    prodTypeId = acreagesToDelete[e.getDmlIndex(i)].AcrProductTypeRef__c;                    
                }                
                if(punto == 1 && acreagesToInsert.values()[e.getDmlIndex(i)]!= null && acreagesToInsert.values()[e.getDmlIndex(i)].AcrFarmRef__c != null && acreagesToInsert.values()[e.getDmlIndex(i)].AcrProductGroupRef__c != null && acreagesToInsert.values()[e.getDmlIndex(i)].AcrProductTypeRef__c != null)
                    {
                        accId = acreagesToInsert.values()[e.getDmlIndex(i)].AcrFarmRef__c;
                        prodGroupId = acreagesToInsert.values()[e.getDmlIndex(i)].AcrProductGroupRef__c;
                        prodTypeId = acreagesToInsert.values()[e.getDmlIndex(i)].AcrProductTypeRef__c;
                        
                    }   
                if(punto == 2 && acreagesToUpdate[e.getDmlIndex(i)]!= null && acreagesToUpdate[e.getDmlIndex(i)].AcrFarmRef__c != null && acreagesToUpdate[e.getDmlIndex(i)].AcrProductGroupRef__c != null && acreagesToUpdate[e.getDmlIndex(i)].AcrProductTypeRef__c != null)
                {
                    accId = acreagesToUpdate[e.getDmlIndex(i)].AcrFarmRef__c;
                    prodGroupId = acreagesToUpdate[e.getDmlIndex(i)].AcrProductGroupRef__c;
                    prodTypeId = acreagesToUpdate[e.getDmlIndex(i)].AcrProductTypeRef__c;
                    
                }
                if(punto == 3 && fieldsToUpdate[e.getDmlIndex(i)] != null && fieldsToUpdate[e.getDmlIndex(i)].LKP_Acreage__c != null)
                {
                    acrId = fieldsToUpdate[e.getDmlIndex(i)].LKP_Acreage__c;
                    fieldId = fieldsToUpdate[e.getDmlIndex(i)].Id;
                    fieldName = fieldsToUpdate[e.getDmlIndex(i)].Name;
                }
                if(punto == 4 && fieldsToInsert.values()[e.getDmlIndex(i)] != null && fieldsToInsert.values()[e.getDmlIndex(i)].LKP_Acreage__c != null)
                {
                    acrId = fieldsToInsert.values()[e.getDmlIndex(i)].LKP_Acreage__c;
                    fieldId = fieldsToInsert.values()[e.getDmlIndex(i)].Id;
                    fieldName = fieldsToInsert.values()[e.getDmlIndex(i)].Name;
                }
                if(punto == 5 && fieldsToDelete[e.getDmlIndex(i)] != null && fieldsToDelete[e.getDmlIndex(i)].LKP_Acreage__c != null)
                {
                    acrId = fieldsToDelete[e.getDmlIndex(i)].LKP_Acreage__c;
                    fieldId = fieldsToUpdate[e.getDmlIndex(i)].Id;
                    fieldName = fieldsToUpdate[e.getDmlIndex(i)].Name;
                }                
            }           
            
            system.debug('DML EXCEPTION FOUND!!! ' + e);
            Database.rollback(sp);
            ID itemFailed;
            String ee ='' + e;
            
            if((''+e).contains(';'))
                if((''+e).split(';')[0].contains('id '))
                    itemFailed = (''+e).split(';')[0].split('id ')[1];
              system.debug('itemFailed: ' + itemFailed);        
            Account acc;
            Product_Grouping__c prodG;
            Product_Grouping__c prodT;
                        
            if(accId!=null && prodGroupId!=null && prodTypeId!=null){
                         acc = [SELECT name FROM Account WHERE id=:accId];
                         prodG = [SELECT name FROM Product_Grouping__c WHERE id=:prodGroupId];
                         prodT = [SELECT name FROM Product_Grouping__c WHERE id=:prodTypeId];
                        errorMsg = e.getDmlMessage(0)+'\n\n' + 'account: ' +acc.name + '\n' +'product group: ' + prodG.name + '\n' +'product type: ' + prodT.name + '\n\n' +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                    }          
                      
             else if(acrId!=null && fieldId !=null){
                 acc = [SELECT Name FROM Account WHERE id IN (SELECT AcrFarmRef__c FROM Acreage__c WHERE id=:acrId) LIMIT 1];
                 
                errorMsg = e.getDmlMessage(0)+'\n\n' + 'account: ' +acc.name + '\n' +'field: ' + fieldName + '\n\n' +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
        }         
            returned.statusDescription = '';
            if((''+e).contains('to review the status of this')){
                returned.statusCode = ERROR_STATUS_CHANGE_NOT_ALLOWED;
            }else{
                returned.statusCode = ERROR_UNKNOWN;
                returned.statusDescription = errorMsg;
            }
            
            returned.statusDescription =  (returned.statusCode==ERROR_UNKNOWN ? '' : (getErrorDescription(returned.statusCode)))+ returned.statusDescription;
            
            if(itemFailed!=null){
                for(REST_AcreageObject rao : returned.acreages){
                    if(rao.acreage.id == itemFailed){
                        rao.statusCode = returned.statusCode;
                        rao.statusDescription = returned.statusDescription;
                    }else{
                        rao.statusCode = ERROR_NOT_PROCESSED;
                        rao.statusDescription = getErrorDescription(rao.statusCode);
                    }
                }
                if(returned.fields != null)
                {
	                for(REST_FieldObject rfo : returned.fields){
	                    if(rfo.field.id == itemFailed){
	                        rfo.statusCode = returned.statusCode;
	                        rfo.statusDescription = returned.statusDescription;
	                    }else{
	                        rfo.statusCode = ERROR_NOT_PROCESSED;
	                        rfo.statusDescription = getErrorDescription(rfo.statusCode);
	                    }
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
    
    global class REST_SendLogicalEntityAcreage{
        public Integer statusCode;
        public String statusDescription;        
        public List<REST_AcreageObject> acreages;
        public List<REST_FieldObject> fields;
    }
    
    global class REST_AcreageObject{
        public String action;
        public Integer statusCode;
        public String statusDescription;        
        public DateTime LastModifiedDate;
        public Acreage__c acreage;
    }
    global class REST_FieldObject{
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public DateTime LastModifiedDate;
        public Field__c field;
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
    private static void generateBackupDocument(String request, REST_SendLogicalEntityAcreage response, boolean status){
        if((
            systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='exception' && status == false ) || 
            systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='all'
        ) {
            String documentName='REST_SendLogicalEntityAcreage'+string.valueOf(system.currentTimeMillis())+'_'+Util.currentUser.ID;
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