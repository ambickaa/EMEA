/*
Class name - DeliveryLineItemWrapper
Description- global class for orderitem wrapper in orderSelection class
Created By - Accenture IDC
*/
global class DeliveryLineItemWrapper{         
    public Delivery_Line_Item__c delLineItm { get; set; }         
    public Boolean flg{get;set;}                   
    public DeliveryLineItemWrapper(Delivery_Line_Item__c delLineItm)
    {            
        this.delLineItm= delLineItm;                     
    }     
}