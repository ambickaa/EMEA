public class TriggerYear implements Triggers.Handler
{
	public void handle()
	{
		if (Trigger.new.size() == 1)
		{
			Year__c aThisYear = (Year__c) Trigger.new[0];
			Year__c anOldYear = (Year__c) Trigger.oldMap.get(aThisYear.Id);
			if (aThisYear.Current_Year__c == true && anOldYear.Current_Year__c != true)
			{
				List<Year__c> aYears = (List<Year__c>) Database.query(new al.SoqlBuilder().selectx('Id').fromx('Year__c')
						.wherex(new al.FieldCondition('Current_Year__c', true)).toSoql());
				List<Year__c> aYearsRes = new List<Year__c>();
				for (Year__c aYear: aYears)
				{
					if (aYear.Id != aThisYear.Id)
					{
						aYear.Current_Year__c = false;
						aYearsRes.add(aYear);
					}
				}
				update aYearsRes;
				
				//new AccountTriggerHelper.AccountBatchManager().updateFarmsChangeYear();
				//new AccountTriggerHelper.AccountBatchManager().updateDistributorsChangeYear();
			}
		}
	}
}