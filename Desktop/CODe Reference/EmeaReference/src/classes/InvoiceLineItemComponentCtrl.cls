/**
 * This class is a controller class to InvoiceLineItemComponent
 * 
 * @author	Accenture
 * @version	1.0, 04/11/2016
 * 
 */ 
public class InvoiceLineItemComponentCtrl {
    
    public Id invoiceId{get;set;}//invoice id for which order line items are required
    final Integer MAX_RECORDS_TO_SHOW = 5;
    public Invoice__c oInvoice{get;set;}
    //property to store list of invoice line items    
    public List<Invoice_Line_Item__c> lstInvoiceLineItems{
        get{
            lstInvoiceLineItems = oInvoice.Invoice_Line_Items2__r;
            return lstInvoiceLineItems;
        }
        set;
    }
    public List<Invoice_Line_Item__c> lstInvoiceLineItemsShow{
        get{
            lstInvoiceLineItemsShow = new List<Invoice_Line_Item__c>();
            for(Integer i = 0 ; i < (lstInvoiceLineItems.size() < MAX_RECORDS_TO_SHOW ? lstInvoiceLineItems.size() : MAX_RECORDS_TO_SHOW) ; i++){
                lstInvoiceLineItemsShow.add(lstInvoiceLineItems.get(i));
            }
            return lstInvoiceLineItemsShow;
        }
        set;
    }
   
}