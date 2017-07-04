public without sharing class importDatafromCSVDeletionBatch implements Database.Batchable<sObject> {
	
	public Datetime timestamp;
	public Id countryId;
	public Id divisionId;
	public Id yearId;
	public Id folderId;
	
	public importDatafromCSVDeletionBatch(Datetime timestampdt, Id country, Id year, Id divisionx){ 
		timestamp = timestampdt;
		countryId = country;
		divisionId = divisionx;
		yearId = year;
		folderId = Id.ValueOf(SystemSettings__c.getValues('NFULOADS_FOLDERID').Value__c);
	}
	
    public Database.QueryLocator start(Database.BatchableContext theContext){ 
    	
        Id monsantoId=Id.ValueOf(SystemSettings__c.getValues('MONSANTO_DISTRIBUTOR_ID').Value__c); 
        return Database.getQueryLocator([SELECT Id FROM CampaignLineItem__c WHERE FarmRef__r.RecordTypeId = '012D000000035Au' 
	 												  						AND RecordTypeId='012D000000035B2' 
						             										AND CampaignRef__r.CountryRef__c =: countryId 
						             										AND CampaignRef__r.YearV2__c =: yearId 
						             										AND CampaignRef__r.DivisionRef__c =: divisionId
						             										AND CreatedDate<:timestamp
						             										AND ProductRef__r.ProductVendor__c =: monsantoId]);
    }
    
    public void execute(Database.BatchableContext theContext, List<sObject> theList){
    	
        List<CampaignLineItem__c> cliToDelete = (List<CampaignLineItem__c>)theList;
        TriggerCampaignLineItemUpdateAccount.fromBatch=true;
        Database.DeleteResult[] dRes = Database.Delete(cliToDelete, false);
        
        String errors='';
		for(Database.DeleteResult dr : dRes) {
		    if (!dr.isSuccess()) {         
		        for(Database.Error err : dr.getErrors()) {
		        	errors += 'The CampaignLineItem with Id= '+dr.getId()+' has not been deleted due to: ' + err.getMessage()+'\n';
		        }
		    }
		}
		
		if(errors!=''){
			String documentName ='Delete Process - ' + String.valueOf(timestamp);
			String developerName = documentName.remove(':').remove(' ').remove('-');
			List<Document >documents = [SELECT Id, body FROM Document WHERE folderId=:folderId 
																	  AND DeveloperName=: developerName];			
   	   	   if (documents.size()>=1){
   	   	       String newBody = (documents.get(0).body).toString() + errors;
   	   	       documents.get(0).body = Blob.ValueOf(newBody);
   	   	       update documents;
   	   	   } else {
		        Document doc= new Document(Name = documentName, 
		        						   body=Blob.valueOf(errors),
		        						   developerName=developerName, 
		        						   IsPublic = true, 
		        						   FolderId=folderId, 
		        						   contentType='text/plain');
		        insert doc;       	   	   
   	   	   }	
    	}
    }
    
    public void finish(Database.BatchableContext BC){
    }
}