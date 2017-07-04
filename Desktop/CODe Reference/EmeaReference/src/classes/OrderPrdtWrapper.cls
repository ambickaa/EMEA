/*
Class name - OrderPrdtWrapper
Description- global class for orderitem wrapper in orderSelection class
Created By - Accenture IDC
*/
global class OrderPrdtWrapper{         
    public  OrderItem ordLineItm { get; set; }         
    public Boolean flg{get;set;}                   
    public OrderPrdtWrapper(OrderItem ordLineItm)
    {            
        this.ordLineItm = ordLineItm;                     
    }     
}