public without sharing class TriggerChangeVisibilityCase implements Triggers.Handler
{
    Set<Id> setIdAccount = new Set<Id>();
    List<CaseShare> listCasesVisibility = new List<CaseShare>();
    
    public void handle()
    {
        for(Case c : (List<Case>)trigger.new)
        {
            if(c.RecordTypeId == Util.recordType.get('Case:Survey_Result'))
            {
            	System.debug('IDACCOUNT:' + c.AccountId);
                setIdAccount.add(c.AccountId);
            }           
        }
        if(setIdAccount.size() > 0)
        {
            Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :setIdAccount]);
            
            for(Case c : (List<Case>)trigger.new)
            {
                if(c.RecordTypeId == Util.recordType.get('Case:Survey_Result') && c.OwnerId != mapAccount.get(c.AccountId).OwnerId)
                {
                    CaseShare cs = new CaseShare();
                    cs.CaseId = c.Id;
                    cs.UserOrGroupId = mapAccount.get(c.AccountId).OwnerId;
                    cs.CaseAccessLevel = 'Read';
                    listCasesVisibility.add(cs);
                }
            }        
            insert listCasesVisibility;
        }
    }
}