/*
	This batch deletes all Acreage__c records without a related Account
*/
public without sharing class AcreageCleanerBatch implements Database.Batchable<sObject> {
	
	public AcreageCleanerBatch(){ 
	}
	
    public Database.QueryLocator start(Database.BatchableContext theContext)
    {     
        return Database.getQueryLocator([SELECT ID 
        								 FROM Acreage__c 
        								 WHERE (AcrFarmRef__c=null OR AcrFarmRef__c='')]);
    }
    
    public void execute(Database.BatchableContext theContext, List<sObject> theList)
    {
        List<Acreage__c> acreages = (List<Acreage__c>)theList;
        System.savepoint sp = Database.setSavepoint();
        
        try{
            delete acreages;
        }catch(Exception e){
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        List<String> emailRecipients=(System.label.AdminUtilities).split(','); 
	        mail.setSenderDisplayName('Acreage Cleaner Batch');
	        mail.setSubject('Acreage Cleaner Batch Process');
	        mail.setPlainTextBody('An error occured during the Acreage cleaning process: '+e.getMessage());
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       		Database.rollback(sp);    
    	}
    }	
    public void finish(Database.BatchableContext BC)
    {
    	AcreageCleanerBatch instance = new AcreageCleanerBatch();
    	System.scheduleBatch(instance, 'Acreage Cleaning Process', 43200);
    }
}