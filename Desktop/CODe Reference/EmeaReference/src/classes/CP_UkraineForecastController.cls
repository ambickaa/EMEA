public class CP_UkraineForecastController
{
    public list<SelectOption> allProducts{get; set;}
    public List<SelectOption> selectedProducts{get; set;}
    public List<SelectOption> allDistributors{get; set;}
    public List<SelectOption> selectedDistributors{get; set;}
    /* public List<SelectOption> allDistributors{get; set;}
    public List<SelectOption> selectedDistributors{get; set;} */
    public List<itemForecast> forecastPreview{get;set;}
    public List<itemForecast> forecastEditable{get;set;}
    public Map<String, Action_Plan_Line__c> Map_Forecast_Values;
    public List<familyTotal> listaPintarForecast{get;set;}
    // public List<SelectOption> fiscalYearSelected {get;set;}
    public Action_Plan_Line__c aplFY {get; set;}
    public Country__c country {get; set;}
    public Id recordTypeForecast;
    private List<Product2> listProduct = new List<Product2>();
    private List<Account> listDist = new List<Account>();
    private List<String> listPeriods = new List<String>();
    private Map<String, Decimal> mapActionPlanForecast = new Map<String, Decimal>();
    private Map<String, Decimal> mapActionPlanForecastRel = new Map<String, Decimal>();
    private Map<String, Decimal> mapActionPlanForecastManager = new Map<String, Decimal>();
    private Map<String, Decimal> mapActionPlanForecastRelManager = new Map<String, Decimal>();
    private Map<String, Decimal> mapActionPlanDelivered = new Map<String, Decimal>();
    private Map<String, Decimal> mapActionPlanDeliveredRel = new Map<String, Decimal>();
    public Map<String, List<familyTotal>> mapProductFamilyTOTAL {get; set;}

    public CP_UKRAINEforecastController()
    {
       forecastPreview = new List<itemForecast>();
       forecastEditable = new List<itemForecast>(); 
       List<ID> listaCatalogosId = new List<ID>();
       List<ID> listaCatalogosFiltrada = new List<ID>();       
       aplFY = new Action_Plan_Line__c();
       selectedProducts = new List<SelectOption>(); 
       selectedDistributors = new List<SelectOption>();
       allDistributors = new List<SelectOption>();
       if((System.Date.today().month() >= 9) && (System.Date.today().month() <= 12))  aplFY.PICK_Forecast_Fiscal_Year__c = String.valueOf(System.Date.today().year()+1);
       else if((System.Date.today().month() >= 1) && (System.Date.today().month() <= 8)) aplFY.PICK_Forecast_Fiscal_Year__c = String.valueOf(System.Date.today().year());
       
       //Record Type ActionPlanLine Forecast
       recordTypeForecast = Util.recordtype.get('Action_Plan_Line__c:Action_Plan_Line');    
       
       //Get Units of Measurement
       User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
       if(currentUser.Country != null) country = [SELECT Id, Units_of_Measurement__c, Name FROM Country__c WHERE Name =: currentUser.Country];
       
       initializePeriods();
        
       for(pricebook2 itemP : [select id from pricebook2 WHERE CP_Account_Type__c = 'Distributor' AND isActive = true AND CountryRef__r.Name =: country.Name])
       {
           listaCatalogosId.add(itemP.id);
       }
       for(UserRecordAccess itemU : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE userid=:Userinfo.getUserId() and RecordID IN :listaCatalogosId ])
       {
            if(itemU.HasReadAccess)
               listaCatalogosFiltrada.add(itemU.RecordId); 
       }
       
       // Get Products and Distributors options
       getProducts();
       
       //Distributors
       for(Account a : [SELECT id, name, Influencer__c FROM Account WHERE GC_Cust_Account_Grp_Descr__c=:'Sold-to party' AND (OwnerId =: UserInfo.getUserId() OR Owner.ManagerId =: UserInfo.getUserId() OR Owner.Manager.ManagerId =: UserInfo.getUserId() OR LKP_Responsible_CP__c =:UserInfo.getUserId()) order by name asc])
       {
            SelectOption opt = new SelectOption(a.id, a.name);
            //New FR CP requirement. Display only purchasing groups defined at Influencer level
            if(currentUser.Country == 'France'){
              if(a.Influencer__c == null) allDistributors.add(opt);
            }
            else
              allDistributors.add(opt);
       }              
    }
    
    public void getProducts()
    {
       List<ID> listaCatalogosId = new List<ID>();
       List<ID> listaCatalogosFiltrada = new List<ID>();
       allProducts = new list<SelectOption>();
       Set<SelectOption> allProductsSet= new Set<SelectOption>();
       
       //display only active products in active catalogs
       for(pricebook2 itemP : [select id from pricebook2 WHERE CP_Account_Type__c != 'PoS' AND isActive = true AND CountryRef__r.Name =: country.Name])
       {
           listaCatalogosId.add(itemP.id);
       }
       for(UserRecordAccess itemU : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE userid=:Userinfo.getUserId() and RecordID IN :listaCatalogosId ])
       {
            if(itemU.HasReadAccess)
               listaCatalogosFiltrada.add(itemU.RecordId); 
       }
       //System.debug('The list catalog filtered is: '+listaCatalogosFiltrada);

       for(Pricebookentry p : [SELECT Product2Id, product2.name, product2.TXT_commercial_name__c FROM PriceBookEntry WHERE isActive = true AND pricebook2id in :listaCatalogosFiltrada order by product2.NUM_AP_CP_Custom_Order__c, product2.TXT_commercial_name__c asc])
       {
           if(p.product2.TXT_commercial_name__c != null)
           {
               SelectOption opt = new SelectOption(p.product2.id, p.product2.TXT_commercial_name__c);
               allProductsSet.add(opt);
           }
       }
       allProducts.addAll(allProductsSet);
       //System.debug('The product set is: '+allProductsSet.size()+allProductsSet);
       //System.debug('The product list is: '+allProducts.size()+allProducts);
    }
    
     
    public void getData()
    {        

       List<Id> idsProduct = new List<Id>();
       for (SelectOption pr : selectedProducts)
       {
            idsProduct.add(pr.getValue());
       }       
       listProduct = [SELECT Id, Name, TXT_commercial_name__c, Family FROM Product2 WHERE Id IN : idsProduct order by NUM_AP_CP_Custom_Order__c, TXT_commercial_name__c asc];

       // Same for distributors
       List<Id> idsDistri = new List<Id>();

       for (SelectOption dt : selectedDistributors) 
       {
            idsDistri.add(dt.getValue());
       }       
       listDist = [SELECT Id, Name FROM Account WHERE Id IN : idsDistri]; 
                
       forecastPreview = new List<itemForecast>();
       forecastEditable = new List<itemForecast>();
       Map_Forecast_Values = new Map<String, Action_Plan_Line__c>();
       mapProductFamilyTOTAL = new map<String, List<familyTotal>>();
       initializeAplForecast();
       Integer sum, sumrel;
       Integer totalFor, totalForRel;
       for(Product2 p : listProduct)
        { 
           for (SelectOption dt : selectedDistributors)
           {
       
              //system.debug('entra en bucle');                              
               //Create Action Plan Line Forecast item
               itemForecast item = new itemForecast(dt.getValue(), p.Id, aplFY.PICK_Forecast_Fiscal_Year__c, UserInfo.getUserId(), Util.recordtype.get('Action_Plan_Line__c:Action_Plan_Line')); 
               item.product = p.TXT_commercial_name__c;
               item.dist = dt.getLabel();
               sum = 0;
               sumrel = 0;         
               
               generateData(item.forecastSeptember,dt.getValue().substring(0,15) + '-' + String.valueOf(p.Id).substring(0,15) + '-' + String.valueOf((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1)) + '-' + '09');
               generateData(item.forecastOctober,dt.getValue().substring(0,15) + '-' + String.valueOf(p.Id).substring(0,15) + '-' + String.valueOf((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1)) + '-' + '10');
               generateData(item.forecastNovember,dt.getValue().substring(0,15) + '-' + String.valueOf(p.Id).substring(0,15) + '-' + String.valueOf((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1)) + '-' + '11');
               generateData(item.forecastDecember,dt.getValue().substring(0,15) + '-' + String.valueOf(p.Id).substring(0,15) + '-' + String.valueOf((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1)) + '-' + '12');
               generateData(item.forecastJanuary,dt.getValue().substring(0,15) + '-' + String.valueOf(p.Id).substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '01');
               generateData(item.forecastFebruary,dt.getValue().substring(0,15) + '-' + String.valueOf(p.Id).substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '02');
               generateData(item.forecastMarch,dt.getValue().substring(0,15) + '-' + String.valueOf(p.Id).substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '03');
               generateData(item.forecastApril,dt.getValue().substring(0,15) + '-' + String.valueOf(p.Id).substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '04');
               generateData(item.forecastMay,dt.getValue().substring(0,15) + '-' + String.valueOf(p.Id).substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '05');
               generateData(item.forecastJune,dt.getValue().substring(0,15) + '-' + String.valueOf(p.Id).substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '06');
               generateData(item.forecastJuly,dt.getValue().substring(0,15) + '-' + String.valueOf(p.Id).substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '07');
               generateData(item.forecastAugust,dt.getValue().substring(0,15) + '-' + String.valueOf(p.Id).substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '08');

               //Total Forecast Units (taula estàtica)
               item.totalForecastUnits = item.getTotalUnits(Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c), true);
               //Total Forecast Rels (taula estàtica)
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
               Map_Forecast_Values.put(item.forecastSeptember.TXT_External_ID__c, item.forecastSeptember.clone());
               Map_Forecast_Values.put(item.forecastOctober.TXT_External_ID__c, item.forecastOctober.clone());
               Map_Forecast_Values.put(item.forecastNovember.TXT_External_ID__c, item.forecastNovember.clone());
               Map_Forecast_Values.put(item.forecastDecember.TXT_External_ID__c, item.forecastDecember.clone());
               Map_Forecast_Values.put(item.forecastJanuary.TXT_External_ID__c, item.forecastJanuary.clone());
               Map_Forecast_Values.put(item.forecastFebruary.TXT_External_ID__c, item.forecastFebruary.clone());
               Map_Forecast_Values.put(item.forecastMarch.TXT_External_ID__c, item.forecastMarch.clone());
               Map_Forecast_Values.put(item.forecastApril.TXT_External_ID__c, item.forecastApril.clone());
               Map_Forecast_Values.put(item.forecastMay.TXT_External_ID__c, item.forecastMay.clone());
               Map_Forecast_Values.put(item.forecastJune.TXT_External_ID__c, item.forecastJune.clone());
               Map_Forecast_Values.put(item.forecastJuly.TXT_External_ID__c, item.forecastJuly.clone());
               Map_Forecast_Values.put(item.forecastAugust.TXT_External_ID__c, item.forecastAugust.clone());
           }
       }
       
        //Totals category 
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        if(currentUser.Country != null) country = [SELECT Id, Units_of_Measurement__c FROM Country__c WHERE Name =: currentUser.Country];
        for(String key : mapProductFamilyTOTAL.keySet())
        {
            // Inicialització a zero del camp on es guardaran els recomptes totals.
            itemForecast forecastAux = (mapProductFamilyTOTAL.get(key)[0].elemForecast).clone();                 
                
            familyTotal totalLine = new FamilyTotal(forecastAux); 
            totalLine.elemForecast.totalForecastUnits = 0 ;
            totalLine.elemForecast.totalForecastRels = 0 ;    
            totalLine.elemForecast.totalUnits = 0 ;
            totalLine.elemForecast.totalRels = 0 ;          
            totalLine.elemForecast.forecastSeptember = new Action_Plan_Line__c(NUM_Forecast__c=0,NUM_Sell_In__c=0);
            totalLine.elemForecast.forecastOctober = new Action_Plan_Line__c(NUM_Forecast__c=0,NUM_Sell_In__c=0);
            totalLine.elemForecast.forecastNovember = new Action_Plan_Line__c(NUM_Forecast__c=0,NUM_Sell_In__c=0);
            totalLine.elemForecast.forecastDecember = new Action_Plan_Line__c(NUM_Forecast__c=0,NUM_Sell_In__c=0);
            totalLine.elemForecast.forecastJanuary = new Action_Plan_Line__c(NUM_Forecast__c=0,NUM_Sell_In__c=0);
            totalLine.elemForecast.forecastFebruary = new Action_Plan_Line__c(NUM_Forecast__c=0,NUM_Sell_In__c=0);
            totalLine.elemForecast.forecastMarch = new Action_Plan_Line__c(NUM_Forecast__c=0,NUM_Sell_In__c=0);
            totalLine.elemForecast.forecastApril = new Action_Plan_Line__c(NUM_Forecast__c=0,NUM_Sell_In__c=0);
            totalLine.elemForecast.forecastMay = new Action_Plan_Line__c(NUM_Forecast__c=0,NUM_Sell_In__c=0);
            totalLine.elemForecast.forecastJune = new Action_Plan_Line__c(NUM_Forecast__c=0,NUM_Sell_In__c=0);
            totalLine.elemForecast.forecastJuly = new Action_Plan_Line__c(NUM_Forecast__c=0,NUM_Sell_In__c=0);
            totalLine.elemForecast.forecastAugust = new Action_Plan_Line__c(NUM_Forecast__c=0,NUM_Sell_In__c=0);
            
            totalLine.name = 'TOTAL ' + key;
            totalLine.total = true;
            for(familyTotal productLine : mapProductFamilyTOTAL.get(key))
            {
                //if(productLine.elemForecast.forecastSeptember.NUM_Forecast__c != null || productLine.elemForecast.forecastSeptember.NUM_Delivered__c!=null) totalLine.elemForecast.forecastSeptember.NUM_Forecast__c += (productLine.elemForecast.forecastSeptember.NUM_Delivered__c!=null? Integer.valueOf(productLine.elemForecast.forecastSeptember.NUM_Delivered__c) :  Integer.valueOf(productLine.elemForecast.forecastSeptember.NUM_Forecast__c));
                //old version---->totalLine.elemForecast.forecastSeptember.NUM_Forecast__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1), 9, country.Units_of_Measurement__c);
                //NEW REQUIREMENT---> TOTAL QUANTITy ALWAYS IN RELS
                totalLine.elemForecast.forecastSeptember.NUM_Forecast__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1), 9, 'Rels');
                totalLine.elemForecast.forecastOctober.NUM_Forecast__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1), 10,'Rels');
                totalLine.elemForecast.forecastNovember.NUM_Forecast__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1), 11, 'Rels');
                totalLine.elemForecast.forecastDecember.NUM_Forecast__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1), 12, 'Rels');
                totalLine.elemForecast.forecastJanuary.NUM_Forecast__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 1, 'Rels');
                totalLine.elemForecast.forecastFebruary.NUM_Forecast__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 2,'Rels');
                totalLine.elemForecast.forecastMarch.NUM_Forecast__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 3, 'Rels');
                totalLine.elemForecast.forecastApril.NUM_Forecast__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 4, 'Rels');
                totalLine.elemForecast.forecastMay.NUM_Forecast__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 5, 'Rels');
                totalLine.elemForecast.forecastJune.NUM_Forecast__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 6, 'Rels');
                totalLine.elemForecast.forecastJuly.NUM_Forecast__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 7, 'Rels');
                totalLine.elemForecast.forecastAugust.NUM_Forecast__c += productLine.elemForecast.getTotalValue((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)), 8, 'Rels');
                //Los 12
                // Repetim per la taula no editable de dalt. Hem de separar pels dos tipus de unitats (bUnits/Rels)
              /*
               * NEW REQUIREMENT---->Total always in Rels.
               * Nov 2016 - CP France requirement: calculate according to country
               * 
               */

              /**********************************************************************************/
              /*                                03/04/2017                                      */
              /* Comment this part of code to show the total in the preview table always in REL */
              /**********************************************************************************/

             /*  if(country.Units_of_Measurement__c=='Basic Units')
                {
                    totalLine.elemForecast.forecastSeptember.NUM_Sell_In__c += productLine.elemForecast.forecastSeptember.NUM_Budget__c!=null? productLine.elemForecast.forecastSeptember.NUM_Budget__c: 0;
                    totalLine.elemForecast.forecastOctober.NUM_Sell_In__c += productLine.elemForecast.forecastOctober.NUM_Budget__c!=null? productLine.elemForecast.forecastOctober.NUM_Budget__c: 0;
                    totalLine.elemForecast.forecastNovember.NUM_Sell_In__c += productLine.elemForecast.forecastNovember.NUM_Budget__c!=null? productLine.elemForecast.forecastNovember.NUM_Budget__c: 0;
                    totalLine.elemForecast.forecastDecember.NUM_Sell_In__c += productLine.elemForecast.forecastDecember.NUM_Budget__c!=null? productLine.elemForecast.forecastDecember.NUM_Budget__c: 0;
                    totalLine.elemForecast.forecastJanuary.NUM_Sell_In__c += productLine.elemForecast.forecastJanuary.NUM_Budget__c!=null? productLine.elemForecast.forecastJanuary.NUM_Budget__c: 0;
                    totalLine.elemForecast.forecastFebruary.NUM_Sell_In__c += productLine.elemForecast.forecastFebruary.NUM_Budget__c!=null? productLine.elemForecast.forecastFebruary.NUM_Budget__c: 0;
                    totalLine.elemForecast.forecastMarch.NUM_Sell_In__c += productLine.elemForecast.forecastMarch.NUM_Budget__c!=null? productLine.elemForecast.forecastMarch.NUM_Budget__c: 0;
                    totalLine.elemForecast.forecastApril.NUM_Sell_In__c += productLine.elemForecast.forecastApril.NUM_Budget__c!=null? productLine.elemForecast.forecastApril.NUM_Budget__c: 0;
                    totalLine.elemForecast.forecastMay.NUM_Sell_In__c += productLine.elemForecast.forecastMay.NUM_Budget__c!=null? productLine.elemForecast.forecastMay.NUM_Budget__c: 0;
                    totalLine.elemForecast.forecastJune.NUM_Sell_In__c += productLine.elemForecast.forecastJune.NUM_Budget__c!=null? productLine.elemForecast.forecastJune.NUM_Budget__c: 0;
                    totalLine.elemForecast.forecastJuly.NUM_Sell_In__c += productLine.elemForecast.forecastJuly.NUM_Budget__c!=null? productLine.elemForecast.forecastJuly.NUM_Budget__c: 0;
                    totalLine.elemForecast.forecastAugust.NUM_Sell_In__c += productLine.elemForecast.forecastAugust.NUM_Budget__c!=null? productLine.elemForecast.forecastAugust.NUM_Budget__c: 0;
                }else{*/
                    totalLine.elemForecast.forecastSeptember.NUM_Sell_In__c += productLine.elemForecast.forecastSeptember.NUM_Budget_Rel__c!=null? productLine.elemForecast.forecastSeptember.NUM_Budget_Rel__c: 0;
                    totalLine.elemForecast.forecastOctober.NUM_Sell_In__c += productLine.elemForecast.forecastOctober.NUM_Budget_Rel__c!=null? productLine.elemForecast.forecastOctober.NUM_Budget_Rel__c: 0;
                    totalLine.elemForecast.forecastNovember.NUM_Sell_In__c += productLine.elemForecast.forecastNovember.NUM_Budget_Rel__c!=null? productLine.elemForecast.forecastNovember.NUM_Budget_Rel__c: 0;
                    totalLine.elemForecast.forecastDecember.NUM_Sell_In__c += productLine.elemForecast.forecastDecember.NUM_Budget_Rel__c!=null? productLine.elemForecast.forecastDecember.NUM_Budget_Rel__c: 0;
                    totalLine.elemForecast.forecastJanuary.NUM_Sell_In__c += productLine.elemForecast.forecastJanuary.NUM_Budget_Rel__c!=null? productLine.elemForecast.forecastJanuary.NUM_Budget_Rel__c: 0;
                    totalLine.elemForecast.forecastFebruary.NUM_Sell_In__c += productLine.elemForecast.forecastFebruary.NUM_Budget_Rel__c!=null? productLine.elemForecast.forecastFebruary.NUM_Budget_Rel__c: 0;
                    totalLine.elemForecast.forecastMarch.NUM_Sell_In__c += productLine.elemForecast.forecastMarch.NUM_Budget_Rel__c!=null? productLine.elemForecast.forecastMarch.NUM_Budget_Rel__c: 0;
                    totalLine.elemForecast.forecastApril.NUM_Sell_In__c += productLine.elemForecast.forecastApril.NUM_Budget_Rel__c!=null? productLine.elemForecast.forecastApril.NUM_Budget_Rel__c: 0;
                    totalLine.elemForecast.forecastMay.NUM_Sell_In__c += productLine.elemForecast.forecastMay.NUM_Budget_Rel__c!=null? productLine.elemForecast.forecastMay.NUM_Budget_Rel__c: 0;
                    totalLine.elemForecast.forecastJune.NUM_Sell_In__c += productLine.elemForecast.forecastJune.NUM_Budget_Rel__c!=null? productLine.elemForecast.forecastJune.NUM_Budget_Rel__c: 0;
                    totalLine.elemForecast.forecastJuly.NUM_Sell_In__c += productLine.elemForecast.forecastJuly.NUM_Budget_Rel__c!=null? productLine.elemForecast.forecastJuly.NUM_Budget_Rel__c: 0;
                    totalLine.elemForecast.forecastAugust.NUM_Sell_In__c += productLine.elemForecast.forecastAugust.NUM_Budget_Rel__c!=null? productLine.elemForecast.forecastAugust.NUM_Budget_Rel__c: 0;
                    
               /* }*/
               /**********************************************************************************/
               /*                                   END                                          */
               /*                                03/04/2017                                      */
               /* Comment this part of code to show the total in the preview table always in REL */
               /**********************************************************************************/
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
 
    private void generateData(Action_Plan_Line__c item, String key)
     {
          //system.debug('key: '+key);
          item.NUM_Forecast__c = mapActionPlanForecast.get(key);
          item.NUM_Forecast_Rel__c = mapActionPlanForecastRel.get(key);
          item.NUM_Delivered__c = mapActionPlanDelivered.get(key);
          item.NUM_Sell_In__c = mapActionPlanDeliveredRel.get(key);
          item.NUM_Budget__c = mapActionPlanForecastManager.get(key);
          item.NUM_Budget_Rel__c = mapActionPlanForecastRelManager.get(key);
     }
           
    public PageReference saveForecastSKU()
    {
        
        List<Action_Plan_Line__c> aplUpserted = new List<Action_Plan_Line__c>();
        Integer sumAux, sumAuxRel;        
        for(itemForecast item : forecastEditable)
        {
            sumAux = 0;
            sumAuxRel = 0;

            if(Map_Forecast_Values.get(item.forecastSeptember.TXT_External_ID__c).NUM_Forecast__c != item.forecastSeptember.NUM_Forecast__c || Map_Forecast_Values.get(item.forecastSeptember.TXT_External_ID__c).NUM_Forecast_Rel__c != item.forecastSeptember.NUM_Forecast_Rel__c)

              aplUpserted.add(new Action_Plan_Line__c(lkp_sku__c=item.forecastSeptember.lkp_sku__c, LKP_Account__c=item.forecastSeptember.lkp_account__c, PICK_Period__c = item.forecastSeptember.pick_period__c, NUM_Forecast__c= item.forecastSeptember.NUM_Forecast__c, NUM_Forecast_Rel__c= item.forecastSeptember.NUM_Forecast_Rel__c, TXT_External_ID__c=item.forecastSeptember.TXT_External_ID__c ));

            if(Map_Forecast_Values.get(item.forecastOctober.TXT_External_ID__c).NUM_Forecast__c != item.forecastOctober.NUM_Forecast__c || Map_Forecast_Values.get(item.forecastOctober.TXT_External_ID__c).NUM_Forecast_Rel__c != item.forecastOctober.NUM_Forecast_Rel__c)

              aplUpserted.add(new Action_Plan_Line__c(lkp_sku__c=item.forecastOctober.lkp_sku__c, LKP_Account__c=item.forecastOctober.lkp_account__c, PICK_Period__c = item.forecastOctober.pick_period__c, NUM_Forecast__c= item.forecastOctober.NUM_Forecast__c, NUM_Forecast_Rel__c= item.forecastOctober.NUM_Forecast_Rel__c, TXT_External_ID__c=item.forecastOctober.TXT_External_ID__c ));

            if(Map_Forecast_Values.get(item.forecastNovember.TXT_External_ID__c).NUM_Forecast__c != item.forecastNovember.NUM_Forecast__c || Map_Forecast_Values.get(item.forecastNovember.TXT_External_ID__c).NUM_Forecast_Rel__c != item.forecastNovember.NUM_Forecast_Rel__c)

              aplUpserted.add(new Action_Plan_Line__c(lkp_sku__c=item.forecastNovember.lkp_sku__c, LKP_Account__c=item.forecastNovember.lkp_account__c, PICK_Period__c = item.forecastNovember.pick_period__c, NUM_Forecast__c= item.forecastNovember.NUM_Forecast__c, NUM_Forecast_Rel__c= item.forecastNovember.NUM_Forecast_Rel__c, TXT_External_ID__c=item.forecastNovember.TXT_External_ID__c ));

            if(Map_Forecast_Values.get(item.forecastDecember.TXT_External_ID__c).NUM_Forecast__c != item.forecastDecember.NUM_Forecast__c || Map_Forecast_Values.get(item.forecastDecember.TXT_External_ID__c).NUM_Forecast_Rel__c != item.forecastDecember.NUM_Forecast_Rel__c)

              aplUpserted.add(new Action_Plan_Line__c(lkp_sku__c=item.forecastDecember.lkp_sku__c, LKP_Account__c=item.forecastDecember.lkp_account__c, PICK_Period__c = item.forecastDecember.pick_period__c, NUM_Forecast__c= item.forecastDecember.NUM_Forecast__c, NUM_Forecast_Rel__c= item.forecastDecember.NUM_Forecast_Rel__c, TXT_External_ID__c=item.forecastDecember.TXT_External_ID__c ));

            if(Map_Forecast_Values.get(item.forecastJanuary.TXT_External_ID__c).NUM_Forecast__c != item.forecastJanuary.NUM_Forecast__c || Map_Forecast_Values.get(item.forecastJanuary.TXT_External_ID__c).NUM_Forecast_Rel__c != item.forecastJanuary.NUM_Forecast_Rel__c)

              aplUpserted.add(new Action_Plan_Line__c(lkp_sku__c=item.forecastJanuary.lkp_sku__c, LKP_Account__c=item.forecastJanuary.lkp_account__c, PICK_Period__c = item.forecastJanuary.pick_period__c, NUM_Forecast__c= item.forecastJanuary.NUM_Forecast__c, NUM_Forecast_Rel__c= item.forecastJanuary.NUM_Forecast_Rel__c, TXT_External_ID__c=item.forecastJanuary.TXT_External_ID__c ));

            if(Map_Forecast_Values.get(item.forecastFebruary.TXT_External_ID__c).NUM_Forecast__c != item.forecastFebruary.NUM_Forecast__c || Map_Forecast_Values.get(item.forecastFebruary.TXT_External_ID__c).NUM_Forecast_Rel__c != item.forecastFebruary.NUM_Forecast_Rel__c)

              aplUpserted.add(new Action_Plan_Line__c(lkp_sku__c=item.forecastFebruary.lkp_sku__c, LKP_Account__c=item.forecastFebruary.lkp_account__c, PICK_Period__c = item.forecastFebruary.pick_period__c, NUM_Forecast__c= item.forecastFebruary.NUM_Forecast__c, NUM_Forecast_Rel__c= item.forecastFebruary.NUM_Forecast_Rel__c, TXT_External_ID__c=item.forecastFebruary.TXT_External_ID__c ));

            if(Map_Forecast_Values.get(item.forecastMarch.TXT_External_ID__c).NUM_Forecast__c != item.forecastMarch.NUM_Forecast__c || Map_Forecast_Values.get(item.forecastMarch.TXT_External_ID__c).NUM_Forecast_Rel__c != item.forecastMarch.NUM_Forecast_Rel__c)

              aplUpserted.add(new Action_Plan_Line__c(lkp_sku__c=item.forecastMarch.lkp_sku__c, LKP_Account__c=item.forecastMarch.lkp_account__c, PICK_Period__c = item.forecastMarch.pick_period__c, NUM_Forecast__c= item.forecastMarch.NUM_Forecast__c, NUM_Forecast_Rel__c= item.forecastMarch.NUM_Forecast_Rel__c, TXT_External_ID__c=item.forecastMarch.TXT_External_ID__c ));

            if(Map_Forecast_Values.get(item.forecastApril.TXT_External_ID__c).NUM_Forecast__c != item.forecastApril.NUM_Forecast__c || Map_Forecast_Values.get(item.forecastApril.TXT_External_ID__c).NUM_Forecast_Rel__c != item.forecastApril.NUM_Forecast_Rel__c)

              aplUpserted.add(new Action_Plan_Line__c(lkp_sku__c=item.forecastApril.lkp_sku__c, LKP_Account__c=item.forecastApril.lkp_account__c, PICK_Period__c = item.forecastApril.pick_period__c, NUM_Forecast__c= item.forecastApril.NUM_Forecast__c, NUM_Forecast_Rel__c= item.forecastApril.NUM_Forecast_Rel__c, TXT_External_ID__c=item.forecastApril.TXT_External_ID__c ));

            if(Map_Forecast_Values.get(item.forecastMay.TXT_External_ID__c).NUM_Forecast__c != item.forecastMay.NUM_Forecast__c || Map_Forecast_Values.get(item.forecastMay.TXT_External_ID__c).NUM_Forecast_Rel__c != item.forecastMay.NUM_Forecast_Rel__c)

              aplUpserted.add(new Action_Plan_Line__c(lkp_sku__c=item.forecastMay.lkp_sku__c, LKP_Account__c=item.forecastMay.lkp_account__c, PICK_Period__c = item.forecastMay.pick_period__c, NUM_Forecast__c= item.forecastMay.NUM_Forecast__c, NUM_Forecast_Rel__c= item.forecastMay.NUM_Forecast_Rel__c, TXT_External_ID__c=item.forecastMay.TXT_External_ID__c ));
              
            if(Map_Forecast_Values.get(item.forecastJune.TXT_External_ID__c).NUM_Forecast__c != item.forecastJune.NUM_Forecast__c || Map_Forecast_Values.get(item.forecastJune.TXT_External_ID__c).NUM_Forecast_Rel__c != item.forecastJune.NUM_Forecast_Rel__c)

              aplUpserted.add(new Action_Plan_Line__c(lkp_sku__c=item.forecastJune.lkp_sku__c, LKP_Account__c=item.forecastJune.lkp_account__c, PICK_Period__c = item.forecastJune.pick_period__c, NUM_Forecast__c= item.forecastJune.NUM_Forecast__c, NUM_Forecast_Rel__c= item.forecastJune.NUM_Forecast_Rel__c, TXT_External_ID__c=item.forecastJune.TXT_External_ID__c ));

            if(Map_Forecast_Values.get(item.forecastJuly.TXT_External_ID__c).NUM_Forecast__c != item.forecastJuly.NUM_Forecast__c || Map_Forecast_Values.get(item.forecastJuly.TXT_External_ID__c).NUM_Forecast_Rel__c != item.forecastJuly.NUM_Forecast_Rel__c)

              aplUpserted.add(new Action_Plan_Line__c(lkp_sku__c=item.forecastJuly.lkp_sku__c, LKP_Account__c=item.forecastJuly.lkp_account__c, PICK_Period__c = item.forecastJuly.pick_period__c, NUM_Forecast__c= item.forecastJuly.NUM_Forecast__c, NUM_Forecast_Rel__c= item.forecastJuly.NUM_Forecast_Rel__c, TXT_External_ID__c=item.forecastJuly.TXT_External_ID__c ));

            if(Map_Forecast_Values.get(item.forecastAugust.TXT_External_ID__c).NUM_Forecast__c != item.forecastAugust.NUM_Forecast__c || Map_Forecast_Values.get(item.forecastAugust.TXT_External_ID__c).NUM_Forecast_Rel__c != item.forecastAugust.NUM_Forecast_Rel__c)

              aplUpserted.add(new Action_Plan_Line__c(lkp_sku__c=item.forecastAugust.lkp_sku__c, LKP_Account__c=item.forecastAugust.lkp_account__c, PICK_Period__c = item.forecastAugust.pick_period__c, NUM_Forecast__c= item.forecastAugust.NUM_Forecast__c, NUM_Forecast_Rel__c= item.forecastAugust.NUM_Forecast_Rel__c, TXT_External_ID__c=item.forecastAugust.TXT_External_ID__c ));

            //system.debug('elem: '+item.forecastMay);

            //Total Units
            if(item.forecastSeptember.NUM_Forecast__c != null) sumAux += Integer.valueOf(item.forecastSeptember.NUM_Forecast__c);
            if(item.forecastOctober.NUM_Forecast__c  != null) sumAux += Integer.valueOf(item.forecastOctober.NUM_Forecast__c);
            if(item.forecastNovember.NUM_Forecast__c != null) sumAux += Integer.valueOf(item.forecastNovember.NUM_Forecast__c);
            if(item.forecastDecember.NUM_Forecast__c != null) sumAux += Integer.valueOf(item.forecastDecember.NUM_Forecast__c);
            if(item.forecastJanuary.NUM_Forecast__c != null) sumAux += Integer.valueOf(item.forecastJanuary.NUM_Forecast__c);
            if(item.forecastFebruary.NUM_Forecast__c != null) sumAux += Integer.valueOf(item.forecastFebruary.NUM_Forecast__c);
            if(item.forecastMarch.NUM_Forecast__c != null) sumAux += Integer.valueOf(item.forecastMarch.NUM_Forecast__c);
            if(item.forecastApril.NUM_Forecast__c != null) sumAux += Integer.valueOf(item.forecastApril.NUM_Forecast__c);
            if(item.forecastMay.NUM_Forecast__c != null) sumAux += Integer.valueOf(item.forecastMay.NUM_Forecast__c);
            if(item.forecastJune.NUM_Forecast__c != null) sumAux += Integer.valueOf(item.forecastJune.NUM_Forecast__c);
            if(item.forecastJuly.NUM_Forecast__c != null) sumAux += Integer.valueOf(item.forecastJuly.NUM_Forecast__c);
            if(item.forecastAugust.NUM_Forecast__c != null) sumAux += Integer.valueOf(item.forecastAugust.NUM_Forecast__c);
            
            //Total Rels
            if(item.forecastSeptember.NUM_Forecast_Rel__c != null) sumAuxRel += Integer.valueOf(item.forecastSeptember.NUM_Forecast_Rel__c);
            if(item.forecastOctober.NUM_Forecast_Rel__c != null) sumAuxRel += Integer.valueOf(item.forecastOctober.NUM_Forecast_Rel__c);
            if(item.forecastNovember.NUM_Forecast_Rel__c != null) sumAuxRel += Integer.valueOf(item.forecastNovember.NUM_Forecast_Rel__c);
            if(item.forecastDecember.NUM_Forecast_Rel__c != null) sumAuxRel += Integer.valueOf(item.forecastDecember.NUM_Forecast_Rel__c);
            if(item.forecastJanuary.NUM_Forecast_Rel__c != null) sumAuxRel += Integer.valueOf(item.forecastJanuary.NUM_Forecast_Rel__c);
            if(item.forecastFebruary.NUM_Forecast_Rel__c != null) sumAuxRel += Integer.valueOf(item.forecastFebruary.NUM_Forecast_Rel__c);
            if(item.forecastMarch.NUM_Forecast_Rel__c  != null) sumAuxRel += Integer.valueOf(item.forecastMarch.NUM_Forecast_Rel__c);
            if(item.forecastApril.NUM_Forecast_Rel__c != null) sumAuxRel += Integer.valueOf(item.forecastApril.NUM_Forecast_Rel__c);
            if(item.forecastMay.NUM_Forecast_Rel__c != null) sumAuxRel += Integer.valueOf(item.forecastMay.NUM_Forecast_Rel__c);
            if(item.forecastJune.NUM_Forecast_Rel__c  != null) sumAuxRel += Integer.valueOf(item.forecastJune.NUM_Forecast_Rel__c);
            if(item.forecastJuly.NUM_Forecast_Rel__c != null) sumAuxRel += Integer.valueOf(item.forecastJuly.NUM_Forecast_Rel__c);
            if(item.forecastAugust.NUM_Forecast_Rel__c != null) sumAuxRel += Integer.valueOf(item.forecastAugust.NUM_Forecast_Rel__c);
            
            item.totalUnits = sumAux;
            item.totalRels = sumAuxRel;
            
            /*if(sumAux == 0)
                item.totalUnits = '';
            else   item.totalUnits = sumAux.format();         
            if(sumAuxRel == 0)
                item.totalRels = '';
            else item.totalRels = sumAuxRel.format(); */
        }
        
        Schema.SObjectField f = Action_Plan_Line__c.Fields.TXT_External_ID__c;
        //system.debug('aplUpserted: ' + aplUpserted);
        Database.upsert(aplUpserted, f, false);
        getData();
        return null;
    }

    private void initializeAplForecast()
    {  
        //system.debug('recordtype: '+ Util.recordtype.get('Action_Plan_Line__c:Action_Plan_Line'));
        //system.debug('LKP_SKU__c: '+ listProduct);
        //system.debug('LKP_Account__c: '+ listDist);

       for(Action_Plan_Line__c apl : [SELECT Id, TXT_External_ID__c, NUM_Forecast__c, NUM_Forecast_Rel__c, LKP_Account__c FROM Action_Plan_Line__c WHERE RecordTypeID =:Util.recordtype.get('Action_Plan_Line__c:Action_Plan_Line') AND LKP_SKU__c IN :listProduct AND LKP_Account__c IN :listDist AND (lkp_account__r.OwnerId =:userinfo.getuserid() or Ownerid =:userinfo.getuserid() or lkp_account__r.LKP_Responsible_CP__c =:userinfo.getuserid())])
       {    
            //system.debug('externalID: '+apl.TXT_External_ID__c+' - '+apl.NUM_Forecast__c);
            mapActionPlanForecast.put(apl.TXT_External_ID__c, apl.NUM_Forecast__c);
            mapActionPlanForecastrel.put(apl.TXT_External_ID__c, apl.NUM_Forecast_Rel__c);
            mapActionPlanForecastManager.put(apl.TXT_External_ID__c, apl.NUM_Forecast__c);
            mapActionPlanForecastrelManager.put(apl.TXT_External_ID__c, apl.NUM_Forecast_Rel__c);
       } 

       system.debug('***MapActionPlanForecast: ' + mapActionPlanForecast);

       List<AggregateResult> listaForecastTeam = [SELECT PICK_Period__c, LKP_Account__c, lkp_sku__c, sum(NUM_Forecast__c) sku, sum(NUM_Forecast_Rel__c) rel FROM Action_Plan_Line__c WHERE RecordTypeID =:Util.recordtype.get('Action_Plan_Line__c:Action_Plan_Line') AND LKP_SKU__c IN :listProduct AND LKP_Account__c IN :listDist AND (lkp_account__r.owner.managerId =:userinfo.getuserid()) group by PICK_Period__c, lkp_sku__c,LKP_Account__c];
       
       if(listaForecastTeam.size() > 0)
       {
            mapActionPlanForecastManager=new Map<String, Decimal>();
            mapActionPlanForecastrelManager=new Map<String, Decimal>();
       }
       for(AggregateResult res : listaForecastTeam) 
       {    
            mapActionPlanForecastManager.put(String.valueOf(res.get('LKP_Account__c')).substring(0,15)  + '-' + String.valueOf(res.get('lkp_sku__c')).substring(0,15)  + '-' + res.get('PICK_Period__c'), (Decimal)res.get('sku'));
            mapActionPlanForecastrelManager.put(String.valueOf(res.get('LKP_Account__c')).substring(0,15)  + '-' + String.valueOf(res.get('lkp_sku__c')).substring(0,15)  + '-' + res.get('PICK_Period__c'), (Decimal)res.get('rel'));
       } 
                       
        for(AggregateResult  res : [SELECT PICK_Period__c, lkp_account__c, lkp_sku__c, sum(NUM_Delivered__c) delivered, sum(FRML_Delivered_Rel__c) deliveredRel FROM Action_Plan_Line__c WHERE RecordTypeID =:Util.recordtype.get('Action_Plan_Line__c:Action_Plan_Line') AND LKP_SKU__c IN :listProduct AND LKP_Account__c IN :listDist AND (LKP_Account__r.OwnerId =:userinfo.getuserid() OR LKP_Account__r.Owner.ManagerId =:userinfo.getuserid() OR LKP_Account__r.Owner.manager.managerid =:userinfo.getuserid()) group by PICK_Period__c, lkp_sku__c,LKP_Account__c])
       {    
            //system.debug('mapa: '+String.valueOf(res.get('LKP_Account__c')).substring(0,15)  + '-' + String.valueOf(res.get('lkp_sku__c')).substring(0,15)  + '-' + res.get('PICK_Period__c') + ' - '+(Decimal)res.get('delivered'));
            mapActionPlanDelivered.put(String.valueOf(res.get('LKP_Account__c')).substring(0,15)  + '-' + String.valueOf(res.get('lkp_sku__c')).substring(0,15)  + '-' + res.get('PICK_Period__c'), (Decimal)res.get('delivered'));
            mapActionPlanDeliveredrel.put(String.valueOf(res.get('LKP_Account__c')).substring(0,15)  + '-' + String.valueOf(res.get('lkp_sku__c')).substring(0,15)  + '-' + res.get('PICK_Period__c'), (Decimal)res.get('deliveredRel'));
       }       
    }
    
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
        public String dist {get; set;}
      /*public Action_Plan_Line__c distribAccount {get; set;} */
        public Action_Plan_Line__c forecastJanuary {get; set;}
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
        
        public Decimal getTotalValue(Integer yr, Integer mnth, string unit)
        {
            return getTotalValueCombo(yr, mnth, unit, false);           
        }
        
        public Decimal getTotalValue(Integer yr, Integer mnth, string unit, boolean forceForecast)
        {
            return getTotalValueCombo(yr, mnth, unit, forceForecast);           
        }
        
        //public Decimal getTotalValueCombo(Integer yr, Integer mnth, string unit/*, itemForecast item*/,boolean forceNotDelivered)
        public Decimal getTotalValueCombo(Integer yr, Integer mnth, string unit,boolean forceNotDelivered)
        {
            map<integer, string> months = new map<integer, string>{1=>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May', 6=>'June', 7=>'July', 8=>'August', 9=>'September', 10=>'October', 11=>'November', 12=>'December'};
            // Date req = Date.newInstance(yr, mnth, Date.daysInMonth(yr, mnth));
            Date req = Date.newInstance(yr, mnth, Integer.valueof(System.Label.CP_day));
                // Falta separar per units i rels               
            if(forceNotDelivered) {                              
                if (unit=='Basic Units'){   
                    if (mnth==1){
                        return (this.forecastJanuary.NUM_Budget__c)!=null?((Decimal)this.forecastJanuary.NUM_Budget__c):0;
                    } else if(mnth==2){
                        return (this.forecastFebruary.NUM_Budget__c)!=null?((Decimal)this.forecastFebruary.NUM_Budget__c):0;
                    } else if(mnth==3){
                        return (this.forecastMarch.NUM_Budget__c)!=null?((Decimal)this.forecastMarch.NUM_Budget__c):0;
                    } else if(mnth==4){
                        return (this.forecastApril.NUM_Budget__c)!=null?((Decimal)this.forecastApril.NUM_Budget__c):0;
                    } else if(mnth==5){
                        return (this.forecastMay.NUM_Budget__c)!=null?((Decimal)this.forecastMay.NUM_Budget__c):0;
                    } else if(mnth==6){
                        return (this.forecastJune.NUM_Budget__c)!=null?((Decimal)this.forecastJune.NUM_Budget__c):0;
                    } else if(mnth==7){
                        return (this.forecastJuly.NUM_Budget__c)!=null?((Decimal)this.forecastJuly.NUM_Budget__c):0;
                    } else if(mnth==8){
                        return (this.forecastAugust.NUM_Budget__c)!=null?((Decimal)this.forecastAugust.NUM_Budget__c):0;
                    } else if(mnth==9){
                        return (this.forecastSeptember.NUM_Budget__c)!=null?((Decimal)this.forecastSeptember.NUM_Budget__c):0;
                    } else if(mnth==10){
                        return (this.forecastOctober.NUM_Budget__c)!=null?((Decimal)this.forecastOctober.NUM_Budget__c):0;
                    } else if(mnth==11){
                        return (this.forecastNovember.NUM_Budget__c)!=null?((Decimal)this.forecastNovember.NUM_Budget__c):0;
                    } else /*if (mnth==12)*/{   
                        return (this.forecastDecember.NUM_Budget__c)!=null?((Decimal)this.forecastDecember.NUM_Budget__c):0;                                                
                    }
                                        
                    
                    // return this.('forecast' + months.get(mnth)).NUM_Forecast__c!=null?this.('forecast' + months.get(mnth)).NUM_Forecast__c:0;                                                
                } else {
                    if (mnth==1){
                        return (this.forecastJanuary.NUM_Budget_Rel__c)!=null?((Decimal)this.forecastJanuary.NUM_Budget_Rel__c):0;
                    } else if(mnth==2){
                        return (this.forecastFebruary.NUM_Budget_Rel__c)!=null?((Decimal)this.forecastFebruary.NUM_Budget_Rel__c):0;
                    } else if(mnth==3){
                        return (this.forecastMarch.NUM_Budget_Rel__c)!=null?((Decimal)this.forecastMarch.NUM_Budget_Rel__c):0;
                    } else if(mnth==4){
                        return (this.forecastApril.NUM_Budget_Rel__c)!=null?((Decimal)this.forecastApril.NUM_Budget_Rel__c):0;
                    } else if(mnth==5){
                        return (this.forecastMay.NUM_Budget_Rel__c)!=null?((Decimal)this.forecastMay.NUM_Budget_Rel__c):0;
                    } else if(mnth==6){
                        return (this.forecastJune.NUM_Budget_Rel__c)!=null?((Decimal)this.forecastJune.NUM_Budget_Rel__c):0;
                    } else if(mnth==7){
                        return (this.forecastJuly.NUM_Budget_Rel__c)!=null?((Decimal)this.forecastJuly.NUM_Budget_Rel__c):0;
                    } else if(mnth==8){
                        return (this.forecastAugust.NUM_Budget_Rel__c)!=null?((Decimal)this.forecastAugust.NUM_Budget_Rel__c):0;
                    } else if(mnth==9){
                        return (this.forecastSeptember.NUM_Budget_Rel__c)!=null?((Decimal)this.forecastSeptember.NUM_Budget_Rel__c):0;
                    } else if(mnth==10){
                        return (this.forecastOctober.NUM_Budget_Rel__c)!=null?((Decimal)this.forecastOctober.NUM_Budget_Rel__c):0;
                    } else if(mnth==11){
                        return (this.forecastNovember.NUM_Budget_Rel__c)!=null?((Decimal)this.forecastNovember.NUM_Budget_Rel__c):0;
                    } else /*if (mnth==12)*/{   
                        return (this.forecastDecember.NUM_Budget_Rel__c)!=null?((Decimal)this.forecastDecember.NUM_Budget_Rel__c):0;                                                
                    }
                    // return this.('forecast' + months.get(mnth)).NUM_Forecast_Rel__c!=null?this.('forecast' + months.get(mnth)).NUM_Forecast_Rel__c:0;    
                } 
            }
            
            else if(date.today() <= req) {                              
                if (unit=='Basic Units'){   
                    if (mnth==1){
                        return (this.forecastJanuary.NUM_Forecast__c)!=null?((Decimal)this.forecastJanuary.NUM_Forecast__c):0;
                    } else if(mnth==2){
                        return (this.forecastFebruary.NUM_Forecast__c)!=null?((Decimal)this.forecastFebruary.NUM_Forecast__c):0;
                    } else if(mnth==3){
                        return (this.forecastMarch.NUM_Forecast__c)!=null?((Decimal)this.forecastMarch.NUM_Forecast__c):0;
                    } else if(mnth==4){
                        return (this.forecastApril.NUM_Forecast__c)!=null?((Decimal)this.forecastApril.NUM_Forecast__c):0;
                    } else if(mnth==5){
                        return (this.forecastMay.NUM_Forecast__c)!=null?((Decimal)this.forecastMay.NUM_Forecast__c):0;
                    } else if(mnth==6){
                        return (this.forecastJune.NUM_Forecast__c)!=null?((Decimal)this.forecastJune.NUM_Forecast__c):0;
                    } else if(mnth==7){
                        return (this.forecastJuly.NUM_Forecast__c)!=null?((Decimal)this.forecastJuly.NUM_Forecast__c):0;
                    } else if(mnth==8){
                        return (this.forecastAugust.NUM_Forecast__c)!=null?((Decimal)this.forecastAugust.NUM_Forecast__c):0;
                    } else if(mnth==9){
                        return (this.forecastSeptember.NUM_Forecast__c)!=null?((Decimal)this.forecastSeptember.NUM_Forecast__c):0;
                    } else if(mnth==10){
                        return (this.forecastOctober.NUM_Forecast__c)!=null?((Decimal)this.forecastOctober.NUM_Forecast__c):0;
                    } else if(mnth==11){
                        return (this.forecastNovember.NUM_Forecast__c)!=null?((Decimal)this.forecastNovember.NUM_Forecast__c):0;
                    } else /*if (mnth==12)*/{   
                        return (this.forecastDecember.NUM_Forecast__c)!=null?((Decimal)this.forecastDecember.NUM_Forecast__c):0;                                                
                    }
                                        
                    
                    // return this.('forecast' + months.get(mnth)).NUM_Forecast__c!=null?this.('forecast' + months.get(mnth)).NUM_Forecast__c:0;                                                
                } else {
                    if (mnth==1){
                        return (this.forecastJanuary.NUM_Forecast_Rel__c)!=null?((Decimal)this.forecastJanuary.NUM_Forecast_Rel__c):0;
                    } else if(mnth==2){
                        return (this.forecastFebruary.NUM_Forecast_Rel__c)!=null?((Decimal)this.forecastFebruary.NUM_Forecast_Rel__c):0;
                    } else if(mnth==3){
                        return (this.forecastMarch.NUM_Forecast_Rel__c)!=null?((Decimal)this.forecastMarch.NUM_Forecast_Rel__c):0;
                    } else if(mnth==4){
                        return (this.forecastApril.NUM_Forecast_Rel__c)!=null?((Decimal)this.forecastApril.NUM_Forecast_Rel__c):0;
                    } else if(mnth==5){
                        return (this.forecastMay.NUM_Forecast_Rel__c)!=null?((Decimal)this.forecastMay.NUM_Forecast_Rel__c):0;
                    } else if(mnth==6){
                        return (this.forecastJune.NUM_Forecast_Rel__c)!=null?((Decimal)this.forecastJune.NUM_Forecast_Rel__c):0;
                    } else if(mnth==7){
                        return (this.forecastJuly.NUM_Forecast_Rel__c)!=null?((Decimal)this.forecastJuly.NUM_Forecast_Rel__c):0;
                    } else if(mnth==8){
                        return (this.forecastAugust.NUM_Forecast_Rel__c)!=null?((Decimal)this.forecastAugust.NUM_Forecast_Rel__c):0;
                    } else if(mnth==9){
                        return (this.forecastSeptember.NUM_Forecast_Rel__c)!=null?((Decimal)this.forecastSeptember.NUM_Forecast_Rel__c):0;
                    } else if(mnth==10){
                        return (this.forecastOctober.NUM_Forecast_Rel__c)!=null?((Decimal)this.forecastOctober.NUM_Forecast_Rel__c):0;
                    } else if(mnth==11){
                        return (this.forecastNovember.NUM_Forecast_Rel__c)!=null?((Decimal)this.forecastNovember.NUM_Forecast_Rel__c):0;
                    } else /*if (mnth==12)*/{   
                        return (this.forecastDecember.NUM_Forecast_Rel__c)!=null?((Decimal)this.forecastDecember.NUM_Forecast_Rel__c):0;                                                
                    }
                    // return this.('forecast' + months.get(mnth)).NUM_Forecast_Rel__c!=null?this.('forecast' + months.get(mnth)).NUM_Forecast_Rel__c:0;    
                } 
            }
            else
            {
                if (unit=='Basic Units'){
                    if (mnth==1){
                        return (this.forecastJanuary.NUM_Delivered__c)!=null?((Decimal)this.forecastJanuary.NUM_Delivered__c):0;
                    } else if(mnth==2){
                        return (this.forecastFebruary.NUM_Delivered__c)!=null?((Decimal)this.forecastFebruary.NUM_Delivered__c):0;
                    } else if(mnth==3){
                        return (this.forecastMarch.NUM_Delivered__c)!=null?((Decimal)this.forecastMarch.NUM_Delivered__c):0;
                    } else if(mnth==4){
                        return (this.forecastApril.NUM_Delivered__c)!=null?((Decimal)this.forecastApril.NUM_Delivered__c):0;
                    } else if(mnth==5){
                        return (this.forecastMay.NUM_Delivered__c)!=null?((Decimal)this.forecastMay.NUM_Delivered__c):0;
                    } else if(mnth==6){
                        return (this.forecastJune.NUM_Delivered__c)!=null?((Decimal)this.forecastJune.NUM_Delivered__c):0;
                    } else if(mnth==7){
                        return (this.forecastJuly.NUM_Delivered__c)!=null?((Decimal)this.forecastJuly.NUM_Delivered__c):0;
                    } else if(mnth==8){
                        return (this.forecastAugust.NUM_Delivered__c)!=null?((Decimal)this.forecastAugust.NUM_Delivered__c):0;
                    } else if(mnth==9){
                        return (this.forecastSeptember.NUM_Delivered__c)!=null?((Decimal)this.forecastSeptember.NUM_Delivered__c):0;
                    } else if(mnth==10){
                        return (this.forecastOctober.NUM_Delivered__c)!=null?((Decimal)this.forecastOctober.NUM_Delivered__c):0;
                    } else if(mnth==11){
                        return (this.forecastNovember.NUM_Delivered__c)!=null?((Decimal)this.forecastNovember.NUM_Delivered__c):0;
                    } else /*(mnth==12)*/{  
                        return (this.forecastDecember.NUM_Delivered__c)!=null?((Decimal)this.forecastDecember.NUM_Delivered__c):0;
                    // return (this.('forecast' + months.get(mnth)).NUM_Delivered__c)!=null?((Decimal)this.(('forecast' + months.get(mnth))).NUM_Delivered__c):0;                                               
                    }
                } else {
                    if (mnth==1){
                        return (this.forecastJanuary.NUM_Sell_In__c)!=null?((Decimal)this.forecastJanuary.NUM_Sell_In__c):0;
                    } else if(mnth==2){
                        return (this.forecastFebruary.NUM_Sell_In__c)!=null?((Decimal)this.forecastFebruary.NUM_Sell_In__c):0;
                    } else if(mnth==3){
                        return (this.forecastMarch.NUM_Sell_In__c)!=null?((Decimal)this.forecastMarch.NUM_Sell_In__c):0;
                    } else if(mnth==4){
                        return (this.forecastApril.NUM_Sell_In__c)!=null?((Decimal)this.forecastApril.NUM_Sell_In__c):0;
                    } else if(mnth==5){
                        return (this.forecastMay.NUM_Sell_In__c)!=null?((Decimal)this.forecastMay.NUM_Sell_In__c):0;
                    } else if(mnth==6){
                        return (this.forecastJune.NUM_Sell_In__c)!=null?((Decimal)this.forecastJune.NUM_Sell_In__c):0;
                    } else if(mnth==7){
                        return (this.forecastJuly.NUM_Sell_In__c)!=null?((Decimal)this.forecastJuly.NUM_Sell_In__c):0;
                    } else if(mnth==8){
                        return (this.forecastAugust.NUM_Sell_In__c)!=null?((Decimal)this.forecastAugust.NUM_Sell_In__c):0;
                    } else if(mnth==9){
                        return (this.forecastSeptember.NUM_Sell_In__c)!=null?((Decimal)this.forecastSeptember.NUM_Sell_In__c):0;
                    } else if(mnth==10){
                        return (this.forecastOctober.NUM_Sell_In__c)!=null?((Decimal)this.forecastOctober.NUM_Sell_In__c):0;
                    } else if(mnth==11){
                        return (this.forecastNovember.NUM_Sell_In__c)!=null?((Decimal)this.forecastNovember.NUM_Sell_In__c):0;
                    } else /*if (mnth==12)*/{   
                        return (this.forecastDecember.NUM_Sell_In__c)!=null?((Decimal)this.forecastDecember.NUM_Sell_In__c):0;                                              
                    }
                    // return this.('forecast' + months.get(mnth)).NUM_Sell_In__c!=null?this.('forecast' + months.get(mnth)).NUM_Sell_In__c:0;                  
                    }
                    
            } 
        }
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
        
        itemForecast(String account, String sku, String fy, Id userId, Id recordTypeForecast)
        {
            forecastSeptember = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_account__c = account, lkp_sku__c = sku, pick_period__c=String.valueOf((Integer.valueOf(fy)-1)) + '-' + '09', TXT_External_ID__c = account.substring(0,15) + '-' + sku.substring(0,15) + '-' + String.valueOf((Integer.valueOf(fy)-1)) + '-' + '09');
            forecastOctober= new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_account__c = account, lkp_sku__c = sku, pick_period__c=String.valueOf((Integer.valueOf(fy)-1)) + '-' + '10',TXT_External_ID__c = account.substring(0,15) + '-' + sku.substring(0,15) + '-' + String.valueOf((Integer.valueOf(fy)-1)) + '-' + '10');
            forecastNovember = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_account__c = account, lkp_sku__c = sku, pick_period__c=String.valueOf((Integer.valueOf(fy)-1)) + '-' + '11',TXT_External_ID__c = account.substring(0,15) + '-' + sku.substring(0,15) + '-' + String.valueOf((Integer.valueOf(fy)-1)) + '-' + '11');
            forecastDecember = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_account__c = account, lkp_sku__c = sku, pick_period__c=String.valueOf((Integer.valueOf(fy)-1)) + '-' + '12',TXT_External_ID__c = account.substring(0,15) + '-' + sku.substring(0,15) + '-' + String.valueOf((Integer.valueOf(fy)-1)) + '-' + '12');
            forecastJanuary = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_account__c = account, lkp_sku__c = sku, pick_period__c=fy + '-' + '01',TXT_External_ID__c = account.substring(0,15) + '-' + sku.substring(0,15) + '-' + fy + '-' + '01');
            forecastFebruary = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_account__c = account, lkp_sku__c = sku, pick_period__c=fy + '-' + '02',TXT_External_ID__c = account.substring(0,15) + '-' + sku.substring(0,15) + '-' + fy + '-' + '02');
            forecastMarch = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_account__c = account, lkp_sku__c = sku, pick_period__c=fy + '-' + '03',TXT_External_ID__c = account.substring(0,15) + '-' + sku.substring(0,15) + '-' + fy + '-' + '03');
            forecastApril= new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_account__c = account, lkp_sku__c = sku, pick_period__c=fy + '-' + '04',TXT_External_ID__c = account.substring(0,15) + '-' + sku.substring(0,15) + '-' + fy + '-' + '04');
            forecastMay = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_account__c = account, lkp_sku__c = sku, pick_period__c=fy + '-' + '05',TXT_External_ID__c = account.substring(0,15) + '-' + sku.substring(0,15) + '-' + fy + '-' + '05');
            forecastJune = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_account__c = account, lkp_sku__c = sku, pick_period__c=fy + '-' + '06',TXT_External_ID__c = account.substring(0,15) + '-' + sku.substring(0,15) + '-' + fy + '-' + '06');
            forecastJuly= new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_account__c = account, lkp_sku__c = sku, pick_period__c=fy + '-' + '07',TXT_External_ID__c = account.substring(0,15) + '-' + sku.substring(0,15) + '-' + fy + '-' + '07');
            forecastAugust = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast, lkp_account__c = account, lkp_sku__c = sku, pick_period__c=fy + '-' + '08',TXT_External_ID__c = account.substring(0,15) + '-' + sku.substring(0,15) + '-' + fy + '-' + '08');
        }        
        
    }
    
    public class familyTotal
    {
        public Boolean total {get; set;}
        public String name {get; set;}
        /*public Decimal totalForecast {get; set;}
        public Decimal totalForecastRel {get; set;}
        public Decimal totalDelivered {get; set;}
        public Decimal totalDeliveredRel {get; set;} */
        public itemForecast elemForecast {get; set;}

        public familyTotal(itemForecast item)
        {
            total = false;
            name = '';
            elemForecast = item;            
        }
    }
    
}