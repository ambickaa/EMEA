/**
* Contains useful methods to work with account object.
*/
public class AccountTriggerHelper
{
    public static final String RECORDTYPE_ACCOUNT_COMPETITOR = 'Account:Competitor';
    public static final String RECORDTYPE_ACCOUNT_DISTRIBUTOR = 'Account:DistRetPoS';
    
    /**
    * This method performs summary fields calculation for CampaignLineItems fields
    * CornTotalSalesCY__c - Corn CLI from current campaign 
    * CornTotalSalesPY__c  - Corn CLI from previous campaign 
    * OSRTotalSalesCY__c  - OSR CLI from current campaign 
    * OSRTotalSalesPY__c - OSR CLI from previous campaign 
    * CPTotalSalesCY__c - CP CLI from current campaign 
    * CPTotalSalesPY__c - CP CLI from previous campaign 
    */
    public static void updateSummaryCampaignLineItem(Set<Id> theAccountIdList)
    {
        CampaignLineItemSummary aSummary = new CampaignLineItemSummary();
        aSummary.updateObjects(theAccountIdList);
    }
    
    public static void updateSummaryAcreages(Set<Id> theAccountIdList)
    {
        AcreagesSummary aSummary = new AcreagesSummary();
        aSummary.updateObjects(theAccountIdList);
    }
    
    public class AccountBatchManager
    {
        /*
            @description Update related Farm Account records without changes regarding Year
        */
        public void updateFarms()
        {
            executeUpdateBatch(false);
        }
        
        /*
            @description Update related Farm Account records with changes regarding Year
        */
        public void updateFarmsChangeYear()
        {
            executeUpdateBatch(true);
        }
        public void updateDistributorsChangeYear(){
            al.AndCondition aResCondition = new al.AndCondition();
            aResCondition.add(new al.FieldCondition('RecordTypeId', Util.recordType.get('Account:DistRetPoS')));
            AccountUpdateBatchable distBatch = new AccountUpdateBatchable(aResCondition);
            distBatch.changeYear = true;
            runUpdates(distBatch);
        }
        
        /*
            @description Run Batch method for update related Account records with parameter for changes Year
        */
        public void executeUpdateBatch(Boolean theChangeYear)
        {
            al.AndCondition aResCondition = new al.AndCondition();
            aResCondition.add(new al.FieldCondition('RecordTypeId', Util.recordType.get('Account:GroupFarmSite')));
            AccountUpdateBatchable aBatch = new AccountUpdateBatchable(aResCondition);
            aBatch.changeYear = theChangeYear;
            runUpdates(aBatch);
        }
        
        /*
            @description Run Batch method for update related Account records when attch CampaignLineItem
        */
        public void updateFarmsByCampaignLineItem(Set<Id> theAccountIdSet)
        {
            al.SoqlBuilder aEntryBuilder = new al.SoqlBuilder().selectx('Id').fromx('TacticalPlanElements__r').limitx(1);
            al.SoqlBuilder aMainBuilder = new al.SoqlBuilder()
                      .selectx(new List<String>{'Id', '(' + aEntryBuilder.toSOQL() + ')'})
                      .fromx('Account')
                      .wherex(new al.SetCondition('Id', al.Operator.INX, new List<Id>(theAccountIdSet)));
            
            al.OrCondition aCondition = new al.OrCondition();
            aCondition.add(new al.SetCondition('ParentId', al.Operator.INX, new List<Id>(theAccountIdSet)));
            aCondition.add(new al.SetCondition('Id', al.Operator.INX, new List<Id>(theAccountIdSet)));
            aCondition.add(new al.SetCondition('Parent.ParentId', al.Operator.INX, new List<Id>(theAccountIdSet)));
            al.SoqlBuilder aBuilder = new al.SoqlBuilder().selectx(new List<String>{'Id', 'Parent.Id', 'Parent.Parent.Id'})
                      .fromx('Account').wherex(aCondition);
            
            system.debug('*** aBuilder: '+aBuilder );
            
            List<Account> anAccountMainList = (List<Account>)Database.query(aMainBuilder.toSOQL());
            List<Account> anAccountList = (List<Account>)Database.query(aBuilder.toSOQL());
            
            system.debug('*** anAccountList : '+anAccountList );
            
            Map<Id, Boolean> anAccountFlagMap = new Map<Id, Boolean>();
            for (Account anAccount : anAccountMainList)
            {
                anAccountFlagMap.put(anAccount.Id, !anAccount.TacticalPlanElements__r.isEmpty());
            }
            
            /* 18/02/2015 INI Due to error having duplicated ID in list: Build Set controlling which values of the list are included*/
            /*Set<Account> anAccountSet = new Set<Account>(anAccountList);*/
            Set<Account> anAccountSet = new Set<Account>();
            for (Account anAccount : anAccountList)
            {            
                if (anAccountFlagMap.get(anAccount.id) == true)
                {
                    anAccountSet.add(anAccount);
                    if (anAccount.ParentId != null)
                    {
                        anAccountSet.add(anAccount.Parent);
                    }
                    if (anAccount.Parent.ParentId != null)
                    {
                        anAccountSet.add(anAccount.Parent.Parent);
                    }                   
                }
            }            
            system.debug('*** anAccountSet1 : '+anAccountSet );        
            /* 18/02/2015 FIN */            

            for (Account anAccount : anAccountList)
            {
                Boolean anGetAccountFlag = anAccountFlagMap.get(anAccount.id);
                if (anGetAccountFlag != null)
                {
                    anAccount.IsCreateCampaignLineItem__c = false;
                    
                    if (anAccount.ParentId != null)
                    {
                        anAccount.Parent.IsCreateCampaignLineItem__c = anGetAccountFlag;
                        anAccountSet.add(anAccount.Parent);
                    }
                    
                    if (anAccount.Parent.ParentId != null)
                    {
                        anAccount.Parent.Parent.IsCreateCampaignLineItem__c = anGetAccountFlag;
                        anAccountSet.add(anAccount.Parent.Parent);
                    }
                }
                else
                {
                    anGetAccountFlag = anAccountFlagMap.get(anAccount.ParentId);
                    if (anGetAccountFlag != null)
                    {
                        anAccount.IsCreateCampaignLineItem__c = anGetAccountFlag;
                    }
                    
                    anGetAccountFlag = anAccountFlagMap.get(anAccount.Parent.ParentId);
                    if (anGetAccountFlag != null)
                    {
                        anAccount.IsCreateCampaignLineItem__c = anGetAccountFlag;
                    }
                }
            }
            /* 18/02/2015 INI Due to error having duplicated ID in list: Build List controlling not having duplicated values 
            Set<Account> auxSet = new Set<Account>();     
            List<Account> UpdateList = new List<Account>();
            for (Account a : anAccountSet) {
              if (auxSet.add(a)) {
                UpdateList.add(a);
              }
            }            
            system.debug('*** UpdateList: '+UpdateList);
            
            update UpdateList;*/            
            /*update new List<Account>(anAccountSet);*/
            /* 18/02/2015 FIN */
            /* COGNIZANT - 02/06/2017 INI Due to error having duplicated ID in list: Build List controlling not having duplicated values*/
            Map<Id,Account> updateMap = new Map<Id,Account>();     
            for (Account a : anAccountSet) 
            {
                updateMap.put(a.Id,a);
            }            
            system.debug('*** UpdateList: '+updateMap);
            update updateMap.values();
        }
        
        /*
            @description Update related Account records by CampaignLineItem records
        */
        public void updateFarmsByCampaigns(Set<Id> theCampaigns)
        {
            List<Id> aCamps = new List<Id>();
            aCamps.addAll(theCampaigns);
            
            al.SoqlBuilder aBuilder = new al.SoqlBuilder().selectx('FarmRef__c').fromx('CampaignLineItem__c')
                      .wherex(new al.SetCondition('CampaignRef__c',al.Operator.INX, aCamps ));
            List<CampaignLineItem__c> aCLIs = (List<CampaignLineItem__c>) Database.query(aBuilder.toSoql());
            Set<Id> anAccounts = new Set<Id>();
            for (CampaignLineItem__c aCLI: aCLIs)
            {
                anAccounts.add(aCLI.FarmRef__c);
            }
            if (anAccounts.size() < 1)
            {
                return;
            }
            List<Id> anAccs = new List<Id>();
            anAccs.addAll(anAccounts);
            al.AndCondition aResCondition = new al.AndCondition();
            aResCondition.add(new al.SetCondition('Id', al.Operator.INX, anAccs));
            aResCondition.add(new al.FieldCondition('RecordTypeId', Util.recordType.get('Account:GroupFarmSite')));
            AccountUpdateBatchable aBatch = new AccountUpdateBatchable(aResCondition);
            aBatch.changeYear = false;
            runUpdates(aBatch);
        }
        
        private void runUpdates(AccountUpdateBatchable theBatchable)
        {
            Database.executebatch(theBatchable, 10);
        }
    }
    
    /**
    * Class, that performs calculations for Account summary fields, that are related to CLI.
    */
    private class CampaignLineItemSummary extends TriggerHelper.CommonSummary
    {
        /**
        * General constructor.
        */
        public CampaignLineItemSummary()
        {
            super('Account', 'TacticalPlanElements__r', new List<String>{'Id','CountryRef__c'},
                     new List<String>{'CampaignRef__r.DivisionRef__r.Name', 'CampaignRef__r.StatusCode__c', 'CampaignRef__r.StartDate', 'CampaignRef__r.EndDate', 'POG__c', 
                      'ProductRef__r.DE_RelFactor__c', 'ProductRef__c', 'ProductRef__r.ProductVendor__c', 'ProductRef__r.ProductVendor__r.RecordTypeId', 
                      'ProductRef__r.NUM_UnitsPerSKU__c', 'Quantity__c', 'Forecast__c', 'ProductRef__r.ProductBagSize__c', 'PlantingDensity__c', 'Status__c', 'Forecast__c', 
                      'Agreed__c', 'Type__c'});
            childConditions = new al.AndCondition();
            childConditions.add(new al.FieldCondition('RecordType.DeveloperName', 'Sales'));
            childConditions.add(new al.FieldCondition('CampaignRef__r.StatusCode__c', al.Operator.GREATER_THAN_OR_EQUAL_TO, 200));
            childConditions.add(new al.FieldCondition('CampaignRef__r.StatusCode__c', al.Operator.LESS_THAN, 400));
        }

                /**
        * Performs calculations
        */
        protected override sObject performCalculation(sObject theParent, List<sObject> theChildren)
        {
            Account anAccount = (Account) theParent;
            
            anAccount.CornTotalSalesCY__c = 0;
            anAccount.CornTotalSalesPY__c = 0;
            anAccount.OSRTotalSalesCY__c = 0;
            anAccount.OSRTotalSalesPY__c = 0;
            anAccount.CPTotalSalesCY__c = 0;
            anAccount.CPTotalSalesPY__c = 0;
            anAccount.TotalCornSalesCompetitorCY__c = 0;
            anAccount.TotalCornSalesCompetitorPY__c = 0;
            anAccount.TotalOSRSalesCompetitorCY__c = 0;
            anAccount.TotalOSRSalesCompetitorPY__c = 0;
            anAccount.TotalCornTPMonsantoCY__c = 0;
            anAccount.TotalCornTPCompetitorCY__c = 0;
            anAccount.TotalOSRTPMonsantoCY__c = 0;
            anAccount.TotalOSRTPCompetitorCY__c = 0;
            anAccount.TotalCornTPMonsantoPY__c = 0;
            anAccount.TotalCornTPCompetitorPY__c = 0;
            anAccount.TotalOSRTPMonsantoPY__c = 0;
            anAccount.TotalOSRTPCompetitorPY__c = 0;
            anAccount.ForecastMTOCornSalesCY__c = 0;
            anAccount.AgreedMTOCornSalesCY__c = 0;
            anAccount.AgreedMTOCornSalesPY__c = 0;
            anAccount.NUM_ForecastCornTPMonsantoCY__c = 0;
            anAccount.NUM_AgreedCornTPMonsantoCY__c = 0;
            anAccount.NUM_ForecastCornTPMonsantoPY__c = 0;
            anAccount.NUM_AgreedCornTPMonsantoPY__c = 0;
            anAccount.NUM_ForecastOSRTPMonsantoCY__c = 0;
            anAccount.NUM_AgreedOSRTPMonsantoCY__c = 0;
            anAccount.NUM_ForecastOSRTPMonsantoPY__c = 0;
            anAccount.NUM_AgreedOSRTPMonsantoPY__c = 0;
            anAccount.NUM_AGREED_OSR_CY__c = 0;           
            anAccount.NUM_AGREED_OSR_PY__c = 0;
            anAccount.NUM_Agreed_OSR_FOC_CY__c =0;
            anAccount.NUM_Agreed_OSR_FOC_PY__c = 0;
            anAccount.NUM_AGREED_CORN_CHARGED_CY__c = 0;
            anAccount.NUM_AGREED_CORN_CHARGED_PY__c = 0;
            anAccount.NUM_AGREED_CORN_FOC_CY__c = 0;
            anAccount.NUM_AGREED_CORN_FOC_PY__c = 0;
            //Germany
            anAccount.DE_ForecastCornCY__c = 0;
            anAccount.DE_ForecastCornPY__c = 0; 
            anAccount.DE_ForecastCornFOCCY__c = 0;
            anAccount.DE_ForecastCornFOCPY__c = 0;
            anAccount.DE_POGCornCY__c = 0;
            anAccount.DE_POGCornFOCCY__c = 0;
            anAccount.DE_POGCornFOCPY__c = 0;
            anAccount.DE_POGCornPY__c = 0;
            anAccount.DE_ForecastOSRCY__c = 0;
            anAccount.DE_ForecastOSRFOCCY__c = 0;
            anAccount.DE_ForecastOSRFOCPY__c = 0;
            anAccount.DE_ForecastOSRPY__c = 0;
            anAccount.DE_POGOSRCY__c = 0;
            anAccount.DE_POGOSRFOCCY__c = 0;
            anAccount.DE_POGOSRFOCPY__c = 0;
            anAccount.DE_POGOSRPY__c = 0;
            anAccount.DE_CP_AGREED_LAT_CY__c  = 0;
            anAccount.DE_CP_AGREED_LAT_PY__c = 0;
            anAccount.DE_CP_AGREED_MON_CY__c = 0;
            anAccount.DE_CP_AGREED_MON_PY__c = 0;
            anAccount.DE_CP_AGREED_RUP_CY__c = 0;
            anAccount.DE_CP_AGREED_RUP_PY__c = 0;
            anAccount.DE_CP_AGREED_MONF_CY__c = 0;
            anAccount.DE_CP_AGREED_MONF_PY__c = 0;
            anAccount.DE_Forecast_LAT_CY__c = 0;
            anAccount.DE_Forecast_LAT_PY__c = 0;
            anAccount.DE_Forecast_MON_CY__c = 0;
            anAccount.DE_Forecast_MON_PY__c = 0;
            anAccount.DE_Forecast_GLY_CY__c = 0;
            anAccount.DE_Forecast_GLY_PY__c = 0;
            anAccount.DE_Forecast_RUP_CY__c = 0;
            anAccount.DE_Forecast_RUP_PY__c = 0;
            anAccount.DE_Forecast_MONF_CY__c = 0;
            anAccount.DE_Forecast_MONF_PY__c = 0;
            anAccount.DE_CP_POG_RUP_CY__c = 0;
            anAccount.DE_CP_POG_RUP_PY__c = 0;
            anAccount.DE_CP_POG_LAT_CY__c = 0;
            anAccount.DE_CP_POG_LAT_PY__c = 0;
            anAccount.DE_CP_POG_MON_CY__c = 0;
            anAccount.DE_CP_POG_MON_PY__c = 0;
            anAccount.DE_CP_POG_MONF_CY__c = 0;
            anAccount.DE_CP_POG_MONF_PY__c = 0;
            anAccount.DE_MS_Lattitude_CY__c = 0;
            anAccount.DE_MS_Lattitude_PY__c = 0;
            anAccount.DE_MS_Monitor_CY__c = 0;
            anAccount.DE_MS_Monitor_PY__c = 0;
            anAccount.DE_MS_Monfast_CY__c = 0;
            anAccount.DE_MS_Monfast_PY__c = 0;
            anAccount.DE_MS_RUP_CY__c = 0;
            anAccount.DE_MS_RUP_PY__c = 0;
            
            /***BEG New Development: France***/
            anAccount.FR_POG_CORN_MS_CY__c = 0;
            Decimal monsantoFrenchCorn = 0;
            Decimal allFrenchCorn = 0;
            anAccount.FR_POG_OSR_MS_CY__c = 0;
            Decimal monsantoFrenchOsr = 0;
            Decimal allFrenchOsr = 0;
            /***END New Development: France***/
            
            /*** Ukraine CP Development ***/
            anAccount.CP_AGREED_ACT_CY__c=0;
            anAccount.CP_AGREED_ACT_PY__c=0;
            anAccount.CP_POG_ACT_CY__c=0;
            anAccount.CP_POG_ACT_PY__c=0;
            anAccount.CP_MS_ACTIMUM_CY__c=0;
            anAccount.CP_MS_ACTIMUM_PY__c=0;
            anAccount.CP_FORECAST_ACT_CY__c=0;
            anAccount.CP_FORECAST_ACT_PY__c=0;
            //anAccount.CP_ACTIMUM_ZV_CY__c=0;
            //anAccount.CP_ACTIMUM_ZV_PY__c=0;
            
            anAccount.CP_AGREED_GUA_CY__c=0;
            anAccount.CP_AGREED_GUA_PY__c=0;
            anAccount.CP_POG_GUA_CY__c=0;
            anAccount.CP_POG_GUA_PY__c=0;
            anAccount.CP_MS_GUARDIAN_CY__c=0;
            anAccount.CP_MS_GUARDIAN_PY__c=0;
            anAccount.CP_FORECAST_GUA_CY__c=0;
            anAccount.CP_FORECAST_GUA_PY__c=0;
            //anAccount.CP_GUARDIAN_ZV_CY__c=0;
            //anAccount.CP_GUARDIAN_ZV_PY__c=0;
            
            anAccount.CP_AGREED_HAR_CY__c=0;
            anAccount.CP_AGREED_HAR_PY__c=0;
            anAccount.CP_POG_HAR_CY__c=0;
            anAccount.CP_POG_HAR_PY__c=0;
            anAccount.CP_MS_HARNESS_CY__c=0;
            anAccount.CP_MS_HARNESS_PY__c=0;
            anAccount.CP_FORECAST_HAR_CY__c=0;
            anAccount.CP_FORECAST_HAR_PY__c=0;
            //anAccount.CP_Harness_ZV_CY__c=0;
            //anAccount.CP_Harness_ZV_PY__c=0;  
            /*** Ukraine CP Development ***/
            
            if (theChildren == null)
            {
                return anAccount;
            }
            
            //Products latitude
            for (CampaignLineItem__c anItem: (List<CampaignLineItem__c>) theChildren)
            {
                if (anItem == null || anItem.CampaignRef__r == null || anItem.CampaignRef__r.DivisionRef__r == null || anItem.Quantity__c == null)
                {
                    continue;
                }
                String aDivisionName = anItem.CampaignRef__r.DivisionRef__r.Name;
                Boolean anIsCompetitorProducer = anItem.ProductRef__c != null && anItem.ProductRef__r.ProductVendor__c != null 
                        && anItem.ProductRef__r.ProductVendor__r.RecordTypeId == Util.recordType.get(RECORDTYPE_ACCOUNT_COMPETITOR);
                Boolean anIsMonsanto = anItem.ProductRef__c != null && anItem.ProductRef__r.ProductVendor__c != null 
                        && anItem.ProductRef__r.ProductVendor__r.RecordTypeId == Util.recordType.get(RECORDTYPE_ACCOUNT_DISTRIBUTOR);
                Decimal aTPValue = 0;
                if (anItem.ProductRef__c != null)
                {
                    try
                    {
                        if(anItem.PlantingDensity__c != null && Decimal.valueOf(anItem.PlantingDensity__c)>0) {
                            if((anItem.PlantingDensity__c).length() > 3)
                                aTPValue = ((anItem.ProductRef__r.ProductBagSize__c * 1000) * anItem.Quantity__c) / Decimal.valueOf(anItem.PlantingDensity__c);
                            else
                                aTPValue = (anItem.ProductRef__r.ProductBagSize__c * anItem.Quantity__c) / Decimal.valueOf(anItem.PlantingDensity__c);
                        } else {
                            aTPValue = 0;
                        }
                    } catch (Exception theException)
                    {
                        System.debug('***Got exception: ' + theException.getMessage());
                        aTPValue = 0;
                    }
                    
                }
                
                Boolean anIsCurrentCampaign = anItem.CampaignRef__r.StatusCode__c == 200;
                Boolean anIsPreviousCampaign = anItem.CampaignRef__r.StatusCode__c == 300;
                Boolean anIsSameSeason = (anItem.CampaignRef__r.StartDate.addYears(1) <= System.today() && anItem.CampaignRef__r.EndDate.addYears(1) >= System.today());
                Boolean anIsCorn = aDivisionName.equalsIgnoreCase(Util.DIVISION_CORN);
                Boolean anIsOSR = aDivisionName.equalsIgnoreCase(Util.DIVISION_OSR);
                Boolean anIsCP = aDivisionName.equalsIgnoreCase(Util.DIVISION_CP);
                Boolean anIsLatitude = aDivisionName.equalsIgnoreCase(Util.DIVISION_LATITUDE);
                Boolean anIsMonitor = aDivisionName.equalsIgnoreCase(Util.DIVISION_MONITOR);
                Boolean anIsRoundup = aDivisionName.equalsIgnoreCase(Util.DIVISION_ROUNDUP);
                Boolean anIsMonfast = aDivisionName.equalsIgnoreCase(Util.DIVISION_MONFAST);
                Boolean anIsActimum = aDivisionName.equalsIgnoreCase(Util.DIVISION_ACTIMUM);
                Boolean anIsGuardian = aDivisionName.equalsIgnoreCase(Util.DIVISION_GUARDIAN);
                Boolean anIsHarness = aDivisionName.equalsIgnoreCase(Util.DIVISION_HARNESS);
                Boolean anIsSales = anItem.Status__c == 'Confirmed';
                Boolean anIsAgreed = anItem.Status__c == 'Ordered / Discussed';
                Boolean anIsForecast = anItem.Status__c == 'Forecast';
                Boolean anIsCharged = anItem.Type__c == 'Charged';
                Boolean anIsFreeCharge = anItem.Type__c == 'Free of charge';

                if (anAccount.CountryRef__c != null)
                {
                    system.debug('***** anIsCorn:'+anIsCorn+'. anIsOSR:'+anIsOSR+'. anIsCurrentCampaign:'+anIsCurrentCampaign+'. anIsPreviousCampaign:'+anIsPreviousCampaign+'. anIsMonsanto:'+anIsMonsanto+'. anIsCompetitorProducer:'+anIsCompetitorProducer);
                    CountryAdapter country = new CountryAdapter(anAccount.CountryRef__c);

                    /***BEG New Development: France***/
                    if (country.isFRTacticalPlan && anIsCurrentCampaign && anIsCharged){
                        //CORN
                        if (anIsCorn && anItem.POG__c != null){
                            if (anIsMonsanto)
                                monsantoFrenchCorn += anItem.PoG__c;
                            allFrenchCorn += anItem.PoG__c;
                        }
                        //OSR
                        if (anIsOsr && anItem.POG__c != null){
                            if (anIsMonsanto)
                                monsantoFrenchOsr += anItem.PoG__c;
                            allFrenchOsr += anItem.PoG__c;
                        }
                    }
                    /***END New Development: France***/
                    
                // CORN
                    if(anIsCorn){
                        if(anIsCurrentCampaign){
                            if(anIsMonsanto){
                                // Forecast CY CORN CHARGED
                                if (anItem.Forecast__c != null && anIsCharged)
                                    anAccount.DE_ForecastCornCY__c += anItem.Forecast__c;
                                // Forecast CY CORN FREE OF CHARGE
                                if (anItem.Forecast__c != null && anIsFreeCharge)
                                    anAccount.DE_ForecastCornFOCCY__c += anItem.Forecast__c;
                                // Agreed CY CORN CHARGED
                                if (anItem.Agreed__c != null && anIsCharged)
                                    anAccount.NUM_AGREED_CORN_CHARGED_CY__c += anItem.Agreed__c;
                                // Agreed CY CORN FREE OF CHARGE
                                if (anItem.Agreed__c != null && anIsFreeCharge)
                                    anAccount.NUM_AGREED_CORN_FOC_CY__c += anItem.Agreed__c;
                                
                                try {
                                    if(anItem.PlantingDensity__c != null && Decimal.valueOf(anItem.PlantingDensity__c) > 0) {
                                        // Monsanto Forecast CY Corn
                                        if(anItem.Forecast__c != null)
                                            anAccount.NUM_ForecastCornTPMonsantoCY__c += ((anItem.ProductRef__r.ProductBagSize__c * 1000) * anItem.Forecast__c) / Decimal.valueOf(anItem.PlantingDensity__c);
                                        // Monsanto Agreed CY Corn
                                        if(anItem.Agreed__c != null)
                                            anAccount.NUM_AgreedCornTPMonsantoCY__c += ((anItem.ProductRef__r.ProductBagSize__c * 1000) * anItem.Agreed__c) / Decimal.valueOf(anItem.PlantingDensity__c);
                                    }
                                } catch(Exception theException) {}
                                
                                // POG CY CORN
                                if(anIsSales && anItem.PoG__c != null){
                                    anAccount.CornTotalSalesCY__c += anItem.PoG__c;
                                    anAccount.TotalCornTPMonsantoCY__c += aTPValue;
                                    // POG CY CORN CHARGED
                                    if(anIsCharged)
                                        anAccount.DE_POGCornCY__c += anItem.PoG__c;
                                    // POG CY CORN FREE OF CHARGE
                                    if(anIsFreeCharge)
                                        anAccount.DE_POGCornFOCCY__c += anItem.PoG__c;
                                }
                            }        
                            if(anIsCompetitorProducer){
                                if(anIsSales && anItem.PoG__c != null){
                                    anAccount.TotalCornSalesCompetitorCY__c += anItem.PoG__c;
                                    anAccount.TotalCornTPCompetitorCY__c += aTPValue;
                                }
                            }
                        }
                        if(anIsPreviousCampaign){
                            if(anIsMonsanto){
                                // Forecast PY CORN CHARGED
                                if (anItem.Forecast__c != null && anIsCharged)
                                    anAccount.DE_ForecastCornPY__c += anItem.Forecast__c;
                                // Forecast PY CORN FREE OF CHARGE
                                if (anItem.Forecast__c != null && anIsFreeCharge)
                                    anAccount.DE_ForecastCornFOCPY__c += anItem.Forecast__c;
                                // Agreed PY CORN CHARGED
                                if (anItem.Agreed__c != null && anIsCharged)
                                    anAccount.NUM_AGREED_CORN_CHARGED_PY__c += anItem.Agreed__c;
                                // Agreed PY CORN FREE OF CHARGE
                                if (anItem.Agreed__c != null && anIsFreeCharge)
                                    anAccount.NUM_AGREED_CORN_FOC_PY__c += anItem.Agreed__c;

                                try {
                                    if(anItem.PlantingDensity__c != null && Decimal.valueOf(anItem.PlantingDensity__c) > 0) {
                                        // Monsanto Forecast CY Corn
                                        if(anItem.Forecast__c != null)
                                            anAccount.NUM_ForecastCornTPMonsantoPY__c += ((anItem.ProductRef__r.ProductBagSize__c * 1000) * anItem.Forecast__c) / Decimal.valueOf(anItem.PlantingDensity__c);
                                        // Monsanto Agreed CY Corn
                                        if(anItem.Agreed__c != null)
                                            anAccount.NUM_AgreedCornTPMonsantoPY__c += ((anItem.ProductRef__r.ProductBagSize__c * 1000) * anItem.Agreed__c) / Decimal.valueOf(anItem.PlantingDensity__c);
                                    }
                                } catch(Exception theException) {}

                                // POG PY CORN
                                if(anIsSales && anItem.PoG__c != null){
                                    anAccount.CornTotalSalesPY__c += anItem.PoG__c;
                                    anAccount.TotalCornTPMonsantoPY__c += aTPValue;
                                    // POG PY CORN CHARGED
                                    if(anIsCharged && anIsSameSeason)
                                        anAccount.DE_POGCornPY__c += anItem.PoG__c;
                                    // POG PY CORN FREE OF CHARGE
                                    if(anIsFreeCharge && anIsSameSeason)
                                        anAccount.DE_POGCornFOCPY__c += anItem.PoG__c;
                                }
                            }        
                            if(anIsCompetitorProducer){
                                if(anIsSales && anItem.PoG__c != null){
                                    anAccount.TotalCornSalesCompetitorPY__c += anItem.PoG__c;
                                    anAccount.TotalCornTPCompetitorPY__c += aTPValue;
                                }
                            }
                        }
                    }
                    
                // OSR
                    if(anIsOSR){
                        if(anIsCurrentCampaign){
                            if(anIsMonsanto){
                                // Forecast CY OSR CHARGED
                                if (anItem.Forecast__c != null && anIsCharged)
                                    anAccount.DE_ForecastOSRCY__c += anItem.Forecast__c;
                                // Forecast CY OSR FREE OF CHARGE
                                if (anItem.Forecast__c != null && anIsFreeCharge)
                                    anAccount.DE_ForecastOSRFOCCY__c += anItem.Forecast__c;
                                // Agreed CY OSR CHARGED
                                if (anItem.Agreed__c != null && anIsCharged)
                                    anAccount.NUM_AGREED_OSR_CY__c += anItem.Agreed__c;
                                // Agreed CY OSR FREE OF CHARGE
                                if (anItem.Agreed__c != null && anIsFreeCharge)
                                    anAccount.NUM_AGREED_OSR_FOC_CY__c += anItem.Agreed__c;
                                    
                                try {
                                    if(anItem.PlantingDensity__c != null && Decimal.valueOf(anItem.PlantingDensity__c) > 0) {
                                        // Monsanto Forecast CY Corn
                                        if(anItem.Forecast__c != null)
                                            anAccount.NUM_ForecastOSRTPMonsantoCY__c += ((anItem.ProductRef__r.ProductBagSize__c * 1000) * anItem.Forecast__c) / Decimal.valueOf(anItem.PlantingDensity__c);
                                        // Monsanto Agreed CY Corn
                                        if(anItem.Agreed__c != null)
                                            anAccount.NUM_AgreedOSRTPMonsantoCY__c += ((anItem.ProductRef__r.ProductBagSize__c * 1000) * anItem.Agreed__c) / Decimal.valueOf(anItem.PlantingDensity__c);
                                    }
                                } catch(Exception theException) {}

                                // POG CY OSR
                                if(anIsSales && anItem.PoG__c != null){
                                    anAccount.OSRTotalSalesCY__c += anItem.PoG__c;
                                    anAccount.TotalOSRTPMonsantoCY__c += aTPValue;
                                    // POG CY OSR CHARGED
                                    if(anIsCharged)
                                        anAccount.DE_POGOSRCY__c += anItem.PoG__c;
                                    // POG CY OSR FREE OF CHARGE
                                    if(anIsFreeCharge)
                                        anAccount.DE_POGOSRFOCCY__c += anItem.PoG__c;
                                }
                            }        
                            if(anIsCompetitorProducer){
                                if(anIsSales && anItem.PoG__c != null){
                                    anAccount.TotalOSRSalesCompetitorCY__c += anItem.PoG__c;
                                    anAccount.TotalOSRTPCompetitorCY__c += aTPValue;
                                }
                            }
                        }
                        if(anIsPreviousCampaign){
                            if(anIsMonsanto){
                                // Forecast PY OSR CHARGED
                                if (anItem.Forecast__c != null && anIsCharged)
                                    anAccount.DE_ForecastOSRPY__c += anItem.Forecast__c;
                                // Forecast PY OSR FREE OF CHARGE
                                if (anItem.Forecast__c != null && anIsFreeCharge)
                                    anAccount.DE_ForecastOSRFOCPY__c += anItem.Forecast__c;
                                // Agreed PY OSR CHARGED
                                if (anItem.Agreed__c != null && anIsCharged)
                                    anAccount.NUM_AGREED_OSR_PY__c += anItem.Agreed__c;
                                // Agreed PY OSR FREE OF CHARGE
                                if (anItem.Agreed__c != null && anIsFreeCharge)
                                    anAccount.NUM_AGREED_OSR_FOC_PY__c += anItem.Agreed__c;

                                try {
                                    if(anItem.PlantingDensity__c != null && Decimal.valueOf(anItem.PlantingDensity__c) > 0) {
                                        // Monsanto Forecast CY Corn
                                        if(anItem.Forecast__c != null)
                                            anAccount.NUM_ForecastOSRTPMonsantoPY__c += ((anItem.ProductRef__r.ProductBagSize__c * 1000) * anItem.Forecast__c) / Decimal.valueOf(anItem.PlantingDensity__c);
                                        // Monsanto Agreed CY Corn
                                        if(anItem.Agreed__c != null)
                                            anAccount.NUM_AgreedOSRTPMonsantoPY__c += ((anItem.ProductRef__r.ProductBagSize__c * 1000) * anItem.Agreed__c) / Decimal.valueOf(anItem.PlantingDensity__c);
                                    }
                                } catch(Exception theException) {}

                                // POG PY OSR
                                if(anIsSales && anItem.PoG__c != null){
                                    anAccount.OSRTotalSalesPY__c += anItem.PoG__c;
                                    anAccount.TotalOSRTPMonsantoPY__c += aTPValue;
                                    // POG PY OSR CHARGED
                                    if(anIsCharged && anIsSameSeason)
                                        anAccount.DE_POGOSRPY__c += anItem.PoG__c;
                                    // POG PY OSR FREE OF CHARGE
                                    if(anIsFreeCharge && anIsSameSeason)
                                        anAccount.DE_POGOSRFOCPY__c += anItem.PoG__c;
                                }
                            }        
                            if(anIsCompetitorProducer){
                                if(anIsSales && anItem.PoG__c != null){
                                    anAccount.TotalOSRSalesCompetitorPY__c += anItem.PoG__c;
                                    anAccount.TotalOSRTPCompetitorPY__c += aTPValue;
                                }
                            }
                        }
                    }
                   Boolean isCPDivision = anIsLatitude || anIsMonitor || anIsRoundup || anIsMonfast || anIsActimum || anIsGuardian || anIsHarness; 
                   if (country.isGermanActionPlan || country.isGermanCPActionPlan || (Test.isRunningTest() && isCPDivision)){
                     
                    // LATITUDE
                        if(anIsLatitude){
                            if(anIsCurrentCampaign){
                                if(anIsMonsanto || anIsCompetitorProducer){
                                    // Forecast CY Latitude
                                    if(anItem.Forecast__c != null)
                                        anAccount.DE_Forecast_LAT_CY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // Agreed CY Latitude
                                    if(anItem.Agreed__c != null)
                                        anAccount.DE_CP_AGREED_LAT_CY__c += (anItem.Agreed__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // PoG CY Latitude
                                    if(anItem.PoG__c != null && anIsMonsanto)
                                        anAccount.DE_CP_POG_LAT_CY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                        // MS CY Latitude
                                        if(anAccount.DE_CP_POG_LAT_CY__c + anAccount.DE_CP_AGREED_LAT_CY__c != 0 && anAccount.DE_CP_AGREED_LAT_CY__c != 0)
                                            anAccount.DE_MS_Lattitude_CY__c = (100*anAccount.DE_CP_POG_LAT_CY__c)/anAccount.DE_CP_AGREED_LAT_CY__c;
                                }
                            }
                            if(anIsPreviousCampaign){
                                if(anIsMonsanto || anIsCompetitorProducer){
                                    // Forecast PY Latitude
                                    if(anItem.Forecast__c != null)
                                        anAccount.DE_Forecast_LAT_PY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // Agreed PY Latitude
                                    if(anItem.Agreed__c != null)
                                        anAccount.DE_CP_AGREED_LAT_PY__c += (anItem.Agreed__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // PoG PY Latitude
                                    if(anItem.PoG__c != null && anIsMonsanto)
                                        anAccount.DE_CP_POG_LAT_PY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                        // MS PY Latitude
                                        if(anAccount.DE_CP_POG_LAT_PY__c + anAccount.DE_CP_AGREED_LAT_PY__c != 0 && anAccount.DE_CP_AGREED_LAT_PY__c != 0)
                                            anAccount.DE_MS_Lattitude_PY__c = (100*anAccount.DE_CP_POG_LAT_PY__c)/anAccount.DE_CP_AGREED_LAT_PY__c;
                                }
                            }
                        }
                    
                    // MONITOR
                        if(anIsMonitor){
                            if(anIsCurrentCampaign){
                                if(anIsMonsanto || anIsCompetitorProducer){
                                    // Forecast CY Monitor
                                    if(anItem.Forecast__c != null)
                                        anAccount.DE_Forecast_MON_CY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // Agreed CY Monitor
                                    if(anItem.Agreed__c != null)
                                        anAccount.DE_CP_AGREED_MON_CY__c += (anItem.Agreed__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // PoG CY Monitor
                                    if(anItem.PoG__c != null && anIsMonsanto)
                                        anAccount.DE_CP_POG_MON_CY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                        // MS CY Monitor
                                        if(anAccount.DE_CP_POG_MON_CY__c + anAccount.DE_CP_AGREED_MON_CY__c != 0 && anAccount.DE_CP_AGREED_MON_CY__c != 0)
                                            anAccount.DE_MS_Monitor_CY__c = (100*anAccount.DE_CP_POG_MON_CY__c)/anAccount.DE_CP_AGREED_MON_CY__c;
                                }
                            }
                            if(anIsPreviousCampaign){
                                if(anIsMonsanto || anIsCompetitorProducer){
                                    // Forecast PY Monitor
                                    if(anItem.Forecast__c != null)
                                        anAccount.DE_Forecast_MON_PY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // Agreed PY Monitor
                                    if(anItem.Agreed__c != null)
                                        anAccount.DE_CP_AGREED_MON_PY__c += (anItem.Agreed__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // PoG PY Monitor
                                    if(anItem.PoG__c != null && anIsMonsanto)
                                        anAccount.DE_CP_POG_MON_PY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                        // MS PY Monitor
                                        if(anAccount.DE_CP_POG_MON_PY__c + anAccount.DE_CP_AGREED_MON_PY__c != 0 && anAccount.DE_CP_AGREED_MON_PY__c != 0)
                                            anAccount.DE_MS_Monitor_PY__c = (100*anAccount.DE_CP_POG_MON_PY__c)/anAccount.DE_CP_AGREED_MON_PY__c;
                                }
                            }
                        }
                        
                    // ROUNDUP
                        if(anIsRoundup){
                            if(anIsCurrentCampaign){
                                if(anIsMonsanto || anIsCompetitorProducer){
                                    // Forecast CY GLY
                                    if(anItem.Forecast__c != null)
                                         anAccount.DE_Forecast_GLY_CY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // Forecast CY Roundup
                                    if(anItem.Forecast__c != null && anIsMonsanto)
                                        anAccount.DE_Forecast_RUP_CY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // INI 17/03/2015 New calculation: OLD Agreed RUP is now POG GLY but there is no change is API name!!!
                                    // Agreed CY Roundup
                                    //if(anItem.Agreed__c != null)
                                    //    anAccount.DE_CP_AGREED_RUP_CY__c += (anItem.Agreed__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // PoG CY Roundup
                                    if(anItem.PoG__c != null) //GLY includes Monsanto or any other competitor
                                        anAccount.DE_CP_AGREED_RUP_CY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // FIN 17/03/2015
                                    if(anItem.PoG__c != null && anIsMonsanto)
                                        anAccount.DE_CP_POG_RUP_CY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                        // MS CY Roundup
                                        if(anAccount.DE_CP_POG_RUP_CY__c + anAccount.DE_CP_AGREED_RUP_CY__c != 0 && anAccount.DE_CP_AGREED_RUP_CY__c != 0)
                                            anAccount.DE_MS_RUP_CY__c = (100*anAccount.DE_CP_POG_RUP_CY__c)/anAccount.DE_CP_AGREED_RUP_CY__c; //calculated using POG, Agreed RUP field is based on POG data
                                }
                            }
                            if(anIsPreviousCampaign){
                                if(anIsMonsanto || anIsCompetitorProducer){
                                    // Forecast PY GLY
                                    if(anItem.Forecast__c != null)
                                         anAccount.DE_Forecast_GLY_PY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // Forecast PY Roundup
                                    if(anItem.Forecast__c != null && anIsMonsanto)
                                        anAccount.DE_Forecast_RUP_PY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // INI 17/03/2015 New calculation: OLD Agreed RUP is now POG GLY but there is no change is API name!!!
                                    // Agreed PY Roundup
                                    //if(anItem.Agreed__c != null)
                                    //    anAccount.DE_CP_AGREED_RUP_PY__c += (anItem.Agreed__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // PoG PY Roundup
                                    if(anItem.PoG__c != null) //GLY includes Monsanto or any other competitor
                                        anAccount.DE_CP_AGREED_RUP_PY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // FIN 17/03/2015
                                    if(anItem.PoG__c != null && anIsMonsanto)
                                        anAccount.DE_CP_POG_RUP_PY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                        // MS PY Roundup
                                        if(anAccount.DE_CP_POG_RUP_PY__c + anAccount.DE_CP_AGREED_RUP_PY__c != 0 && anAccount.DE_CP_AGREED_RUP_PY__c != 0)
                                            anAccount.DE_MS_RUP_PY__c = (100*anAccount.DE_CP_POG_RUP_PY__c)/anAccount.DE_CP_AGREED_RUP_PY__c; //calculated using POG, Agreed RUP field is based on POG data
                                }
                            }
                        }
                        
                    // MONFAST
                        if(anIsMonfast){
                            if(anIsCurrentCampaign){
                                if(anIsMonsanto || anIsCompetitorProducer){
                                    // Forecast CY Monfast
                                    if(anItem.Forecast__c != null)
                                        anAccount.DE_Forecast_MONF_CY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // Agreed CY Monfast
                                    if(anItem.Agreed__c != null)
                                        anAccount.DE_CP_AGREED_MONF_CY__c += (anItem.Agreed__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // PoG CY Monfast
                                    if(anItem.PoG__c != null && anIsMonsanto)
                                        anAccount.DE_CP_POG_MONF_CY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                        // MS CY Monfast
                                        if(anAccount.DE_CP_POG_MONF_CY__c + anAccount.DE_CP_AGREED_MONF_CY__c != 0 && anAccount.DE_CP_AGREED_MONF_CY__c != 0)
                                            anAccount.DE_MS_Monfast_CY__c = (100*anAccount.DE_CP_POG_MONF_CY__c)/anAccount.DE_CP_AGREED_MONF_CY__c;
                                }
                            }
                            if(anIsPreviousCampaign){
                                if(anIsMonsanto || anIsCompetitorProducer){
                                    // Forecast PY Monfast
                                    if(anItem.Forecast__c != null)
                                        anAccount.DE_Forecast_MONF_PY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // Agreed PY Monfast
                                    if(anItem.Agreed__c != null)
                                        anAccount.DE_CP_AGREED_MONF_PY__c += (anItem.Agreed__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // PoG PY Monfast
                                    if(anItem.PoG__c != null && anIsMonsanto)
                                        anAccount.DE_CP_POG_MONF_PY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                        // MS PY Monfast
                                        if(anAccount.DE_CP_POG_MONF_PY__c + anAccount.DE_CP_AGREED_MONF_PY__c != 0 && anAccount.DE_CP_AGREED_MONF_PY__c != 0)
                                            anAccount.DE_MS_Monfast_PY__c = (100*anAccount.DE_CP_POG_MONF_PY__c)/anAccount.DE_CP_AGREED_MONF_PY__c;
                                }
                            }
                        }
                        
                    // ACTIMUM
                        if(anIsActimum){
                            if(anIsCurrentCampaign){
                                if(anIsMonsanto || anIsCompetitorProducer){
                                    // Forecast CY ACTIMUM
                                    if(anItem.Forecast__c != null)
                                        anAccount.CP_Forecast_ACT_CY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // Agreed CY ACTIMUM
                                    if(anItem.Agreed__c != null)
                                        anAccount.CP_AGREED_ACT_CY__c += (anItem.Agreed__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // PoG CY ACTIMUM
                                    if(anItem.PoG__c != null && anIsMonsanto)
                                        anAccount.CP_POG_ACT_CY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                        // MS CY ACTIMUM
                                        if(anAccount.CP_POG_ACT_CY__c + anAccount.CP_AGREED_ACT_CY__c != 0 && anAccount.CP_AGREED_ACT_CY__c != 0)
                                            anAccount.CP_MS_ACTIMUM_CY__c = (100*anAccount.CP_POG_ACT_CY__c)/anAccount.CP_AGREED_ACT_CY__c;
                                }
                            }
                            if(anIsPreviousCampaign){
                                if(anIsMonsanto || anIsCompetitorProducer){
                                    // Forecast PY ACTIMUM
                                    if(anItem.Forecast__c != null)
                                        anAccount.CP_Forecast_ACT_PY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // Agreed PY ACTIMUM
                                    if(anItem.Agreed__c != null)
                                        anAccount.CP_AGREED_ACT_PY__c += (anItem.Agreed__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // PoG PY ACTIMUM
                                    if(anItem.PoG__c != null && anIsMonsanto)
                                        anAccount.CP_POG_ACT_PY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                        // MS PY ACTIMUM
                                        if(anAccount.CP_POG_ACT_PY__c + anAccount.CP_AGREED_ACT_PY__c != 0 && anAccount.CP_AGREED_ACT_PY__c != 0)
                                            anAccount.CP_MS_ACTIMUM_PY__c = (100*anAccount.CP_POG_ACT_PY__c)/anAccount.CP_AGREED_ACT_PY__c;
                                }
                            }
                        }
                        
                    // GUARDIAN
                        if(anIsGuardian){
                            if(anIsCurrentCampaign){
                                if(anIsMonsanto || anIsCompetitorProducer){
                                    // Forecast CY GUARDIAN
                                    if(anItem.Forecast__c != null)
                                        anAccount.CP_Forecast_GUA_CY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // Agreed CY GUARDIAN
                                    if(anItem.Agreed__c != null)
                                        anAccount.CP_AGREED_GUA_CY__c += (anItem.Agreed__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // PoG CY GUARDIAN
                                    if(anItem.PoG__c != null && anIsMonsanto)
                                        anAccount.CP_POG_GUA_CY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                        // MS CY GUARDIAN
                                        if(anAccount.CP_POG_GUA_CY__c + anAccount.CP_AGREED_GUA_CY__c != 0 && anAccount.CP_AGREED_GUA_CY__c != 0)
                                            anAccount.CP_MS_GUARDIAN_CY__c = (100*anAccount.CP_POG_GUA_CY__c)/anAccount.CP_AGREED_GUA_CY__c;
                                }
                            }
                            if(anIsPreviousCampaign){
                                if(anIsMonsanto || anIsCompetitorProducer){
                                    // Forecast PY GUARDIAN
                                    if(anItem.Forecast__c != null)
                                        anAccount.CP_Forecast_GUA_PY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // Agreed PY GUARDIAN
                                    if(anItem.Agreed__c != null)
                                        anAccount.CP_AGREED_GUA_PY__c += (anItem.Agreed__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // PoG PY GUARDIAN
                                    if(anItem.PoG__c != null && anIsMonsanto)
                                        anAccount.CP_POG_GUA_PY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                        // MS PY GUARDIAN
                                        if(anAccount.CP_POG_GUA_PY__c + anAccount.CP_AGREED_GUA_PY__c != 0 && anAccount.CP_AGREED_GUA_PY__c != 0)
                                            anAccount.CP_MS_GUARDIAN_PY__c = (100*anAccount.CP_POG_GUA_PY__c)/anAccount.CP_AGREED_GUA_PY__c;
                                }
                            }
                        }
                        
                    // HARNESS
                        if(anIsHarness){
                            if(anIsCurrentCampaign){
                                if(anIsMonsanto || anIsCompetitorProducer){
                                    // Forecast CY HARNESS
                                    if(anItem.Forecast__c != null)
                                        anAccount.CP_Forecast_HAR_CY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // Agreed CY HARNESS
                                    if(anItem.Agreed__c != null)
                                        anAccount.CP_AGREED_HAR_CY__c += (anItem.Agreed__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // PoG CY HARNESS
                                    if(anItem.PoG__c != null && anIsMonsanto)
                                        anAccount.CP_POG_HAR_CY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                        // MS CY HARNESS
                                        if(anAccount.CP_POG_HAR_CY__c + anAccount.CP_AGREED_HAR_CY__c != 0 && anAccount.CP_AGREED_HAR_CY__c != 0)
                                            anAccount.CP_MS_HARNESS_CY__c = (100*anAccount.CP_POG_HAR_CY__c)/anAccount.CP_AGREED_HAR_CY__c;
                                }
                            }
                            if(anIsPreviousCampaign){
                                if(anIsMonsanto || anIsCompetitorProducer){
                                    // Forecast PY HARNESS
                                    if(anItem.Forecast__c != null)
                                        anAccount.CP_Forecast_HAR_PY__c += (anItem.Forecast__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // Agreed PY HARNESS
                                    if(anItem.Agreed__c != null)
                                        anAccount.CP_AGREED_HAR_PY__c += (anItem.Agreed__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                    // PoG PY HARNESS
                                    if(anItem.PoG__c != null && anIsMonsanto)
                                        anAccount.CP_POG_HAR_PY__c += (anItem.PoG__c * anItem.ProductRef__r.DE_RelFactor__c * anItem.ProductRef__r.NUM_UnitsPerSKU__c);
                                        // MS PY HARNESS
                                        if(anAccount.CP_POG_HAR_PY__c + anAccount.CP_AGREED_HAR_PY__c != 0 && anAccount.CP_AGREED_HAR_PY__c != 0)
                                            anAccount.CP_MS_HARNESS_PY__c = (100*anAccount.CP_POG_HAR_PY__c)/anAccount.CP_AGREED_HAR_PY__c;
                                }
                            }
                        }
                        
                    }
                }
                
            // Monsanto Forecast
                if (anIsMonsanto && anIsCurrentCampaign && anIsCorn && anItem.Forecast__c != null)
                    anAccount.ForecastMTOCornSalesCY__c += anItem.Forecast__c;
            // Monsanto Agreed
                if (anIsMonsanto && anIsCurrentCampaign && anIsCorn && anItem.Agreed__c != null)
                    anAccount.AgreedMTOCornSalesCY__c += anItem.Agreed__c;
            // Monsanto Agreed PY
                if (anIsMonsanto && anIsPreviousCampaign && anIsCorn && anItem.Agreed__c != null)
                    anAccount.AgreedMTOCornSalesPY__c += anItem.Agreed__c;
                    
            // CP DIVISION
                if(anIsCP){
                    if(anIsCurrentCampaign && anIsMonsanto && anIsSales && anItem.PoG__c!=null){
                        anAccount.CPTotalSalesCY__c += anItem.PoG__c;
                    }
                    else if(anIsPreviousCampaign && anIsMonsanto && anIsSales && anItem.PoG__c!=null){
                        anAccount.CPTotalSalesPY__c += anItem.PoG__c;
                    }
                }

            }
            /***BEG New Development: France***/
            //CORN
            if (allFrenchCorn != 0){
                anAccount.FR_POG_CORN_MS_CY__c = (monsantoFrenchCorn / allFrenchCorn)*100;
            }
            //OSR
            if (allFrenchOsr != 0){
                anAccount.FR_POG_OSR_MS_CY__c = (monsantoFrenchOsr / allFrenchOsr)*100;
            }
            /***END New Development: France***/
            
            return anAccount; 
        }
    }
    
    /**
    * Class, that performs calculations for Account summary fields, that are related to Acreages.
    */
    private class AcreagesSummary extends TriggerHelper.CommonSummary
    {
        /**
        * General constructor.
        */
        public AcreagesSummary()
        {
            super('Account', 'Acreages__r', new List<String>{'Id','CountryRef__c'},
                    new List<String>
                    {
                        'AcrProductGroupRef__c', 'AcrFarmRef__c', 'AcrYearRef__c','AcrProviderRef__r.RecordTypeId', 
                        'AcrProviderRef__r.RecordType.Name', 'AcrTotalAcreages__c', 'AcrProductGroupRef__r.Name',
                        'AcrFarmRef__r.CountryRef__r.LKP_CurrentYear__c', 'AcrFarmRef__r.CountryRef__r.LKP_CurrentYear__r.YearPreviousYear__c'
                    });
            childConditions = new al.AndCondition();
            childConditions.add(new al.FieldCondition('RecordTypeId', Util.recordType.get('Acreage__c:AcreagesPerProductGroup'))); 
            al.OrCondition aYearCond = new al.OrCondition();
            childConditions.add(aYearCond);
            aYearCond.add(new al.FieldCondition('AcrYearRef__c', Util.currentYear.Id));
            aYearCond.add(new al.FieldCondition('AcrYearRef__c', Util.lastYear.Id));
            aYearCond.add(new al.FieldCondition('AcrYearRef__r.Name', String.valueOf(Integer.valueOf(Util.currentYear.Name) - 2)));
        }
        
        /**
        * Performs calculations
        */
        protected override sObject performCalculation(sObject theParent, List<sObject> theChildren)
        {
            Account anAccount = (Account) theParent; 
            anAccount.CornTotalAcreagesCY__c = 0;
            anAccount.CornTotalAcreagesPY__c = 0;
            anAccount.OSRTotalAcreagesCY__c = 0;
            anAccount.OSRTotalAcreagesPY__c = 0;
            anAccount.DE_TotalCerealAcreagesCY__c = 0;
            anAccount.DE_Total_Other_Acreages_CY__c = 0;
            anAccount.CompetitorTotalAcreagesCY__c = 0;
            anAccount.CompetitorTotalAcreagesPY__c = 0;

            anAccount.CornDekalbMarketshareCY__c = 0;
            anAccount.CornDekalbMarketsharePY__c = 0;
            anAccount.OSRDekalbMarketshareCY__c = 0;
            anAccount.OSRDekalbMarketsharePY__c = 0;
            anAccount.DE_TotalCerealAcreagesPY__c = 0;
            anAccount.DE_Total_Other_Acreages_PY__c = 0;
            anAccount.TotalAcreagesCY__c = 0;
            anAccount.TotalAcreagesPY__c = 0;
            anAccount.DE_TotalArableAcreagesCY__c = 0;
            anAccount.DE_TotalArableAcreagesPY__c = 0;
            if (anAccount.TotalOtherAcreagesManualPY__c == null){
                anAccount.TotalOtherAcreagesManualPY__c = 0;
            }
            if (anAccount.TotalOtherAcreagesManualCY__c == null){
                anAccount.TotalOtherAcreagesManualCY__c = 0;
            }
            
            Set<ID> accountsReset = new Set<ID>();
            if (theChildren == null)
            {
                return anAccount;
            }
            
            Double MonsantoCornAcreage = 0;
            Double MonsantoOSRAcreage = 0;
            Double MonsantoCornAcreagePY = 0;
            Double MonsantoOSRAcreagePY = 0;
            
            for (Acreage__c anItem: (List<Acreage__c>) theChildren)
            {
                if (anItem == null || anItem.AcrProductGroupRef__c == null)
                {
                    continue;
                }
                
                Boolean anIsCompetitorProducer = anItem.AcrProviderRef__c != null 
                        && anItem.AcrProviderRef__r.RecordTypeId == Util.recordType.get(RECORDTYPE_ACCOUNT_COMPETITOR);
                Boolean anIsMonsanto = anItem.AcrProviderRef__c != null 
                        && anItem.AcrProviderRef__r.RecordTypeId == Util.recordType.get(RECORDTYPE_ACCOUNT_DISTRIBUTOR);
                String aGroupId = anItem.AcrProductGroupRef__c;
                String aGroupName = anItem.AcrProductGroupRef__r.Name;
                
                if(anItem.AcrYearRef__c == anItem.AcrFarmRef__r.CountryRef__r.LKP_CurrentYear__c)
                {
                    if (aGroupId == (Util.getProductGroup(Util.PRODUCT_GROUP_CORN)))
                    {
                        anAccount.CornTotalAcreagesCY__c += anItem.AcrTotalAcreages__c;
                        
                        if (anIsMonsanto)
                        {
                            anAccount.CornDekalbMarketshareCY__c += anItem.AcrTotalAcreages__c;
                        }
                    } else if (aGroupId == Util.getProductGroup(Util.PRODUCT_GROUP_OSR))
                    {
                        anAccount.OSRTotalAcreagesCY__c += anItem.AcrTotalAcreages__c;
                        if (anIsMonsanto)
                        {
                            anAccount.OSRDekalbMarketshareCY__c += anItem.AcrTotalAcreages__c;
                        }
                    } 
                    if (anIsCompetitorProducer)
                    {
                        anAccount.CompetitorTotalAcreagesCY__c += anItem.AcrTotalAcreages__c;
                    }
                    
                    //Germany
                    if (anAccount.CountryRef__c != null)
                    {
                        CountryAdapter country = new CountryAdapter(anAccount.CountryRef__c);
                        if(country.isGermanActionPlan || Test.isRunningTest())
                        {
                          // if(userDivision == 'Corn' || userDivision == 'OSR'){
                            if(!accountsReset.contains(anAccount.ID)){
                                accountsReset.add(anAccount.ID);
                               // 
                               if(anAccount.TotalOtherAcreagesManualCY__c==null)
                                 anAccount.TotalOtherAcreagesManualCY__c = 0;
                               if(anAccount.TotalOtherAcreagesManualPY__c==null)
                                  anAccount.TotalOtherAcreagesManualPY__c = 0;
                               }
                                if (aGroupId == (Util.getProductGroup(Util.PRODUCT_GROUP_WINTER_WHEAT)) || aGroupId == (Util.getProductGroup(Util.PRODUCT_GROUP_TRITICALE)) || aGroupName.contains('Barley'))
                                {
                                    anAccount.DE_TotalCerealAcreagesCY__c += anItem.AcrTotalAcreages__c;
                                }else if(aGroupId != (Util.getProductGroup(Util.PRODUCT_GROUP_CORN)) && aGroupId != (Util.getProductGroup(Util.PRODUCT_GROUP_OSR)) && aGroupId != (Util.getProductGroup(Util.PRODUCT_GROUP_WINTER_WHEAT)) && aGroupId != (Util.getProductGroup(Util.PRODUCT_GROUP_TRITICALE)) && !aGroupName.contains('Barley')){
                                    anAccount.TotalOtherAcreagesManualCY__c += anItem.AcrTotalAcreages__c;
                                }
                                
                                //MARKET SHARE
                                if (aGroupId == (Util.getProductGroup(Util.PRODUCT_GROUP_CORN)))
                                {
                                    if (anIsMonsanto)
                                    {
                                    
                                        MonsantoCornAcreage += anItem.AcrTotalAcreages__c;
                                    }
                                    
                                    if (anAccount.CornTotalAcreagesCY__c != 0)
                                    {
                                        anAccount.CornDekalbMarketshareCY__c = (MonsantoCornAcreage/anAccount.CornTotalAcreagesCY__c);
                                    }
                                    
                                } else if (aGroupId == Util.getProductGroup(Util.PRODUCT_GROUP_OSR))
                                {
                                    if (anIsMonsanto)
                                    {
                                        MonsantoOSRAcreage += anItem.AcrTotalAcreages__c;
                                    }
                                    if (anAccount.OSRTotalAcreagesCY__c != 0)
                                    {
                                        anAccount.DE_OSRDekalbMarketCY_c__c = (MonsantoOSRAcreage/anAccount.OSRTotalAcreagesCY__c);
                                    }
                                }
                                //THE END MARKET SHARE
                            //}
                            
                          //  if(userDivision == 'Latitude' || userDivision == 'Monitor' || userDivision == 'Roundup'){
                                if (!aGroupName.contains('Greenland') && aGroupId != (Util.getProductGroup(Util.PRODUCT_GROUP_OTHER_HERBACEOUS_CROPS)))
                                {
                                    anAccount.DE_TotalArableAcreagesCY__c += anItem.AcrTotalAcreages__c;
                                }else if (aGroupName.contains('Greenland') || aGroupId == (Util.getProductGroup(Util.PRODUCT_GROUP_OTHER_HERBACEOUS_CROPS)))
                                {
                                    anAccount.DE_Total_Other_Acreages_CY__c += anItem.AcrTotalAcreages__c;
                                }
                           // }
                        }
                    }
                    //The end Germany
                    anAccount.TotalAcreagesCY__c += anItem.AcrTotalAcreages__c;
                } else if (anItem.AcrYearRef__c == anItem.AcrFarmRef__r.CountryRef__r.LKP_CurrentYear__r.YearPreviousYear__c) {
                    if (aGroupId == Util.getProductGroup(Util.PRODUCT_GROUP_CORN))
                    {
                        anAccount.CornTotalAcreagesPY__c += anItem.AcrTotalAcreages__c;
                        if (anIsMonsanto)
                        {
                            anAccount.CornDekalbMarketsharePY__c += anItem.AcrTotalAcreages__c;
                        }
                    } else if (aGroupId == Util.getProductGroup(Util.PRODUCT_GROUP_OSR))
                    {
                        anAccount.OSRTotalAcreagesPY__c  += anItem.AcrTotalAcreages__c;
                        if (anIsMonsanto)
                        {
                            anAccount.OSRDekalbMarketsharePY__c += anItem.AcrTotalAcreages__c;
                        }
                    }
                    if (anIsCompetitorProducer)
                    {
                        anAccount.CompetitorTotalAcreagesPY__c += anItem.AcrTotalAcreages__c;
                    }
                    
                    //For Germany
                    if (anAccount.CountryRef__c != null)
                    {
                        CountryAdapter country = new CountryAdapter(anAccount);
                        if(country.isGermanActionPlan || Test.isRunningTest())
                        {
                        
                           // if(userDivision == 'Corn' || userDivision == 'OSR'){
                                if (aGroupId == (Util.getProductGroup(Util.PRODUCT_GROUP_WINTER_WHEAT)) || aGroupId == (Util.getProductGroup(Util.PRODUCT_GROUP_TRITICALE)) || aGroupName.contains('Barley'))
                                {
                                    anAccount.DE_TotalCerealAcreagesPY__c += anItem.AcrTotalAcreages__c;
                                }else if(aGroupId != (Util.getProductGroup(Util.PRODUCT_GROUP_CORN)) && aGroupId != (Util.getProductGroup(Util.PRODUCT_GROUP_OSR)) && aGroupId != (Util.getProductGroup(Util.PRODUCT_GROUP_WINTER_WHEAT)) && aGroupId != (Util.getProductGroup(Util.PRODUCT_GROUP_TRITICALE)) && !aGroupName.contains('Barley')){
                                    anAccount.TotalOtherAcreagesManualPY__c += anItem.AcrTotalAcreages__c;
                                }
                                
                                //MARKET SHARE
                                if (aGroupId == (Util.getProductGroup(Util.PRODUCT_GROUP_CORN)))
                                {
                                    if (anIsMonsanto)
                                    {
                                        MonsantoCornAcreagePY += anItem.AcrTotalAcreages__c;
                                    }
                                    
                                    if (anAccount.CornTotalAcreagesPY__c != 0)
                                    {
                                        anAccount.DE_CornDekalbMarketsharePY__c = (MonsantoCornAcreagePY/anAccount.CornTotalAcreagesPY__c);
                                    }
                                    
                                } else if (aGroupId == Util.getProductGroup(Util.PRODUCT_GROUP_OSR))
                                {
                                    if (anIsMonsanto)
                                    {
                                        MonsantoOSRAcreagePY += anItem.AcrTotalAcreages__c;
                                    }
                                    if (anAccount.OSRTotalAcreagesPY__c != 0)
                                    {
                                        anAccount.DE_OSRDekalbMarketsharePY__c = (MonsantoOSRAcreagePY/anAccount.OSRTotalAcreagesPY__c);
                                    }
                                }
                                //THE END MARKET SHARE
                           // }
                            
                           // if(userDivision == 'Latitude' || userDivision == 'Monitor' || userDivision == 'Roundup'){
                               
                                if (!aGroupName.contains('Greenland') && aGroupId != (Util.getProductGroup(Util.PRODUCT_GROUP_OTHER_HERBACEOUS_CROPS)))
                                {                                
                                    anAccount.DE_TotalArableAcreagesPY__c += anItem.AcrTotalAcreages__c;
                                }else if (aGroupName.contains('Greenland') || aGroupId == (Util.getProductGroup(Util.PRODUCT_GROUP_OTHER_HERBACEOUS_CROPS)))
                                {                                   
                                    anAccount.DE_Total_Other_Acreages_PY__c += anItem.AcrTotalAcreages__c;
                                }
                           // }
                        }
                    }
                    //The end
                    anAccount.TotalAcreagesPY__c += anItem.AcrTotalAcreages__c;
                }
            }
            return anAccount;
        }
    }
}