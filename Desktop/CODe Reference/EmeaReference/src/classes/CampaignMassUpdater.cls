/*
	This batch updates all non-archived Campaigns and schedule a new job for the next month
*/

public without sharing class CampaignMassUpdater implements Database.Batchable<sObject> {

    public CampaignMassUpdater(){
    }
    
    public Database.QueryLocator start(Database.BatchableContext theContext)
    {     
        return Database.getQueryLocator([SELECT ID FROM Campaign WHERE StatusCode__c != 400]);
    }
    
    public void execute(Database.BatchableContext theContext, List<sObject> theList)
    {
        List<Campaign> campaigns = (List<Campaign>)theList;
        System.savepoint sp = Database.setSavepoint();
        
        try{
            update campaigns;
        }catch(Exception e){
	        List<String> emailRecipients=(System.label.AdminUtilities).split(','); 
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        mail.setToAddresses(emailRecipients);
	        mail.setSenderDisplayName('Mass Campaign Updater');
	        mail.setSubject('Mass Campaign Update Process');
	        mail.setPlainTextBody('An error has occurred in Campaign Mass Update Process.');
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	        
       		Database.rollback(sp);    
    	}
    }	
    public void finish(Database.BatchableContext BC)
    {
    	// Schedule a new batch process for the next month (43200 minutes)
    	CampaignMassUpdater instance = new CampaignMassUpdater();
    	System.scheduleBatch(instance, 'Mass Campaign Update Process', 43200);
    }
}