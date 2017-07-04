public with sharing class TriggerOrderItemTrackToActionPlanLine implements Triggers.Handler 
{
    map<Id, Id> mapOrderItemOrder = new map<Id, Id>();
    map<Id, OrderItem> mapOrderItem = new map<Id, OrderItem>();
    map<string, Action_Plan_Line__c> mapActionPlanLine = new map<String, Action_Plan_Line__c>();
    list<Action_Plan_Line__c> listActionPlanLine = new list<Action_Plan_Line__c>();
    list<Id> listPriceBookEntries = new list<Id>();
    list<Id> listAccounts = new list<Id>();
    
    public void handle()
    {/*
        List<OrderItem> listOLI;
        if(Trigger.isDelete)
            listOLI = (List<OrderItem>)trigger.old;            
        else
            listOLI = (List<OrderItem>)trigger.new;  

        for(OrderItem oi: listOLI)
        {
            mapOrderItemOrder.put(oi.Id, oi.OrderId);
            mapOrderItem.put(oi.Id, oi);
            listPriceBookEntries.add(oi.PricebookentryId);
        }       
        
        map<Id, Order> mapOrder = new map<Id, Order>([SELECT Id, AccountId, GC_Requested_Delivery_Date__c FROM Order WHERE Id IN : mapOrderItemOrder.values() AND GC_Document_Type_Descr__c IN('Sample Order','Ag-Eu Rush Order','Ag-Eu FOC Rush Order','Ag-Eu Free of Charge','Ag-Eu Standard Order') AND Divison_Code__c =: '15']);
        map<Id, PricebookEntry> mapProduct = new map<Id, PricebookEntry>([SELECT Id, Product2Id FROM PricebookEntry WHERE Id IN :listPriceBookEntries]);
        list<Id> listProducts = new list<Id>();
        
        for(PricebookEntry pe : mapProduct.values())
        {
            listProducts.add(pe.Product2Id);
        }
        map<Id, Product2> mapProductBU = new map<Id, Product2>([SELECT Id FROM Product2 WHERE Id IN :listProducts]);
        
        //Accounts of Orders
        for(Order o : mapOrder.values())
        {
            listAccounts.add(o.AccountId);
        }        
        
        //Existing Action Plan Line
        map<String, Action_Plan_Line__c> mapExistingAPL = new map<String, Action_Plan_Line__c>();
        for(Action_Plan_Line__c apl : [SELECT TXT_External_ID__c, Id, LKP_SKU__c, LKP_Account__c, NUM_Ordered__c FROM Action_Plan_Line__c WHERE LKP_Account__c IN :listAccounts])
        {
            mapExistingAPL.put(apl.TXT_External_ID__c, apl);
        }
        
        if(mapOrder.size()>0)
        {
        if(trigger.isInsert)
        {
            for(OrderItem oi : mapOrderItem.values())
            {   if (mapOrderItemOrder.get(oi.Id)!=null && mapOrder.get(mapOrderItemOrder.get(oi.Id))!=null && mapOrder.get(mapOrderItemOrder.get(oi.Id)).AccountId!=null)
                    {
                    Action_Plan_Line__c apl = new Action_Plan_Line__c();
                    apl.LKP_Account__c = mapOrder.get(mapOrderItemOrder.get(oi.Id)).AccountId;
                    apl.LKP_SKU__c = mapProduct.get(oi.PricebookentryId).Product2Id;
                    
                    if(mapOrder.get(mapOrderItemOrder.get(oi.Id)).GC_Requested_Delivery_Date__c.month() < 10) apl.PICK_Period__c = String.valueOf(mapOrder.get(mapOrderItemOrder.get(oi.Id)).GC_Requested_Delivery_Date__c.year()) + '-' + '0' + String.valueOf(mapOrder.get(mapOrderItemOrder.get(oi.Id)).GC_Requested_Delivery_Date__c.month());
                    else apl.PICK_Period__c = String.valueOf(mapOrder.get(mapOrderItemOrder.get(oi.Id)).GC_Requested_Delivery_Date__c.year()) + '-' + String.valueOf(mapOrder.get(mapOrderItemOrder.get(oi.Id)).GC_Requested_Delivery_Date__c.month());
                    
                    apl.TXT_External_ID__c = String.valueOf(apl.LKP_Account__c).substring(0,15) + '-' + String.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + apl.PICK_Period__c;
                    
                    apl.NUM_Ordered__c = oi.Quantity;
                    
                    if(mapActionPlanLine.get(apl.TXT_External_ID__c) == null) mapActionPlanLine.put(apl.TXT_External_ID__c, apl);
                    else mapActionPlanLine.get(apl.TXT_External_ID__c).NUM_Ordered__c = mapActionPlanLine.get(apl.TXT_External_ID__c).NUM_Ordered__c + apl.NUM_Ordered__c;
                    }
            }
            
            for(Action_Plan_Line__c apl : mapActionPlanLine.values())
            {
                if(mapExistingAPL.get(apl.TXT_External_ID__c) != null)
                    if(mapExistingAPL.get(apl.TXT_External_ID__c).NUM_Ordered__c != null) apl.NUM_Ordered__c = apl.NUM_Ordered__c + mapExistingAPL.get(apl.TXT_External_ID__c).NUM_Ordered__c;                
            }
        }
        
        else if(trigger.isUpdate || trigger.isDelete)
        {            
            for(OrderItem oi : mapOrderItem.values())
            {   if (mapOrderItemOrder.get(oi.Id)!=null && mapOrder.get(mapOrderItemOrder.get(oi.Id))!=null && mapOrder.get(mapOrderItemOrder.get(oi.Id)).AccountId!=null)
                    {
                    Action_Plan_Line__c apl = new Action_Plan_Line__c();
                    apl.LKP_Account__c = mapOrder.get(mapOrderItemOrder.get(oi.Id)).AccountId;
                    apl.LKP_SKU__c = mapProduct.get(oi.PricebookentryId).Product2Id;
                    
                    if(mapOrder.get(mapOrderItemOrder.get(oi.Id)).GC_Requested_Delivery_Date__c.month() < 10) apl.PICK_Period__c = String.valueOf(mapOrder.get(mapOrderItemOrder.get(oi.Id)).GC_Requested_Delivery_Date__c.year()) + '-' + '0' + String.valueOf(mapOrder.get(mapOrderItemOrder.get(oi.Id)).GC_Requested_Delivery_Date__c.month());
                    else apl.PICK_Period__c = String.valueOf(mapOrder.get(mapOrderItemOrder.get(oi.Id)).GC_Requested_Delivery_Date__c.year()) + '-' + String.valueOf(mapOrder.get(mapOrderItemOrder.get(oi.Id)).GC_Requested_Delivery_Date__c.month());
                    
                    apl.TXT_External_ID__c = String.valueOf(apl.LKP_Account__c).substring(0,15) + '-' + String.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + apl.PICK_Period__c;
                    
                    if(trigger.isUpdate)
                    {
                        //Compare NEW Ordered with OLD Ordered
                        if(oi.Quantity != ((map<Id, OrderItem>)trigger.oldMap).get(oi.Id).Quantity) apl.NUM_Ordered__c = (oi.Quantity - ((map<Id, OrderItem>)trigger.oldMap).get(oi.Id).Quantity);               
                    }  
                    else
                    {
                        //Substract quantity
                        apl.NUM_Ordered__c = oi.Quantity * -1;               
                    }   
                    //Accumulate Ordered of order item
                    if(mapActionPlanLine.get(apl.TXT_External_ID__c) == null) mapActionPlanLine.put(apl.TXT_External_ID__c, apl);
                    else
                    {
                        if(mapActionPlanLine.get(apl.TXT_External_ID__c).NUM_Ordered__c==null)
                        {
                            Action_Plan_Line__c line=new Action_Plan_Line__c();
                            line=mapActionPlanLine.get(apl.TXT_External_ID__c);
                            line.NUM_Ordered__c=0;
                            mapActionPlanLine.put(apl.TXT_External_ID__c, line);
                        }
                        if(apl.NUM_Ordered__c==null)apl.NUM_Ordered__c=0;
                        mapActionPlanLine.get(apl.TXT_External_ID__c).NUM_Ordered__c = mapActionPlanLine.get(apl.TXT_External_ID__c).NUM_Ordered__c + apl.NUM_Ordered__c;
                    }
                        
                    }
            }
            for(Action_Plan_Line__c apl : mapActionPlanLine.values())
            {
                if(mapExistingAPL.get(apl.TXT_External_ID__c) != null)
                {
                    if(mapExistingAPL.get(apl.TXT_External_ID__c).NUM_Ordered__c != null) 
                        if(apl.NUM_Ordered__c != null) apl.NUM_Ordered__c = apl.NUM_Ordered__c + mapExistingAPL.get(apl.TXT_External_ID__c).NUM_Ordered__c;
                }
            }
        }        
        
        Database.upsert(mapActionPlanLine.values(), Action_Plan_Line__c.Fields.TXT_External_ID__c, false);
        }      */  
    }
}