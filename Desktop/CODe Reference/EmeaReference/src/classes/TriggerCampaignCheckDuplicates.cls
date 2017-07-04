public class TriggerCampaignCheckDuplicates implements Triggers.Handler
{
	public void handle()
	{
		List<String> aNameList = new List<String>();
		for (sObject anObject : Trigger.new)
		{
			aNameList.add((String)anObject.get('name'));
		}
		
		Set<String> aNamesInDB = new Set<String>();
		for (Campaign aCampaign : [SELECT Name FROM Campaign WHERE Name IN :aNameList])
		{
			aNamesInDB.add(aCampaign.name);
		}
		
		for (sObject anObject : Trigger.new)
		{
			if (aNamesInDB.contains((String)anObject.get('name')))
			{
				anObject.addError(Label.DuplicateRecordInsert);
			}
		}
	}
}