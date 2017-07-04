public with sharing class TriggerAcreageSharingManager implements Triggers.Handler
{
    public void handle()
    {
        Set<ID> accountsReferred = new Set<ID>();
        Set<ID> allAccounts = new Set<ID>();
        for(sObject s : trigger.new)
        {
            allAccounts.add((ID)s.get('AcrFarmRef__c'));
        }
        TriggerCampaignLineItemHelper.add(allAccounts);
        for(sObject s : trigger.new)
        {
            if( TriggerCampaignLineItemHelper.isAccountSharingEnabled((ID)s.get('AcrFarmRef__c')) && 
                (trigger.isInsert || 
                 trigger.oldMap.get(s.ID).get('AcrFarmRef__c') != trigger.newMap.get(s.ID).get('AcrFarmRef__c') ||
                 trigger.oldMap.get(s.ID).get('OwnerId') != trigger.newMap.get(s.ID).get('OwnerId')))
            {
                accountsReferred.add(((ID)s.get('AcrFarmRef__c')));
            }
        }
        if(!accountsReferred.isEmpty())
        {
            AccountSharingManager.updateChildrenSharing(accountsReferred);
        }
    }
}