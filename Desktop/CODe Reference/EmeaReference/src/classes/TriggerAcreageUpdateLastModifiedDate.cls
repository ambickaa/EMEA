/**
* This trigger sets custom LastModified date to the current date.
* This should happen only if we really modified anything.
*/
public class TriggerAcreageUpdateLastModifiedDate implements Triggers.Handler
{
	//List of fields, that we skip changes.
	public static final Set<String> SKIP_FIELDS = new Set<String> {'systemmodstamp', 'lastmodifieddate', 'lastmodifiedbyid', 'acrlastmodified__c'};
	
	public void handle()
	{
		Datetime aCurrent = Datetime.now();
		for (Acreage__c anAcreage: (List<Acreage__c>)Trigger.new)
		{
			Boolean anIsUpdated = Trigger.isInsert;
			if (!anIsUpdated)
			{
				for (String aField: Schema.getGlobalDescribe().get('Acreage__c').getDescribe().fields.getMap().keySet())
				{
					if (!SKIP_FIELDS.contains(aField.toLowerCase()) && anAcreage.get(aField) != Trigger.oldMap.get(anAcreage.Id).get(aField))
					{
						anIsUpdated = true;
					}
				}
			}
			if (anIsUpdated)
			{
				anAcreage.AcrLastModified__c = aCurrent;
			}
		}
		
	}
}