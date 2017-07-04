public with sharing class TriggerOpportunityStatusUpdate implements Triggers.Handler{

 public void handle()
 {
      // If an approval process is needed uncomment this section
  /*  for(integer i = 0 ; i <Trigger.new.size(); i++)
        {
            Opportunity itemNew = ((List<Opportunity>)Trigger.new)[i];
            Opportunity itemOld = ((List<Opportunity>)Trigger.old)[i];
            
            if(itemNew.Status__c== 'Submitted' && itemOld.Status__c!= 'Submitted')
            {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(itemNew.id);            
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(req1);
            }
        }    */
 }

}