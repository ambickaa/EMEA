trigger onOrderItem on OrderItem (after insert, after update, after delete) {
    
    new Triggers()
    .bind(Triggers.Evt.afterinsert, new TriggerOrderItemTrackToActionPlanLine())
    .bind(Triggers.Evt.afterupdate, new TriggerOrderItemTrackToActionPlanLine())  
    .bind(Triggers.Evt.afterdelete, new TriggerOrderItemTrackToActionPlanLine())
    .manage();

}