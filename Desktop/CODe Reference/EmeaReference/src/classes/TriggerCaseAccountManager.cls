public without sharing class TriggerCaseAccountManager implements Triggers.Handler
{
    public void handle()
    {
        Set<Id> setAccountId = new Set<Id>();
        Set<Id> setAccountOwners = new Set<Id>();       
        
        for(Case c: (list<Case>)Trigger.new)
        {
            setAccountId.add(c.AccountId);
        }
        
        Map<Id, Account> mapAccountOwner = new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :setAccountId]);
        
        for(Account a: mapAccountOwner.values())
        {
            setAccountOwners.add(a.OwnerId);
        }
        
        Map<Id, User> mapUserManager = new Map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN :setAccountOwners and ManagerId != null]);
        
        if(mapUserManager.size() > 0)
        {
            for(Case c: (list<Case>)Trigger.new)
            { 
                if(c.RecordTypeId == Util.recordType.get('Case:Survey_Result') && mapAccountOwner.get(c.AccountId) != null && mapAccountOwner.get(c.AccountId).OwnerId != null && mapUserManager.get(mapAccountOwner.get(c.AccountId).OwnerId) != null)
                {              
                    c.LKP_Account_Owner_Manager__c = mapUserManager.get(mapAccountOwner.get(c.AccountId).OwnerId).ManagerId;
                }
            }
        }       
    }
}