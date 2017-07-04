public class TriggerWarehousePK implements Triggers.Handler 
{
    public void handle()
    {	
	   for(ConsignmentWarehouse__c cw: (List<ConsignmentWarehouse__c>)trigger.new)
	   {
	   		if(trigger.isUpdate)
	   		{	   
	   			cw.Name=(String)Trigger.oldMap.get(cw.id).get('Name'); 		
	   			cw.ProductCatalogRef__c=(ID)Trigger.oldMap.get(cw.id).get('ProductCatalogRef__c'); 		
	   			cw.UserRef__c=(ID)Trigger.oldMap.get(cw.id).get('UserRef__c'); 	
	   			cw.OwnerId=(ID)Trigger.oldMap.get(cw.id).get('OwnerId'); 			   			   					   		
	   		}
	    	cw.PK__c=cw.Name+'-'+cw.UserRef__c+'-'+cw.ProductCatalogRef__c;	
	   }      		
    }    	

}