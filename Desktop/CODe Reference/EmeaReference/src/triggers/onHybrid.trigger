trigger onHybrid on Hybrid__c (before insert, before update) {
		new Triggers()
    .bind(Triggers.Evt.beforeInsert, new TriggerHybridSetOwner())
    .bind(Triggers.Evt.beforeUpdate, new TriggerHybridSetOwner())
    .bind(Triggers.Evt.beforeUpdate, new TriggerHybridPK())
    .bind(Triggers.Evt.beforeInsert, new TriggerHybridPK())    
    .manage();
}