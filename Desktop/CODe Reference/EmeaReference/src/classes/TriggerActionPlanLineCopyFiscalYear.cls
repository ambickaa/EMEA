public with sharing class TriggerActionPlanLineCopyFiscalYear implements Triggers.Handler 
{
    
    public void handle()
    {
        Decimal fiscalYear;
        Integer month, quarter, cont;
        Boolean isCurrentFY;
        String nextPeriod, nextQuarter, externalId;
        List<Action_Plan_Line__c> listApl = new List<Action_Plan_Line__c>();
        List<Id> listProducts = new List<Id>();
        List<Id> listAccounts = new List<Id>();
        map<Id, Action_Plan_Line__c> mapActionPlanLine = new map<Id, Action_Plan_Line__c>();
        map<String, Action_Plan_Line__c> mapExistingActionPlanLine = new map<String, Action_Plan_Line__c>();
        
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        
        Country__c country =  new Country__c();
        if(currentUser.Country != null) 
        {
        try
            {
            country = [SELECT Id, Units_of_Measurement__c FROM Country__c WHERE Name =: currentUser.Country];
            }
        catch(Exception e)
            {
            country.Units_of_Measurement__c = 'Basic Units';
            }
        }
        
        for(Action_Plan_Line__c apl : (list<Action_Plan_Line__c>)trigger.new)
        {
            if(apl.RecordTypeId == Util.recordType.get('Action_Plan_Line__c:Action_Plan_Line'))
            {
                mapActionPlanLine.put(apl.Id, apl);
                listProducts.add(apl.LKP_SKU__c);
                listAccounts.add(apl.LKP_Account__c);
            }
        }
        
        //Account Category
        Map<Id, Account> mapAccountCategory = new Map<Id, Account>([SELECT Id, GC_Cust_Account_Grp_Descr__c FROM Account WHERE Id IN :listAccounts]);
        
        //Existing Action Plan Line
        for(Action_Plan_Line__c apl : [SELECT Id, TXT_External_ID__c, LKP_SKU__c, LKP_Account__c, NUM_Ordered__c, NUM_Delivered__c FROM Action_Plan_Line__c WHERE LKP_SKU__c IN :listProducts AND LKP_Account__c IN :listAccounts])
        {
            mapExistingActionPlanLine.put(apl.TXT_External_ID__c, apl);
        }        
        
        //Action Plan Line Inserted
        for(Action_Plan_Line__c apl : mapActionPlanLine.values())
        {
            //Calculate counter
            cont = 0;
            //DISTRIBUTOR
            if(mapAccountCategory.get(apl.LKP_Account__c).GC_Cust_Account_Grp_Descr__c == 'Sold-to party')
            {
                month = Integer.valueOf(apl.FRML_Period_Month__c);
                fiscalYear = apl.FRML_Get_FY__c;
                //Acion Plan Line period is in FY?
                if(month >= 1 && month <= 8)
                {
                    if(fiscalYear == System.Date.today().year())
                    {
                        cont = 8 - month;
                    }
                }
                else if(month > 8 && month <= 12)
                {
                    if(fiscalYear - 1 == System.Date.today().year())
                    {
                        cont = 12 - month + 8;
                    }
                }
                
                //Calculate next periods
                for(Integer i = 0; i < cont; ++i)
                {
                    if((month >= 1 && month < 8) && (fiscalYear == System.Date.today().year()))
                    {
                        nextPeriod = String.valueOf(fiscalYear) + '-' + '0' + String.valueOf(month + i);
                    }
                    else if((month > 8 && month <= 12) && (fiscalYear - 1 == System.Date.today().year()))
                    {
                        if(month + i > 12) nextPeriod = String.valueOf(fiscalYear) + '-' + '0' + String.valueOf(month + i - 12);              
                        else nextPeriod = String.valueOf(fiscalYear - 1) + '-' + String.valueOf(month + i);                          
                    }
                    externalId = string.valueOf(apl.LKP_Account__c).substring(0,15) + '-' + string.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + nextPeriod;
                    
                    if(mapExistingActionPlanLine.get(externalId) == null)
                    {
                        Action_Plan_Line__c ac = new Action_Plan_Line__c();
                        ac.TXT_External_ID__c = externalId;
                        ac.PICK_Period__c = nextPeriod;
                        if(currentUser.Country != null && country.Units_of_Measurement__c == 'Basic Units') ac.NUM_Forecast__c = apl.NUM_Forecast__c;
                            else if(country.Units_of_Measurement__c != null) ac.NUM_Forecast_Rel__c = apl.NUM_Forecast_Rel__c;
                        ac.LKP_SKU__c = apl.LKP_SKU__c;
                        ac.LKP_Account__c = apl.LKP_Account__c;
                        listApl.add(ac);
                    }
                }
                
            }
            //PoS
            else if(mapAccountCategory.get(apl.LKP_Account__c).GC_Cust_Account_Grp_Descr__c == 'Ship-to party')
            {
                if(apl.FRML_CHK_Is_Current_FY__c)
                {
                    quarter = Integer.valueOf(apl.PICK_Quarter__c.substring(6,7));
                }
                else
                {
                    quarter = 4;
                }
                for(Integer i = 1; i <= 4 - quarter; i++)
                {
                    nextQuarter = 'FY' + apl.PICK_Quarter__c.substring(2,4) + ' ' + 'Q' + String.valueOf(quarter + i);
                    externalId = string.valueOf(apl.LKP_Account__c).substring(0,15) + '-' + string.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + nextQuarter;
                    
                    if(mapExistingActionPlanLine.get(externalId) == null)
                    {
                        Action_Plan_Line__c ac = new Action_Plan_Line__c();
                        ac.TXT_External_ID__c = externalId;
                        ac.PICK_Quarter__c = nextQuarter;
                        if(currentUser.Country != null && country.Units_of_Measurement__c == 'Basic Units') ac.NUM_Forecast__c = apl.NUM_Forecast__c;
                            else if(country.Units_of_Measurement__c != null) ac.NUM_Forecast_Rel__c = apl.NUM_Forecast_Rel__c;
                        ac.LKP_SKU__c = apl.LKP_SKU__c;
                        ac.LKP_Account__c = apl.LKP_Account__c;
                        listApl.add(ac);
                    }
                }
            }
        }
        //System.debug('New list to upsert: '+listApl);
        Database.upsert(listApl, Action_Plan_Line__c.Fields.TXT_External_ID__c, false);                           
    }
}