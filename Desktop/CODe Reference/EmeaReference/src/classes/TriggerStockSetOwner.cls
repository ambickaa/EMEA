public with sharing class TriggerStockSetOwner implements Triggers.Handler
{
    // copy user_RSA__c to OwnerID
    public void handle()
    {
   //     for(Stock__c s : (List<Stock__c>)trigger.new){
      //      s.ownerID = s.User_RSA__c;
  //      }
    }
    public static testMethod void testHandle(){
        try{
            new TriggerStockSetOwner().handle();
        }catch(Exception e){}
     }
}