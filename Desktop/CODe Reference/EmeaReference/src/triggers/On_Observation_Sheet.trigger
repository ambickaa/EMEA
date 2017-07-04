trigger On_Observation_Sheet on Observation_Sheet__c (before insert,before update ) 
{
    for(Observation_Sheet__c tsk:Trigger.new)
    {
         if(Trigger.isInsert && tsk.Coach__c == null)
         {
             tsk.Coach__c = tsk.OwnerId;
         }
        tsk.OwnerId = tsk.Coachee__c;
        
    }
}