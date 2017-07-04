trigger onDiscount on Discount__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
   
    new Triggers()
    .bind(Triggers.Evt.beforeInsert, new TriggerDiscountLadder())
    .bind(Triggers.Evt.beforeUpdate, new TriggerDiscountLadder())    
    .manage();

}