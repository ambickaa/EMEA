//-------------
//Created by everis.
//
// This batch is responsible for comparing the value of OrderItems' Quantity and SAP's Quantity from new Object AllocationConsumeLog.
// Look for AllocationConsumeLog and update the quantity value with SAP's value.
//----------------

global  with sharing class ProductAllocationBatch implements Database.batchable<sObject>{    
    
    global Integer numDays;
    global Set<Id> SetOrders = new Set<Id>();


    global ProductAllocationBatch (integer days)
    {
        numDays = days;
    }
    
    //-----------------
    // START method
    //-----------------

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        //Update on 23/03/2017 we need to process the whole order related with each incominf order item
        //return Database.getQueryLocator('SELECT pricebookentry.ProductCode, OrderId, pricebookentry.Product2.Id, pricebookentry.Product2.ProductSAPCode__c, Order.OwnerId, GC_Rejection_Reason_Descr__c, Order.Order_Owner_Code__c, Quantity, AvailableQuantity, Order.GC_Integration_Key__c, Order.PoNumber FROM OrderItem WHERE Order.GC_Doc_Creation_Date__c = THIS_FISCAL_YEAR and (LastModifiedDate >= last_n_days:'+numDays+') and Order.Divison_Code__c = \'17\' and Order.Account.CountryRef__r.Name = \'Italy\' and Order.GC_Document_Type_Descr__c IN(\'Sample Order\',\'Ag-Eu Rush Order\',\'Ag-Eu FOC Rush Order\',\'Ag-Eu Free of Charge\',\'Ag-Eu Standard Order\') order by Order.GC_Integration_Key__c,GC_SalesOrder_Item_Nbr__c');
        String OIquery='SELECT OrderId FROM OrderItem WHERE Order.GC_Doc_Creation_Date__c = THIS_FISCAL_YEAR and (LastModifiedDate >= last_n_days:'+numDays+') and Order.Divison_Code__c = \'17\' and Order.Account.CountryRef__r.Name = \'Italy\' and Order.GC_Document_Type_Descr__c IN(\'Sample Order\',\'Ag-Eu Rush Order\',\'Ag-Eu FOC Rush Order\',\'Ag-Eu Free of Charge\',\'Ag-Eu Standard Order\') order by Order.GC_Integration_Key__c,GC_SalesOrder_Item_Nbr__c';
        for(orderItem item :Database.query(OIquery)){
            SetOrders.add(item.OrderId);
        }
        return Database.getQueryLocator('SELECT Id FROM Order WHERE id IN: SetOrders');        
    }

    //-----------------     
    // EXECUTE method
    //-----------------
    
    global void execute(Database.BatchableContext BC,List<Order> scope)
    { 
        Set<String> setUsers = new Set<String>();
        Set<Id> setordIDs = new Set<Id>();
        List<Allocation_Consume_Log__c> allocConsLogList = new List<Allocation_Consume_Log__c>();
        Map<String,Opportunity> mapOppWithoutSAPNumber = new Map<String, Opportunity>();
        Map<String, String> userCodesMap = new Map<String, String>();
        Map<String,Allocation_Consume_Log__c> allocConsLogMap = new Map<String,Allocation_Consume_Log__c>();
        
        //Recover all order items from the orders in scope
        for(Order ord : scope)
        {
            setordIDs.add(ord.Id);
        }
        List<OrderItem> ListOI = [SELECT pricebookentry.ProductCode, OrderId, pricebookentry.Product2.Id, pricebookentry.Product2.ProductSAPCode__c, GC_Rejection_Reason_Descr__c, Order.Order_Owner_Code__c, Quantity, Order.GC_Integration_Key__c, Order.PoNumber FROM OrderItem WHERE OrderId IN: setordIDs order by Order.GC_Integration_Key__c, pricebookentry.ProductCode ASC, GC_SalesOrder_Item_Nbr__c ASC];

        //Get all users ID and PO Numbers based on SAP Partner codes coming from SAP Orders
        for(OrderItem ordIt : ListOI)
        {
            setUsers.add(ordIt.Order.Order_Owner_Code__c);
        }

        for(User oppOwner : [SELECT id,SAP_Partner_Code__c from User where SAP_Partner_Code__c IN: setUsers])
        {
            userCodesMap.put(oppOwner.SAP_Partner_Code__c,oppOwner.Id);
        }

        for(Opportunity opp : [SELECT id,Name,TXT_SAP_Order_number__c,PICK_Status__c from Opportunity where TXT_SAP_Order_number__c = null and TXTA_Division__c = '17' and TXTA_Sales_Org__c = 'IT01' and PICK_Status__c = 'Review by Customer Services'])
        {
            mapOppWithoutSAPNumber.put(opp.Name,opp);
        }
        //system.debug('****mapa de Opp sin SAP number: '+ mapOppWithoutSAPNumber );

        // Query Allocations and convert from Allocation to AllocationConsumeLog. 
        // Based on OrderItems identify the corresponding AllocationConsumeLog ExternalId and update the quantity (UPSERT)
        // 2 differente situations depending on order field GC_Rejection_Reason_Descr__c: UPDATE or CANCELLED
        for(OrderItem ordi: ListOI){
            //system.debug('****order item: '+ ordi );
            // Query the Master Allocation to find the main Id by its Ext_Id 
            if(userCodesMap.get(ordi.Order.Order_Owner_Code__c) != null)
            {
                Allocation__c al = new Allocation__c(txt_external_id__c=String.valueOf(userCodesMap.get(ordi.Order.Order_Owner_Code__c)).substring(0,15)+'-'+String.valueOf(ordi.pricebookentry.Product2.Id).substring(0,15)+'-'+Util.currentYear.name);            
                Allocation_Consume_Log__c acl = new Allocation_Consume_Log__c(MD_Allocation__r = al, 
                                                        TXT_External_ID__c=ordi.Order.Order_Owner_Code__c +'-'+ ordi.Order.GC_Integration_Key__c +'-'+ordi.pricebookentry.Product2.ProductSAPCode__c, 
                                                        TXT_Order_SAP__c=ordi.Order.GC_Integration_Key__c, 
                                                        TXT_SKU_SAP__c=ordi.pricebookentry.Product2.ProductSAPCode__c, 
                                                        TXT_User_SAP__c=ordi.Order.Order_Owner_Code__c,
                                                        LKP_User__c=userCodesMap.get(ordi.Order.Order_Owner_Code__c),
                                                        LKP_Product__c=ordi.pricebookentry.Product2.Id);
                
                if(ordi.GC_Rejection_Reason_Descr__c == null) acl.NUM_Qty__c = ordi.Quantity;  // Order not Cancelled -> (ordi.GC_Rejection_Reason_Descr__c == null)
                else acl.NUM_Qty__c = 0;
                
                //allocConsLogList.add(acl);
                if(allocConsLogMap.get(acl.TXT_External_ID__c) != null)
                    acl.Num_Qty__c = acl.Num_Qty__c + allocConsLogMap.get(acl.TXT_External_ID__c).NUM_Qty__c;
                
                allocConsLogMap.put(acl.TXT_External_ID__c, acl);

                //Verify if there is a record with that PONumber at the mapOppWithoutSAPNumber
                //system.debug('****esta el PoNumber de la order: '+ mapOppWithoutSAPNumber.get(ordi.Order.PoNumber) );
                if(mapOppWithoutSAPNumber.get(ordi.Order.PoNumber) != null)
                {
                    //system.debug('****entra en el if para esta PoNumber: '+ ordi.Order.GC_Integration_Key__c );
                    mapOppWithoutSAPNumber.get(ordi.Order.PoNumber).TXT_SAP_Order_number__c = ordi.Order.GC_Integration_Key__c;
                    mapOppWithoutSAPNumber.get(ordi.Order.PoNumber).PICK_Status__c = 'Submitted';
                }
                //system.debug('****valores despues de la comprobacion: '+ mapOppWithoutSAPNumber.values());
            }

            else system.debug('****order owner code without user: '+ ordi.Order.Order_Owner_Code__c );
        }


        //Database.Upsert(allocConsLogList, Allocation_Consume_Log__c.Fields.TXT_External_ID__c, false);
        Database.Upsert(allocConsLogMap.values(), Allocation_Consume_Log__c.Fields.TXT_External_ID__c, false);
        Database.Update(mapOppWithoutSAPNumber.values(), false);
        
    }
    
    // -----------------
    // FINISH method
    // -----------------
    
    global void finish(Database.BatchableContext BC){}

}