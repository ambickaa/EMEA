public with sharing class AccountTacticalPlanItalyController  extends AccountListVirtualController
{
	public AccountTacticalPlanItalyController()
    {
        objectFactory = new TacticalPlanItalyFactory();
        mode = 'tacticalEdit';
        jumperTag = 'tacticalPlanList';
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
			if(sumOfNumberFields == null)
			{
				sumOfNumberFields = new Map<String, Double>();
				sumOfNumberFields.put('FOC_PY_POG', 0);
				sumOfNumberFields.put('C_PY_POG', 0);
				sumOfNumberFields.put('FOC_CY_FORECAST', 0);
				sumOfNumberFields.put('C_CY_FORECAST', 0);
				sumOfNumberFields.put('FOC_CY_AGREED', 0);
				sumOfNumberFields.put('C_CY_AGREED', 0);
				sumOfNumberFields.put('C_CY_POG', 0);
				sumOfNumberFields.put('FOC_CY_POG', 0);
				sumOfNumberFields.put('CY_Inventory', 0);
				for(CampaignLineItem c : tacticalPlans)
				{
					if(c.freeOfChargeElement.record.POG__c<> null)
					{
						sumOfNumberFields.put('FOC_PY_POG', (sumOfNumberFields.get('FOC_PY_POG')+c.freeOfChargeElement.record.POG__c));
					}
					
					if(c.record.POG__c<> null)
					{
						sumOfNumberFields.put('C_PY_POG', (sumOfNumberFields.get('C_PY_POG')+c.record.POG__c));
					}
					
					
					//System.assert(false, c.nextPeriodeElement);
					if(c.nextPeriodeElement.freeOfChargeElement.record.Forecast__c<> null)
					{
						sumOfNumberFields.put('FOC_CY_FORECAST', (sumOfNumberFields.get('FOC_CY_FORECAST')+c.nextPeriodeElement.freeOfChargeElement.record.Forecast__c));
					}
					if(c.nextPeriodeElement.record.Forecast__c<> null)
					{
						sumOfNumberFields.put('C_CY_FORECAST', (sumOfNumberFields.get('C_CY_FORECAST')+c.nextPeriodeElement.record.Forecast__c));
					}
					
					if(c.nextPeriodeElement.freeOfChargeElement.record.Agreed__c<> null)
					{
						sumOfNumberFields.put('FOC_CY_AGREED', (sumOfNumberFields.get('FOC_CY_AGREED')+c.nextPeriodeElement.freeOfChargeElement.record.Agreed__c));
					}
					if(c.nextPeriodeElement.record.Agreed__c<> null)
					{
						sumOfNumberFields.put('C_CY_AGREED', (sumOfNumberFields.get('C_CY_AGREED')+c.nextPeriodeElement.record.Agreed__c));
					}
					
					if(c.nextPeriodeElement.freeOfChargeElement.record.POG__c<> null)
					{
						sumOfNumberFields.put('FOC_CY_POG', (sumOfNumberFields.get('FOC_CY_POG')+c.nextPeriodeElement.freeOfChargeElement.record.POG__c));
					}
					if(c.nextPeriodeElement.record.POG__c<> null)
					{
						sumOfNumberFields.put('C_CY_POG', (sumOfNumberFields.get('C_CY_POG')+c.nextPeriodeElement.record.POG__c));
					}
					
					if(c.nextPeriodeElement.getInventory() <> null)
					{
						sumOfNumberFields.put('CY_Inventory', (sumOfNumberFields.get('CY_Inventory')+c.nextPeriodeElement.getInventory()));
					}
					
					
				}
				
			}
			return sumOfNumberFields;
		}
		set;
	}
}