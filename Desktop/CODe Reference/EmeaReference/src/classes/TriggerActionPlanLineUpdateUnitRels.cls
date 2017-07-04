public with sharing class TriggerActionPlanLineUpdateUnitRels implements Triggers.Handler 
{   
    private Product2 p;
    public static Country__c country;
    
    public void handle()
    {
        Set<Id> productsId = new Set<Id>();
        for (Action_Plan_Line__c aplp :  (list<Action_Plan_Line__c>)trigger.new) 
            {
                if (aplp.RecordTypeId == Util.recordType.get('Action_Plan_Line__c:Action_Plan_Line') && aplp.LKP_SKU__c != null && aplp.LKP_account__c != null)
                {
                    if (aplp.PICK_Period__c != null)
                    {
                        aplp.txt_external_id__c = string.valueOf(aplp.LKP_Account__c).substring(0,15) + '-' + string.valueOf(aplp.LKP_SKU__c).substring(0,15) + '-' + aplp.PICK_Period__c;
                    }
                    else if(aplp.PICK_Quarter__c != null)
                    {
                        aplp.txt_external_id__c = string.valueOf(aplp.LKP_Account__c).substring(0,15) + '-' + string.valueOf(aplp.LKP_SKU__c).substring(0,15) + '-' + aplp.PICK_Quarter__c;
                    }
                }
                
                if (aplp.LKP_SKU__c != null) productsId.add(aplp.LKP_SKU__c);        
            }
        // Handy special map constructor
        Map<Id, Product2> products = new Map<Id, Product2>([select Id, DE_RelFactor__c from Product2 where Id in :productsId]);

        if(Util.currentUser.Country != null && country == null) 
        {
            try
            {
                country = [SELECT Id, Units_of_Measurement__c FROM Country__c WHERE Name =: Util.currentUser.Country];
            }
            catch(Exception e)
            {
                country.Units_of_Measurement__c = 'Basic Units';
            }
        }
         
        for(Action_Plan_Line__c apl :  (list<Action_Plan_Line__c>)trigger.new)
        {           
            if (apl.LKP_SKU__c !=null) p = products.get(apl.LKP_SKU__c);
            
            //27-06-2016 Support Team - add new validation for products not included in catalog
            if(Util.currentUser.Country != null && country.Units_of_Measurement__c == 'Basic Units' && p!=null)
            {
                if(p.DE_RelFactor__c == 0 || p.DE_RelFactor__c == null)
                {                
                    p.DE_RelFactor__c = 1;
                }
                
                if(apl.RecordTypeId == Util.recordType.get('Action_Plan_Line__c:CP_Forecast'))
                {
                    apl.NUM_Forecast_SKU_Rel__c = apl.NUM_Forecast_SKU__c != null ? apl.NUM_Forecast_SKU__c * p.DE_RelFactor__c : null;
                }    
                else if(apl.RecordTypeId == Util.recordType.get('Action_Plan_Line__c:Action_Plan_Line'))
                {
                    apl.NUM_Forecast_Rel__c = apl.NUM_Forecast__c != null ? apl.NUM_Forecast__c * p.DE_RelFactor__c : null;
                    apl.NUM_Final_stock_Rel__c = apl.NUM_Final_stock__c != null ? apl.NUM_Final_stock__c * p.DE_RelFactor__c : null;
                }
                else if(apl.RecordTypeId == Util.recordType.get('Action_Plan_Line__c:CP_Budget'))
                {
                    apl.NUM_Budget_Rel__c = apl.NUM_Budget__c != null ? apl.NUM_Budget__c * p.DE_RelFactor__c : null;
                }
            }
            //27-06-2016 Support Team - add new validation for products not included in catalog
            else if(Util.currentUser.Country != null && country.Units_of_Measurement__c == 'Rels' && p!=null)
            {
                if(p.DE_RelFactor__c == 0 || p.DE_RelFactor__c == null)
                {
                    p.DE_RelFactor__c = 1;
                }

                if(apl.RecordTypeId == Util.recordType.get('Action_Plan_Line__c:CP_Forecast'))
                {
                    apl.NUM_Forecast_SKU__c = apl.NUM_Forecast_SKU_Rel__c != null ? apl.NUM_Forecast_SKU_Rel__c / p.DE_RelFactor__c : null;
                }
                else if(apl.RecordTypeId == Util.recordType.get('Action_Plan_Line__c:Action_Plan_Line'))
                {
                    apl.NUM_Forecast__c = apl.NUM_Forecast_Rel__c != null ? apl.NUM_Forecast_Rel__c / p.DE_RelFactor__c : null;
                    apl.NUM_Final_stock__c = apl.NUM_Final_stock_Rel__c != null ? apl.NUM_Final_stock_Rel__c / p.DE_RelFactor__c : null;
                }
                else if(apl.RecordTypeId == Util.recordType.get('Action_Plan_Line__c:CP_Budget'))
                {
                    apl.NUM_Budget__c = apl.NUM_Budget_Rel__c != null ? apl.NUM_Budget_Rel__c / p.DE_RelFactor__c : null;
                }
            }
        }
    }
}