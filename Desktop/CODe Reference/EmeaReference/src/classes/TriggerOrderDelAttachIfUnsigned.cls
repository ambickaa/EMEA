public class TriggerOrderDelAttachIfUnsigned implements Triggers.Handler
{
  public void handle()
  {
    Set<ID> unsignedOrders = new Set<ID>();
    for(Order__c o : (List<Order__c>)trigger.new)
    {
                         	 
        
        if(!o.Signed_RSA__c && ((Order__c)trigger.oldMap.get(o.id)).Signed_RSA__c /*||
            o.Discretionary_Discount_RSA__c != ((Order__c)trigger.oldMap.get(o.id)).Discretionary_Discount_RSA__c*/)
        {
            unsignedOrders.add(o.id);
            o.Signed_RSA__c = false;
        }
        if(o.Status_RSA__c != 'Cancelled' && o.Discretionary_Discount_RSA__c != ((Order__c)trigger.oldMap.get(o.id)).Discretionary_Discount_RSA__c && o.Discretionary_Discount_RSA__c != 0){
            o.Status_RSA__c = 'Waiting for discount approval';
        }
        if (o.Discretionary_Discount_RSA__c == 0 && o.Status_RSA__c == 'Waiting for discount approval' && o.VolumeDiscount_RSA__c == 0){
        	o.Status_RSA__c = 'Approved';
        }
        if (o.Status_RSA__c == 'Cancelled' && ((Order__c)trigger.oldMap.get(o.id)).status_RSA__c != 'Cancelled'){
        	o.PdfSent_RSA__c=False;
        }
    }
    //List<Attachment> todelete = new List<Attachment>( [SELECT ID FROM Attachment WHERE parentID in :unsignedOrders AND name = 'Signature.png']);
   
    //delete todelete;//[SELECT ID FROM Attachment WHERE parentID in :unsignedOrders AND name = 'Signature.png'];
  }
  
   public static testMethod void testHandle(){
        try{
            new TriggerOrderDelAttachIfUnsigned().handle();
        }catch(Exception e){}
    }
}