trigger triggerSetCatalog on Order (before insert, before update) 
{
    for(Order item : Trigger.new)
    {
        item.Pricebook2Id='01sD0000000gy8w';
    }
}