trigger onYear on Year__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
	 new Triggers()
        .bind(Triggers.Evt.afterupdate, new TriggerYear())
        .manage();
	
}