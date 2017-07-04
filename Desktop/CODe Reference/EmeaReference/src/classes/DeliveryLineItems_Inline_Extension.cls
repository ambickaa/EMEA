public class DeliveryLineItems_Inline_Extension{
    public List<Delivery_Line_Item__c> delivery {get;set;}
    public DeliveryLineItems_Inline_Extension(ApexPages.StandardController sc){
        delivery = [SELECT Id,Name,GC_SKULine_Item_Nbr__c,GC_Item_Code__c,GC_Item_Descr__c
                                ,GC_Batch_Number_Text__c,GC_Plant_Desc__c,GC_SKULineItem_Quantity__c
                                ,GC_Shipping_Point_Descr__c FROM Delivery_Line_Item__c
                                where GC_Dlvry_Integration_Key__c =: sc.getId()
                                ORDER BY GC_Item_Code__c ASC,Name ASC ];
    }
}