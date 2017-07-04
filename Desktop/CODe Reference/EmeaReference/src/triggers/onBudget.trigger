trigger onBudget on Budget__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    new Triggers()
      .bind(Triggers.Evt.beforeinsert, new TriggerBudgetPK())
      .bind(Triggers.Evt.beforeupdate, new TriggerBudgetPK())
    .manage();
}