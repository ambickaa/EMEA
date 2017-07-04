public with sharing class TriggerActionPlanLineInitialStockControl implements Triggers.Handler 
{
    public void handle()
    {
        map<String, Action_Plan_Line__c> mapActionPlanLine = new map<String, Action_Plan_Line__c>();

        list<Action_Plan_Line__c> listupsertActionPlanLines = new list<Action_Plan_Line__c>();
        String actualPeriod, actualQuarter;
        Boolean validQuarter = false;
        
        //Update Action Plan Line Previous Periods
        for(Action_Plan_Line__c apl : (list<Action_Plan_Line__c>)trigger.new)
        {
            
            //Check valid quarter
            if(String.isEmpty(apl.PICK_Quarter__c) != true)
            {
                if(Integer.valueof(System.Date.today().month()) >= 9 && Integer.valueof(System.Date.today().month()) < 12) actualQuarter = 'Q1';
                else if(Integer.valueof(System.Date.today().month()) == 12 || Integer.valueof(System.Date.today().month()) < 3) actualQuarter = 'Q2';
                else if(Integer.valueof(System.Date.today().month()) >= 3 && Integer.valueof(System.Date.today().month()) < 6) actualQuarter = 'Q3';
                else if(Integer.valueof(System.Date.today().month()) >= 6 && Integer.valueof(System.Date.today().month()) < 9) actualQuarter = 'Q4';
                
                if(String.valueof(apl.PICK_Quarter__c).substring(5,7) <= actualQuarter) validQuarter = true;
                else validQuarter = false;
            }

            //Check prior periods OR prior quarter
            if(apl.FRML_CHK_Is_Current_YTD__c && apl.FRML_CHK_Is_Current_FY__c || validQuarter )
            {
                if(apl.NUM_Final_stock__c != ((Action_Plan_Line__c)trigger.oldMap.get(apl.Id)).NUM_Final_stock__c)
                {
                    Action_Plan_Line__c aplNew = new Action_Plan_Line__c();
                    //DISTRIBUTORS
                    if(String.isEmpty(apl.PICK_Period__c) != true)
                    {
                        aplNew.LKP_Account__c = apl.LKP_Account__c;
                        aplNew.LKP_SKU__c = apl.LKP_SKU__c;
                        aplNew.NUM_Initial_stock__c = apl.NUM_Final_stock__c;                        
                        if(apl.PICK_Period__c.substring(5,7) == '12') aplNew.PICK_Period__c = String.valueOf(apl.FRML_Get_FY__c) + '-' + '01';
                        else 
                            {
                            if (Integer.valueOf(apl.PICK_Period__c.substring(5,7)) <= 8) aplNew.PICK_Period__c = String.valueOf(apl.PICK_Period__c.substring(0,4)) + '-' + '0' + String.valueOf(Integer.valueOf(apl.PICK_Period__c.substring(5,7)) + 1);                            
                            else aplNew.PICK_Period__c = String.valueOf(apl.PICK_Period__c.substring(0,4)) + '-' + String.valueOf(Integer.valueOf(apl.PICK_Period__c.substring(5,7)) + 1);
                            }                        
                        aplNew.TXT_External_ID__c = string.valueOf(apl.LKP_Account__c).substring(0,15) + '-' + string.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + aplNew.PICK_Period__c;                        
                        
                    }
                    //PoS
                    else if(String.isEmpty(apl.PICK_Quarter__c) != true)
                    {
                        aplNew.LKP_Account__c = apl.LKP_Account__c;
                        aplNew.LKP_SKU__c = apl.LKP_SKU__c;
                        aplNew.NUM_Initial_stock__c = apl.NUM_Final_stock__c;
                                                
                        if(Integer.valueOf(apl.PICK_Quarter__c.substring(6,7)) + 1 == 5) aplNew.PICK_Quarter__c = 'FY' + String.ValueOf(Integer.ValueOf(apl.FRML_Quarter_Date__c) + 1) + ' ' + 'Q1';
                        else aplNew.PICK_Quarter__c = String.ValueOf(apl.PICK_Quarter__c).substring(0,6) + String.valueOf(Integer.valueOf(apl.PICK_Quarter__c.substring(6,7)) + 1);
                        
                        aplNew.TXT_External_ID__c = String.valueOf(apl.LKP_Account__c).substring(0,15) + '-' + String.valueOf(apl.LKP_SKU__c).substring(0,15) + '-' + aplNew.PICK_Quarter__c;
                    }

                    listupsertActionPlanLines.add(aplNew); 

                }
            }                   
        }

        Database.upsert(listupsertActionPlanLines, Action_Plan_Line__c.Fields.TXT_External_ID__c, false);

    }
}