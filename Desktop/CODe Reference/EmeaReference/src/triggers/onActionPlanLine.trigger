trigger onActionPlanLine on Action_Plan_Line__c (after update, after insert, before insert, before update, after delete) 
{
    new Triggers()
    .bind(Triggers.Evt.afterupdate, new TriggerActionPlanLineInitialStockControl())
    .bind(Triggers.Evt.afterupdate, new TriggerActionPlanLineFillFYears())
    .bind(Triggers.Evt.afterinsert, new TriggerActionPlanLineFillFYears())
    .bind(Triggers.Evt.beforeinsert, new TriggerActionPlanLineUpdateUnitRels())
    .bind(Triggers.Evt.beforeupdate, new TriggerActionPlanLineUpdateUnitRels())
    .bind(Triggers.Evt.afterinsert, new TriggerActionPlanLineCopyFiscalYear())    
    .bind(Triggers.Evt.afterdelete, new TriggerActionPlanLineDeleteFiscalYear())

    .bind(Triggers.Evt.afterInsert, new TriggerActionPlanLine_Influencer())
    .bind(Triggers.Evt.afterUpdate, new TriggerActionPlanLine_Influencer())
    .bind(Triggers.Evt.afterDelete, new TriggerActionPlanLine_Influencer())

    .manage(); 
}