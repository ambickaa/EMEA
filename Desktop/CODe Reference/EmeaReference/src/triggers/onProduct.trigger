trigger onProduct on Product2 (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
	new Triggers()
	.bind(Triggers.Evt.afterupdate, new TriggerProduct2UpdateAcreages())
	.manage();
}