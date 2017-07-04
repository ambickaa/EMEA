trigger onInvoiceLineItem on Invoice_Line_Item__c (after insert, after update, after delete) 
{
    new Triggers()
    .bind(Triggers.Evt.afterinsert, new TriggerInvoiceLineTrackToActionPlanLine())
    .bind(Triggers.Evt.afterupdate, new TriggerInvoiceLineTrackToActionPlanLine())
    .bind(Triggers.Evt.afterdelete, new TriggerInvoiceLineTrackToActionPlanLine())
    .manage();
}