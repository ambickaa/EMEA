trigger onLead on Lead (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    
    new Triggers()
    .bind(Triggers.Evt.beforeupdate, new TriggerLeadCheckDuplicates())
    .bind(Triggers.Evt.beforeinsert, new TriggerLeadCreateToken())
    .bind(Triggers.Evt.beforeupdate, new TriggerLeadConfirmed())
    .bind(Triggers.Evt.beforeupdate, new TriggerLeadUnconfirmedDeletion())
    .bind(Triggers.Evt.afterupdate, new TriggerLeadConversionAccountFields ())    
    .manage();
}