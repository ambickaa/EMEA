trigger onConsignment on Consignment__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    new Triggers()

    .bind(Triggers.Evt.beforeupdate, new TriggerConsignmentFillStockLookups())
    .bind(Triggers.Evt.beforeinsert, new TriggerConsignmentFillStockLookups()) 
    .bind(Triggers.Evt.beforeInsert, new TriggerConsignmentAssignWarehouse())  
    .bind(Triggers.Evt.beforeUpdate, new TriggerConsignmentAssignWarehouse())      

    .manage();

}