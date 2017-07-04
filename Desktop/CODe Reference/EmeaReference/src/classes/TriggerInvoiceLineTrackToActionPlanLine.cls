public with sharing class TriggerInvoiceLineTrackToActionPlanLine implements Triggers.Handler 
{
    map<Id, Id> mapInvoiceItemInvoice = new map<Id, Id>();
    map<Id, Invoice_Line_Item__c> mapInvoiceItem = new map<Id, Invoice_Line_Item__c>();
    map<string, Action_Plan_Line__c> mapActionPlanLine = new map<String, Action_Plan_Line__c>();
    list<Action_Plan_Line__c> listActionPlanLine = new list<Action_Plan_Line__c>();
    list<string> listProducts = new list<string>();
    list<Id> listAccounts = new list<Id>();
    
    public void handle()
    {/*
        List<Invoice_Line_Item__c> listILI;
        if(Trigger.isDelete)
            listILI = (List<Invoice_Line_Item__c>)trigger.old;            
        else
            listILI = (List<Invoice_Line_Item__c>)trigger.new;  
        
        for(Invoice_Line_Item__c ili: listILI)
        {
            mapInvoiceItemInvoice.put(ili.Id, ili.GC_Invoice_Integration_Key__c);
            mapInvoiceItem.put(ili.Id, ili);
            listProducts.add(ili.GC_Item_Code__c);
        }   
            
        map<Id, Invoice__c> mapInvoice = new map<Id, Invoice__c>([SELECT Id, Name, GC_Account_Integration_Key__c, GC_Invoice_Creation_Date__c FROM Invoice__c WHERE Id IN : mapInvoiceItemInvoice.values() AND Divison_Code__c =: '15']);
        
        map<String, Product2> mapProducts = new map<String, Product2>();
        for(Product2 p : [SELECT Id, Name, ProductSAPCode__c FROM Product2 WHERE ProductSAPCode__c IN :listProducts])
        {
            mapProducts.put(p.ProductSAPCode__c, p);
        }
        
        //Accounts of Invoices
        for(Invoice__c i : mapInvoice.values())
        {
            listAccounts.add(i.GC_Account_Integration_Key__c);
        } 
        
        //Existing Action Plan Line
        map<String, Action_Plan_Line__c> mapExistingAPL = new map<String, Action_Plan_Line__c>();
        for(Action_Plan_Line__c apl : [SELECT TXT_External_ID__c, Id, LKP_SKU__c, LKP_Account__c, NUM_Delivered__c FROM Action_Plan_Line__c WHERE LKP_Account__c IN :listAccounts])
        {
            mapExistingAPL.put(apl.TXT_External_ID__c, apl);
        }
        
        if(mapInvoice.size() > 0)
        {        
            if(trigger.isInsert)
            {
                for(Invoice_Line_Item__c ili : mapInvoiceItem.values())
                {   
                    if(mapProducts.get(ili.GC_Item_Code__c)!=null && mapInvoiceItemInvoice.get(ili.Id) !=null && mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)) != null && mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)).GC_Account_Integration_Key__c!=null)
                    {
                        Action_Plan_Line__c apl = new Action_Plan_Line__c();
                        apl.LKP_Account__c = mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)).GC_Account_Integration_Key__c;    
                        apl.LKP_SKU__c = mapProducts.get(ili.GC_Item_Code__c).Id;
                        
                        if(mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)).GC_Invoice_Creation_Date__c.month() < 10) apl.PICK_Period__c = String.valueOf(mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)).GC_Invoice_Creation_Date__c.year()) + '-' + '0' + String.valueOf(mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)).GC_Invoice_Creation_Date__c.month());
                        else apl.PICK_Period__c = String.valueOf(mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)).GC_Invoice_Creation_Date__c.year()) + '-' + String.valueOf(mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)).GC_Invoice_Creation_Date__c.month());
                        
                        apl.TXT_External_ID__c = String.valueOf(apl.LKP_Account__c).substring(0,15) + '-' +  String.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + apl.PICK_Period__c;
                        
                        apl.NUM_Delivered__c = ili.GC_Quantity__c;   
                        
                        if(mapActionPlanLine.get(apl.TXT_External_ID__c) == null) mapActionPlanLine.put(apl.TXT_External_ID__c, apl);
                        else mapActionPlanLine.get(apl.TXT_External_ID__c).NUM_Delivered__c = mapActionPlanLine.get(apl.TXT_External_ID__c).NUM_Delivered__c + apl.NUM_Delivered__c;
                    }                
                }
                
                for(Action_Plan_Line__c apl : mapActionPlanLine.values())
                {
                    if(mapExistingAPL.get(apl.TXT_External_ID__c) != null)
                    {                        
                        apl.NUM_Delivered__c = (apl.NUM_Delivered__c==null?0:apl.NUM_Delivered__c) + (mapExistingAPL.get(apl.TXT_External_ID__c).NUM_Delivered__c==null?0:mapExistingAPL.get(apl.TXT_External_ID__c).NUM_Delivered__c);
                    }
                }            
            }            
            else if(trigger.isUpdate || trigger.isDelete)
            {
                for(Invoice_Line_Item__c ili : mapInvoiceItem.values())
                {   
                    if(mapProducts.get(ili.GC_Item_Code__c)!= null && mapInvoiceItemInvoice.get(ili.Id)!=null && mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)) != null && mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)).GC_Account_Integration_Key__c!=null)
                    {
                        Action_Plan_Line__c apl = new Action_Plan_Line__c();
                        apl.LKP_Account__c = mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)).GC_Account_Integration_Key__c;
                        apl.LKP_SKU__c = mapProducts.get(ili.GC_Item_Code__c).Id;
                        
                        if(mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)).GC_Invoice_Creation_Date__c.month() < 10) apl.PICK_Period__c = String.valueOf(mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)).GC_Invoice_Creation_Date__c.year()) + '-' + '0' + String.valueOf(mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)).GC_Invoice_Creation_Date__c.month());
                        else apl.PICK_Period__c = String.valueOf(mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)).GC_Invoice_Creation_Date__c.year()) + '-' + String.valueOf(mapInvoice.get(mapInvoiceItemInvoice.get(ili.Id)).GC_Invoice_Creation_Date__c.month());
                        
                        apl.TXT_External_ID__c = String.valueOf(apl.LKP_Account__c).substring(0,15) + '-' +  String.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + apl.PICK_Period__c;
                        if(trigger.isUpdate)
                        {
                            //Compare NEW Delivered with OLD Delivered
                            if(ili.GC_Quantity__c != ((map<Id, Invoice_Line_Item__c>)trigger.oldMap).get(ili.Id).GC_Quantity__c) apl.NUM_Delivered__c = (ili.GC_Quantity__c - ((map<Id, Invoice_Line_Item__c>)trigger.oldMap).get(ili.Id).GC_Quantity__c);
                        }
                        else
                        {
                            //Substract quantity
                            apl.NUM_Delivered__c = ili.GC_Quantity__c * -1;
                        }
                        //Accumulate delivered of Invoice Line
                        if(mapActionPlanLine.get(apl.TXT_External_ID__c) == null) mapActionPlanLine.put(apl.TXT_External_ID__c, apl);
                        else {
                            if(mapActionPlanLine.get(apl.TXT_External_ID__c).NUM_Delivered__c==null)
                            {
                                Action_Plan_Line__c line=new Action_Plan_Line__c();
                                line=mapActionPlanLine.get(apl.TXT_External_ID__c);
                                line.NUM_Delivered__c=0;
                                mapActionPlanLine.put(apl.TXT_External_ID__c, line);
                            }
                            if(apl.NUM_Delivered__c==null)
                            {
                                apl.NUM_Delivered__c=0;
                            }
                          mapActionPlanLine.get(apl.TXT_External_ID__c).NUM_Delivered__c = mapActionPlanLine.get(apl.TXT_External_ID__c).NUM_Delivered__c + apl.NUM_Delivered__c;  
                        } 
                    }                    
                }
                
                for (Action_Plan_Line__c apl : mapActionPlanLine.values())
                {
                    if(mapExistingAPL.get(apl.TXT_External_ID__c) != null)
                    {
                        if(mapExistingAPL.get(apl.TXT_External_ID__c).NUM_Delivered__c != null)
                            if(apl.NUM_Delivered__c != null) 
                                apl.NUM_Delivered__c = (apl.NUM_Delivered__c==null?0:apl.NUM_Delivered__c) + (mapExistingAPL.get(apl.TXT_External_ID__c).NUM_Delivered__c==null?0:mapExistingAPL.get(apl.TXT_External_ID__c).NUM_Delivered__c);

                    }
                }       
            }                           
            Database.upsert(mapActionPlanLine.values(), Action_Plan_Line__c.Fields.TXT_External_ID__c, false);
        }
   */ }
}