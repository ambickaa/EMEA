/*
Class name - OrderWrapper
Description- global class for order wrapper in orderSelection class
Created By - Accenture IDC
*/
global class OrderWrapper{
    public  Order ord { get; set;}       
    public  List<OrderPrdtWrapper> OrderItemList { get; set;} 
    public Boolean flg1{get;set;}
    public OrderWrapper(Order ord, List<OrderPrdtWrapper> OrderitemList){
        this.ord = ord;
        this.OrderitemList = OrderitemList;           
    }
}