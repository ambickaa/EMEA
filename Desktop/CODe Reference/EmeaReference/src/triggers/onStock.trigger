trigger onStock on Stock__c (before insert, before update) {
     new Triggers()
    .bind(Triggers.Evt.beforeUpdate, new TriggerStockPK())
    .bind(Triggers.Evt.beforeInsert, new TriggerStockPK())
    .bind(Triggers.Evt.beforeInsert, new TriggerStockAssignHybrid())  
    .bind(Triggers.Evt.beforeUpdate, new TriggerStockAssignHybrid())      
    .manage(); 
}