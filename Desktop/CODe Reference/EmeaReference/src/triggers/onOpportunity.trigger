trigger onOpportunity on Opportunity (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
    new Triggers()
    .bind(Triggers.Evt.beforeInsert, new TriggerOpportunityAutoInfoCreator())
    .bind(Triggers.Evt.beforeupdate, new TriggerOpportunityAutoInfoCreator())
    .bind(Triggers.Evt.beforeupdate, new TriggerOpportunityPreventNameUpdate())
    .bind(Triggers.Evt.afterupdate, new TriggerOpportunityStatusUpdate())     
        .bind(Triggers.Evt.afterupdate, new TriggerOppAllocationStatusUpdate ())
    .bind(Triggers.Evt.beforedelete, new TriggerOpportunityAvoidDeleteSubmitted ()) 
    .manage();
}