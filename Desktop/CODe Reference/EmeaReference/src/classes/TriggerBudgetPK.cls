/*
 * Class which avoids duplicate PK
 *
 */
public class TriggerBudgetPK implements Triggers.Handler
{

    public TriggerBudgetPK()
    {
    }
 
    public void handle()
    {   	
       for(Budget__c bu: (List<Budget__c>)trigger.new)
	   {
	    	bu.PK__c=bu.YearRef__c+'-'+bu.SalesRep__c+'-'+bu.ProductRef__c;
	   }    	
    }    	
}