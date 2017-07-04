trigger onUser on User (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{

    String Ignore = 'false';
   
    public SystemSettings__c settings = SystemSettings__c.getValues('IgnoreTriggers_User');
    if(settings <> null) Ignore = settings.Value__c;

    
    if(Ignore =='false' || (Ignore =='true' && !UserInfo.getUserId().contains('005D0000002FcQu'))){
    
    new Triggers()
    .bind(Triggers.Evt.beforeinsert, new TriggerUser())
    .bind(Triggers.Evt.beforeupdate, new TriggerUser())
    // PDP
    .bind(Triggers.Evt.beforeinsert, new TriggerUserPDPValidateFields())
    .bind(Triggers.Evt.beforeupdate, new TriggerUserPDPValidateFields())
    
    
    .bind(Triggers.Evt.afterinsert, new TriggerUserPDP())
    .bind(Triggers.Evt.afterupdate, new TriggerUserPDP())
    
    

    .manage();
    } 
}