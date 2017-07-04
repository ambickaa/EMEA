trigger onAccount on Account (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    new Triggers()
    .bind(Triggers.Evt.beforeinsert, new TriggerSetCountryId())
    .bind(Triggers.Evt.beforeupdate, new TriggerSetCountryId())
    .bind(Triggers.Evt.beforeupdate, new TriggerValidationAccountRetoure())
    .bind(Triggers.Evt.beforeinsert, new TriggerAccountDuplicateBlocker())
    .bind(Triggers.Evt.afterinsert, new TriggerAccountAcreagesManager())
    .bind(Triggers.Evt.afterupdate, new TriggerAccountAcreagesManager())
    
    .bind(Triggers.Evt.beforeinsert, new TriggerAccountSharingManager())
    .bind(Triggers.Evt.afterinsert, new TriggerAccountSharingManager())
    
    .bind(Triggers.Evt.beforeinsert, new TriggerAccountIbanCalculator())
    .bind(Triggers.Evt.beforeupdate, new TriggerAccountIbanCalculator())
    
    .bind(Triggers.Evt.beforeupdate, new TriggerAccountSharingManager())
    .bind(Triggers.Evt.afterupdate, new TriggerAccountSharingManager())
    
    //.bind(Triggers.Evt.beforeinsert, new TriggerTerritoryManagement())
    //.bind(Triggers.Evt.beforeupdate, new TriggerTerritoryManagement())
    .manage();
    
    if(Trigger.IsBefore && Trigger.IsInsert){
        TriggerSetAccountDefaultValues.fnSetAccountDefaultValues(Trigger.New);
    }
}