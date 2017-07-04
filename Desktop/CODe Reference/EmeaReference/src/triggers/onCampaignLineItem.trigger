trigger onCampaignLineItem on CampaignLineItem__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
    String Ignore = 'false';
   
    public SystemSettings__c settings = SystemSettings__c.getValues('IgnoreTriggers_Cli');
    if(settings <> null) Ignore = settings.Value__c;

    
    if(Ignore =='false' || (Ignore =='true' && !UserInfo.getUserId().contains('005D0000002FcQu'))){
      
    new Triggers()
    .bind(Triggers.Evt.afterInsert, new TriggerCampaignLineItemCreateHistory())
    .bind(Triggers.Evt.afterUpdate, new TriggerCampaignLineItemCreateHistory())   
    .bind(Triggers.Evt.beforeDelete, new TriggerCampaignLineItemCreateHistory())

   .bind(Triggers.Evt.beforeInsert, new TriggerCLIUpdatePCEStock())
   .bind(Triggers.Evt.beforeUpdate, new TriggerCLIUpdatePCEStock())
   .bind(Triggers.Evt.beforeDelete, new TriggerCLIUpdatePCEStock())
        
    .bind(Triggers.Evt.beforeInsert, new TriggerCampaignLineItemFillQuantityField())
    .bind(Triggers.Evt.beforeUpdate, new TriggerCampaignLineItemFillQuantityField())
    .bind(Triggers.Evt.afterInsert, new TriggerCampaignLineItemSummaryFields())
    .bind(Triggers.Evt.afterUpdate, new TriggerCampaignLineItemSummaryFields())
    .bind(Triggers.Evt.afterDelete, new TriggerCampaignLineItemSummaryFields())
    .bind(Triggers.Evt.beforeInsert, new TriggerCampaignLineItemAddProductLineI())
    .bind(Triggers.Evt.beforeUpdate, new TriggerCampaignLineItemAddProductLineI())
    .bind(Triggers.Evt.afterInsert, new TriggerCampaignLineItemUpdateAccount())
    .bind(Triggers.Evt.afterDelete, new TriggerCampaignLineItemUpdateAccount())
    .bind(Triggers.Evt.afterInsert, new TriggerCampaignLineItemMarkCatalogAsUsed())
    .bind(Triggers.Evt.afterUpdate, new TriggerCampaignLineItemMarkCatalogAsUsed())
    .bind(Triggers.Evt.beforeinsert, new TriggerCampaignLineItemValidateForecast())
    .bind(Triggers.Evt.beforeupdate, new TriggerCampaignLineItemValidateForecast())

    
    .bind(Triggers.Evt.afterinsert, new TriggerCampaignLineItemSharingManager())
    .bind(Triggers.Evt.afterupdate, new TriggerCampaignLineItemSharingManager())

    .bind(Triggers.Evt.beforeinsert, new TriggerCampaignLineItemMatchProdAndCatal())
    .bind(Triggers.Evt.beforeupdate, new TriggerCampaignLineItemMatchProdAndCatal())
    .bind(Triggers.Evt.beforeupdate, new TriggerCampaignLineItemFillStockLookups())
    .bind(Triggers.Evt.beforeinsert, new TriggerCampaignLineItemFillStockLookups())
    //.bind(Triggers.Evt.afterInsert, new TriggerCampaignLineItemFillStockLKNew())
   // .bind(Triggers.Evt.afterUpdate, new TriggerCampaignLineItemDeleteEmptyOrder())
   // .bind(Triggers.Evt.afterDelete, new TriggerCampaignLineItemDeleteEmptyOrder())
    .bind(Triggers.Evt.beforeUpdate, new TriggerCampaignLineItemCheckChanges())
    .bind(Triggers.Evt.beforeDelete, new TriggerCampaignLineItemCheckChanges())
    .bind(Triggers.Evt.beforeUpdate, new TriggerCampaignLineItemCloneFields())
    
    .bind(Triggers.Evt.beforeupdate, new TriggerCampaignLineItemValidateDiscussed())
    
    .bind(Triggers.Evt.afterUpdate, new TriggerCampaignLineItemUpdateStock())
    .bind(Triggers.Evt.afterDelete, new TriggerCampaignLineItemUpdateStock())

    
    .bind(Triggers.Evt.beforeInsert, new TriggerPreviousYearSales())  
    
    //just to preLoad PY sales
    //.bind(Triggers.Evt.beforeUpdate, new TriggerPreviousYearSales()) 
    //  
   
   .bind(Triggers.Evt.beforeInsert, new TriggerCampaignLineItemAgreedCopy())  
   .bind(Triggers.Evt.beforeUpdate, new TriggerCampaignLineItemAgreedCopy())
   
   // Future development //
   //.bind(Triggers.Evt.afterInsert, new TriggerCLIAcreages())            
   //.bind(Triggers.Evt.beforeUpdate, new TriggerCLIAcreages())           
   //.bind(Triggers.Evt.beforeDelete, new TriggerCLIAcreages())
   
   .bind(Triggers.Evt.afterInsert, new TriggerCampaignLineItemUpdateStockOnline())  
   .bind(Triggers.Evt.afterUpdate, new TriggerCampaignLineItemUpdateStockOnline())  
   .bind(Triggers.Evt.beforeDelete, new TriggerCampaignLineItemUpdateStockOnline()) 
   
   //New Trigger validation
   .bind(Triggers.Evt.afterInsert, new TriggerValidationCampaignLineItemRetoure())
   .bind(Triggers.Evt.afterUpdate, new TriggerValidationCampaignLineItemRetoure())
   .bind(Triggers.Evt.afterDelete, new TriggerValidationCampaignLineItemRetoure())
   
   //New Trigger for the Budget new field
   .bind(Triggers.Evt.beforeInsert, new TriggerCampaignLineItemFillBudgetLookup())  
   .bind(Triggers.Evt.beforeUpdate, new TriggerCampaignLineItemFillBudgetLookup())
   
    .manage();
   }
}