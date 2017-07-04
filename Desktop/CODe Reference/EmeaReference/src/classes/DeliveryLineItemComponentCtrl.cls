/**
 * This class is a controller class to DeliveryLineItemComponent
 * 
 * @author	Accenture
 * @version	1.0, 04/11/2016
 * 
 */
public class DeliveryLineItemComponentCtrl {
    
    public Id deliveryId{get;set;}//delivery id for which order line items are required
    public Delivery__c oDelivery{get;set;}
    final Integer MAX_RECORDS_TO_SHOW = 5;
    //property to store list of delivery line items    
    public List<Delivery_Line_Item__c> lstDeliveryLineItems{
        get{
            lstDeliveryLineItems = oDelivery.Delivery_Line_Items2__r;
            return lstDeliveryLineItems;
        }
        set;
    }
    public List<Delivery_Line_Item__c> lstDeliveryLineItemsShow{
        get{
            lstDeliveryLineItemsShow = new List<Delivery_Line_Item__c>();
            for(Integer i = 0 ; i < (lstDeliveryLineItems.size() < MAX_RECORDS_TO_SHOW ? lstDeliveryLineItems.size() : MAX_RECORDS_TO_SHOW) ; i++){
                lstDeliveryLineItemsShow.add(lstDeliveryLineItems.get(i));
            }
            return lstDeliveryLineItemsShow;
        }
        set;
    }
}