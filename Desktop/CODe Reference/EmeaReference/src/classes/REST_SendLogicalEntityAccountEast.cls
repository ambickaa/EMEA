@RestResource(urlMapping='/sendLogicalEntity/AccountEast/*')
global with sharing class REST_SendLogicalEntityAccountEast{

    private static Map<Integer,Account> accountsToInsert = new Map<Integer,Account>();
    private static List<Account> accountsToUpdate = new List<Account>();
    private static List<Account> accountsToDelete = new List<Account>();
    private static Map<Id,Account> accountsToReassign = new Map<Id,Account>();
    private static Map<Integer,Contact> contactsToInsert = new Map<Integer,Contact>();
    private static List<Contact> contactsToUpdate = new List<Contact>();
    private static List<Contact> contactsToDelete = new List<Contact>();
    private static Map<Integer,Touchpoint_Program__c> tppToInsert = new Map<Integer,Touchpoint_Program__c>();
    private static List<Touchpoint_Program__c> tppToUpdate = new List<Touchpoint_Program__c>();
    private static List<Touchpoint_Program__c> tppToDelete = new List<Touchpoint_Program__c>();
    
     
    @HttpPost
    global static REST_SendLogicalEntityAccount sendAccounts(REST_SendLogicalEntityAccount paramInfo)
    {
        String request = System.JSON.serializePretty(paramInfo);
        REST_SendLogicalEntityAccount returned = paramInfo;
        
        // Init_Of    TimeStamp check
        Set<ID> contactsIdToCheck = new Set<ID>();
        for(REST_ContactObject rco : returned.contacts){
            if(!'Insert'.equalsIgnoreCase(rco.action)){
                contactsIdToCheck.add(rco.contact.ID);
            }
        }
        Set<ID> accountsIdToCheck = new Set<ID>();
        for(REST_AccountObject rao : returned.accounts){
            if(!'Insert'.equalsIgnoreCase(rao.action)){
                accountsIdToCheck.add(rao.account.ID);
            }
        }
        
        Set<ID> tppIdToCheck = new Set<ID>();

        if(returned.touchpoints == null){
            REST_TPPObject rp1 = new REST_TPPObject();
            returned.touchpoints = new List<REST_TPPObject>();
        }
        
        for(REST_TPPObject rpo : returned.touchpoints)
        {
            system.debug('1 - ***** rpo.touchpoint.LastModifiedDate: '+rpo.touchpoint.LastModifiedDate);
            system.debug('1 - ***** rpo.LastModifiedDate: '+rpo.LastModifiedDate);
            if(rpo!=null){
                if(!'Insert'.equalsIgnoreCase(rpo.action)){
                system.debug('***** tppIdToCheck'+rpo.touchpoint.ID);
                    tppIdToCheck.add(rpo.touchpoint.ID);
                }
            }
        }
        
        Map<ID,Contact> contactsToCheck = new Map<ID,Contact>([SELECT LastModifiedDate FROM Contact WHERE ID IN :contactsIdToCheck]);
        Map<ID,Account> accountsToCheck = new Map<ID,Account>([SELECT LastModifiedDate FROM Account WHERE ID IN :accountsIdToCheck]);
        Map<ID,Touchpoint_Program__c> tppToCheck = new Map<ID,Touchpoint_Program__c>([SELECT LastModifiedDate FROM Touchpoint_Program__c WHERE ID IN :tppIdToCheck]);

        
        String contactsTimestamp = '';
        String contactsDelete = '';
        returned.statusDescription = '';
        for(REST_ContactObject rco : returned.contacts){
            if(!'Insert'.equalsIgnoreCase(rco.action)){
                if(contactsToCheck.get(rco.contact.id) == null){
                    returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                    contactsDelete += rco.contact.name+'\n';
                    rco.statusCode = returned.statusCode;
                    rco.statusDescription = returned.statusDescription;
                }else if(rco.contact.LastModifiedDate != contactsToCheck.get(rco.contact.id).LastModifiedDate){
                    returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    contactsTimestamp += rco.contact.name+'\n';
                    rco.statusCode = returned.statusCode;
                    rco.statusDescription = returned.statusDescription;
                }
                if('Update'.equalsIgnoreCase(rco.action)){
                    contactsToUpdate.add(rco.contact);
                }else{
                    if(Contact.sObjectType.getDescribe().isDeletable()){
                        contactsToDelete.add(rco.contact);
                    }else{
                        returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        returned.statusDescription = getErrorDescription(returned.statusCode);
                        rco.statusCode = returned.statusCode;
                        rco.statusDescription = returned.statusDescription;
                    }
                }
            }else{
                contactsToInsert.put(Integer.valueof(rco.contact.idDevice__c),rco.contact);
            }
        }
        if(contactsTimestamp != '')
        {
            returned.statusDescription += 'The next contacts have been overwritten because of online changes: \n'+contactsTimestamp;
        }
        if(contactsDelete != '')
        {
            returned.statusDescription += '\n\nThe next contacts have been deleted from the online: \n'+contactsDelete;            
        }
        
        String accountsTimestamp = '';
        String accountsDelete = '';
        for(REST_AccountObject rao : returned.accounts){
            if(!'Insert'.equalsIgnoreCase(rao.action)){
                if(accountsToCheck.get(rao.account.id) == null){
                    returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                    accountsDelete += rao.account.name+'\n';
                    rao.statusCode = returned.statusCode;
                    rao.statusDescription = returned.statusDescription + '\n name: '+rao.account.name+'\n';
                }else if(rao.account.LastModifiedDate != accountsToCheck.get(rao.account.id).LastModifiedDate){
                    returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    accountsTimestamp += rao.account.name+'\n';
                    rao.statusCode = returned.statusCode;
                    rao.statusDescription = returned.statusDescription + '\n name: '+rao.account.name+'\n';
                }
                if('Update'.equalsIgnoreCase(rao.action)){
                    accountsToUpdate.add(rao.account);
                }else if('Delete'.equalsIgnoreCase(rao.action)){
                    if(Account.sObjectType.getDescribe().isDeletable()){
                        accountsToDelete.add(rao.account);
                    }else{
                        returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        returned.statusDescription = getErrorDescription(returned.statusCode);
                        rao.statusCode = returned.statusCode;
                        rao.statusDescription = returned.statusDescription;
                    }
                }
            }else{
             //BEGIN CR-00000286: For Italy, when an active account is create in the ipad the REST class will update the status to "Review".
             system.debug('***** Log 1:'+rao.account.CountryRef__c + ', ' +rao.account.GC_Status_Descr__c);
                if(rao.account.CountryRef__c == 'a0CD000000PNdHGMA1' && rao.account.GC_Status_Descr__c =='Active') rao.account.GC_Status_Descr__c ='To be reviewed'; 
            //END 16/07/2015
            
                accountsToInsert.put(Integer.valueOf(rao.account.idDevice__c),rao.account);
                accountsToUpdate.add(rao.account);
            }
        }       
        
        if(accountsTimestamp != '')
        {
            returned.statusDescription += 'The next accounts have been overwritten because of online changes: \n'+accountsTimestamp;
        }
        if(accountsDelete != '')
        {
            returned.statusDescription += '\n\nThe next accounts have been deleted from the online: \n'+accountsDelete;            
        }
        
        
        String tppTimestamp = '';
        String tppDelete = '';
        returned.statusDescription = '';
        for(REST_TPPObject rpo : returned.touchpoints){
            if(!'Insert'.equalsIgnoreCase(rpo.action)){
                if(tppToCheck.get(rpo.touchpoint.id) == null){
                    returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                    tppDelete += rpo.touchpoint.name+'\n';
                    rpo.statusCode = returned.statusCode;
                    rpo.statusDescription = returned.statusDescription;
                
                }else if(rpo.touchpoint.LastModifiedDate != tppToCheck.get(rpo.touchpoint.id).LastModifiedDate){
                    returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    tppTimestamp += rpo.touchpoint.name+'\n';
                    rpo.statusCode = returned.statusCode;
                    rpo.statusDescription = returned.statusDescription;
                }
                if('Update'.equalsIgnoreCase(rpo.action)){
                    tppToUpdate.add(rpo.touchpoint);
                }else{
                    if(Touchpoint_Program__c.sObjectType.getDescribe().isDeletable()){
                        tppToDelete.add(rpo.touchpoint);
                    }else{
                        returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        returned.statusDescription = getErrorDescription(returned.statusCode);
                        rpo.statusCode = returned.statusCode;
                        rpo.statusDescription = returned.statusDescription;
                    }
                }
            }else{
                tppToInsert.put(Integer.valueof(rpo.touchpoint.idDevice__c),rpo.touchpoint);
            }
        }
        if(tppTimestamp != '')
        {
            returned.statusDescription += 'The next touchpoint have been overwritten because of online changes: \n'+tppTimestamp;
        }
        if(tppDelete != '')
        {
            returned.statusDescription += '\n\nThe next touchpoint have been deleted from the online: \n'+tppDelete;            
        }
        
        if(returned.statusCode == ERROR_TIMESTAMP_MISMATCH || returned.statusCode == ERROR_RECORD_PREVIOUSLY_DELETED || returned.statusCode == ERROR_USER_HAS_NO_RIGHTS){
             generateBackupDocument(request,paramInfo,false);
             return returned;
        }
        // End_Of    TimeStamp Check
        
        returned.statusCode = 100;
        returned.statusDescription = 'Processed';
        Savepoint sp = Database.setSavepoint();
        //punto indicates the last DML operation that was completed correctly
        Integer punto = 0;
        try{
            delete accountsToDelete;
            punto = 1;
            insert accountsToInsert.values();
            punto = 2;
            update accountsToUpdate;
            punto = 3;
            delete contactsToDelete;
            punto = 4;
            for(REST_ContactObject rco : returned.contacts){
                if(rco.AccountIdIdDevice != 0 && rco.contact.accountID == null){
                    rco.contact.accountID = accountsToInsert.get(rco.AccountIdIdDevice).id;
                    
                }
            }
            insert contactsToInsert.values();
            punto = 5;
            update contactsToUpdate;
            punto = 6;
     
          
            for(REST_AccountObject rao :  returned.accounts){
                if(rao.ParentIdIdDevice != 0 && ( rao.account.parentID == null || string.valueof(rao.account.parentID).equals(''))){
                    rao.account.parentId = accountsToInsert.get(rao.ParentIdIdDevice).id;
                    accountsToReassign.put(rao.account.ID,rao.account);
                }
                if(rao.PrimaryPoSIdDevice != 0 && (rao.account.PrimaryPoS__c == null || string.valueof(rao.account.PrimaryPoS__c).equals(''))){
                    rao.account.PrimaryPoS__c = accountsToInsert.get(rao.PrimaryPoSIdDevice).id;
                    accountsToReassign.put(rao.account.ID,rao.account);
                }
                if(rao.PrimaryDistributorIdDevice != 0 && ( rao.account.PrimaryDistributor__c == null || string.valueof(rao.account.PrimaryDistributor__c).equals(''))){
                    rao.account.PrimaryDistributor__c = accountsToInsert.get(rao.PrimaryDistributorIdDevice).id;
                    accountsToReassign.put(rao.account.ID,rao.account);
                }
                    
                if(rao.BuyerIdDevice != 0 && (rao.account.Buyer_RSA__c == null || string.valueof(rao.account.Buyer_RSA__c).equals(''))){
                    rao.account.Buyer_RSA__c=contactsToInsert.get(rao.BuyerIdDevice).id;
                    accountsToReassign.put(rao.account.ID,rao.account);
                    
                }
                
            }
            update accountsToReassign.values();
      punto = 7;
            
            Map<id,Account> accountsToGet = new Map<ID,Account>([SELECT LastModifiedDate, City__c, StateProvince__c,DE_Landkreis__c, Micro_Region__c, County__c,DE_ZIP_PLZ__c FROM Account WHERE ID IN :accountsToUpdate]);
             //Set all the error codes to 100 and fill LastModifiedDate if possible
            for(REST_AccountObject rao : returned.accounts){
                rao.statusCode = returned.statusCode;
                rao.statusDescription = returned.statusDescription;
                if(!'Delete'.equalsIgnoreCase(rao.action)){
                    rao.LastModifiedDate = accountsToGet.get(rao.account.id).LastModifiedDate;
                    if(rao.account.City__c!=null)
                        rao.account.City__c = accountsToGet.get(rao.account.id).City__c;
                    if(rao.account.StateProvince__c!=null)
                        rao.account.StateProvince__c = accountsToGet.get(rao.account.id).StateProvince__c;
                    if(rao.account.DE_Landkreis__c!=null)
                        rao.account.DE_Landkreis__c = accountsToGet.get(rao.account.id).DE_Landkreis__c;
                    if(rao.account.Micro_Region__c!=null)
                        rao.account.Micro_Region__c = accountsToGet.get(rao.account.id).Micro_Region__c;
                    if(rao.account.County__c!=null)
                        rao.account.County__c = accountsToGet.get(rao.account.id).County__c;
                    if(rao.account.DE_ZIP_PLZ__c!=null)
                        rao.account.DE_ZIP_PLZ__c = accountsToGet.get(rao.account.id).DE_ZIP_PLZ__c;                    
                }
            }
            Map<ID,Contact> contactsToGet = new Map<ID,Contact>([SELECT LastModifiedDate,DE_Territory_Key__c,Street__c,StateProvince__c,Micro_Region__c,County__c,CountryRef__c,City__c,DE_Landkreis__c,DE_ZIP_PLZ__c FROM Contact WHERE ID IN :contactsToInsert.values() OR ID IN :contactsToUpdate]);
            for(REST_ContactObject rco : returned.contacts){
                rco.statusCode = returned.statusCode;
                rco.statusDescription = returned.statusDescription;
                if(!'Delete'.equalsIgnoreCase(rco.action)){
                    rco.LastModifiedDate = contactsToGet.get(rco.contact.id).LastModifiedDate;
                    if(rco.contact.DE_Territory_Key__c!=null)
                          rco.contact.DE_Territory_Key__c = contactsToGet.get(rco.contact.id).DE_Territory_Key__c;
                    if(rco.contact.Street__c!=null)
                          rco.contact.Street__c = contactsToGet.get(rco.contact.id).Street__c;
                    if(rco.contact.StateProvince__c!=null)
                          rco.contact.StateProvince__c = contactsToGet.get(rco.contact.id).StateProvince__c;
                    if(rco.contact.Micro_Region__c!=null)
                          rco.contact.Micro_Region__c = contactsToGet.get(rco.contact.id).Micro_Region__c;
                    if(rco.contact.County__c!=null)
                          rco.contact.County__c = contactsToGet.get(rco.contact.id).County__c;
                    if(rco.contact.CountryRef__c!=null)
                          rco.contact.CountryRef__c = contactsToGet.get(rco.contact.id).CountryRef__c;
                    if(rco.contact.City__c!=null)
                          rco.contact.City__c = contactsToGet.get(rco.contact.id).City__c;
                    if(rco.contact.DE_Landkreis__c!=null)
                          rco.contact.DE_Landkreis__c = contactsToGet.get(rco.contact.id).DE_Landkreis__c;
                }
            }
            
            punto = 8;
            delete tppToDelete;
            punto = 9;
            
            for(REST_TPPObject rtpp : returned.touchpoints){
                if(rtpp.AccountIdIdDevice != 0 && rtpp.touchpoint.LKP_ACCOUNT__c == null){
                    rtpp.touchpoint.LKP_ACCOUNT__c = accountsToInsert.get(rtpp.AccountIdIdDevice).id;
                    
                }
            }
            
            insert tppToInsert.values();
            punto = 10;
            update tppToUpdate;
            
            Map<ID,Touchpoint_Program__c> tppsToGet = new Map<ID,Touchpoint_Program__c>([SELECT LastModifiedDate FROM Touchpoint_Program__c WHERE ID IN :tppToInsert.values() OR ID IN :tppToUpdate]);
            for(REST_TPPObject rtpp : returned.touchpoints){
                rtpp.statusCode = returned.statusCode;
                rtpp.statusDescription = returned.statusDescription;
                if(!'Delete'.equalsIgnoreCase(rtpp.action)){
                    rtpp.LastModifiedDate = tppsToGet.get(rtpp.touchpoint.id).LastModifiedDate;
                }
            }
            
            generateBackupDocument(request,paramInfo,true);
            
            if(Test.isRunningTest()) {
                // Cause DMLException
                insert new Lead();
            }
            
        }catch(DMLException e){
            String errorMsg ='';
            String accName;
            String ConName;
            String tppName;
            for(Integer i = 0; i<e.getNumDMl(); i++){            
                errorMsg += e.getDmlMessage(i);
                if(e.getDmlFields(i)!=null &&  e.getDmlFields(i).size()>0)
                    errorMsg += ' : ' + e.getDmlFields(i)[0].getDescribe().getLabel() + ' ';
            system.debug('***** errorMsg: '+errorMsg );
            if(punto == 0 && accountsToDelete[e.getDmlIndex(i)]!= null && accountsToDelete[e.getDmlIndex(i)].Name != null)
                {
                  AccName = accountsToDelete[e.getDmlIndex(i)].Name;
                }
            if(punto == 1 && accountsToInsert.values()[e.getDmlIndex(i)]!= null && accountsToInsert.values()[e.getDmlIndex(i)].Name != null)
                {
                  AccName = accountsToInsert.values()[e.getDmlIndex(i)].Name;
                }  
            if(punto == 2 && accountsToUpdate[e.getDmlIndex(i)]!= null && accountsToUpdate[e.getDmlIndex(i)].Name != null)
                {
                  AccName = accountsToUpdate[e.getDmlIndex(i)].Name;
                }  
            if(punto == 3 && contactsToDelete[e.getDmlIndex(i)]!= null && contactsToDelete[e.getDmlIndex(i)].Name != null)
                {
                  ConName = contactsToDelete[e.getDmlIndex(i)].Name;
                }  
            if(punto == 4 && contactsToInsert.values()[e.getDmlIndex(i)]!= null && contactsToInsert.values()[e.getDmlIndex(i)].Name != null)
                {
                  ConName = contactsToInsert.values()[e.getDmlIndex(i)].Name;
                }
             if(punto == 5 && contactsToUpdate[e.getDmlIndex(i)]!= null && contactsToUpdate[e.getDmlIndex(i)].Name != null)
                {
                  ConName = contactsToUpdate[e.getDmlIndex(i)].Name;
                }
             if(punto == 6 && accountsToReassign.values()[e.getDmlIndex(i)]!= null && accountsToReassign.values()[e.getDmlIndex(i)].Name != null)
                {
                  AccName = accountsToReassign.values()[e.getDmlIndex(i)].Name;
                } 
             if(punto == 8 && tppToDelete[e.getDmlIndex(i)]!= null && tppToDelete[e.getDmlIndex(i)].Name != null)
                {system.debug('***** errorMsg1: '+errorMsg );
                  tppName = tppToDelete[e.getDmlIndex(i)].Name;
                }  
            if(punto == 9 && tppToInsert.values()[e.getDmlIndex(i)]!= null && tppToInsert.values()[e.getDmlIndex(i)].Name != null)
                {system.debug('***** errorMsg2: '+errorMsg );
                  tppName = tppToInsert.values()[e.getDmlIndex(i)].Name;
                }
             if(punto == 10 && tppToUpdate[e.getDmlIndex(i)]!= null && tppToUpdate[e.getDmlIndex(i)].Name != null)
                {system.debug('***** errorMsg3: '+errorMsg );
                  tppName = tppToUpdate[e.getDmlIndex(i)].Name;
                }
            }
          
          system.debug('entra en exception'+e);

            Database.rollback(sp);
            ID itemFailed;
            String ee ='' + e;
            if((''+e).contains(';'))
                if((''+e).split(';')[0].contains('id '))
                    itemFailed = (''+e).split(';')[0].split('id ')[1];
                      


   if(AccName!=null){
                       
                        errorMsg = e.getDmlMessage(0)+'\n\n' + 'account: ' + AccName + '\n\n' +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                    }        
             if(ConName!=null){
                       
                        errorMsg = e.getDmlMessage(0)+'\n\n' + 'contact: ' + ConName + '\n\n' +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                    }
             if(tppName!=null){
                       
                        errorMsg = e.getDmlMessage(0)+'\n\n' + 'touchpointprogram: ' + tppName + '\n\n' +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                    }         
            
            system.debug('***** mensaje: '+ errorMsg);
          
            returned.statusDescription = '';
            if((''+e).contains('to review the status of this')){
                returned.statusCode = ERROR_STATUS_CHANGE_NOT_ALLOWED;
            }else{
                returned.statusCode = ERROR_UNKNOWN;
                returned.statusDescription =  errorMsg;
            }
            
            returned.statusDescription =  (returned.statusCode==ERROR_UNKNOWN ? '' : (getErrorDescription(returned.statusCode)))+ returned.statusDescription;
            
            if(itemFailed!=null){
                for(REST_AccountObject rao : returned.accounts){
                    if(rao.account.id == itemFailed){
                        rao.statusCode = returned.statusCode;
                        rao.statusDescription = returned.statusDescription;
                    }else{
                        rao.statusCode = ERROR_NOT_PROCESSED;
                        rao.statusDescription = getErrorDescription(rao.statusCode);
                    }
                }
                for(REST_ContactObject rco : returned.contacts){
                    if(rco.contact.id == itemFailed){
                        rco.statusCode = returned.statusCode;
                        rco.statusDescription = returned.statusDescription;
                    }else{
                        rco.statusCode = ERROR_NOT_PROCESSED;
                        rco.statusDescription = getErrorDescription(rco.statusCode);
                    }
                }
                
                for(REST_TPPObject rpo : returned.touchpoints){
                    if(rpo.touchpoint.id == itemFailed){
                        rpo.statusCode = returned.statusCode;
                        rpo.statusDescription = returned.statusDescription;
                    }else{
                        rpo.statusCode = ERROR_NOT_PROCESSED;
                        rpo.statusDescription = getErrorDescription(rpo.statusCode);
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
    
    global class REST_SendLogicalEntityAccount{
        public Integer statusCode;
        public String statusDescription;
        
        public List<REST_AccountObject> accounts;
        public List<REST_ContactObject> contacts;
        public List<REST_TPPObject> touchpoints;
    }
    
    global class REST_AccountObject{
        public String action;
        public Integer statusCode;
        public String statusDescription;
        
        public DateTime LastModifiedDate;
        public Integer BuyerIdDevice;
        public Integer BankAccountHolderIdDevice;
        public Integer ParentIdIdDevice;
        public Integer PrimaryPoSIdDevice;
        public Integer PrimaryDistributorIdDevice;
        
        public Account account;
    }
    
    global class REST_ContactObject{
        public String action;
        public Integer statusCode;
        public String statusDescription;
        
        public DateTime LastModifiedDate;
        
        public Integer AccountIdIdDevice;
        
        public Contact contact;
    }
    
     global class REST_TPPObject{
        public String action;
        public Integer statusCode;
        public String statusDescription;
        
        public DateTime LastModifiedDate;
        
        public Integer AccountIdIdDevice;
        
        public Touchpoint_Program__c touchpoint;
    }
    
    
    
    // Errors Description
    private static Integer ERROR_STATUS_CHANGE_NOT_ALLOWED = 105;
    
    private static Integer ERROR_TIMESTAMP_MISMATCH = 200;
    private static Integer ERROR_RECORD_PREVIOUSLY_DELETED = 201;
    private static Integer ERROR_USER_HAS_NO_RIGHTS = 202;
    
    private static Integer ERROR_NOT_PROCESSED = 998;
    private static Integer ERROR_UNKNOWN = 999;
    private static Integer ERROR_EMPTY = 0;
    
    private static String getErrorDescription(Integer paramError){
        if(paramError == ERROR_EMPTY) 
            return '';
        if(paramError == ERROR_STATUS_CHANGE_NOT_ALLOWED) 
            return 'You are not allowed to change Status field';
        if(paramError == ERROR_TIMESTAMP_MISMATCH) 
            return 'Record was updated on the server before sync';
        if(paramError == ERROR_RECORD_PREVIOUSLY_DELETED) 
            return 'Record was deleted on the server before sync';
        if(paramError == ERROR_USER_HAS_NO_RIGHTS) 
            return 'This user does not have enougth rights to perform this operation';
        if(paramError == ERROR_NOT_PROCESSED) 
            return 'Item Not Processed or no Error Found';
        if(paramError == ERROR_UNKNOWN) 
            return 'Unknown Error: ';
        
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
    private static void generateBackupDocument(String request, REST_SendLogicalEntityAccount response, boolean status){
        if((
            systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='exception' && status == false ) || 
            systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='all'
        ) {
            String documentName='REST_SendLogicalEntityAccount'+string.valueOf(system.currentTimeMillis())+'_'+Util.currentUser.ID;
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