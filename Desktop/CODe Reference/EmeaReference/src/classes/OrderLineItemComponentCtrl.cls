/**
 * This class is a controller class to OrderLineItemComponent
 * 
 * @author	Accenture
 * @version	1.0, 04/11/2016
 * 
 */ 
public class OrderLineItemComponentCtrl {
    
    public Id orderId{get;set;}//order id for which order line items are required
    final Integer MAX_RECORDS_TO_SHOW = 5;
    public Object arrOrderItems{get;set;}
    public List<OrderItem> lstOrderItemsShow{
        get{
            lstOrderItemsShow = new List<OrderItem>();
            for(Integer i = 0 ; i < (lstOrderItems.size() < MAX_RECORDS_TO_SHOW ? lstOrderItems.size() : MAX_RECORDS_TO_SHOW) ; i++){
                lstOrderItemsShow.add(lstOrderItems.get(i));
            }
            return lstOrderItemsShow;
        }
        set;
    }
    
    public List<OrderItem> lstOrderItems{
        get{
            lstOrderItems = (List<OrderItem>)arrOrderItems;
            return lstOrderItems;
        }
        set;
    }
}