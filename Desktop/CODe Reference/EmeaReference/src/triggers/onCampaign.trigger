trigger onCampaign on Campaign (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    String Ignore = 'false';
   
    public SystemSettings__c settings = SystemSettings__c.getValues('IgnoreTriggers_Campaign');
    if(settings <> null) Ignore = settings.Value__c;

	if(Ignore == 'false' || (Ignore =='true' && !UserInfo.getUserId().contains('005D0000002FcQu')))
    {

    new Triggers()
        .bind(Triggers.Evt.beforeinsert, new TriggerSetCountryId())
        .bind(Triggers.Evt.beforeupdate, new TriggerSetCountryId())
        .bind(Triggers.Evt.afterupdate, new TriggerCampaignUpdateAccounts())
        .bind(Triggers.Evt.afterupdate, new TriggerCampaignBlockFields())
        .bind(Triggers.Evt.beforeinsert, new TriggerCampaignAutoData())
        .bind(Triggers.Evt.beforeupdate, new TriggerCampaignAutoData())
        .bind(Triggers.Evt.beforeinsert, new TriggerCampaignCheckDuplicates())
        .bind(Triggers.Evt.afterupdate, new TriggerCampaignUpdateTargets())
        .manage();
        
	}
}