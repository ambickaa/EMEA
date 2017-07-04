global with sharing class BatchFranceOwnerCLIUpdate implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([SELECT ID, OwnerId, FarmRef__r.OwnerId, FarmRef__r.RecordType.Name FROM CampaignLineItem__c WHERE FarmRef__C != NULL AND CampaignRef__r.CountryRef__r.Name ='France' AND FarmRef__r.RecordType.Name='Group/Farm/Site']);
    }
   
    global void execute(Database.BatchableContext BC, List<CampaignLineItem__c> scope)
    {
    	List<CampaignLineItem__c> cliToUpdate = new List<CampaignLineItem__c>();
         for(CampaignLineItem__c cli : scope)
         {
         		
	 		cli.OwnerId = cli.FarmRef__r.OwnerId;
	 		cliToUpdate.add(cli);
         		           
         }
         update cliToUpdate;
    }   
    global void finish(Database.BatchableContext BC)
    {
    }

}