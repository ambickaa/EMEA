/**
* Contains code to perform summarizing Campaign Line Item fields to Campaing.
*/
public  class CampaignTriggerHelper
{
    /**
    * General mapping fot parent-child pairs for summarizing.
    */
    private static final Map<String, String> CAMPAIGN_CLI_MAPPING = new Map<String, String> {'TotalAllocatedBudget__c' => 'Quantity__c'};
    
    /**
    * Updates Campaing summary fields that are related to CLI
    */
    public static void updateCLIFields(Set<Id> theCampaignIds)
    {
        CLISummary aSummary = new CLISummary();
        aSummary.updateObjects(theCampaignIds);
    }
    
    class CLISummary extends TriggerHelper.CommonSummary
    {
        protected override sObject performCalculation(sObject theParent, List<sObject> theChildList)
        {

            Campaign aCampaign = (Campaign) theParent;
            aCampaign.TotalAllocatedCharged__c = 0;
            aCampaign.TotalAllocatedFOC__c = 0;
            aCampaign.TotalForecastCharged__c = 0;
            aCampaign.TotalForecastFOC__c = 0;
            aCampaign.TotalAgreedCharged__c = 0;
            aCampaign.TotalAgreedFOC__c = 0;
            aCampaign.TotalSalesCharged__c = 0;
            aCampaign.TotalSalesFOC__c = 0;
            aCampaign.NUM_TotalAllocatedDist__c = 0;
            aCampaign.NUM_TotalForecastDist__c = 0;
            aCampaign.NUM_TotalAgreedDist__c = 0;
            aCampaign.NUM_TotalSalesDist__c = 0;
            
            for (CampaignLineItem__c anItem: (List<CampaignLineItem__c>)theChildList)
            {
                Boolean anIsCharged = anItem.Type__c == 'Charged';
                Boolean anIsFOC = anItem.Type__c == 'Free of charge';
                System.debug('anIsCharged:' + anIsCharged + ';anIsFOC:' + anIsFOC);
                Boolean anIsSales = anItem.Status__c == 'Confirmed';
                Boolean anIsAgreed = anItem.Status__c == 'Ordered / Discussed';
                Boolean anIsForecast = anItem.Status__c == 'Forecast';

                if(anItem.FarmRef__c != null && anItem.FarmRef__r.CountryID__c != null && 
                   CountryAdapter.COUNTRY_CODE_MAP.get(CountryAdapter.allCountryMap.get(anItem.FarmRef__r.CountryID__c).Name) == CountryAdapter.CountryEnum.southAfrica){
                   System.debug('My debug 1');
                   Decimal aQuantity = anItem.Quantity__c == null ? 0 : anItem.Quantity__c;
                   Decimal aForecast = anItem.Forecast__c == null ? 0 : anItem.Forecast__c; 
                   Decimal anAgreed = anItem.Agreed__c == null ? 0 : anItem.Agreed__c;
                   Decimal aPOG = anItem.POG__c == null ? 0 : anItem.POG__c;
                   if (anIsCharged)
                   {
                       aCampaign.TotalAllocatedCharged__c += aQuantity;
                       aCampaign.TotalForecastCharged__c += aForecast;
                       aCampaign.TotalAgreedCharged__c += anAgreed;
                       aCampaign.TotalSalesCharged__c += aPOG;
                   } else if (anIsFOC)
                   {
                       aCampaign.TotalAllocatedFOC__c += aQuantity;
                       aCampaign.TotalForecastFOC__c += aForecast;
                       aCampaign.TotalAgreedFOC__c += anAgreed;
                       aCampaign.TotalSalesFOC__c += aPOG;
                   }
                }else{
                
                //Germany (Farms are not taken into account for the budged)
                CountryAdapter country = new CountryAdapter(anItem.FarmRef__r.CountryRef__c);
                //Fix campaign summary issue (CR-00000142)
                if (!(country.isGermanActionPlan) ||(!(anItem.FarmRef__r.RecordTypeId == Util.recordType.get('Account:GroupFarmSite')) && !Util.currentUser.Is_Promoter__c ) || ((anItem.FarmRef__r.RecordTypeId == Util.recordType.get('Account:GroupFarmSite')) && Util.currentUser.Is_Promoter__c)){
                //Germany  -
                  //System.debug('Quantity from CLI: ' + anItem.Quantity__c); 
                  Decimal aQuantity = anItem.Quantity__c == null ? 0 : anItem.Quantity__c;
                  Decimal aForecast = anItem.Forecast__c == null ? 0 : anItem.Forecast__c; 
                  Decimal anAgreed = anItem.Agreed__c == null ? 0 : anItem.Agreed__c;
                  Decimal aPOG = anItem.POG__c == null ? 0 : anItem.POG__c;

                    //Campaign Summary fields for Distributors (CR-00000142)
                    if (anItem.FarmRef__r.RecordTypeId == Util.recordType.get('Account:DistRetPoS') && (CountryAdapter.COUNTRY_CODE_MAP.get(CountryAdapter.allCountryMap.get(anItem.FarmRef__r.CountryID__c).Name) != CountryAdapter.CountryEnum.france 
                      && CountryAdapter.COUNTRY_CODE_MAP.get(CountryAdapter.allCountryMap.get(anItem.FarmRef__r.CountryID__c).Name) != CountryAdapter.CountryEnum.germany))
                    {
                        aCampaign.NUM_TotalAllocatedDist__c += aQuantity;
                        aCampaign.NUM_TotalForecastDist__c += aForecast;
                        aCampaign.NUM_TotalAgreedDist__c += anAgreed;
                        aCampaign.NUM_TotalSalesDist__c += aPOG;
                    }

                    else if (anItem.ProductRef__c != null && anItem.ProductRef__r.ProductVendor__c != null && anItem.ProductRef__r.ProductVendor__r.RecordTypeId == Util.recordType.get('Account:DistRetPoS'))
                    {
                        if (anIsCharged)
                        {
                            aCampaign.TotalAllocatedCharged__c += aQuantity;
                            aCampaign.TotalForecastCharged__c += aForecast;
                            aCampaign.TotalAgreedCharged__c += anAgreed;
                            aCampaign.TotalSalesCharged__c += aPOG;
                        } else if (anIsFOC)
                        {
                            aCampaign.TotalAllocatedFOC__c += aQuantity;
                            aCampaign.TotalForecastFOC__c += aForecast;
                            aCampaign.TotalAgreedFOC__c += anAgreed;
                            aCampaign.TotalSalesFOC__c += aPOG;
                        }
                    }
                }
              }
            }
            return aCampaign;
        }
        
        public CLISummary()
        {
            super('Campaign', 'TacticalPlanElements__r', new List<String>{'Id'}, new List<String> {'Quantity__c',
                      'Type__c', 'ProductRef__c', 'Status__c', 'ProductRef__r.ProductVendor__c',
                      'ProductRef__r.ProductVendor__r.RecordTypeId', 'Forecast__c', 'Agreed__c', 'POG__c', 
                      'FarmRef__c', 'FarmRef__r.CountryID__c', 'FarmRef__r.CountryRef__c' ,'FarmRef__r.RecordTypeId'});
        }
    }
}