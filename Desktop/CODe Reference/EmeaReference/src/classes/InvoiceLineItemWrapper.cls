/*
Class name - InvoiceLineItemWrapper
Description- global class for orderitem wrapper in orderSelection class
Created By - Accenture IDC
*/
global class InvoiceLineItemWrapper{         
    public Invoice_Line_Item__c InvLineItm { get; set; }         
    public Boolean flg{get;set;}                   
    public InvoiceLineItemWrapper(Invoice_Line_Item__c InvLineItm)
    {            
        this.InvLineItm= InvLineItm;                     
    }     
}