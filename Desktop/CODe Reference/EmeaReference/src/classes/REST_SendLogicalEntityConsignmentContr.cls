@RestResource(urlMapping='/sendLogicalEntity/Consignment_5/*')
global with sharing class REST_SendLogicalEntityConsignmentContr{

    private static Map<Integer,Consignment__c> consignmentsToInsert = new Map<Integer,Consignment__c>();
    private static List<Consignment__c> consignmentsToUpdate = new List<Consignment__c>();
    private static List<Consignment__c> consignmentsToPending = new List<Consignment__c>();
    private static SET<ID> InsertsOK = new SET<ID>();
    
        
    @HttpPost
    global static REST_SendLogicalEntityConsignment sendConsignments(REST_SendLogicalEntityConsignment paramInfo)
    {
        String request = System.JSON.serializePretty(paramInfo);       
        REST_SendLogicalEntityConsignment returned = paramInfo;
        User currentUser=Util.currentUser;      
                
        for(REST_ConsignmentObject rco : returned.consignments){                
            //Consignment to insert 
            rco.consignment.Status__c='Rejected';   
            rco.consignment.UserRef__C=currentUser.Id;  
            consignmentsToInsert.put(Integer.valueOf(rco.consignment.idDevice__c),rco.consignment);
        }
        
        returned.statusCode = 100;
        returned.statusDescription = 'Processed';
        
        Savepoint sp = Database.setSavepoint();
        Integer punto = 0;
        Integer posicion = 0;
        try{
            Database.SaveResult[] insertList = Database.insert(consignmentsToInsert.values(), false);
            integer i = 0; 
                                            
            for (Database.SaveResult sr : insertList)
            {
                if((sr.isSuccess()))
                {
                    InsertsOK.add(sr.getId());
                }
            else
            {
              CustomException e = new CustomException();
            //  consignmentsToInsert.values()[i];
              posicion = i;
              e.setMessage(sr.getErrors()[0].getMessage());
              Database.rollback(sp);
              throw e;              
            }
            i++;
            }
            
            for(REST_ConsignmentObject rco : returned.consignments)         
            {
                if(InsertsOK.contains(rco.consignment.Id))
                {
                    rco.consignment.Status__c='Pending';
                    consignmentsToUpdate.add(rco.consignment);
                }   
            }   
                                                        
            punto = 1;
            Database.SaveResult[] updateList = Database.update(consignmentsToUpdate, false);
            Boolean anError=false;                      
            Map<id,Consignment__c> consignmentsToGet = new Map<ID,Consignment__c>([SELECT Name,LastModifiedDate, GlobalStockRef__r.HybridRef__r.Name, GlobalStockRef__r.HybridRef__r.Stockleft__c, Status__c, ProductCatalogEntryRef__r.ProductRef__r.Name, Requested__c FROM Consignment__c WHERE ID IN :consignmentsToUpdate]);
             
            if(consignmentsToGet.Size()>0)
                UtilRest.sendConsignmentMail(consignmentsToGet); 
            
            
            Map<Id,Double> totalRequested = new Map<Id,Double>();
            for(REST_ConsignmentObject rco : returned.consignments){
                if(totalRequested.get(rco.consignment.ProductCatalogEntryRef__c)==null)
                    totalRequested.put(rco.consignment.ProductCatalogEntryRef__c, rco.consignment.Requested__c);
                else{
                    Decimal sum = rco.consignment.Requested__c + totalRequested.get(rco.consignment.ProductCatalogEntryRef__c); 
                    totalRequested.put(rco.consignment.ProductCatalogEntryRef__c, sum); 
                }
            }   
            
            for(REST_ConsignmentObject rco : returned.consignments){
                if(!InsertsOK.contains(rco.consignment.id))
                {
                    anError=true;
                    rco.statusCode = ERROR_REQUIRED_FIELD_MISSING;                  
                    rco.consignment.Status__c=NOK;
                    rco.statusDescription=System.label.RSA_Consignment_RequiredFieldsMissing;
                }               
                else
                {
                    rco.consignment.Status__c = consignmentsToGet.get(rco.consignment.id).Status__c;                                        
                    if(rco.consignment.Status__c=='Pending')
                    {   
                        //Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
                        //app.setObjectId(rco.consignment.Id);
                        //Approval.ProcessResult result = Approval.process(app,false);
                        //system.debug('APPROVAL PROCESS RESULTS' +result.getErrors()); 
                        
                        //rco.consignment.status__c='Pending';
                        //consignmentsToPending.add(rco.consignment);
                        rco.statusCode = returned.statusCode;
                        rco.statusDescription = returned.statusDescription;
                        
                    }
                    else
                    {
                        anError=true;
                        rco.statusCode = ERROR_NOT_ENOUGH_STOCK;
                        rco.statusDescription = System.Label.RSA_Consignment_StockError; 
                        rco.statusDescription = rco.statusDescription.Replace('[HYBRID]', consignmentsToGet.get(rco.consignment.id).GlobalStockRef__r.HybridRef__r.Name);                   
                        rco.statusDescription = rco.statusDescription.Replace('[REQUESTED]', String.valueOf(rco.consignment.Requested__c));                 
                        rco.statusDescription = rco.statusDescription.Replace('[TOTALREQUESTED]', String.valueOf(totalRequested.get(rco.consignment.ProductCatalogEntryRef__c)));                   
                        rco.statusDescription = rco.statusDescription.Replace('[AVAILABLE]', String.valueOf(consignmentsToGet.get(rco.consignment.id).GlobalStockRef__r.HybridRef__r.Stockleft__c));                
                    }
                    rco.LastModifiedDate = consignmentsToGet.get(rco.consignment.id).LastModifiedDate;
                }
            }

            
          //  if(consignmentsToPending.size()==0)
         //   update consignmentsToPending;
            
            if(anError)
            {
                returned.statusCode = ERROR_PARCIAL_SUCCESS;
                returned.statusDescription = System.Label.RSA_Consignment_ParcialSuccess;                                   
            }           
            generateBackupDocument(request,paramInfo,true);

                    }catch(CustomException e){
          String errorMsg = '';
          String pceId;
          double quantityReq;
            
            if(punto == 0 && consignmentsToInsert.values()[posicion]!= null && consignmentsToInsert.values()[posicion].ProductCatalogEntryRef__c != null && consignmentsToInsert.values()[posicion].Requested__c != null)
                {
                  pceId = consignmentsToInsert.values()[posicion].ProductCatalogEntryRef__c;
                  quantityReq = (consignmentsToInsert.values()[posicion].Requested__c);
                }
            if(punto == 1 && consignmentsToUpdate[posicion]!= null && consignmentsToUpdate[posicion].ProductCatalogEntryRef__c != null && consignmentsToUpdate[posicion].Requested__c != null)
                {
                  pceId = consignmentsToUpdate[posicion].ProductCatalogEntryRef__c;
                  quantityReq = (consignmentsToUpdate[posicion].Requested__c);
                }
            if(punto == 2 && consignmentsToPending[posicion]!= null && consignmentsToPending[posicion].ProductCatalogEntryRef__c != null && consignmentsToPending[posicion].Requested__c != null)
                {
                  pceId = consignmentsToPending[posicion].ProductCatalogEntryRef__c;
                  quantityReq = (consignmentsToPending[posicion].Requested__c);
                }        
          
          

            system.debug('DML EXCEPTION FOUND!!! ' + e);
            Database.rollback(sp);
            ID itemFailed;
            String ee ='' + e;
            if((''+e).contains(';'))
                if((''+e).split(';')[0].contains('id '))
                    itemFailed = (''+e).split(';')[0].split('id ')[1];
           
            ProductCatalogEntry__c pce;
            if(pceId!=null && quantityReq!=null){
                       try
                       {pce = [SELECT ProductRef__r.name FROM ProductCatalogEntry__c WHERE id=:pceId];
                       }
                       catch(Exception e2)
                       {}
                       errorMsg = e.getMessage()+'\n\n' + (pce==null?'':'product: ' +pce.ProductRef__r.name + '\n') + 'requested quantity: ' +quantityReq + '\n\n' +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
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
                for(REST_ConsignmentObject rco : returned.consignments){
                    if(rco.consignment.id == itemFailed){
                        rco.statusCode = returned.statusCode;
                        rco.statusDescription = returned.statusDescription;
                    }else{
                        rco.statusCode = ERROR_NOT_PROCESSED;
                        rco.statusDescription = getErrorDescription(rco.statusCode);
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
        
                     
        return returned;
    }
    
  
    
    // Errors Description
    
    private static String OK = 'Accepted';
    private static String NOK = 'Rejected';
    
    private static Integer ERROR_REQUIRED_FIELD_MISSING = 103;    
    private static Integer ERROR_NOT_ENOUGH_STOCK = 104;
    
    private static Integer ERROR_STATUS_CHANGE_NOT_ALLOWED = 105;
    
    private static Integer ERROR_TIMESTAMP_MISMATCH = 200;
    private static Integer ERROR_RECORD_PREVIOUSLY_DELETED = 201;
    private static Integer ERROR_USER_HAS_NO_RIGHTS = 202;
    
    private static Integer ERROR_NOT_PROCESSED = 998;
    private static Integer ERROR_UNKNOWN = 999;

    private static Integer ERROR_PARCIAL_SUCCESS = 333;
    
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
    private static void generateBackupDocument(String request, REST_SendLogicalEntityConsignment response, boolean status){
        if((
            systemSettings__c.getvalues('RSA_REST_SVC_JSON_SAVE').Value__c=='exception' && status == false ) || 
            systemSettings__c.getvalues('RSA_REST_SVC_JSON_SAVE').Value__c=='all'
        ) {
            String documentName='REST_SendLogicalEntityConsignment'+string.valueOf(system.currentTimeMillis())+'_'+Util.currentUser.ID;
            
            if (status){
                documentName = documentName+'_OK';
            }
            else{
                documentName = documentName+'_ERR';
            }
            
            documentName=documentName.remove(':').remove(' ').remove('-');
            
            String body = '[REQUEST]\n'+request+'\n[RESPONSE]\n'+System.JSON.serializePretty(response);
            Blob documentBody= Blob.valueOf(body);
            list<Folder> destFolder = [SELECT Id FROM Folder WHERE DeveloperName = 'SharedDocuments' AND Type = 'Document'];
            if (destFolder.size() == 1) {
                Document doc= new Document(Name = documentName , body=documentBody,developerName=documentName, IsPublic = true, FolderId=destFolder[0].Id, contentType='text/plain',type='json' );
                insert doc;
            }
            else {
                system.debug('SharedDocuments folder not found or returned too many values: ' + destFolder);
            }
        }
        else if (systemSettings__c.getvalues('RSA_REST_SVC_JSON_SAVE').Value__c!='none'){
            system.debug('Warning: Unexpected value in System Setting \'RSA_REST_SVC_JSON_SAVE\'. Expected values are \'None\', \'Exceptioin\' or \'All\'');
        }
    }
    
    public class CustomException extends Exception
    {
      
    }
}