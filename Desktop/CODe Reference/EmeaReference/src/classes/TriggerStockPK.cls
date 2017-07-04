/*
 * Class which avoids duplicate PK
 *
 */
public class TriggerStockPK implements Triggers.Handler
{ 
    public void handle()
    {		   
	   for(Stock__c st: (List<Stock__c>)trigger.new)
	   {
	    	st.PK__c=st.User_RSA__c+'-'+st.ProductCatalogEntryRef_RSA__c;
	   }      		
    }    	
}