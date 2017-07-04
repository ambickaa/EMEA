global with sharing class BatchWhiteLabelLines implements Database.batchable<String> 
{

    global iterable<String> start(Database.BatchableContext bc)
    {
        map<String,Product2> whiteProds=new map<String,Product2>();
        for(product2 item :[Select name,ProductSAPCode__c from product2 where CHK_White_label_prods__c=True])
        {
            system.debug(item.ProductSAPCode__c);
            whiteProds.put(item.ProductSAPCode__c , item);
        }
        list<string> whiteProdsCodes=new list<String>();
        whiteProdsCodes.addAll(whiteProds.keySet());
        return whiteProdsCodes;
    }
    global void execute(Database.BatchableContext BC,list<String> scope)
    {   
        map<id,sObject> objToUpd=new map<id,sObject>();
        
        for(Invoice_Line_Item__c item:[Select name,GC_Invoice_Integration_Key__c from Invoice_Line_Item__c where /*lastModifiedDate>Yesterday and*/ GC_Item_Code__c in:scope])
        {            
            objToUpd.put(item.GC_Invoice_Integration_Key__c,item);
        }
        for(Delivery_Line_Item__c item:[Select name,GC_Dlvry_Integration_Key__c from Delivery_Line_Item__c where /*lastModifiedDate>Yesterday and*/ GC_Item_Code__c in:scope])
        {            
            objToUpd.put(item.GC_Dlvry_Integration_Key__c,item);
        }
        for(Contract_Line_Item__c item:[Select name,GC_Contrct_Integration_Key__c from Contract_Line_Item__c where /*lastModifiedDate>Yesterday and*/ Material_Number_Text__c in:scope])
        {
            objToUpd.put(item.GC_Contrct_Integration_Key__c,item);
        }
        for(OrderItem item:[Select orderId from OrderItem where /*lastModifiedDate>Yesterday and*/ Pricebookentry.ProductCode in:scope])
        {
            objToUpd.put(item.orderId,item);
        }  
        
        
        list<Invoice__c> invToUpd=new list<Invoice__c>();
        for(Invoice__c item:[Select name,CHK_White_label_prods__c from invoice__C where id in:objToUpd.keySet() ])
        {
            item.CHK_White_label_prods__c=True;
            invToUpd.add(item);
        }
        
        list<Delivery__c> delToUpd=new list<Delivery__c>();
        for(Delivery__c item:[Select name,CHK_White_label_prods__c from Delivery__c where id in:objToUpd.keySet() ])
        {
            item.CHK_White_label_prods__c=True;
            delToUpd.add(item);
        }   
        
        list<Order> ordToUpd=new list<Order>();
        for(Order item:[Select name,CHK_White_label_prods__c from Order where id in:objToUpd.keySet() ])
        {
            item.CHK_White_label_prods__c=True;
            ordToUpd.add(item);
        }  
        
        list<Contract> conToUpd=new list<Contract>();
        for(Contract item:[Select name,CHK_White_label_prods__c from Contract where id in:objToUpd.keySet() ])
        {
            item.CHK_White_label_prods__c=True;
            conToUpd.add(item);
        } 
        update delToUpd;
        update ordToUpd;
        update conToUpd;
        update invToUpd;  		
    }
    global void finish(Database.BatchableContext BC)
    {
        
    }
}