/*
 * Check there are no duplicated ladders
 *
 */
public class TriggerDiscountLadder implements Triggers.Handler
{
	
	List<Id> vcActive = new List<ID>();
	List<Discount__c> dList = new List<Discount__c>();
    
    public TriggerDiscountLadder()
    {
    	for(Discount__c d: [SELECT ID, MinBags__c, MaxBags__c, VoucherCampaignRef__c FROM Discount__c WHERE Active__c = true AND RecordTypeId != : Util.recordType.get('Discount__c:Smart_discount')])
    	{
    		dList.add(d);
    	}
    }
 
    public void handle()
    {
    	for(Discount__c d: (List<Discount__c>)trigger.new)
    	{
    		if(d.RecordTypeId != Util.recordType.get('Discount__c:Smart_discount')) {
	    		for(Discount__c dl: dList)
	    		{
	    			if(dl.Id!=d.Id && d.VoucherCampaignRef__c==dl.VoucherCampaignRef__c)
	    			{
		    			if( (d.MinBags__c>=dl.MinBags__c && 
		    			d.MinBags__c<=dl.MaxBags__c))
		    			{
		    					d.MinBags__c.addError(System.label.DiscountWrongLadder);
		    			}
		    			if(( d.MaxBags__c>=dl.MinBags__c && 
		    			d.MaxBags__c<=dl.MaxBags__c ))
		    			{
		     					d.MaxBags__c.addError(System.label.DiscountWrongLadder);			   				
		    			}
	    			}
	    		}
    		}
    	}   	
    }    	
}