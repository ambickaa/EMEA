public without sharing class TriggerVoucherNameCreator implements Triggers.Handler {
  	  
  	public static boolean fromTest = false;
  	  
    public void handle()
    { 	
    	if(!fromTest)
    	{
	    	User currentUser = Util.currentUser; 
	    	
	    	//BEG TO MAKE TRIGGER ATOMIC
	    	
	    		Country__c co= [SELECT id from Country__c where Name=:Util.currentUser.Country FOR UPDATE];
	    	//END
	    	
	    	Integer newNumber = 0;
	        String initials;  
	        String restriction= '%/'+Util.currentUser.CountryISOCode__c+'-%';
	        String year=UtilREST.currentVoucherYear.Name;
	        	
	        for( AggregateResult av : [
	           SELECT max(Name) name FROM Voucher__c 
	           WHERE VoucherCampaignRef__r.isActive__c=true and VoucherCampaignRef__r.CountryRef__r.Name=:Util.currentUser.Country
	           AND Name LIKE :restriction
	           GROUP BY VoucherCampaignRef__r.CountryRef__c         
	        ])
	        {
	        	newNumber=Integer.valueof(((String.valueOf(av.get('name'))).split('-')).get(1));
	        	break;
	        }
	
	        initials = year+'/'+Util.currentUser.CountryISOCode__c;                       
	            	        for (Voucher__c v : (List<Voucher__c>)Trigger.new)
	        {           
	                v.Name =  String.valueOf(++newNumber);
	                while (v.Name.length () < 7){
	                    v.Name = '0' + v.Name;
	                }               
	                v.Name = initials + '-' + v.Name;  
	                v.PKNumber__c=newNumber;    
	        }
	    }
    }
}