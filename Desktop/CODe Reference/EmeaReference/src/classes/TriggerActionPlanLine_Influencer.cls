// --------------------------------------------------
// TriggerActionPlanLine_Influencer (after insert, after update, after delete)
// Process triggered to aggregate Forecast and Final stock quantities from children accounts
// to the SAP parent accounts related via Purchasing Group (influencer)
// 
// Last modified by Support Team (Everis) on 15/03/2017
// --------------------------------------------------
public with sharing class TriggerActionPlanLine_Influencer implements Triggers.Handler {

	public Set<Id> Set_Influencers = new Set<Id>();
	public Set<Id> Set_Accounts = new Set<Id>();
	public Map<String, Action_Plan_Line__c> Map_APL = new Map<String, Action_Plan_Line__c>();
	
	public void handle()
	{
		// --------------------------------------------------
		// Building set of accounts related to the incoming Action Plan Lines.
		//
		// It only handles the lines with record type Action Plan Line.
		// Further conditions:
		// - On Insert
		// - On Delete
		// - On Update when Forecast or Final stock have changed
		// --------------------------------------------------
		if(Trigger.isInsert || Trigger.isUpdate)
		{
			for(Action_Plan_Line__c apl : (List<Action_Plan_Line__c>)trigger.new)
			{
				if(apl.RecordTypeId == Util.recordType.get('Action_Plan_Line__c:Action_Plan_Line') &&
				(Trigger.isInsert
				|| (Trigger.isUpdate && apl.NUM_Forecast__c != ((Action_Plan_Line__c)trigger.oldMap.get(apl.Id)).NUM_Forecast__c)
				|| (Trigger.isUpdate && apl.NUM_Final_stock__c != ((Action_Plan_Line__c)trigger.oldMap.get(apl.Id)).NUM_Final_stock__c)))
				{
					Set_Accounts.add(apl.LKP_Account__c);

					// --------------------------------------------------
					// In case the account changes, the old one must also be handled.
					// --------------------------------------------------
					if(Trigger.isUpdate && apl.LKP_Account__c != ((Action_Plan_Line__c)trigger.oldMap.get(apl.Id)).LKP_Account__c)
						Set_Accounts.add(((Action_Plan_Line__c)trigger.oldMap.get(apl.Id)).LKP_Account__c);
				}
			}
		}
		if(Trigger.isDelete)
		{
			for(Action_Plan_Line__c apl : (List<Action_Plan_Line__c>)trigger.old)
			{
				if(apl.RecordTypeId == Util.recordType.get('Action_Plan_Line__c:Action_Plan_Line'))
				{
					Set_Accounts.add(apl.LKP_Account__c);
				}
			}
		}
		
		// --------------------------------------------------
		// If there are some accounts to handle.
		// --------------------------------------------------
		if(Set_Accounts.size() > 0)
		{
			// --------------------------------------------------
			// It retrieves all affected influencers (parent accounts where the numbers are aggregated)
			// --------------------------------------------------
			for(Account a : [SELECT Id, Influencer__c FROM Account WHERE Influencer__c != null AND Influencer__r.GC_Integration_Key__c != null AND Id IN :Set_Accounts])
				Set_Influencers.add(a.Influencer__c);
			
			// --------------------------------------------------
			// If there are some influencers (Purchasing groups) to handle.
			// --------------------------------------------------
			if(Set_Influencers.size() > 0)
			{
				// --------------------------------------------------
				// It retrieves all Action Plan Lines related to the accounts whose influencer
				// is included in the previous set and with active products (SKU).
				// --------------------------------------------------
				for(Action_Plan_Line__c apl : [SELECT Id, LKP_Account__c, LKP_Account__r.Influencer__c, LKP_SKU__c, NUM_Forecast__c, NUM_Final_stock__c, PICK_Period__c
					FROM Action_Plan_Line__c
					WHERE RecordTypeId = :Util.recordType.get('Action_Plan_Line__c:Action_Plan_Line')
					AND LKP_SKU__r.IsActive = true
					AND LKP_Account__c IN (SELECT Id FROM Account WHERE Influencer__c != null AND Influencer__r.GC_Integration_Key__c != null AND Influencer__c IN :Set_Influencers)])
				{
					Action_Plan_Line__c aplToUpsert = new Action_Plan_Line__c();
					// --------------------------------------------------
					// Building the corresponding key to upsert the new lines (TXT_External_ID__c).
					// --------------------------------------------------
					aplToUpsert.TXT_External_ID__c = String.valueOf(apl.LKP_Account__r.Influencer__c).substring(0,15) + '-' + String.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + apl.PICK_Period__c;
					aplToUpsert.LKP_Account__c = apl.LKP_Account__r.Influencer__c;
					aplToUpsert.LKP_SKU__c = apl.LKP_SKU__c;
					aplToUpsert.PICK_Period__c = apl.PICK_Period__c;

					// --------------------------------------------------
					// Avoiding sum up null values to the existent ones.
					// --------------------------------------------------
					Decimal NUM_Forecast = apl.NUM_Forecast__c != null ? apl.NUM_Forecast__c : 0;
					Decimal NUM_Final_stock = apl.NUM_Final_stock__c != null ? apl.NUM_Final_stock__c : 0;
					
					aplToUpsert.NUM_Forecast__c = Map_APL.containsKey(aplToUpsert.TXT_External_ID__c) ? (Map_APL.get(aplToUpsert.TXT_External_ID__c).NUM_Forecast__c + NUM_Forecast) : NUM_Forecast;
					aplToUpsert.NUM_Final_stock__c = Map_APL.containsKey(aplToUpsert.TXT_External_ID__c) ? (Map_APL.get(aplToUpsert.TXT_External_ID__c).NUM_Final_stock__c + NUM_Final_stock) : NUM_Final_stock;
					
					Map_APL.put(aplToUpsert.TXT_External_ID__c, aplToUpsert);
				}

				// --------------------------------------------------
				// Upserting Action Plan Lines only when the map is not empty.
				// --------------------------------------------------
				if(!Map_APL.isEmpty())
				{
					try {
						upsert Map_APL.values() TXT_External_ID__c;
					}
					catch(DMLException e)
					{
						for(Integer i = 0; i < e.getNumDml(); i++)
						{
							system.debug(e.getDmlMessage(i));
						}
					}
				}
			}
		
		}
	}
}