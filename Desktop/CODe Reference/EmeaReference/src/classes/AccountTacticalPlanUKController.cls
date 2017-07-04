public with sharing class AccountTacticalPlanUKController extends AccountListVirtualController
{
	public AccountTacticalPlanUKController()
	{
		objectFactory = new TacticalPlanUKFactory();
        mode = 'tacticalEdit';
        jumperTag = 'tacticalPlanList';
        fieldSetManager = new FieldSetMemberxManager(Schema.SObjectType.CampaignLineItem__c, jumperTag);
		//objectFactory.selectFields.addAll(fieldSetManager.getSOQLFields());
	}
	
	
	
	public List<CampaignLineItem> tacticalPlans
	{
		get
		{
			 return ( List<CampaignLineItem> ) wrapperObjects;
		}
		set;
	}
	
	public Map<String, Double>sumOfNumberFields
	{
		get
		{
			if( sumOfNumberFields == null)
			{
				sumOfNumberFields = new Map<String, Double>();
				sumOfNumberFields.put('pogPrev', 0);
				sumOfNumberFields.put('ForecastLow__c', 0);
				sumOfNumberFields.put('Forecast__c', 0);
				sumOfNumberFields.put('Agreed__c', 0);
				sumOfNumberFields.put('POG__c', 0);
				sumOfNumberFields.put('ForecastPlusOne__c', 0);
				sumOfNumberFields.put('Treatment__c', 0);
				sumOfNumberFields.put('Type__c', 0);
				sumOfNumberFields.put('ProductCatalogEntryRef__c', 0);
				sumOfNumberFields.put('PoS__c', 0);
				sumOfNumberFields.put('DistributorRef__c', 0);
				
				for(CampaignLineItem c : tacticalPlans)
				{
					if(c.record.POG__c<> null)
					{
						sumOfNumberFields.put('pogPrev', (sumOfNumberFields.get('pogPrev')+c.record.POG__c));
					}
					
					//System.assert(false, c.nextPeriodeElement);
					if(c.nextPeriodeElement.record.ForecastLow__c<> null)
					{
						sumOfNumberFields.put('ForecastLow__c', (sumOfNumberFields.get('ForecastLow__c')+c.nextPeriodeElement.record.ForecastLow__c));
					}
					if(c.nextPeriodeElement.record.Forecast__c<> null)
					{
						sumOfNumberFields.put('Forecast__c', (sumOfNumberFields.get('Forecast__c')+c.nextPeriodeElement.record.Forecast__c));
					}
					if(c.nextPeriodeElement.record.Agreed__c<> null)
					{
						sumOfNumberFields.put('Agreed__c', (sumOfNumberFields.get('Agreed__c')+c.nextPeriodeElement.record.Agreed__c));
					}
					if(c.nextPeriodeElement.record.POG__c<> null)
					{
						sumOfNumberFields.put('POG__c', (sumOfNumberFields.get('POG__c')+c.nextPeriodeElement.record.POG__c));
					}
					if(c.nextPeriodeElement.record.ForecastPlusOne__c<> null)
					{
						sumOfNumberFields.put('ForecastPlusOne__c', (sumOfNumberFields.get('ForecastPlusOne__c')+c.nextPeriodeElement.record.ForecastPlusOne__c));
					}
					
					
					
				}
				
			}
			return sumOfNumberFields;
		}
		set;
	}
}