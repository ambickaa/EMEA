trigger onCampaignLineItemHistory on CampaignLineItemHistory__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
    new Triggers()
   .bind(Triggers.Evt.beforeUpdate, new TriggerCampaignLineItemHistoryNoUpdate())     
    .manage();

}