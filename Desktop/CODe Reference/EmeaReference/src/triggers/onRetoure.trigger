trigger onRetoure on Retoure__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    new Triggers()
        .bind(Triggers.Evt.beforeInsert, new TriggerValidationRetoure())
        .bind(Triggers.Evt.beforeUpdate, new TriggerValidationRetoure())
    .manage();
}