public class CP_forecastSKUDistributionController
{
 
    public List<itemForecast> forecastPreview{get;set;}
    public List<itemForecast> forecastEditable{get;set;}
    public List<familyTotal> listaPintarForecast{get;set;}
    // public List<SelectOption> fiscalYearSelected {get;set;}
    public Action_Plan_Line__c aplFY {get; set;}
    public Country__c country {get; set;}
    public Id recordTypeForecast;
    private List<Product2> listProduct = new List<Product2>();
    private List<String> listPeriods = new List<String>();
    private Map<String, Decimal> mapActionPlanForecast = new Map<String, Decimal>();
    private Map<String, Decimal> mapActionPlanForecastRel = new Map<String, Decimal>();
    private Map<String, Decimal> mapActionPlanForecastManager = new Map<String, Decimal>();
    private Map<String, Decimal> mapActionPlanForecastRelManager = new Map<String, Decimal>();
    private Map<String, Decimal> mapActionPlanDelivered = new Map<String, Decimal>();
    private Map<String, Decimal> mapActionPlanDeliveredRel = new Map<String, Decimal>();
    public Map<String, List<familyTotal>> mapProductFamilyTOTAL {get; set;}

    public CP_forecastSKUDistributionController()
    {
        /*
            Fiscal year filter options
            Consider substitution by custom list of selectoptions with only CY and PY
        */      
       aplFY = new Action_Plan_Line__c();
       if((System.Date.today().month() >= 9) && (System.Date.today().month() <= 12))  aplFY.PICK_Forecast_Fiscal_Year__c = String.valueOf(System.Date.today().year()+1);
       else if((System.Date.today().month() >= 1) && (System.Date.today().month() <= 8)) aplFY.PICK_Forecast_Fiscal_Year__c = String.valueOf(System.Date.today().year());
       
       //Record Type ActionPlanLine Forecast
       recordTypeForecast = Util.recordtype.get('Action_Plan_Line__c:CP_Forecast');
       
       //Get Units of Measurement
       User currentuser = [SELECT Id, Name, Country FROM User WHERE Id=:userinfo.getuserId()];
       if(currentUser.Country != null) country = [SELECT Id, Units_of_Measurement__c, Name FROM Country__c WHERE Name =: currentUser.Country];
       
       initializePeriods();
       
        /*
            Retrieve available products based on pricebook visibility
        */
       List<ID> listaCatalogosId = new List<ID>();
       List<ID> listaCatalogosFiltrada = new List<ID>();       
       for(pricebook2 itemP : [select id from pricebook2 WHERE CP_Account_Type__c = 'Distributor' AND isActive = true AND CountryRef__r.Name =: country.Name])
       {
           listaCatalogosId.add(itemP.id);
       }
       for(UserRecordAccess itemU : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE userid=:Userinfo.getUserId() and RecordID IN :listaCatalogosId ])
       {
            if(itemU.HasReadAccess)
               listaCatalogosFiltrada.add(itemU.RecordId); 
       }
       
       listProduct = [SELECT Id, Name, TXT_commercial_name__c, Family FROM Product2 WHERE Id IN (SELECT Product2Id FROM PriceBookEntry WHERE pricebook2id in :listaCatalogosFiltrada AND isActive = true) order by NUM_AP_CP_Custom_Order__c, TXT_commercial_name__c];
       
       getData();    
    }
    
    /*
        Main method to retrieve existing data from the syste
    */
    public void getData()
    {
       forecastPreview = new List<itemForecast>();
       forecastEditable = new List<itemForecast>();
       mapProductFamilyTOTAL = new map<String, List<familyTotal>>();
       /*
            Execution of queries and generation of maps based on external IDs
       */
       initializeAplForecast();
       Integer sum, sumrel;
       Integer totalFor, totalForRel;
       
       /*
        For each available product, a line with data for all the months is created and added to a list
       */
       for(Product2 p : listProduct)
       { 
           String pr2Id = ((String)p.Id).substring(0,15);
           /*
                Create Action Plan Line Forecast item
                Contains one APL for each period and fields to store totals in RELS and units
            */
           itemForecast item = new itemForecast(pr2Id, aplFY.PICK_Forecast_Fiscal_Year__c, UserInfo.getUserId().substring(0,15), recordTypeForecast);           
           item.product = p.TXT_commercial_name__c;
           sum = 0;
           sumrel = 0;            
           /*
                Retrieve data from queries to fill the necessary fields
                Use the external ID as parameter for the method
           */
           generateData(item.forecastSeptember, pr2Id + '-' + String.valueOf((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1)) + '-' + '09' + '-' + UserInfo.getUserId().substring(0,15));
           generateData(item.forecastOctober, pr2Id + '-' + String.valueOf((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1)) + '-' + '10' + '-' + UserInfo.getUserId().substring(0,15));
           generateData(item.forecastNovember, pr2Id + '-' + String.valueOf((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1)) + '-' + '11' + '-' + UserInfo.getUserId().substring(0,15));
           generateData(item.forecastDecember, pr2Id + '-' + String.valueOf((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1)) + '-' + '12' + '-' + UserInfo.getUserId().substring(0,15));
           generateData(item.forecastJanuary, pr2Id + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '01' + '-' + UserInfo.getUserId().substring(0,15));
           generateData(item.forecastFebruary, pr2Id + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '02' + '-' + UserInfo.getUserId().substring(0,15));
           generateData(item.forecastMarch, pr2Id + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '03' + '-' + UserInfo.getUserId().substring(0,15));
           generateData(item.forecastApril, pr2Id + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '04' + '-' + UserInfo.getUserId().substring(0,15));
           generateData(item.forecastMay, pr2Id + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '05' + '-' + UserInfo.getUserId().substring(0,15));
           generateData(item.forecastJune, pr2Id + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '06' + '-' + UserInfo.getUserId().substring(0,15));
           generateData(item.forecastJuly, pr2Id + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '07' + '-' + UserInfo.getUserId().substring(0,15));
           generateData(item.forecastAugust, pr2Id + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '08' + '-' + UserInfo.getUserId().substring(0,15));
            
            /*
                Method to calculate total units per row
            */
           //Total Forecast Units (taula est�tica)
           item.totalForecastUnits = item.getTotalUnits(Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c), true);
           //Total Forecast Rels (taula est�tica)
           item.totalForecastRels = item.getTotalRels(Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c), true);
           //Total Units
           item.totalUnits = item.getTotalUnits(Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c), false);
           //Total Rels
           item.totalRels = item.getTotalRels(Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c), false);
           
       
// Create Product Families map for the totals rows.
           if(mapProductFamilyTOTAL.get(p.Family) == null)
           {
               List<familyTotal> listaFamily = new List<familyTotal>();
               listaFamily.add(new familyTotal(item));
               mapProductFamilyTOTAL.put(p.Family, listaFamily);
           }
            else
            {
                mapProductFamilyTOTAL.get(p.Family).add(new familyTotal(item));
            }                                               
           
           
           forecastPreview.add(item);
           forecastEditable.add(item);
       }
       
//Calculation of total rows per family
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        if(currentUser.Country != null) country = [SELECT Id, Units_of_Measurement__c FROM Country__c WHERE Name =: currentUser.Country];
        for(String key : mapProductFamilyTOTAL.keySet())
        {
            // Inicialitzaci� a zero del camp on es guardaran els recomptes totals.
            itemForecast forecastAux = (mapProductFamilyTOTAL.get(key)[0].elemForecast).clone(); 
                
            /*
                Creation of totals line
            */          
            familyTotal totalLine = new FamilyTotal(forecastAux); 
            totalLine.elemForecast.totalForecastUnits = 0 ;
            totalLine.elemForecast.totalForecastRels = 0 ;    
            totalLine.elemForecast.totalUnits = 0 ;
            totalLine.elemForecast.totalRels = 0 ;          
            totalLine.elemForecast.forecastSeptember = new Action_Plan_Line__c(NUM_Forecast_SKU__c=0,NUM_Forecast_SKU_Rel__c=0);
            totalLine.elemForecast.forecastOctober = new Action_Plan_Line__c(NUM_Forecast_SKU__c=0,NUM_Forecast_SKU_Rel__c=0);
            totalLine.elemForecast.forecastNovember = new Action_Plan_Line__c(NUM_Forecast_SKU__c=0,NUM_Forecast_SKU_Rel__c=0);
            totalLine.elemForecast.forecastDecember = new Action_Plan_Line__c(NUM_Forecast_SKU__c=0,NUM_Forecast_SKU_Rel__c=0);
            totalLine.elemForecast.forecastJanuary = new Action_Plan_Line__c(NUM_Forecast_SKU__c=0,NUM_Forecast_SKU_Rel__c=0);
            totalLine.elemForecast.forecastFebruary = new Action_Plan_Line__c(NUM_Forecast_SKU__c=0,NUM_Forecast_SKU_Rel__c=0);
            totalLine.elemForecast.forecastMarch = new Action_Plan_Line__c(NUM_Forecast_SKU__c=0,NUM_Forecast_SKU_Rel__c=0);
            totalLine.elemForecast.forecastApril = new Action_Plan_Line__c(NUM_Forecast_SKU__c=0,NUM_Forecast_SKU_Rel__c=0);
            totalLine.elemForecast.forecastMay = new Action_Plan_Line__c(NUM_Forecast_SKU__c=0,NUM_Forecast_SKU_Rel__c=0);
            totalLine.elemForecast.forecastJune = new Action_Plan_Line__c(NUM_Forecast_SKU__c=0,NUM_Forecast_SKU_Rel__c=0);
            totalLine.elemForecast.forecastJuly = new Action_Plan_Line__c(NUM_Forecast_SKU__c=0,NUM_Forecast_SKU_Rel__c=0);
            totalLine.elemForecast.forecastAugust = new Action_Plan_Line__c(NUM_Forecast_SKU__c=0,NUM_Forecast_SKU_Rel__c=0);                        
            
            totalLine.name = 'TOTAL ' + key + ' (Rels)';
            totalLine.total = true;
            
            // Loop through each line that belongs to a total
            for(familyTotal productLine : mapProductFamilyTOTAL.get(key))
            {
                // Calculation of forecast, adding up the forecast for each line
                //if(productLine.elemForecast.forecastSeptember.NUM_Forecast_SKU__c != null || productLine.elemForecast.forecastSeptember.NUM_Delivered__c!=null) totalLine.elemForecast.forecastSeptember.NUM_Forecast_SKU__c += (productLine.elemForecast.forecastSeptember.NUM_Delivered__c!=null? Integer.valueOf(productLine.elemForecast.forecastSeptember.NUM_Delivered__c) :  Integer.valueOf(productLine.elemForecast.forecastSeptember.NUM_Forecast_SKU__c));
                totalLine.elemForecast.forecastSeptember.NUM_Forecast_SKU__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1), 9, 'Rels');
                totalLine.elemForecast.forecastOctober.NUM_Forecast_SKU__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1), 10, 'Rels');
                totalLine.elemForecast.forecastNovember.NUM_Forecast_SKU__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1), 11, 'Rels');
                totalLine.elemForecast.forecastDecember.NUM_Forecast_SKU__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1), 12, 'Rels');
                totalLine.elemForecast.forecastJanuary.NUM_Forecast_SKU__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 1, 'Rels');
                totalLine.elemForecast.forecastFebruary.NUM_Forecast_SKU__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 2, 'Rels');
                totalLine.elemForecast.forecastMarch.NUM_Forecast_SKU__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 3, 'Rels');
                totalLine.elemForecast.forecastApril.NUM_Forecast_SKU__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 4, 'Rels');
                totalLine.elemForecast.forecastMay.NUM_Forecast_SKU__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 5, 'Rels');
                totalLine.elemForecast.forecastJune.NUM_Forecast_SKU__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 6, 'Rels');
                totalLine.elemForecast.forecastJuly.NUM_Forecast_SKU__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 7, 'Rels');
                totalLine.elemForecast.forecastAugust.NUM_Forecast_SKU__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 8, 'Rels');

                // Calculation of totals and totals in rels depending on country specification
                // NEW REQUIREMENT---> TOTAL QUANTITY FOR THE FAMILIES ALWAYS IN RELS

                totalLine.elemForecast.forecastSeptember.NUM_Forecast_SKU_Rel__c += productLine.elemForecast.forecastSeptember.NUM_Forecast_SKU_Rel__c!=null? productLine.elemForecast.forecastSeptember.NUM_Forecast_SKU_Rel__c: 0;
                totalLine.elemForecast.forecastOctober.NUM_Forecast_SKU_Rel__c += productLine.elemForecast.forecastOctober.NUM_Forecast_SKU_Rel__c!=null? productLine.elemForecast.forecastOctober.NUM_Forecast_SKU_Rel__c: 0;
                totalLine.elemForecast.forecastNovember.NUM_Forecast_SKU_Rel__c += productLine.elemForecast.forecastNovember.NUM_Forecast_SKU_Rel__c!=null? productLine.elemForecast.forecastNovember.NUM_Forecast_SKU_Rel__c: 0;
                totalLine.elemForecast.forecastDecember.NUM_Forecast_SKU_Rel__c += productLine.elemForecast.forecastDecember.NUM_Forecast_SKU_Rel__c!=null? productLine.elemForecast.forecastDecember.NUM_Forecast_SKU_Rel__c: 0;
                totalLine.elemForecast.forecastJanuary.NUM_Forecast_SKU_Rel__c += productLine.elemForecast.forecastJanuary.NUM_Forecast_SKU_Rel__c!=null? productLine.elemForecast.forecastJanuary.NUM_Forecast_SKU_Rel__c: 0;
                totalLine.elemForecast.forecastFebruary.NUM_Forecast_SKU_Rel__c += productLine.elemForecast.forecastFebruary.NUM_Forecast_SKU_Rel__c!=null? productLine.elemForecast.forecastFebruary.NUM_Forecast_SKU_Rel__c: 0;
                totalLine.elemForecast.forecastMarch.NUM_Forecast_SKU_Rel__c += productLine.elemForecast.forecastMarch.NUM_Forecast_SKU_Rel__c!=null? productLine.elemForecast.forecastMarch.NUM_Forecast_SKU_Rel__c: 0;
                totalLine.elemForecast.forecastApril.NUM_Forecast_SKU_Rel__c += productLine.elemForecast.forecastApril.NUM_Forecast_SKU_Rel__c!=null? productLine.elemForecast.forecastApril.NUM_Forecast_SKU_Rel__c: 0;
                totalLine.elemForecast.forecastMay.NUM_Forecast_SKU_Rel__c += productLine.elemForecast.forecastMay.NUM_Forecast_SKU_Rel__c!=null? productLine.elemForecast.forecastMay.NUM_Forecast_SKU_Rel__c: 0;
                totalLine.elemForecast.forecastJune.NUM_Forecast_SKU_Rel__c += productLine.elemForecast.forecastJune.NUM_Forecast_SKU_Rel__c!=null? productLine.elemForecast.forecastJune.NUM_Forecast_SKU_Rel__c: 0;
                totalLine.elemForecast.forecastJuly.NUM_Forecast_SKU_Rel__c += productLine.elemForecast.forecastJuly.NUM_Forecast_SKU_Rel__c!=null? productLine.elemForecast.forecastJuly.NUM_Forecast_SKU_Rel__c: 0;
                totalLine.elemForecast.forecastAugust.NUM_Forecast_SKU_Rel__c += productLine.elemForecast.forecastAugust.NUM_Forecast_SKU_Rel__c!=null? productLine.elemForecast.forecastAugust.NUM_Forecast_SKU_Rel__c: 0;
                    
                totalLine.elemForecast.totalForecastUnits += productLine.elemForecast.totalForecastUnits ;
                totalLine.elemForecast.totalForecastRels += productLine.elemForecast.totalForecastRels ;    
                totalLine.elemForecast.totalUnits += productLine.elemForecast.totalUnits ;
                totalLine.elemForecast.totalRels += productLine.elemForecast.totalRels ;                    
            }                   
            mapProductFamilyTOTAL.get(key).add(totalLine);
        }
        listaPintarForecast = new list<familyTotal>();
        for(String s : mapProductFamilyTOTAL.keySet())
        {
            listaPintarForecast.addAll(mapProductFamilyTOTAL.get(s));
        }       
    }
 
 /*
    Method to retrieve data from queries and initialize each APL for the table
 */
private void generateData(Action_Plan_Line__c item, String key)
           {
                // Forecast SKU
                item.NUM_Forecast_SKU__c = mapActionPlanForecast.get(key);
                // Forecast Rel
                item.NUM_Forecast_SKU_Rel__c = mapActionPlanForecastRel.get(key);
                //Delivered
                item.NUM_Delivered__c = mapActionPlanDelivered.get(key);
                //Delivered Rel
                item.NUM_Sell_In__c = mapActionPlanDeliveredRel.get(key);
                // Team's forecast
                item.NUM_Budget__c = mapActionPlanForecastManager.get(key);
                //Team's forecast Rel
                item.NUM_Budget_Rel__c = mapActionPlanForecastRelManager.get(key);
           }
           
    public void saveForecastSKU()
    {
        Decimal sumPreview, sumRelPreview;
        List<Action_Plan_Line__c> aplUpserted = new List<Action_Plan_Line__c>();
        
        for(itemForecast item : forecastEditable)
        {
            aplUpserted.add(item.forecastSeptember);
            aplUpserted.add(item.forecastOctober);
            aplUpserted.add(item.forecastNovember);
            aplUpserted.add(item.forecastDecember);
            aplUpserted.add(item.forecastJanuary);
            aplUpserted.add(item.forecastFebruary);
            aplUpserted.add(item.forecastMarch);
            aplUpserted.add(item.forecastApril);
            aplUpserted.add(item.forecastMay);
            aplUpserted.add(item.forecastJune);
            aplUpserted.add(item.forecastJuly);
            aplUpserted.add(item.forecastAugust);           
        }
        //Make sure that auxiliary fields for the page view don't get saved
        for(Action_Plan_Line__c item : aplUpserted)
        {
            item.NUM_Sell_In__c=0;
            item.NUM_Delivered__c=0;
            item.NUM_Budget__c=0;
            item.NUM_Budget_REl__c=0;
        }
        Schema.SObjectField f = Action_Plan_Line__c.Fields.TXT_External_ID__c;
        Database.upsert(aplUpserted, f, false);
        getData();
    }
    
    /*
        Queries
    */
    private void initializeAplForecast()
    {
       for(Action_Plan_Line__c apl : [SELECT Id, TXT_External_ID__c, NUM_Forecast_SKU__c, NUM_Forecast_SKU_Rel__c FROM Action_Plan_Line__c WHERE RecordTypeID =:recordTypeForecast AND LKP_SKU__c IN :listProduct  AND OwnerId =:userinfo.getuserid()])
       {    
            mapActionPlanForecast.put(apl.TXT_External_ID__c, apl.NUM_Forecast_SKU__c);
            mapActionPlanForecastRel.put(apl.TXT_External_ID__c, apl.NUM_Forecast_SKU_Rel__c);
            mapActionPlanForecastManager.put(apl.TXT_External_ID__c, apl.NUM_Forecast_SKU__c);
            mapActionPlanForecastRelManager.put(apl.TXT_External_ID__c, apl.NUM_Forecast_SKU_Rel__c);
       } 
       List<AggregateResult> listaForecastTeam = [SELECT PICK_Period__c, lkp_sku__c, sum(NUM_Forecast_SKU__c) sku, sum(NUM_Forecast_SKU_Rel__c) rel FROM Action_Plan_Line__c WHERE RecordTypeID =:recordTypeForecast AND LKP_SKU__c IN :listProduct  AND (createdby.managerId =:userinfo.getuserid() OR createdby.manager.managerId =:userinfo.getuserid()) group by PICK_Period__c, lkp_sku__c];
       if(listaForecastTeam.size() > 0)
       {
            mapActionPlanForecastManager=new Map<String, Decimal>();
            mapActionPlanForecastRelManager=new Map<String, Decimal>();
       }
       for(AggregateResult res : listaForecastTeam) 
       {    
            mapActionPlanForecastManager.put(res.get('lkp_sku__c')  + '-' + res.get('PICK_Period__c')  + '-' + UserInfo.getUserId().substring(0,15), (Decimal)res.get('sku'));
            mapActionPlanForecastRelManager.put(res.get('lkp_sku__c')  + '-' + res.get('PICK_Period__c')  + '-' + UserInfo.getUserId().substring(0,15), (Decimal)res.get('rel'));
           
       } 
                       
        for(AggregateResult  res : [SELECT PICK_Period__c, lkp_sku__c, sum(NUM_Delivered__c) delivered, sum(FRML_Delivered_Rel__c) deliveredRel FROM Action_Plan_Line__c WHERE RecordTypeID =:Util.recordtype.get('Action_Plan_Line__c:Action_Plan_Line') AND LKP_SKU__c IN :listProduct  AND (LKP_Account__r.OwnerId =:userinfo.getuserid() OR LKP_Account__r.Owner.ManagerId =:userinfo.getuserid() OR LKP_Account__r.Owner.manager.managerid =:userinfo.getuserid()) group by PICK_Period__c, lkp_sku__c])
       {    
            mapActionPlanDelivered.put(res.get('lkp_sku__c')  + '-' + res.get('PICK_Period__c')  + '-' + UserInfo.getUserId().substring(0,15), (Decimal)res.get('delivered'));
            mapActionPlanDeliveredrel.put(res.get('lkp_sku__c')  + '-' + res.get('PICK_Period__c')  + '-' + UserInfo.getUserId().substring(0,15), (Decimal)res.get('deliveredRel'));
       }       
    }
    
    // Auxiliar method to construct list of FY periods based on FY selected
    private void initializePeriods()
    {
        for(Integer i=1; i <13; i++)
        {
            if(i < 10) listPeriods.add(aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '0' + String.valueOf(i));
            else listPeriods.add(aplFY.PICK_Forecast_Fiscal_Year__c + '-' + String.valueOf(i));
        }        
    }
    
    public String previousFY
    {
        get
        {
           return String.valueOf((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1));
        }
        set{}
    }
    // To enable edition on touchable devices
    public String getIsDevice()
    {
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
         
        //& some devices use custom headers for the user-agent.
        if (userAgent==null || userAgent.length()==0){
            userAgent = ApexPages.currentPage().getHeaders().get('HTTP_X_OPERAMINI_PHONE_UA');
        }       
        if (userAgent==null || userAgent.length()==0){
            userAgent = ApexPages.currentPage().getHeaders().get('HTTP_X_SKYFIRE_PHONE');
        }
                 
        //& replace with custom setting - using (?i) case insensitive mode.     
        String deviceReg = '(?i)(iphone|ipod|ipad|blackberry|android|palm|windows\\s+ce)';
        String desktopReg = '(?i)(windows|linux|os\\s+[x9]|solaris|bsd)';
        String botReg = '(?i)(spider|crawl|slurp|bot)';
        
        if(!Test.isRunningTest())
        {
            Matcher m = Pattern.compile(deviceReg).matcher(userAgent);
            return m.find()?'true':'false';
        }
        else return 'true';
    }
    
    public class itemForecast
    {
        public String product {get; set;}
        public Id productId {get; set;}
        public Action_Plan_Line__c forecastJanuary{get; set;}
        public Action_Plan_Line__c forecastFebruary {get; set;}
        public Action_Plan_Line__c forecastMarch {get; set;}
        public Action_Plan_Line__c forecastApril{get; set;}
        public Action_Plan_Line__c forecastMay {get; set;}
        public Action_Plan_Line__c forecastJune {get; set;}
        public Action_Plan_Line__c forecastJuly{get; set;}
        public Action_Plan_Line__c forecastAugust {get; set;}
        public Action_Plan_Line__c forecastSeptember {get; set;}
        public Action_Plan_Line__c forecastOctober{get; set;}
        public Action_Plan_Line__c forecastNovember {get; set;}
        public Action_Plan_Line__c forecastDecember {get; set;}     
        public Decimal totalUnits {get; set;}
        public Decimal totalRels {get; set;}
        public Decimal totalForecastUnits {get; set;}
        public Decimal totalForecastRels {get; set;}      
        
        //Retrieve total for a year, month and unit
        public Decimal getTotalValue(Integer yr, Integer mnth, string unit)
        {
            return getTotalValueCombo(yr, mnth, unit, false);           
        }
        
        //Retrieve total for a year, month and unit forcing forecast only data, not closed sales
        public Decimal getTotalValue(Integer yr, Integer mnth, string unit, boolean forceForecast)
        {
            return getTotalValueCombo(yr, mnth, unit, forceForecast);           
        }

        public Decimal getTotalValueCombo(Integer yr, Integer mnth, string unit/*, itemForecast item*/,boolean forceNotDelivered)
        {
            map<integer, string> months = new map<integer, string>{1=>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May', 6=>'June', 7=>'July', 8=>'August', 9=>'September', 10=>'October', 11=>'November', 12=>'December'};      

            if (unit=='Basic Units'){   
                if (mnth==1){
                    return (this.forecastJanuary.NUM_Forecast_SKU__c)!=null?((Decimal)this.forecastJanuary.NUM_Forecast_SKU__c):0;
                } else if(mnth==2){
                    return (this.forecastFebruary.NUM_Forecast_SKU__c)!=null?((Decimal)this.forecastFebruary.NUM_Forecast_SKU__c):0;
                } else if(mnth==3){
                    return (this.forecastMarch.NUM_Forecast_SKU__c)!=null?((Decimal)this.forecastMarch.NUM_Forecast_SKU__c):0;
                } else if(mnth==4){
                    return (this.forecastApril.NUM_Forecast_SKU__c)!=null?((Decimal)this.forecastApril.NUM_Forecast_SKU__c):0;
                } else if(mnth==5){
                    return (this.forecastMay.NUM_Forecast_SKU__c)!=null?((Decimal)this.forecastMay.NUM_Forecast_SKU__c):0;
                } else if(mnth==6){
                    return (this.forecastJune.NUM_Forecast_SKU__c)!=null?((Decimal)this.forecastJune.NUM_Forecast_SKU__c):0;
                } else if(mnth==7){
                    return (this.forecastJuly.NUM_Forecast_SKU__c)!=null?((Decimal)this.forecastJuly.NUM_Forecast_SKU__c):0;
                } else if(mnth==8){
                    return (this.forecastAugust.NUM_Forecast_SKU__c)!=null?((Decimal)this.forecastAugust.NUM_Forecast_SKU__c):0;
                } else if(mnth==9){
                    return (this.forecastSeptember.NUM_Forecast_SKU__c)!=null?((Decimal)this.forecastSeptember.NUM_Forecast_SKU__c):0;
                } else if(mnth==10){
                    return (this.forecastOctober.NUM_Forecast_SKU__c)!=null?((Decimal)this.forecastOctober.NUM_Forecast_SKU__c):0;
                } else if(mnth==11){
                    return (this.forecastNovember.NUM_Forecast_SKU__c)!=null?((Decimal)this.forecastNovember.NUM_Forecast_SKU__c):0;
                } else /*if (mnth==12)*/{   
                    return (this.forecastDecember.NUM_Forecast_SKU__c)!=null?((Decimal)this.forecastDecember.NUM_Forecast_SKU__c):0;                                                
                }
                                            
            } else {
                
                if (mnth==1){
                    return (this.forecastJanuary.NUM_Forecast_SKU_Rel__c)!=null?((Decimal)this.forecastJanuary.NUM_Forecast_SKU_Rel__c):0;
                } else if(mnth==2){
                    return (this.forecastFebruary.NUM_Forecast_SKU_Rel__c)!=null?((Decimal)this.forecastFebruary.NUM_Forecast_SKU_Rel__c):0;
                } else if(mnth==3){
                    return (this.forecastMarch.NUM_Forecast_SKU_Rel__c)!=null?((Decimal)this.forecastMarch.NUM_Forecast_SKU_Rel__c):0;
                } else if(mnth==4){
                    return (this.forecastApril.NUM_Forecast_SKU_Rel__c)!=null?((Decimal)this.forecastApril.NUM_Forecast_SKU_Rel__c):0;
                } else if(mnth==5){
                    return (this.forecastMay.NUM_Forecast_SKU_Rel__c)!=null?((Decimal)this.forecastMay.NUM_Forecast_SKU_Rel__c):0;
                } else if(mnth==6){
                    return (this.forecastJune.NUM_Forecast_SKU_Rel__c)!=null?((Decimal)this.forecastJune.NUM_Forecast_SKU_Rel__c):0;
                } else if(mnth==7){
                    return (this.forecastJuly.NUM_Forecast_SKU_Rel__c)!=null?((Decimal)this.forecastJuly.NUM_Forecast_SKU_Rel__c):0;
                } else if(mnth==8){
                    return (this.forecastAugust.NUM_Forecast_SKU_Rel__c)!=null?((Decimal)this.forecastAugust.NUM_Forecast_SKU_Rel__c):0;
                } else if(mnth==9){
                    return (this.forecastSeptember.NUM_Forecast_SKU_Rel__c)!=null?((Decimal)this.forecastSeptember.NUM_Forecast_SKU_Rel__c):0;
                } else if(mnth==10){
                    return (this.forecastOctober.NUM_Forecast_SKU_Rel__c)!=null?((Decimal)this.forecastOctober.NUM_Forecast_SKU_Rel__c):0;
                } else if(mnth==11){
                    return (this.forecastNovember.NUM_Forecast_SKU_Rel__c)!=null?((Decimal)this.forecastNovember.NUM_Forecast_SKU_Rel__c):0;
                } else /*if (mnth==12)*/{   
                    return (this.forecastDecember.NUM_Forecast_SKU_Rel__c)!=null?((Decimal)this.forecastDecember.NUM_Forecast_SKU_Rel__c):0;                                                
                }
                // return this.('forecast' + months.get(mnth)).NUM_Forecast_SKU_Rel__c!=null?this.('forecast' + months.get(mnth)).NUM_Forecast_SKU_Rel__c:0;    
            }
        }
        
        /*
            Implements a loop to automatically retrieve the total in units for a year
        */
        public Decimal getTotalUnits(Integer yr, boolean forceForecast)
        {   
            List<Integer> listaMeses = new List<Integer> {(yr-1),9,(yr-1),10,(yr-1),11,(yr-1),12,yr,1,yr,2,yr,3,yr,4,yr,5,yr,6,yr,7,yr,8};

            
            Decimal suma = 0;
            Integer i = 0;
            while(i<listaMeses.size())
            {
                suma += getTotalValue(listaMeses[i], listaMeses[i+1],'Basic Units',forceForecast);
                i=i+2;
            }
            return suma;            
        }
        
        /*
            Implements a loop to automatically retrieve the total in Rels for a year
        */
        public Decimal getTotalRels(Integer yr, boolean forceForecast)
        {   
            List<Integer> listaMeses = new List<Integer> {(yr-1),9,(yr-1),10,(yr-1),11,(yr-1),12,yr,1,yr,2,yr,3,yr,4,yr,5,yr,6,yr,7,yr,8};

            
            Decimal suma = 0;
            Integer i = 0;
            while(i<listaMeses.size())
            {
                suma += getTotalValue(listaMeses[i], listaMeses[i+1],'Rels',forceForecast);
                i=i+2;
            }
            return suma;
        }
        
        /*
            Instance declaration
            Initializes all the 12 month action plan line items
        */
        itemForecast(String sku, String fy, String userId, Id recordTypeForecast)
        {
            forecastSeptember = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_sku__c = sku, pick_period__c=String.valueOf((Integer.valueOf(fy)-1)) + '-' + '09', TXT_External_ID__c = string.valueOf(sku).substring(0,15) + '-' + String.valueOf((Integer.valueOf(fy)-1)) + '-' + '09' + '-' + userId);
            forecastOctober= new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_sku__c = sku, pick_period__c=String.valueOf((Integer.valueOf(fy)-1)) + '-' + '10',TXT_External_ID__c = string.valueOf(sku).substring(0,15) + '-' + String.valueOf((Integer.valueOf(fy)-1)) + '-' + '10' + '-' + userId);
            forecastNovember = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_sku__c = sku, pick_period__c=String.valueOf((Integer.valueOf(fy)-1)) + '-' + '11',TXT_External_ID__c = string.valueOf(sku).substring(0,15) + '-' + String.valueOf((Integer.valueOf(fy)-1)) + '-' + '11' + '-' + userId);
            forecastDecember = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_sku__c = sku, pick_period__c=String.valueOf((Integer.valueOf(fy)-1)) + '-' + '12',TXT_External_ID__c = string.valueOf(sku).substring(0,15) + '-' + String.valueOf((Integer.valueOf(fy)-1)) + '-' + '12' + '-' + userId);
            forecastJanuary = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_sku__c = sku, pick_period__c=fy + '-' + '01',TXT_External_ID__c = string.valueOf(sku).substring(0,15) + '-' + fy + '-' + '01' + '-' + userId);
            forecastFebruary = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_sku__c = sku, pick_period__c=fy + '-' + '02',TXT_External_ID__c = string.valueOf(sku).substring(0,15) + '-' + fy + '-' + '02' + '-' + userId);
            forecastMarch = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_sku__c = sku, pick_period__c=fy + '-' + '03',TXT_External_ID__c = string.valueOf(sku).substring(0,15) + '-' + fy + '-' + '03' + '-' + userId);
            forecastApril= new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_sku__c = sku, pick_period__c=fy + '-' + '04',TXT_External_ID__c = string.valueOf(sku).substring(0,15) + '-' + fy + '-' + '04' + '-' + userId);
            forecastMay = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_sku__c = sku, pick_period__c=fy + '-' + '05',TXT_External_ID__c = string.valueOf(sku).substring(0,15) + '-' + fy + '-' + '05' + '-' + userId);
            forecastJune = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_sku__c = sku, pick_period__c=fy + '-' + '06',TXT_External_ID__c = string.valueOf(sku).substring(0,15) + '-' + fy + '-' + '06' + '-' + userId);
            forecastJuly= new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_sku__c = sku, pick_period__c=fy + '-' + '07',TXT_External_ID__c = string.valueOf(sku).substring(0,15) + '-' + fy + '-' + '07' + '-' + userId);
            forecastAugust = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_sku__c = sku, pick_period__c=fy + '-' + '08',TXT_External_ID__c = string.valueOf(sku).substring(0,15) + '-' + fy + '-' + '08' + '-' + userId);
        }
    }
    
    /*
        This class is used to contain all the product lines and the total item.
        If total, the boolean is set to true
    */
    public class familyTotal
    {
        public Boolean total {get; set;}
        public String name {get; set;}
        public itemForecast elemForecast {get; set;}

        public familyTotal(itemForecast item)
        {
            total = false;
            name = '';
            elemForecast = item;            
        }
    }
    
}