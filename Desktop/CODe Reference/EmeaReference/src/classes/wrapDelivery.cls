/*
Class name - wrapDelivery
Description- global class for Delivery wrapper in orderSelection class
Created By - Accenture IDC
*/
global class wrapDelivery{
        public Delivery__c del{get;set;}
        public List<DeliveryLineItemWrapper> DelItemList { get; set;} 
        public boolean isSelected{get;set;}
        public wrapDelivery(Delivery__c d, List<DeliveryLineItemWrapper> DelItemList ){
        del=d;
        this.DelItemList = DelItemList ; 
        }
    }