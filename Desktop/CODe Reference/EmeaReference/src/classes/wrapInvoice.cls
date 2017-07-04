/*
Class name - wrapInvoice
Description- global class for Invoice wrapper in orderSelection class
Created By - Accenture IDC
*/
global class wrapInvoice{
    public Invoice__c Inv{get;set;}
    public List<InvoiceLineItemWrapper> InvoiceItemList { get; set;} 
    public boolean isSelected{get;set;}
       public wrapInvoice(Invoice__c a, List<InvoiceLineItemWrapper> InvoiceItemList ){
         Inv=a;
         this.InvoiceItemList = InvoiceItemList;  
        }
    }