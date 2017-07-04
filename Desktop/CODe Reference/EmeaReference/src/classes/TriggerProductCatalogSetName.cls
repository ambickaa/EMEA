public with sharing class TriggerProductCatalogSetName implements Triggers.Handler
{
	public void handle()
	{
		Set<Id> aCountryIds = new Set<Id>();
		Set<Id> anYearIds = new Set<Id>();
		Set<Id> aDivisionIds = new Set<Id>();
		Set<Id> aRecordTypeIds = new Set<Id>();
		for (ProductCatalog__c p : (List<ProductCatalog__c>)Trigger.new)
		{
			if (p.CountryRef__c != null)
			{
				aCountryIds.add(p.CountryRef__c);
				anYearIds.add(p.YearRef__c);
				aRecordTypeIds.add(p.RecordTypeId);
				if(p.DivisionRef__c != null)
				{
					aDivisionIds.add(p.DivisionRef__c);
				}
			}
		}
		
		// init Maps
		Map<Id, Country__c> aCountryMap = new Map<Id, Country__c>();
		Map<Id, Year__c> anyearMap = new Map<Id, Year__c>();
		Map<Id, Division__c> aDivisionMap = new Map<Id, Division__c>();
		Map<Id, RecordType> aRecordTypeMap = new Map<Id, RecordType>();
		
		// Query Data From DB
		if (aCountryIds.size() > 0)
		{
			aCountryMap = new Map<Id, Country__c>([SELECT ID, Name FROM Country__c WHERE ID IN :aCountryIds]);
	   	}
	   	
	   	if (anYearIds.size() > 0)
		{
			anYearMap = new Map<Id, Year__c>([SELECT ID, Name FROM Year__c WHERE ID IN :anYearIds]);
	   	}
	   	
	   	if (aDivisionIds.size() > 0)
		{
			aDivisionMap = new Map<Id, Division__c>([SELECT ID, Name FROM Division__c WHERE ID IN :aDivisionIds]);
	   	}
	   	
	   	if (aRecordTypeIds.size() > 0)
		{
			aRecordTypeMap = new Map<Id, RecordType>([SELECT ID, Name FROM RecordType WHERE ID IN :aRecordTypeIds]);
	   	}
	   	
	   	// generate name
	   	for (ProductCatalog__c p : (List<ProductCatalog__c>)Trigger.new)
	   	{
	   		List<String> aNameList = new List<String>();
	   		if (aCountryMap.containsKey(p.CountryRef__c))
	   		{
	   			aNameList.add(aCountryMap.get(p.CountryRef__c).Name);
	   		}
	   		
	   		if (aDivisionMap.containsKey(p.DivisionRef__c))
	   		{
	   			aNameList.add(aDivisionMap.get(p.DivisionRef__c).Name);
	   		}
	   		
	   		if (aRecordTypeMap.containsKey(p.RecordTypeId))
	   		{
	   			String aRecordTypeName = aRecordTypeMap.get(p.RecordTypeId).Name;
   				if (aRecordTypeName.contains(' Product Catalog'))
   				{
   					aRecordTypeName = aRecordTypeName.replace(' Product Catalog', '');
   				}
	   			aNameList.add(aRecordTypeName);
	   		}
	   		
	   		if (anYearMap.containsKey(p.YearRef__c))
	   		{
	   			aNameList.add(anYearMap.get(p.YearRef__c).Name);
	   		}
	   		p.Name = Util.joinStrings(aNameList, ' - ');
	   	}
	}
}