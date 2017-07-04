trigger onOpportunityLineItem on OpportunityLineItem  (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
    new Triggers()
    .bind(Triggers.Evt.beforeInsert, new TriggerOpportunityProductConverter())
    .bind(Triggers.Evt.beforeUpdate, new TriggerOpportunityProductConverter())

    .manage();
}