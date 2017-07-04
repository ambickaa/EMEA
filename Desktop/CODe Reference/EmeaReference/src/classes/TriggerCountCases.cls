public without sharing class TriggerCountCases implements Triggers.Handler {
	
	//ID Account + Number of Cases
    public void handle() 
    {
    	set<Id> setIdAccount = new set<Id>();

        if(Trigger.isInsert || Trigger.isUpdate)
        {
            for(Case c : (List<Case>)trigger.new)
            {
            	
            	if(c.RecordTypeId == Util.recordType.get('Case:Survey_Result'))
            	{
                	setIdAccount.add(c.AccountId);
            	}
            }
        }
        
        else if(Trigger.isDelete)
        {
            for(Case c : (List<Case>)trigger.old)
            {
            	if(c.RecordTypeId == Util.recordType.get('Case:Survey_Result'))
            	{
                	setIdAccount.add(c.AccountId);
            	}
            }
        }
    	 
		List<Account> listAccounts = [SELECT Id, NUM_NPS_Case_Number__c, (select id from cases where recordtypeid=:Util.recordType.get('Case:Survey_Result'))  FROM Account WHERE Id IN :setIdAccount ];
				
   			for (Account acc : listAccounts)
     		{
     			if (acc.cases!=null)
     				acc.NUM_NPS_Case_Number__c = acc.cases.size();
      			else
      				acc.NUM_NPS_Case_Number__c = 0;
    		}
    	
    	update listAccounts;
	}
}