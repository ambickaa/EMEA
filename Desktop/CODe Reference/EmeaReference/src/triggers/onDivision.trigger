trigger onDivision on Division__c (before insert, before update) {
  new Triggers()
    .bind(Triggers.Evt.beforeInsert, new TriggerDivisionMarkHasChildren())
    .bind(Triggers.Evt.beforeUpdate, new TriggerDivisionMarkHasChildren())
  .manage();
}