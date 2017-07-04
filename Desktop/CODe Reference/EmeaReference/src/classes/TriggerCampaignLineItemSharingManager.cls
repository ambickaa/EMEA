public without sharing class TriggerCampaignLineItemSharingManager implements Triggers.Handler
{
    private static boolean firstRun = true;
    public static Boolean fromBatch =false; 
    
    public void handle()
    {
        if(!fromBatch)
        {
	        Set<ID> accountsReferred = new Set<ID>();
	        Set<ID> allAccounts = new Set<ID>();
	        for(sObject s : trigger.new)
	        {
	            allAccounts.add((ID)s.get('FarmRef__c'));
	        }
	        TriggerCampaignLineItemHelper.add(allAccounts);
	        for(sObject s : trigger.new)
	        {
	            if(TriggerCampaignLineItemHelper.isAccountSharingEnabled((ID)s.get('FarmRef__c')) &&
	            (trigger.isInsert ||
	            trigger.oldMap.get(s.ID).get('FarmRef__c') != trigger.newMap.get(s.ID).get('FarmRef__c') ||
	            trigger.oldMap.get(s.ID).get('OwnerId') != trigger.newMap.get(s.ID).get('OwnerId') || firstRun))
	            {
	                accountsReferred.add(((ID)s.get('FarmRef__c')));
	            }
	        }
	        if(!accountsReferred.isEmpty())
	        {
	            AccountSharingManager.updateChildrenSharing(accountsReferred);
	            firstRun = false;
	        }
	     }
    }
}