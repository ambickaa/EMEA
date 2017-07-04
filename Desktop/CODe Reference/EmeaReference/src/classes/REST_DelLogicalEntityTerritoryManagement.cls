@RestResource(urlMapping='/getDeletedLogicalEntity/TerritoryManagement/*')
global with sharing class REST_DelLogicalEntityTerritoryManagement{

    @HttpPost
    global static REST_DelLogicalEntity_Territory getDeletedTerritories(REST_DelLogicalEntity_Territory paramInfo)
    {
        REST_DelLogicalEntity_Territory returned = new REST_DelLogicalEntity_Territory();
        
        returned.territories = new List<TerritoryManagement__c>();
        Map<ID,TerritoryManagement__c> paramInfoTerritories = new Map<ID,TerritoryManagement__c>(paramInfo.territories);
        Set<ID> paramInfoTerritoryIDs = paramInfoTerritories.keySet();
        
        Map<ID,TerritoryManagement__c> currentTerritories = new Map<ID,TerritoryManagement__c>([SELECT ID FROM TerritoryManagement__c WHERE ID IN :paramInfoTerritoryIDs]);
        Set<ID> currentTerritoryIDs = currentTerritories.keySet();
        
        paramInfoTerritoryIDs.removeAll(currentTerritoryIDs);
        for(ID i : paramInfoTerritoryIDs){
            returned.territories.add(paramInfoTerritories.get(i));
        }
        
        return returned;
    }
    @HttpGet
    global static REST_DelLogicalEntity_Territory getExample()
    {
        REST_DelLogicalEntity_Territory returned = new REST_DelLogicalEntity_Territory();
        
        returned.territories = [SELECT ID FROM TerritoryManagement__c LIMIT 2];
        
        return returned;
    }
    
    global class REST_DelLogicalEntity_Territory {
        public List<TerritoryManagement__c> territories;
    }
    
}