//--------------------------------------------------
// This trigger copies Italian Country Lead campaign fields DisableAgreedStatus__c
// and DisableForecastStatus__c to the rest of the campaigns in the country.
//
// Last Modified on 23/06/2016 by Support Team
//--------------------------------------------------
public with sharing class TriggerCampaignBlockFields implements Triggers.Handler {

    public void handle()
    {
    	//--------------------------------------------------
    	// Defining variables
    	//--------------------------------------------------
        List<Campaign> List_CampaignsToUpdate = new List<Campaign>();
        Set<Campaign> Set_CampaignsToUpdate = new Set<Campaign>();
        Map<Id, Campaign> Map_Campaign = new Map<Id, Campaign>();
        Map<Id,String> Map_Country = new Map<Id,String>();
        Set<Id> Set_Division = new Set<Id>();
        Set<Id> Set_Year = new Set<Id>();
        
        //--------------------------------------------------
        // Retrieving the system country Id for Italy.
        //--------------------------------------------------
        for(Country__c c :[SELECT Id, Name FROM Country__c WHERE Name = 'Italy'])
            Map_Country.put(c.Id, c.Name);

		//--------------------------------------------------
		// Loop for new state of campaigns entering in the trigger.
		//--------------------------------------------------
        for (sObject c: Trigger.new)
        {
            Campaign cNew = (Campaign) c;

			//--------------------------------------------------
			// It only handles those campaigns from Italy
			//--------------------------------------------------
            if(Map_Country.containsKey(cNew.CountryRef__c))
            {
                Campaign cOld = (Campaign)Trigger.oldMap.get(cNew.Id);
                
                //--------------------------------------------------
                // Moreover, it only handles those campaigns in the top of the hierarchy (without parent campaign)
                // and whose fields DisableAgreedStatus__c or DisableForecastStatus__c have changed.
                //
                // In this case, campaigns map and year and division sets are populated.
                //--------------------------------------------------
                if((cNew.DisableAgreedStatus__c != cOld.DisableAgreedStatus__c || cNew.DisableForecastStatus__c != cOld.DisableForecastStatus__c) && cNew.ParentId == null)
                {
                    Map_Campaign.put(cNew.Id, cNew);
                    Set_Division.add(cNew.DivisionRef__c);
                    Set_Year.add(cNew.YearV2__c);
                }
            }
        }
        
        //--------------------------------------------------
		// If the map of Italian parent campaigns with changed values is not empty, it will retrieve all
		// sales campaigns of the country related to the existent divisions and years of the sets.
		//--------------------------------------------------
        if (Map_Campaign.size() > 0)
        {
            List<Campaign> List_Campaigns = [SELECT Id, Name, DisableAgreedStatus__c, DisableForecastStatus__c, DivisionRef__c, YearV2__c, ParentId, CountryRef__c
            								FROM Campaign
            								WHERE RecordTypeId = :Util.RecordType.get('Campaign:Sales_camp')
            								AND YearV2__c IN : Set_Year
            								AND DivisionRef__c IN: Set_Division
            								AND CountryRef__c IN : Map_Country.keySet()];

			//--------------------------------------------------
			// Double loop for all campaigns of the list related to the year and the division of each parent.
			//--------------------------------------------------
            for (Campaign M : Map_Campaign.values())
            {
                for(Campaign L : List_Campaigns)
                {
                    if(L.YearV2__c == M.YearV2__c && L.DivisionRef__c == M.DivisionRef__c)
                    {
                        Boolean isUpdate = false;
                        //--------------------------------------------------
                        // The iteration will update the campaign item if, also being parent campaign, some value is different from
                        // the parent coming from the map, or directly if it is children campaign (without parent campaign).
                        //--------------------------------------------------
                        if(L.ParentId != null || L.DisableAgreedStatus__c != M.DisableAgreedStatus__c || L.DisableForecastStatus__c != M.DisableForecastStatus__c)
                        	isUpdate = true;
                        	
                        //--------------------------------------------------
                        // It modifies the changed values reflecting the same conditions than previous IF.
                        // Then, it populates the set of campaigns to update.
                        //--------------------------------------------------
                        L.DisableAgreedStatus__c = (L.ParentId != null || L.DisableAgreedStatus__c != M.DisableAgreedStatus__c) ? M.DisableAgreedStatus__c : L.DisableAgreedStatus__c;
                        L.DisableForecastStatus__c = (L.ParentId != null || L.DisableForecastStatus__c != M.DisableForecastStatus__c) ? M.DisableForecastStatus__c : L.DisableForecastStatus__c;
                        if(isUpdate)
                            Set_CampaignsToUpdate.add(L);
                    }
                }
            }
            
            //--------------------------------------------------
            // It converts the set of campaigns to update into a list for the DML statement.
            //--------------------------------------------------
            List_CampaignsToUpdate.addAll(Set_CampaignsToUpdate);
            
            //--------------------------------------------------
            // If the list is not empty, it updates the campaigns, triggering once more the execution of the trigger.
            //--------------------------------------------------
            if(List_CampaignsToUpdate.size() > 0)
                update List_CampaignsToUpdate;
        }
    }
}