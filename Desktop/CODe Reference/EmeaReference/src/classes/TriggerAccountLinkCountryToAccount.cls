/*
 * Trigger takes care about filling the countryRef with the right country
 *
 */
public class TriggerAccountLinkCountryToAccount implements Triggers.Handler
{
	public void handle()
	 {
		System.debug( LoggingLevel.INFO, 'Pre insert / update handling ' + Trigger.new );
		Set<String>countries = new Set<String>();

		for( Account a : ( List<Account> )trigger.new )
		{
			if( a.BillingCountry != null )
			{
				countries.add( a.BillingCountry );
			}
		}

		Map<String, Country__c>countryNameMap = new Map<String, Country__c>();

		for( Country__c c : [SELECT ID, Name FROM Country__c WHERE Name IN :countries] )
		{
			countryNameMap.put( c.name, c );
		}

		for( Account a : ( List<Account> )trigger.new )
		{
			if( a.BillingCountry!= null && countryNameMap.containsKey( a.BillingCountry ) )
			{
				a.CountryRef__c = countryNameMap.get( a.BillingCountry ).id;
			}
		}
	}

	static testMethod void basicTest()
	{
		for( Account f : TestInit.farmers )
		{
			f.BillingCountry = TestInit.countries.get( 0 ).name;
		}

		upsert TestInit.farmers;

		for( Account f : TestInit.farmers )
		{
			f.BillingCountry = TestInit.countries.get( 1 ).name;
		}

		upsert TestInit.farmers;
	}
}