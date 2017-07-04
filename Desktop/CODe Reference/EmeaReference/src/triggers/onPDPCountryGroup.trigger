trigger onPDPCountryGroup  on PDPCountryGroup__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
    new Triggers()
    .bind(Triggers.Evt.beforeInsert, new TriggerPDPCountryGroupUpdateHierarchy())
    .bind(Triggers.Evt.afterDelete, new TriggerPDPCountryGroupUpdateHierarchy())
    .bind(Triggers.Evt.afterUpdate, new TriggerPDPCountryGroupUpdateHierarchy())

    .manage();
}