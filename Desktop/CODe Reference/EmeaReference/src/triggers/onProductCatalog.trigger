trigger onProductCatalog on ProductCatalog__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
	new Triggers()
	.bind(Triggers.Evt.beforeinsert, new TriggerProductCatalogSetName())
	.bind(Triggers.Evt.beforeupdate, new TriggerProductCatalogSetName())
	.bind(Triggers.Evt.beforeinsert, new TriggerSetCountryId())
	.bind(Triggers.Evt.beforeupdate, new TriggerSetCountryId())
	.manage();
}