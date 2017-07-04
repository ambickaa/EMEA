trigger onVoucherLineItem on VoucherLineItem__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
	new Triggers()
	//.bind(Triggers.Evt.afterInsert, new TriggerVoucherFOCBags())
	.bind(Triggers.Evt.afterInsert, new TriggerVoucherDiscounts())
	.bind(Triggers.Evt.afterInsert, new TriggerVoucherCalculatePoints())

	.manage();
}