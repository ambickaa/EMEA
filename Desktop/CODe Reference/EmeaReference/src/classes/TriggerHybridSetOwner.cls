public with sharing class TriggerHybridSetOwner implements Triggers.Handler
{
    // copy UserRef__c to OwnerID
    public void handle()
    {
        for(Hybrid__c hyb : (List<Hybrid__c>)trigger.new){
            hyb.ownerID = hyb.UserRef__c;
        }
    }
    
}