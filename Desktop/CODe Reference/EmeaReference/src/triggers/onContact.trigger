trigger onContact on Contact (after delete, after insert, after undelete, 
                                    after update, before delete, before insert, before update) 
{   
    new Triggers()
            .bind(Triggers.Evt.beforeinsert, new TriggerContact())
          //  .bind(Triggers.Evt.beforeupdate, new TriggerContact())
         //   .bind(Triggers.Evt.beforeUpdate, new TriggerContactSharingManager())
         //   .bind(Triggers.Evt.afterInsert, new TriggerContactSharingManager())
            .bind(Triggers.Evt.beforeInsert, new TriggerTerritoryManagementContact())
            .bind(Triggers.Evt.beforeUpdate, new TriggerTerritoryManagementContact())
           .bind(triggers.Evt.beforeInsert, new TriggerContactAutoincrement ())
            .manage();  
            
        HlprConUpdate cu = new HlprConUpdate();
        if((trigger.isInsert && trigger.isbefore)||(trigger.isbefore && trigger.isUpdate))    
        {
            cu.SapIdUpdate(trigger.new);
        }
}