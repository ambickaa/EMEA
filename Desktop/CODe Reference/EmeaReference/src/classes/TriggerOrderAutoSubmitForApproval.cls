public with sharing class TriggerOrderAutoSubmitForApproval implements Triggers.Handler
{
  public void handle()
  {
    for(Order__c o : (List<Order__c>)trigger.new)
    {
      if(o.Status_RSA__c == 'Waiting for discount approval')
      {
        try
        {
          Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
          app.setObjectId(o.id);
          Approval.ProcessResult result = Approval.process(app);
        }catch(DMLException e){
            if(e.getDMLType(0) == StatusCode.MANAGER_NOT_DEFINED){
                o.addError('The user does not have any manager set');
            }else if(e.getDMLType(0) == StatusCode.ALREADY_IN_PROCESS){}
            else{
                o.addError(''+e);
            }
        }
      }
    }
  }
  
  public static testMethod void testHandle(){
      try{
          new TriggerOrderAutoSubmitForApproval().handle();
      }catch(Exception e){}
  }
}