public class TriggerCampaignLineItemValidateDiscussed implements Triggers.Handler
{
    
    public void handle()
    {
       /* for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new)
        {
            if(cli.PreliminaryOrderRef_RSA__c!= null && cli.FinalOrderRef_RSA__c== null && ( cli.Agreed__c==0 || cli.Agreed__c==null))
            {
                cli.Agreed__c.addError('Discussed value can not be 0 if it is contained in a Preliminary Order');
            }
        }*/
    }
}