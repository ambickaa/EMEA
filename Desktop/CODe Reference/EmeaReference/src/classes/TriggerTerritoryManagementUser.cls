public with sharing class TriggerTerritoryManagementUser implements Triggers.Handler
{
    public static Boolean forceUpdate = true; // to allow others to force updates and to see if the TerritoryMgtUserUpdAccountBatch is already run

    public void handle()
    {// DE_PK__C
        Map<ID,Division__c> divisions = new Map<ID,Division__c>([SELECT NAME FROM Division__c]);
        Map<ID,User> users = new Map<ID,User>([SELECT Alias from User]);
        
        set<ID> territoryManagementUsedIDs = new Set<ID>();
        for(TerritoryManagementUser__c tmu : (List<TerritoryManagementUser__c>)trigger.new)
        {
            territoryManagementUsedIDs.add(tmu.DE_TerritoryManagementRef__c);
        }
                
        Map<ID,TerritoryManagement__c> tmUsed = new Map<ID,TerritoryManagement__c>([SELECT DE_PrimaryKey__c FROM TerritoryManagement__c WHERE ID in :territoryManagementUsedIDs]);

        for(TerritoryManagementUser__c tmu : (List<TerritoryManagementUser__c>)trigger.new)
        {
            Boolean isST = 
                Util.DIVISION_CORN.equalsIgnoreCase(divisions.get(tmu.DivisionRef__c).Name) ||  
                Util.DIVISION_OSR.equalsIgnoreCase(divisions.get(tmu.DivisionRef__c).Name);
            Boolean isCP = 
                Util.DIVISION_CP.equalsIgnoreCase(divisions.get(tmu.DivisionRef__c).Name) || 
                Util.DIVISION_LATITUDE.equalsIgnoreCase(divisions.get(tmu.DivisionRef__c).Name) || 
                Util.DIVISION_MONITOR.equalsIgnoreCase(divisions.get(tmu.DivisionRef__c).Name) || 
                Util.DIVISION_ROUNDUP.equalsIgnoreCase(divisions.get(tmu.DivisionRef__c).Name);
                
            if(tmu.DE_UserRef__c != null)
            {
                tmu.DE_PK__C = tmUsed.get(tmu.DE_TerritoryManagementRef__c).DE_PrimaryKey__c + ' - ' + (isST?'S&T':'') + (isCP?'CP':'') + ' - ' + users.get(tmu.DE_UserRef__c).Alias;
                // This TMU record has to be processed again if there's been an update. Check that previous processed value was true to avoid a processing loop.
                if(Trigger.isUpdate)
                {
                    TerritoryManagementUser__c tmuOld = (TerritoryManagementUser__c)Trigger.oldMap.get(tmu.Id);
                    if(tmu.Processed__c && tmuOld.Processed__c && forceUpdate)
                        tmu.Processed__c = false;
                }
            }
        }
    }
}