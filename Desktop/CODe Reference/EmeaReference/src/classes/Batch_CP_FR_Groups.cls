//-------------
//Created by Support Team.
//
//This batch aggregates data (orders and delivered quantities) coming from APL at Purchasing Group level (account influencer filled at FR Distributors).
//----------------

global  with sharing class Batch_CP_FR_Groups implements Database.batchable<sObject>{
    
    global String AccountsQuery;

    global Batch_CP_FR_Groups(String q)
    {
        AccountsQuery = q;
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(AccountsQuery);
    }
    
    global void execute(Database.BatchableContext BC,list<Account> scope)
    { 
        map<Id,Account> accsMap=new map<Id,Account>();
        for(Account acc:scope)
        {
            accsMap.put(acc.Id,acc);
        }
        system.debug('Accounts list: ' + accsMap.values());
        
        List<Action_Plan_Line__c> listAPL = new List<Action_Plan_line__c>();
        map<string,Action_Plan_Line__c> mapAPL = new map<string,Action_Plan_Line__c>(); //map for APL with keyset defined as ExternalId
        
        listAPL = [SELECT id, LKP_Account__c, LKP_Account__r.Influencer__c, PICK_Period__c, LKP_SKU__c, NUM_Forecast__c, NUM_Final_stock__c, NUM_Ordered__c, num_delivered__c from action_plan_line__c where lkp_account__c in:scope and FRML_Period_Date__c>= LAST_FISCAL_YEAR];
        for(Action_Plan_Line__c item : listAPL)
        {
            system.debug('APL: ' + item);
            Action_Plan_Line__c apl = new Action_Plan_Line__c();
            apl.LKP_Account__c = item.LKP_Account__r.Influencer__c;
            apl.LKP_SKU__c = item.LKP_SKU__c;       
            apl.PICK_Period__c = item.PICK_Period__c;
            apl.TXT_External_ID__c = String.valueOf(apl.LKP_Account__c).substring(0,15) + '-' + String.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + apl.PICK_Period__c; 
            apl.NUM_Ordered__c = item.NUM_Ordered__c;
            apl.NUM_Delivered__c = item.NUM_Delivered__c;

            if((apl.NUM_Ordered__c != null && apl.NUM_Ordered__c > 0) || (apl.NUM_Delivered__c != null && apl.NUM_Delivered__c > 0))
            {
                if(!mapAPL.containsKey(apl.TXT_External_ID__c))
                {
                	mapAPL.put(apl.TXT_External_ID__c, apl);
                }
                else
                {
                	if(apl.NUM_Ordered__c != null && apl.NUM_Ordered__c > 0)
                	{
	                	if(mapAPL.get(apl.TXT_External_ID__c).NUM_Ordered__c == null)
	                    	mapAPL.get(apl.TXT_External_ID__c).NUM_Ordered__c = apl.NUM_Ordered__c;
	                    else
	                    	mapAPL.get(apl.TXT_External_ID__c).NUM_Ordered__c += apl.NUM_Ordered__c;
                	}
                    
                	if(apl.NUM_Delivered__c != null && apl.NUM_Delivered__c > 0)
                	{
	                    if(mapAPL.get(apl.TXT_External_ID__c).NUM_Delivered__c == null)
	                    	mapAPL.get(apl.TXT_External_ID__c).NUM_Delivered__c = apl.NUM_Delivered__c;
	                    else
	                    	mapAPL.get(apl.TXT_External_ID__c).NUM_Delivered__c += apl.NUM_Delivered__c;
                	}
                }
            }
        }   

        Database.upsert(mapAPL.values(), Action_Plan_Line__c.Fields.TXT_External_ID__c, false);           
    }
    global void finish(Database.BatchableContext BC){}
    
}