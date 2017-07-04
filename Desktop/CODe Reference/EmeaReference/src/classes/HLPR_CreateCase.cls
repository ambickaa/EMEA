/*
Class name - HLPR_CreateCase
Description- Utility class for after insert trigger 
Created By - Accenture IDC
*/
public class HLPR_CreateCase {
/*
Method name - ProcessInsert
Description - This method is used to create case from order,deivery or invoice
*/
public static void ProcessInsert(List < Case > lstcase) {
    set<id> casids = new set<id>();
    set<id> accordids = new set<id>();
    set<id> accdelids = new set<id>();
    set<id> accinvids = new set<id>();
    
    set<id> ordids = new set<id>();
    set<id> delids = new set<id>();
    set<id> invids = new set<id>();
    
    List<Case> caslst = new List<Case>();  

     
    for(case c:lstcase)
    {
        if(c.id!=null)
        {
            casids.add(c.id);
        }   
    }
    
    if(casids.size()==1)
    {
        caslst = [select id,accountid,GC_Source_Order_SFID__c,GC_Source_Delivery_SFID__c ,GC_Source_Invoice_SFID__c from case where id in :casids];
    }
    
    for(case c1:caslst)
    {
        if(c1.GC_Source_Order_SFID__c !=null)
        {
            ordids.add(c1.GC_Source_Order_SFID__c);
            accordids.add(c1.accountid);
        }
        
        if(c1.GC_Source_Delivery_SFID__c !=null)
        {
            delids.add(c1.GC_Source_Delivery_SFID__c);
            accdelids.add(c1.accountid);
        }
        
        if(c1.GC_Source_Invoice_SFID__c !=null)
        {
            invids.add(c1.GC_Source_Invoice_SFID__c);
            accinvids.add(c1.accountid);
        }
    }
    
    List<Order> ordlst = [select id, ShipTo_Acc_Integration_Key__c, GC_Currency_Description__c,GC_Ship_To_Party_Text__c,
    GC_Integration_Key__c,LastModifiedDate, AccountID, Account.Name, ShipTo_Acc_Integration_Key__r.Name, GC_Ship_To_Party_Descr__c,
    Name, PoNumber, GC_Document_Type_Descr__c, GC_Doc_Creation_Date__c,fGC_Total_Amount__c, GC_Requested_Delivery_Date__c, 
    GC_Open_Order_Qty__c from Order where id in:ordids and AccountID = :accordids]; 
    
    List<Delivery__c> dellst =[select Id,name,GC_Account_Integration_Key__c, ShipTo_Acc_Integration_Key__c,ShipTo_Acc_Integration_Key__r.name,
    GC_Delivery_Creation_Date__c,GC_Delivery_Date__c,GC_Proposed_GI_Date__c,GC_Actual_GI_Date__c,GC_Order_Number__c,LastModifiedDate 
    FROM Delivery__c where id in :delids AND GC_Account_Integration_Key__c = :accdelids];

    List<Invoice__c> invlst =[ SELECT id,Name,GC_Invoice_Status_descr__c ,GC_Invoice_Due_Date__c,GC_Total_Inv_Amount_Nbr__c,
    GC_Invoice_Creation_Date__c ,GC_Currency_Desc__c,LastModifiedDate FROM Invoice__c where id in :invids and GC_Account_Integration_Key__c =:accinvids];
    
    List<Orderselection__c> ocslst = new List<Orderselection__c>();
    List<Orderselection__c> OCSdeliverylist = new List<Orderselection__c>();
    List<Orderselection__c> OCSInvoicelist = new List<Orderselection__c>();
    
    for(Case c :caslst)
    {
        if(c.GC_Source_Order_SFID__c!=null)
        {
            for(Order o:ordlst)
            {
                if(ordlst.size() == 1)
                {
                Orderselection__c o1 = new Orderselection__c();
                
                o1.Order_Number_Text__c = o.GC_Integration_Key__c;
                o1.CaseId_Text__c= c.id;
                o1.Ship_To_Party_Text__c = o.GC_Ship_To_Party_Text__c;
                o1.Ship_To_Party_Descr_Text__c =    o.GC_Ship_To_Party_Descr__c;
                o1.Order_Currency_Descr__c = o.GC_Currency_Description__c;
                o1.Net_Value_Curncy__c = o.fGC_Total_Amount__c;
                o1.PO_Number_Text__c= o.PONumber;
                o1.Document_Type_Text__c = o.GC_Document_Type_Descr__c;
                o1.Last_Modified_Date__c = o.LastModifiedDate ; 
                o1.OrderId_Text__c = o.id;
                o1.Delivery_Id_Text__c = null;
                o1.DeliveryItem_Id_Text__c = null;
                o1.InvoiceId_Text__c = null;
                o1.InvoiceLineItemId_Text__c = null;
                ocslst.add(o1);
                }
            }
        }
        
        if(c.GC_Source_Delivery_SFID__c!=null)
        {
            for(Delivery__c del:dellst)
            {
                if(dellst.size() > 0)
                {
                    Orderselection__c o1 = new Orderselection__c();
                    
                    o1.Delivery_Number_Text__c = del.name;
                    o1.Delivery_Id_Text__c= del.id;
                    o1.CaseId_Text__c = c.id ;
                    o1.DeliveryRecordId__c = del.Id;
                    o1.Ship_To_Name_Text__c = del.ShipTo_Acc_Integration_Key__r.name;
                    o1.Delivery_Creation_Date_header__c = del.GC_Delivery_Creation_Date__c;
                    o1.Delivery_Date__c = del.GC_Delivery_Date__c;
                    o1.Proposed_GI_Date__c = del.GC_Proposed_GI_Date__c;
                    o1.Actual_GI_Date__c = del.GC_Actual_GI_Date__c;
                    o1.Delivery_Order_Number__c = del.GC_Order_Number__c;
                    o1.Last_Modified_Del_Date__c = del.LastModifiedDate;
                    o1.Order_Number_Text__c = null;
                    o1.OrderLine_Item_Id_Text__c = null;
                    o1.InvoiceId_Text__c = null;
                    o1.InvoiceLineItemId_Text__c = null;
                    OCSdeliverylist.add(o1);
                }
            }
        }
        
        if(c.GC_Source_Invoice_SFID__c!=null)
        {
            for(Invoice__c inv:invlst)
            {
                if(invlst.size() > 0)
                {
                    Orderselection__c o1 = new Orderselection__c();
                    
                    o1.Invoice_Number_Text__c = inv.name;
                    o1.InvoiceId_Text__c= inv.id;
                    o1.CaseId_Text__c = c.id ;
                    o1.Invoice_Creation_Date__c = inv.GC_Invoice_Creation_Date__c;
                    o1.Total_Inv_Amount_Nbr__c= inv.GC_Total_Inv_Amount_Nbr__c;
                    o1.Invoice_Status_Descr__c=inv.GC_Invoice_Status_Descr__c;
                    o1.InvoiceRecordId__c = inv.Id;
                    o1.Invoice_Due_Date__c = inv.GC_Invoice_Due_Date__c;
                    o1.Invoice_Currency_Descr__c = inv.GC_Currency_Desc__c;
                    o1.Last_Modified_Inv_Date__c = inv.LastModifiedDate;
                    o1.Order_Number_Text__c = null;
                    o1.OrderLine_Item_Id_Text__c = null;
                    o1.Delivery_Id_Text__c = null;
                    o1.DeliveryItem_Id_Text__c = null;
                    
                    OCSInvoicelist.add(o1);
                }
            }
        }
        
    }
    
    if(ocslst.size()>0)
    {
        insert ocslst;
    }
    if(OCSdeliverylist.size()>0)
    {
        insert OCSdeliverylist;
    }
    if(OCSInvoicelist.size()>0)
    {
        insert OCSInvoicelist;
    }
}
}