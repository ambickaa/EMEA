//-------------
//Created by everis.
//
//This batch is responsible for filling the values on CLIs with data coming from orders PY and CY and from CY invoices.
//----------------

global  with sharing class Batch_CP_ordered_Delivered implements Database.batchable<sObject>{
                        
    global List<String> listAccounts = Label.Batch_CP_Acc_NoStd.split('\r\n');
    global List<String> listDTstd = Label.Batch_CP_DocType_Std.split('\r\n');
    global List<String> listDT = Label.Batch_CP_DocType_NoStd.split('\r\n');
    global List<String> listInvoice_Std = Label.Batch_CP_InvoiceType_Std.split('\r\n');
    global List<String> listInvoice_NoStd = Label.Batch_CP_InvoiceType_NoStd.split('\r\n');

    global String countryQuery;
    global Integer numMonths;

    global Batch_CP_ordered_Delivered (String q, Integer months){
        countryQuery = q;
        numMonths = Months;
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(countryQuery);
    }
    global void execute(Database.BatchableContext BC,list<Account> scope)
    { 
        map<Id,Account> accsMap=new map<Id,Account>();
        for(Account acc:scope)
        {
            accsMap.put(acc.Id,acc);
        }
        List<Action_Plan_Line__c> listAPL = new List<Action_Plan_line__c>();
        listAPL = [SELECT id, NUM_Ordered__c, num_delivered__c from action_plan_line__c where lkp_account__c in:scope and FRML_Period_Date__c>= THIS_FISCAL_YEAR];
        for(Action_Plan_Line__c item : listAPL)
        {
            item.num_ordered__C =0;
            item.num_delivered__c=0;
        }
        update listAPL;
        map<String, Product2> mapProducts = new map<String, Product2>();
        for(Product2 item : [SELECT Id, Name, ProductSAPCode__c, ProductPrmyPkContent__c FROM Product2 WHERE recordtype.developername='CPSalesProduct' and id in (select Product2Id from pricebookentry where gc_integration_key__c like 'ACS%')])
        {
            mapProducts.put(item.ProductSAPCode__c , item);
        }       
        
        //This map takes all the orders from CY in order to take all the invoices related
        map<string,Action_Plan_Line__c> mapActionPlanLine=new map<string,Action_Plan_Line__c>();
        map<string,string> productSAPcodes=new map<string,string>();
        map<string,id> ordersProcessed_STD = new map<string,id>();
        map<string,id> ordersProcessed_NoSTD = new map<string,id>();
        
        map<Id,map<String,Decimal>> quantOrdersCYPerAccs=new map<Id,map<String,Decimal>>();
        map<Id,map<String,Decimal>> quantOrdersPYPerAccs=new map<Id,map<String,Decimal>>();
        map<Id,map<String,Decimal>> quantInvoicesPerAccs=new map<Id,map<String,Decimal>>();
                            
        String query='SELECT id, order.GC_Integration_Key__c, Order.GC_Requested_Delivery_Date__c, orderId,order.accountid,PricebookEntry.Product2.Id,';
        query+=' Quantity, PricebookEntry.Product2.Name, GC_Sales_UoM_Text__c, PricebookEntry.Product2.ProductPrmyPkContent__c, order.GC_Document_Type_Descr__c';
        query+=' FROM OrderItem WHERE order.accountid in:scope';
        query+=' AND Order.Divison_Code__c = \'15\'';
        query+=' AND Order.GC_Requested_Delivery_Date__c >= last_n_months:'+numMonths;
        query+=' AND (order.GC_Document_Type_Descr__c IN :listDTstd';
        query+=' OR (order.GC_Document_Type_Descr__c IN :listDT AND Order.Account.GC_Integration_Key__c IN :listAccounts))';
        
        //crear sets
        set<String> setDT_STD = new set<String>();
        set<String> setDT_noSTD = new set<String>();
        setDT_STD.addAll(listDTstd);
        setDT_noSTD.addAll(listDT);
                
        for(orderItem item :Database.query(query))
        {
            if(setDT_STD.contains(item.order.GC_Document_Type_Descr__c))
            {
                ordersProcessed_STD.put(item.order.GC_Integration_Key__c, item.orderId); //This map will be used to get the related invoices 
            }
            else if(setDT_noSTD.contains(item.order.GC_Document_Type_Descr__c))
            {
                ordersProcessed_NoSTD.put(item.order.GC_Integration_Key__c, item.orderId);              
            }
            Action_Plan_Line__c apl = new Action_Plan_Line__c();
            apl.LKP_Account__c = item.Order.AccountId;
            apl.LKP_SKU__c = item.PricebookEntry.Product2.Id;
            
            if(item.Order.GC_Requested_Delivery_Date__c.month() < 10) apl.PICK_Period__c = String.valueOf(item.Order.GC_Requested_Delivery_Date__c.year()) + '-' + '0' + String.valueOf(item.Order.GC_Requested_Delivery_Date__c.month());
            else apl.PICK_Period__c = String.valueOf(item.Order.GC_Requested_Delivery_Date__c.year()) + '-' + String.valueOf(item.Order.GC_Requested_Delivery_Date__c.month());
            
            apl.TXT_External_ID__c = String.valueOf(apl.LKP_Account__c).substring(0,15) + '-' + String.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + apl.PICK_Period__c;          
            apl.NUM_Ordered__c = convertQuantityBottles(item.Quantity, item.PricebookEntry.Product2.ProductPrmyPkContent__c, item.GC_Sales_UoM_Text__c);
            apl.NUM_Delivered__c = 0;
            
            if(mapActionPlanLine.get(apl.TXT_External_ID__c) == null) mapActionPlanLine.put(apl.TXT_External_ID__c, apl);
            else mapActionPlanLine.get(apl.TXT_External_ID__c).NUM_Ordered__c = mapActionPlanLine.get(apl.TXT_External_ID__c).NUM_Ordered__c + apl.NUM_Ordered__c;
        }                            
                
        for(Invoice_Line_Item__c item: [SELECT GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c,GC_Invoice_Integration_Key__r.GC_Invoice_Creation_Date__c, GC_Invoice_Integration_Key__r.GC_Order_Number__c, GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__c, GC_Item_Code__c, GC_Quantity__c, GC_Item_Descr__c,GC_Invoice_Integration_Key__r.GC_Invoice_Type_Descr__c, GC_UOM_Line_Item_Descr__c
                                        FROM Invoice_Line_Item__c 
                                        WHERE (GC_Invoice_Integration_Key__r.GC_Invoice_Type_Descr__c IN :listInvoice_Std AND GC_Invoice_Integration_Key__r.GC_Order_Number__c IN: ordersProcessed_STD.keySet()) OR
                                        ((GC_Invoice_Integration_Key__r.GC_Invoice_Type_Descr__c IN :listInvoice_NoStd OR GC_Invoice_Integration_Key__r.GC_Invoice_Type_Descr__c IN :listInvoice_Std) AND 
                                        (GC_Invoice_Integration_Key__r.GC_Order_Number__c IN: ordersProcessed_NoSTD.keySet() OR GC_Invoice_Integration_Key__r.GC_Order_Number__c IN: ordersProcessed_STD.keySet()) )])
        {
            productSAPCodes.put(item.GC_Item_Code__c,item.GC_Item_Descr__c) ;
            //Compare accounts in scope with invoice field Account
            if(accsMap.containsKey(item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c) && mapProducts.get(item.GC_Item_Code__c)!= null) 
            {    
                Action_Plan_Line__c apl = new Action_Plan_Line__c();
                apl.LKP_Account__c = item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c;    
                apl.LKP_SKU__c = mapProducts.get(item.GC_Item_Code__c).Id;

                if(item.GC_Invoice_Integration_Key__r.GC_Invoice_Creation_Date__c.month() < 10) apl.PICK_Period__c = String.valueOf(item.GC_Invoice_Integration_Key__r.GC_Invoice_Creation_Date__c.year()) + '-' + '0' + String.valueOf(item.GC_Invoice_Integration_Key__r.GC_Invoice_Creation_Date__c.month());
                else apl.PICK_Period__c = String.valueOf(item.GC_Invoice_Integration_Key__r.GC_Invoice_Creation_Date__c.year()) + '-' + String.valueOf(item.GC_Invoice_Integration_Key__r.GC_Invoice_Creation_Date__c.month());

                apl.TXT_External_ID__c = String.valueOf(apl.LKP_Account__c).substring(0,15) + '-' +  String.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + apl.PICK_Period__c;
                
                if(item.GC_Invoice_Integration_Key__r.GC_Invoice_Type_Descr__c == 'Cancellation of Inv'){
                    apl.NUM_Delivered__c = convertQuantityBottles(item.GC_Quantity__c, mapProducts.get(item.GC_Item_Code__c).ProductPrmyPkContent__c, item.GC_UOM_Line_Item_Descr__c)*(-1); 
                }else{
                    apl.NUM_Delivered__c = convertQuantityBottles(item.GC_Quantity__c, mapProducts.get(item.GC_Item_Code__c).ProductPrmyPkContent__c, item.GC_UOM_Line_Item_Descr__c); 
                }
                
                if(mapActionPlanLine.get(apl.TXT_External_ID__c) == null) mapActionPlanLine.put(apl.TXT_External_ID__c, apl);
                else mapActionPlanLine.get(apl.TXT_External_ID__c).NUM_Delivered__c = mapActionPlanLine.get(apl.TXT_External_ID__c).NUM_Delivered__c + apl.NUM_Delivered__c;
            }
        }           
        Database.upsert(mapActionPlanLine.values(), Action_Plan_Line__c.Fields.TXT_External_ID__c, false);           
    }

    global void finish(Database.BatchableContext BC)
    {    }

    public static Decimal convertQuantityBottles(Decimal qtyToConvert, String convFactor, String UoM)
    {
        if('BT'.equals(UoM) && convFactor!=null && convFactor !='')
        {
            String factor =convFactor.replace('KG','').replace('L','');
            qtyToConvert = Double.valueOf(factor) * qtyToConvert;
        }
        return qtyToConvert;
    }
}