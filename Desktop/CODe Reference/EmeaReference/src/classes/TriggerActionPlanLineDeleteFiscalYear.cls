public with sharing class TriggerActionPlanLineDeleteFiscalYear implements Triggers.Handler 
{
    public void handle()
    {
        Decimal fiscalYear;
        Integer month, cont;
        String nextPeriod, nextQuarter, quarter, category;
        List<String> listExternalsId;
        String externalId;
        List<Id> listAccount = new List<Id>();
        List<Id> listProduct = new List<Id>();
        List<Action_Plan_Line__c> listDeletingActionPlan = new List<Action_Plan_Line__c>();        
        map<Id, Action_Plan_Line__c> mapActionPlanLine = new map<Id, Action_Plan_Line__c>();
        map<String, Action_Plan_Line__c> mapExistingActionPlanLine = new map<String, Action_Plan_Line__c>();

        //Action Plan deleted
        for(Action_Plan_Line__c apl : (list<Action_Plan_Line__c>)trigger.old)
        {
            mapActionPlanLine.put(apl.Id, apl);
            listAccount.add(apl.LKP_Account__c);
            listProduct.add(apl.LKP_SKU__c);
        }  
        
        for(Action_Plan_Line__c apl :[SELECT Id, TXT_External_Id__c FROM Action_Plan_Line__c WHERE LKP_Account__c IN :listAccount AND LKP_SKU__c IN :listProduct])
        {
            mapExistingActionPlanLine.put(apl.TXT_External_Id__c, apl);
        }   
        
        Decimal todayFiscalYear = (System.Date.today().month()<9)?System.Date.today().year():System.Date.today().year()+1;
        
        for(Action_Plan_Line__c apl :mapActionPlanLine.values())
        {
            //DISTRIBUTOR
            if(apl.FRML_Period_Month__c != null)
            {
                if(apl.FRML_Period_Month__c.length() != 0)
                {
                    month = Integer.valueOf(apl.FRML_Period_Month__c);
                    fiscalYear = apl.FRML_Get_FY__c;
                    category = 'Distributor';
                    
                    if(month >= 1 && month <= 8) cont = 8 - month;
                    else if(month >= 9 && month <= 12) cont = 12 - month + 8;
                }
            }
            //PoS
            else if(apl.PICK_Quarter__c != null)
            {           
                if(apl.PICK_Quarter__c.length() != 0)
                {                         
                    quarter = apl.TXT_Quarter_Group_WF__c;
                    if(apl.FRML_Quarter_Date__c == String.valueOf(todayFiscalYear).substring(2,4))
                    {   
                        category = 'PoS';
                        fiscalYear = todayFiscalYear;
                        cont = 4 - Integer.valueOf(quarter);
                    }
                }
            }
                        
            if(todayFiscalYear == fiscalYear)
            {             
                for(Integer i = 1; i <= cont; i++)
                {                    
                    //DISTRIBUTOR
                    if(category == 'Distributor')
                    {
                        if((month >= 1 && month <= 8) && (fiscalYear == System.Date.today().year() + 1))
                        {
                            nextPeriod = String.valueOf(fiscalYear) + '-' + '0' + String.valueOf(month + i);
                            externalId = String.valueOf(apl.LKP_Account__c).substring(0,15) + '-' + String.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + nextPeriod;
                        }
                        else if((month > 8 && month <= 12) && (fiscalYear - 1 ==  System.Date.today().year()))
                        {
                            if(month + i <= 12) nextPeriod = String.valueOf(fiscalYear-1) + '-' + String.valueOf(month + i);
                            else if(month + i > 12) nextPeriod = String.valueOf(fiscalYear) + '-' + '0' + String.valueOf(math.mod(month + i,12));
                            externalId = String.valueOf(apl.LKP_Account__c).substring(0,15) + '-' + String.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + nextPeriod;
                        }
                    }
                    //PoS
                    else if(category == 'PoS')
                    {                        
                        nextQuarter = 'FY' + apl.FRML_Quarter_Date__c + ' ' + 'Q' + String.ValueOf(Integer.valueOf(apl.TXT_Quarter_Group_WF__c) + i);                        
                        externalId = String.valueOf(apl.LKP_Account__c).substring(0,15) + '-' + String.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + nextQuarter;
                    }
                    //Existing Action Plan to be deleted
                    if(mapExistingActionPlanLine.get(externalId) != null)
                    {
                        listDeletingActionPlan.add(mapExistingActionPlanLine.get(externalId));
                    }
                }
            } 
        }
        
        delete listDeletingActionPlan;   
    }   
}