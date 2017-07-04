public without sharing class TriggerTerritoryManagementContact implements Triggers.Handler
{
    public void handle()
    {
        // gather all the territory ids
        Set<Id> territoryIds = new Set<Id>();
        Set<Id> territoryIdsPrivat = new Set<Id>();
        Map<Id, Id> Map_Old = new Map<Id, Id>();
        
        if(Trigger.isUpdate)
        {
	        for(Contact c : (List<Contact>)Trigger.old)
	        {
	            Map_Old.put(c.Id, c.DE_Private_Territory_Key__c);
	        }
        }

        for(Contact c : (List<Contact>)Trigger.new)
        {
            if(c.CountryRef__c != null && new CountryAdapter(c.CountryRef__c).isAccountSharingEnabled)
            {
                territoryIds.add(c.DE_Territory_Key__c);
                territoryIdsPrivat.add(c.DE_Private_Territory_Key__c);
            }  
        }
        
        if(!territoryIds.isEmpty())
        {
            Map<ID,TerritoryManagement__c> territory = new Map<ID,TerritoryManagement__c>([
					SELECT DE_CountryRef__c, DE_StateProvince__c, DE_LandKreis__c, DE_CP__c, DE_Ort__c, DE_LandKreis2__c
					FROM TerritoryManagement__c  
					WHERE Id =: territoryIds]);
            
            Map<ID,TerritoryManagement__c> territoryPrivat = new Map<ID,TerritoryManagement__c>([
					SELECT DE_CountryRef__c, DE_StateProvince__c, DE_LandKreis__c, DE_CP__c, DE_Ort__c
					FROM TerritoryManagement__c  
					WHERE Id =: territoryIdsPrivat]);
        

			// iterate through all the contacts and copy the field values from the account
            for (Contact c : (List<Contact>)Trigger.new)
            {
            	Boolean isTerritoryChanged =  (Trigger.isInsert || (Trigger.isUpdate && c.DE_Private_Territory_Key__c !=  Map_Old.get(c.Id))) ? true : false;
            	
                if(c.DE_Private_Territory_Key__c != null && territoryPrivat.get(c.DE_Private_Territory_Key__c) != null)
                {                	
                    c.DE_PrivateZIP__c = (c.DE_PrivateZIP__c == null || isTerritoryChanged) ? territoryPrivat.get(c.DE_Private_Territory_Key__c).DE_CP__c : c.DE_PrivateZIP__c;
                    c.DE_PrivateCity__c = (c.DE_PrivateCity__c == null || isTerritoryChanged) ? territoryPrivat.get(c.DE_Private_Territory_Key__c).DE_Ort__c : c.DE_PrivateCity__c;
                    c.DE_Private_Landkreis__c = (c.DE_Private_Landkreis__c == null || isTerritoryChanged) ? territoryPrivat.get(c.DE_Private_Territory_Key__c).DE_LandKreis__c : c.DE_Private_Landkreis__c;
                    c.DE_Private_State_Province__c = (c.DE_Private_State_Province__c == null || isTerritoryChanged) ? territoryPrivat.get(c.DE_Private_Territory_Key__c).DE_StateProvince__c : c.DE_Private_State_Province__c;
                    c.DE_PrivateCountry__c = (c.DE_PrivateCountry__c == null || isTerritoryChanged) ? territoryPrivat.get(c.DE_Private_Territory_Key__c).DE_CountryRef__c : c.DE_PrivateCountry__c;
                }
                
                if(c.DE_Territory_Key__c != null && new CountryAdapter(c.CountryRef__c).isAccountSharingEnabled)
                {
                    c.DE_ZIP_PLZ__c = territory.get(c.DE_Territory_Key__c).DE_CP__c;
                    c.City__c = territory.get(c.DE_Territory_Key__c).DE_Ort__c;
                    c.County__c= territory.get(c.DE_Territory_Key__c).DE_LandKreis2__c;
                    c.DE_Landkreis__c= territory.get(c.DE_Territory_Key__c).DE_LandKreis__c;
                    c.StateProvince__c = territory.get(c.DE_Territory_Key__c).DE_StateProvince__c;
                    c.CountryRef__c = territory.get(c.DE_Territory_Key__c).DE_CountryRef__c;
                }

                if(isTerritoryChanged && c.DE_Private_Territory_Key__c == null)
                {
                    c.DE_PrivateZIP__c = '';
                    c.DE_Private_State_Province__c = '';
                    c.DE_PrivateCity__c = '';
                    c.DE_Private_Landkreis__c = '';
                    //c.DE_PrivateCountry__c = null;
                }
            }
        }
    }
}