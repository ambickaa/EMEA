global with sharing class importDatafromCSVBatch implements Database.batchable<string>{
    
    public Id COUNTRY_ID;
    public Id DIVISION_ID;
    public Id YEAR_ID;
    public Id PC_SALES_ID;
    public Id FOLDER_ID;
    public Id DOCUMENT_ID; 
    public final Datetime TIMESTAMP;
    
    public Set<string> distributors;
    public Map<String, ProductCatalogEntry__c> products ;
    public Map<String,Campaign> campaigns;
    
    public importDatafromCSVBatch (Id documentId, Id countryId, Id yearId, Id divisionId, Datetime timestampDT){
        COUNTRY_ID = countryId;
        DIVISION_ID = divisionId;
        YEAR_ID = yearId;
        DOCUMENT_ID = documentId;
        TIMESTAMP = timestampDT;
        FOLDER_ID = Id.ValueOf(SystemSettings__c.getValues('NFULOADS_FOLDERID').Value__c);
        
        Id monsantoId=Id.ValueOf(SystemSettings__c.getValues('MONSANTO_DISTRIBUTOR_ID').Value__c); 
        distributors = new Set<String>();
        for(Account acc : [SELECT id FROM Account WHERE RecordTypeId ='012D000000035Au' AND CountryRef__c =: COUNTRY_ID]){
            distributors.add(to15(String.valueOf(acc.id)));
        }

        PC_SALES_ID = [SELECT id FROM ProductCatalog__c WHERE YearRef__c =: YEAR_ID 
                                                         AND RecordTypeId='012D000000035BE' 
                                                         AND DivisionRef__c =:  DIVISION_ID
                                                         AND CountryRef__c=: COUNTRY_ID LIMIT 1].Id;

        products = new Map<String, ProductCatalogEntry__c>();
        for(ProductCatalogEntry__c pce : [SELECT id,ProductRef__c,FRML_ProductCode__c FROM ProductCatalogEntry__c WHERE ProductCatalogRef__c =:PC_SALES_ID 
                                                                                                                      AND ProductRef__r.ProductVendor__c =: monsantoId]){
            products.put(pce.FRML_ProductCode__c,pce);
        }  

        campaigns = new Map<String,Campaign>();
        for(Campaign cam : [SELECT id, ownerid FROM Campaign WHERE YearV2__c =: YEAR_ID 
                                                             AND DivisionRef__c =: DIVISION_ID 
                                                             AND CountryRef__c =: COUNTRY_ID]){
            campaigns.put(to15(String.valueOf(cam.OwnerId)),cam);
        }   
    }
    
    global Iterable<String> start(Database.batchableContext batchableContext){

        return new CustomCSVIterator();
    }
   
    global void execute(Database.BatchableContext batchableContext, List<String> scope){
        System.debug('***** scope:'+scope);
       Integer x=0;
       TriggerCampaignLineItemUpdateAccount.fromBatch=true;
       CSVReader reader = new CSVReader(scope[x]);
       Set<Id> distSet=new Set<Id>();
       Map <String,CampaignLineItem__c> cliJoined = new map<string,CampaignLineItem__c>();
       String body='';
       system.debug('***** Init reader'+reader);
       while(!reader.EOF){
           List<string> csvRecordData = reader.ReadLine();
           system.debug('***** Start'+csvRecordData);
           if(products.containsKey(csvRecordData[2]) && campaigns.containsKey(to15(csvRecordData[0])) && distributors.contains(to15(csvRecordData[1]))){
              CampaignLineItem__c cli= new CampaignLineItem__c(
                       OwnerId                   = Id.valueOf(csvRecordData[0]),
                       FarmRef__c                = Id.valueOf(csvRecordData[1]),
                       ProductCatalogEntryRef__c = products.get(csvRecordData[2]).id,
                       ProductRef__c             = products.get(csvRecordData[2]).ProductRef__c,
                       Forecast__c               = decimal.valueOf(csvRecordData[3]),
                       NUM_DELIVERED_CY_QTY__c      = decimal.valueOf(csvRecordData[5]),
                       /* 23/02/2015 ini - Add data in POG when loading from SAP*/
                       POG__c                    = decimal.valueOf(csvRecordData[5]),
                       /* 23/02/2015 fin */
                       Status__c                 = 'Confirmed',
                       Type__c                   = 'Charged',
                       CampaignRef__c            = campaigns.get(csvRecordData[0]).id,
                       RecordTypeId              ='012D000000035B2'
               );
               system.debug('***** cli:'+cli);
               if (!cliJoined.containsKey(cli.FarmRef__c+''+cli.ProductRef__c+''+cli.OwnerId)){
                    system.debug('***** cli 1');
                    cliJoined.put(cli.FarmRef__c+''+cli.ProductRef__c+''+cli.OwnerId, cli);
                    distSet.add(cli.FarmRef__c);
               } else {
                    system.debug('***** cli 2');
                    cli.Forecast__c += cliJoined.get(cli.FarmRef__c+''+cli.ProductRef__c+''+cli.OwnerId).forecast__c;   
                    cli.NUM_DELIVERED_CY_QTY__c += cliJoined.get(cli.FarmRef__c+''+cli.ProductRef__c+''+cli.OwnerId).NUM_DELIVERED_CY_QTY__c;
                    /* 23/02/2015 ini - Add data in POG when loading from SAP*/
                    cli.POG__c += cliJoined.get(cli.FarmRef__c+''+cli.ProductRef__c+''+cli.OwnerId).POG__c;
                    /* 23/02/2015 fin */                    
                    cliJoined.put(cli.FarmRef__c+''+cli.ProductRef__c+''+cli.OwnerId, cli);
               }
           } else {
                system.debug('***** ELSE');
               for(Integer i=0; i<csvRecordData.size()-2; i++){
                   body += csvRecordData[i]+',';
               }
               body +=  csvRecordData[csvRecordData.size()-1]; 
           }
       }    
       if(((cliJoined).keySet()).size()>0){
           
           Map<String, CampaignLineItem__c> existingClis = new Map<String, CampaignLineItem__c>();
           List<CampaignLineItem__c> cliToUpdate = new List<CampaignLineItem__c> ();
           List<CampaignLineItem__c> cliToInsert = new List<CampaignLineItem__c> ();
           
           for(CampaignLineItem__c cli : [SELECT Id, FarmRef__c, OwnerId, ProductRef__c, Forecast__c, NUM_ORDERED_CY_QTY__c, NUM_DELIVERED_CY_QTY__c,
                                          //23/02/2015 ini - Add data in POG when loading from SAP
                                          POG__c
                                          //23/02/2015 fin
                                          FROM CampaignLineItem__c
                                          WHERE FarmRef__c IN :distSet
                                          AND RecordTypeId='012D000000035B2'
                                          AND CreatedDate >:TIMESTAMP]){
                existingClis.put(cli.FarmRef__c+''+cli.ProductRef__c+''+cli.OwnerId, cli);                            
           }
           for (String key : cliJoined.keySet()){
               if(!existingClis.containsKey(key)) cliToInsert.add(cliJoined.get(key));
               else{
                    cliToUpdate.add(new CampaignLineItem__c( Id                     =  existingClis.get(key).Id,
                                                             Forecast__c            =  existingClis.get(key).Forecast__c + cliJoined.get(key).Forecast__c,
                                                             NUM_ORDERED_CY_QTY__c   =  existingClis.get(key).NUM_ORDERED_CY_QTY__c + cliJoined.get(key).NUM_ORDERED_CY_QTY__c,
                                                             NUM_DELIVERED_CY_QTY__c   =  existingClis.get(key).NUM_DELIVERED_CY_QTY__c + cliJoined.get(key).NUM_DELIVERED_CY_QTY__c,
                                                             /* 23/02/2015 ini - Add data in POG when loading from SAP*/
                                                             POG__c                 =  existingClis.get(key).POG__c + cliJoined.get(key).POG__c
                                                             /* 23/02/2015 fin */
                                   ));
               }
           }
           system.debug('***** cli cliToInsert'+cliToInsert);
           system.debug('***** cli cliToUpdate'+cliToUpdate);
           if(cliToInsert.size()>0) insert cliToInsert;
           if(cliToUpdate.size()>0) update cliToUpdate;
       }
       if(body!=''){
           String developerName = ('NFU Load - '+(String.valueOf(TIMESTAMP))).remove(':').remove(' ').remove('-');
           List<Document >documents = [SELECT Id, body FROM Document WHERE folderId=:FOLDER_ID AND DeveloperName=: developerName];
           if (documents.size()>=1){
               String newBody = (documents.get(0).body).toString() + body;
               documents.get(0).body = Blob.ValueOf(newBody);
               update documents;
           } else {
                String documentName = 'NFU Load - ' + String.valueOf(TIMESTAMP);
                Document doc= new Document(Name = documentName, 
                                           body=Blob.valueOf(body),
                                           developerName=documentName.remove(':').remove(' ').remove('-'), 
                                           IsPublic = true, 
                                           FolderId=FOLDER_ID, 
                                           contentType='text/plain');
                insert doc;                
           }
       }
       x++;        
    }
    global void finish(Database.BatchableContext batchableContext){
        
        Document docToDelete =new Document(id=DOCUMENT_ID);
        try{
            delete docToDelete;
        } catch (Exception e){
            System.Debug('The dcument cannot be deleted due to '+e.getmessage());
            /** A deletion failure means the document does not exist anymore so no action is needed **/
        }
        importDatafromCSVDeletionBatch instance = new importDatafromCSVDeletionBatch(TIMESTAMP, COUNTRY_ID, YEAR_ID, DIVISION_ID);
        System.scheduleBatch(instance, 'Old CampaignLineItem deletion process', 30);        
    }
    private static String to15(String stringId){
        if (stringId.length()>15) return stringId.substring(0,15);
        else return stringId;
    }    
}