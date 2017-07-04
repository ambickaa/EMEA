public with sharing class TriggerAccountDuplicateBlocker implements Triggers.Handler
{
	public void handle()
	{
		if(Util.currentUser.Country=='France')
		{
		 	System.debug( LoggingLevel.INFO, 'Pre insert / update handling ' + Trigger.new );
		 	List<String> aNameList = new List<String>();
			for (sObject anObject : Trigger.new)
			{
				aNameList.add((String)anObject.get('name'));
			}
			
			List<String> aCountryList = new List<String>();
			for (sObject anObject : Trigger.new)
			{
				aCountryList.add((String)anObject.get('CountryRef__c'));
			}
			
			Set<String> aNamesInDB = new Set<String>();
			for (Account anAccount : [SELECT Name FROM Account WHERE Name IN :aNameList AND CountryRef__c IN :aCountryList])
			{
				aNamesInDB.add(anAccount.name);
			}
			
			for (sObject anObject : Trigger.new)
			{
				if (aNamesInDB.contains((String)anObject.get('name')))
				{
					// country specific only for enabled countries
					if(new CountryAdapter((Account)anObject).isAccountNameDuplicateBlockerEnabled())
					{
						anObject.addError(Label.DuplicateRecordInsert);
					}
				}
			}
		}
	}
}