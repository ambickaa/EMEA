trigger onVoucher on Voucher__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
    new Triggers()
    .bind(Triggers.Evt.beforeInsert, new TriggerVoucherNameCreator())
    .bind(Triggers.Evt.beforeUpdate, new TriggerVoucherPreventNameUpdate())
    //.bind(Triggers.Evt.beforeInsert, new TriggerVoucherLadderCopy())
    
    //.bind(Triggers.Evt.beforeUpdate, new TriggerVoucherGiveStockBack())
    .bind(Triggers.Evt.beforeUpdate, new TriggerVoucherDiscountsCancelled())
    //.bind(Triggers.Evt.beforeUpdate, new TriggerVoucherFOCBagsCancelled())

    .manage();
}