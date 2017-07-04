trigger onAcreage on Acreage__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
    new Triggers()
    //Link Account and Country via Account Billing Country and CountryRef
    .bind(Triggers.Evt.afterinsert, new TriggerAcreageAccountSummary())
    .bind(Triggers.Evt.afterupdate, new TriggerAcreageAccountSummary())
    .bind(Triggers.Evt.afterdelete, new TriggerAcreageAccountSummary())
    .bind(Triggers.Evt.beforeinsert, new TriggerAcreageUpdateLastModifiedDate())
    .bind(Triggers.Evt.beforeupdate, new TriggerAcreageUpdateLastModifiedDate())
    .bind(Triggers.Evt.beforeinsert, new TriggerAcreageProductData())
    .bind(Triggers.Evt.beforeupdate, new TriggerAcreageProductData())
    
    .bind(Triggers.Evt.afterinsert, new TriggerAcreageSharingManager())
    .bind(Triggers.Evt.afterupdate, new TriggerAcreageSharingManager())
    .manage();
}