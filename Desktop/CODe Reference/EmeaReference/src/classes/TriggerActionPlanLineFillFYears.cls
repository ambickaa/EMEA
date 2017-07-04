public with sharing class TriggerActionPlanLineFillFYears implements Triggers.Handler {

	public void handle()
	{
	/* This trigger updates an account field (forecasted_year__c) when an action plan line with a fiscal year is inserted */ 

	Id rt = Util.recordType.get('Action_Plan_Line__c:Action_Plan_Line');

	List<Action_Plan_Line__c> listAPL = [SELECT Id, PICK_Period__c, RecordTypeId, LKP_Account__r.Name, LKP_Account__r.Forecasted_Year__c, LKP_Account__r.GC_Cust_Account_Grp_Descr__c
    	FROM Action_Plan_Line__c WHERE (Id IN :Trigger.new
    	AND RecordtypeId = :rt) 
		AND (LKP_Account__r.GC_Cust_Account_Grp_Descr__c = :'Sold-to party')]; 
    
		map<id, Account> accsRel=new map <id, Account>();
		list<Account> accsRel2=new list<Account>();
		for (Action_Plan_Line__c newAPL: listAPL)
		{
			if(newAPL.RecordTypeID==rt)   
			{

				integer month=integer.valueOf(string.valueOf(newAPL.PICK_Period__c).right(2));
				integer year=0;

				if(month<9)
				{
					year=integer.valueOf(string.valueOf(newAPL.PICK_Period__c).left(4));
				}
				else year=integer.valueOf(string.valueOf(newAPL.PICK_Period__c).left(4)) + 1;
            
				if(newAPL.LKP_Account__r.Forecasted_Year__c==null ) 
				{
					newAPL.LKP_Account__r.Forecasted_Year__c=string.valueOF(year)+ ';';
					accsRel.put(newAPL.LKP_Account__r.id,newAPL.LKP_Account__r);
				}
				else if(newAPL.LKP_Account__r.Forecasted_Year__c.contains(string.valueOF(year))==false)
				{
					newAPL.LKP_Account__r.Forecasted_Year__c=newAPL.LKP_Account__r.Forecasted_Year__c + string.valueOF(year)+ ';';
					accsRel.put(newAPL.LKP_Account__r.id,newAPL.LKP_Account__r);
				}
			}
		}

		update accsRel.values();
	}
}