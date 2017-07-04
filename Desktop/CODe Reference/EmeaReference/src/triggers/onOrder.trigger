//************************************************************************//
// Data: 30/06/2014
// Add SystemSetting. This admin functionality allow change the order without the Trigger's executions.
//************************************************************************//
trigger onOrder on Order__c (after update, before update, before insert) {
    
    String Ignore = 'false';
    /*for (SystemSettings__c VAL : SystemSettings__c.getAll().values())
            if(VAL.Name == 'IgnoreTriggers_Order')
                Ignore = Val.Value__c;*/
   
   public SystemSettings__c settings = SystemSettings__c.getValues('IgnoreTriggers_Order');
   if(settings <> null) Ignore = settings.Value__c;
   
   if(Ignore=='false' || (Ignore=='true' && !UserInfo.getUserId().contains('005D0000002FcQu'))){

    new Triggers()
        .bind(Triggers.Evt.beforeinsert, new TriggerOrderCalculateVat())
        .bind(Triggers.Evt.beforeupdate, new TriggerOrderCalculateVat())
        .bind(Triggers.Evt.beforeinsert, new TriggerOrderCreateName())
        .bind(Triggers.Evt.beforeupdate, new TriggerOrderCalculatePrice())
        .bind(Triggers.Evt.beforeupdate, new TriggerOrderSumBagsPreliminary ())
        .bind(Triggers.Evt.beforeupdate, new TriggerOrderPreventNameUpdate())
        .bind(Triggers.Evt.afterupdate, new TriggerOrderUpdateStocks2())
        .bind(Triggers.Evt.beforeUpdate, new TriggerOrderDelAttachIfUnsigned())
        .bind(Triggers.Evt.afterUpdate, new TriggerOrderAutoSubmitForApproval())
        .bind(Triggers.Evt.beforeUpdate, new TriggerOrderCloneFields())
        //.bind(Triggers.Evt.afterUpdate, new TriggerOrderDeleteIdleOrders())
            
        .bind(Triggers.Evt.afterUpdate, new TriggerOrderUpdateBudgetOnline())
        .bind(Triggers.Evt.beforeDelete, new TriggerOrderUpdateBudgetOnline())
    
    .manage();
    }
   }