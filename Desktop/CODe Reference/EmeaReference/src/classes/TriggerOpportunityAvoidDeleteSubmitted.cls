public without sharing class TriggerOpportunityAvoidDeleteSubmitted implements Triggers.Handler {
            
   public void handle()
    {
        if(Trigger.isDelete)
        {
            for(Opportunity opp : (List<Opportunity>)Trigger.old)   
            {
                if(opp.PICK_Status__c == 'Submitted')
                    opp.addError(Label.OE2_0_Error_Delete_Submitted);
            }
        }
    }
    
}