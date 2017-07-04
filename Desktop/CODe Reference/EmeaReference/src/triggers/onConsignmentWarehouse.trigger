trigger onConsignmentWarehouse on ConsignmentWarehouse__c (before insert, before update) {
    new Triggers()
        .bind(Triggers.Evt.beforeInsert, new TriggerWarehouseSetOwner())
        .bind(Triggers.Evt.beforeUpdate, new TriggerWarehouseSetOwner())
        .bind(Triggers.Evt.beforeUpdate, new TriggerWarehousePK())
        .bind(Triggers.Evt.beforeInsert, new TriggerWarehousePK())    
    .manage();
}