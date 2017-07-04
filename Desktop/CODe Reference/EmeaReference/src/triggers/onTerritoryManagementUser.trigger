trigger onTerritoryManagementUser on TerritoryManagementUser__c (before insert, before update, after insert, after update, after delete, before delete) {
    new Triggers()
        .bind(Triggers.Evt.beforeInsert, new TriggerTerritoryManagementUser())
        .bind(Triggers.Evt.beforeUpdate, new TriggerTerritoryManagementUser())
        .bind(Triggers.Evt.afterInsert, new TriggerTerritoryMgmtUserUpdateUsersField())
        .bind(Triggers.Evt.afterUpdate, new TriggerTerritoryMgmtUserUpdateUsersField())
        .bind(Triggers.Evt.afterDelete, new TriggerTerritoryMgmtUserUpdateUsersField())        
        .bind(Triggers.Evt.afterInsert, new TriggerAccountSharingManagerUpdater())
        .bind(Triggers.Evt.afterUpdate, new TriggerAccountSharingManagerUpdater()) 
        .bind(Triggers.Evt.beforeDelete, new TriggerAccountSharingManagerUpdater())      
        .manage();
}