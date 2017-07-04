trigger onCountry on Country__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
    String Ignore = 'false';
   
    public SystemSettings__c settings = SystemSettings__c.getValues('IgnoreTriggers_Country');
    if(settings <> null) Ignore = settings.Value__c;

    
    if(Ignore =='false' || (Ignore =='true' && !UserInfo.getUserId().contains('005D0000002FcQu'))){
      
    new Triggers()
    //Link Account and Country via Account Billing Country and CountryRef
    .bind(Triggers.Evt.beforeupdate, new TriggerSetCountryId('Id', 'CountryId__c'))
    .bind(Triggers.Evt.afterinsert, new TriggerCountryHandler())
    .bind(Triggers.Evt.afterUpdate, new TriggerCountrySharingController())
    .bind(Triggers.Evt.afterUpdate, new TriggerChangeYearOnCountry())
    .manage();
    }
}