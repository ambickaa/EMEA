public without sharing class TriggerContactSharingManager implements Triggers.Handler
{
    public void handle()
    {
        Set<ID> accountsReferred = new Set<ID>();
        Set<ID> allAccounts = new Set<ID>();
        for(sObject s : trigger.new)
        {
            allAccounts.add((ID)s.get('AccountID'));
        }
        TriggerCampaignLineItemHelper.add(allAccounts);
        for(sObject s : trigger.new)
        {
            if( TriggerCampaignLineItemHelper.isAccountSharingEnabled((ID)s.get('AccountID')) && 
                (trigger.isInsert || 
                 trigger.oldMap.get(s.ID).get('AccountID') != trigger.newMap.get(s.ID).get('AccountID')))
            {
                accountsReferred.add(((ID)s.get('AccountID')));
            }
        }
        if(!accountsReferred.isEmpty())
        {
            AccountSharingManager.updateChildrenSharing(accountsReferred);
        }
    }
}