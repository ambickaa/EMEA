public class TriggerDivisionMarkHasChildren implements Triggers.Handler{
    public void handle()
    {
        Set<ID> parentDivisionIDs = new set<ID>();
        for(sObject s : trigger.new){
            parentDivisionIDs.add((ID)s.get('DE_ParentDivision__c'));
        }
        List<Division__c> divisionsToUpdate = new List<Division__c>();
        for(ID divisionID : parentDivisionIDs){
            if(divisionID != null){
                divisionsToUpdate.add(new Division__c(id=divisionID, DE_hasChildren__c = true));
            }
        }
        
        if(divisionsToUpdate.size() > 0){
            update divisionsToUpdate;
        }
    }
}