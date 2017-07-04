trigger onCase on Case (after insert, after update, after delete, before insert) {

    new Triggers()
    .bind(Triggers.Evt.beforeinsert, new TriggerCaseAccountManager())  
    .bind(Triggers.Evt.afterinsert, new TriggerCreateNPSTask())
    .bind(Triggers.Evt.afterinsert, new TriggerCaseNPS())
    .bind(Triggers.Evt.afterupdate, new TriggerCaseNPS())
    .bind(Triggers.Evt.afterdelete, new TriggerCaseNPS())
    .bind(Triggers.Evt.afterinsert, new TriggerChangeVisibilityCase())
    .bind(Triggers.Evt.afterinsert, new TriggerCountCases())
    .bind(Triggers.Evt.afterupdate, new TriggerCountCases())
    .bind(Triggers.Evt.afterdelete, new TriggerCountCases())  
    .manage();
}