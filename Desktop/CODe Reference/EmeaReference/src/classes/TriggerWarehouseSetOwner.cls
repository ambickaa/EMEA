public with sharing class TriggerWarehouseSetOwner implements Triggers.Handler
{
    public void handle()
    {
        for(ConsignmentWarehouse__c hyb : (List<ConsignmentWarehouse__c>)trigger.new){
            hyb.ownerID = hyb.UserRef__c;
        }
    }
    
}