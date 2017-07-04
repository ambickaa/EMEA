trigger onVoucherCampaign on VoucherCampaign__c ( after insert, after undelete, 
after update, before insert, before update) {
   
    new Triggers()
    .bind(Triggers.Evt.beforeInsert, new TriggerVoucherCampaignPK())
    .bind(Triggers.Evt.beforeUpdate, new TriggerVoucherCampaignPK())
    .manage();

}