public class CP_forecastDistributionController
{
    public Integer distributeForecast{get; set;}
    public list<SelectOption> allProducts{get; set;}
    public List<SelectOption> selectedproducts{get; set;}
    public List<SelectOption> allDistributors{get; set;}
    public List<SelectOption> selectedDistributors{get; set;}
    public List<itemForecast> forecastPreview{get;set;}
    public List<itemForecast> forecastEditable{get;set;}
    public Action_Plan_Line__c aplFY {get; set;}
    public Country__c country {get; set;}
    public RecordType recordTypeAPL;
    private Map<String, Integer> mapActionPlanForecast = new Map<String, Integer>();
    private Map<String, Integer> mapActionPlanForecastRel = new Map<String, Integer>();

    public CP_forecastDistributionController()
    {
       aplFY = new Action_Plan_Line__c();            
       selectedproducts = new List<SelectOption>();
       selectedDistributors = new List<SelectOption>();
       allDistributors = new List<SelectOption>();
       forecastPreview = new List<itemForecast>();
       forecastEditable = new List<itemForecast>();   
       
       //Record Type ActionPlanLine Forecast
       recordTypeAPL = [SELECT Id FROM RecordType WHERE DeveloperName = 'Action_Plan_Line' LIMIT 1];
       
       if(System.Date.today().month()>=9 && System.Date.today().month() <= 12)  aplFY.PICK_Forecast_Fiscal_Year__c = String.valueOf(System.Date.today().year()+1);
       else if(System.Date.today().month()>= 1 && System.Date.today().month() <= 8) aplFY.PICK_Forecast_Fiscal_Year__c = String.valueOf(System.Date.today().year());
       
       //Get Units of Mesurement
       User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
       if(currentUser.Country != null) country = [SELECT Id, Units_of_Measurement__c FROM Country__c WHERE Name =: currentUser.Country];
       
       //Distributors
       for(Account a : [Select id, name from account where GC_Cust_Account_Grp_Descr__c=:'Sold-to party'  and (OwnerId =: UserInfo.getUserId() or Owner.ManagerId =: UserInfo.getUserId() or Owner.Manager.ManagerId =: UserInfo.getUserId()) order by name asc])
       {
           SelectOption opt = new SelectOption(a.id, a.name);
           allDistributors.add(opt);
       }
       
       getProducts();    
    }
    
    public void getProducts()
    {
       List<ID> listaCatalogosId = new List<ID>();
       List<ID> listaCatalogosFiltrada = new List<ID>();
       allProducts = new list<SelectOption>();
       Set<SelectOption> allProductsSet= new Set<SelectOption>();
       
       for(pricebook2 itemP : [select id from pricebook2 WHERE CP_Account_Type__c != 'PoS' AND isActive = true])
       {
           listaCatalogosId.add(itemP.id);
       }
       for(UserRecordAccess itemU : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE userid=:Userinfo.getUserId() and RecordID IN :listaCatalogosId ])
       {
            if(itemU.HasReadAccess)
               listaCatalogosFiltrada.add(itemU.RecordId); 
       }
       //System.debug('The list catalog filtered is: '+listaCatalogosFiltrada);

       for(Pricebookentry p : [SELECT Product2Id, product2.name, product2.TXT_commercial_name__c FROM PriceBookEntry where pricebook2id in :listaCatalogosFiltrada order by name asc])
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
    
    public void generateForecastPreview()
    {
        if(selectedproducts.size() > 0)
        {
        
            Integer forecastUnit = distributeForecast/(selectedproducts.size() * selectedDistributors.size() * 12);
            Integer resto = Math.mod(distributeForecast, (selectedproducts.size() * selectedDistributors.size() * 12));
            //initializeAplForecast();
            forecastEditable = new List<itemForecast>();
            Integer sum, sumRel;
            
            for(SelectOption acc : selectedDistributors)
            {            
                for(SelectOption prod : selectedProducts)
                {
                    sum = 0;
                    sumRel = 0;
                    itemForecast item = new itemForecast(recordTypeAPL, acc.getValue().substring(0,15), prod.getValue().substring(0,15));
                    item.account= acc.getlabel();
                    item.product = prod.getlabel();
                    
                    //BASIC UNITS
                    if(country.Units_of_Measurement__c == 'Basic Units')
                    {
                        item.forecastSeptember.NUM_Forecast__c = 0; 
                        item.forecastOctober.NUM_Forecast__c = 0;
                        item.forecastNovember.NUM_Forecast__c = 0;
                        item.forecastDecember.NUM_Forecast__c = 0;
                        item.forecastJanuary.NUM_Forecast__c = 0;
                        item.forecastFebruary.NUM_Forecast__c = 0;
                        item.forecastMarch.NUM_Forecast__c = 0;
                        item.forecastApril.NUM_Forecast__c = 0;
                        item.forecastMay.NUM_Forecast__c = 0;
                        item.forecastJune.NUM_Forecast__c = 0;
                        item.forecastJuly.NUM_Forecast__c = 0;
                        item.forecastAugust.NUM_Forecast__c = 0;
                        
                        item.forecastSeptember.NUM_Forecast__c = item.forecastSeptember.NUM_Forecast__c + forecastUnit;
                        item.forecastOctober.NUM_Forecast__c = item.forecastOctober.NUM_Forecast__c + forecastUnit;
                        item.forecastNovember.NUM_Forecast__c = item.forecastNovember.NUM_Forecast__c + forecastUnit;
                        item.forecastDecember.NUM_Forecast__c = item.forecastDecember.NUM_Forecast__c + forecastUnit;
                        item.forecastJanuary.NUM_Forecast__c = item.forecastJanuary.NUM_Forecast__c + forecastUnit;
                        item.forecastFebruary.NUM_Forecast__c = item.forecastFebruary.NUM_Forecast__c + forecastUnit;
                        item.forecastMarch.NUM_Forecast__c = item.forecastMarch.NUM_Forecast__c + forecastUnit;
                        item.forecastApril.NUM_Forecast__c = item.forecastApril.NUM_Forecast__c + forecastUnit;
                        item.forecastMay.NUM_Forecast__c = item.forecastMay.NUM_Forecast__c + forecastUnit;
                        item.forecastJune.NUM_Forecast__c = item.forecastJune.NUM_Forecast__c + forecastUnit;
                        item.forecastJuly.NUM_Forecast__c = item.forecastJuly.NUM_Forecast__c + forecastUnit;
                        item.forecastAugust.NUM_Forecast__c = item.forecastAugust.NUM_Forecast__c + forecastUnit;
                        
                        if(resto > 0)
                        {
                            item.forecastSeptember.NUM_Forecast__c = forecastUnit + 1;
                            resto = resto - 1;                    
                            
                            if(resto > 0)
                            {
                                item.forecastOctober.NUM_Forecast__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastNovember.NUM_Forecast__c  = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastDecember.NUM_Forecast__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            
                            if(resto > 0)
                            {
                                item.forecastJanuary.NUM_Forecast__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            
                            if(resto > 0)
                            {
                                item.forecastFebruary.NUM_Forecast__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastMarch.NUM_Forecast__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastApril.NUM_Forecast__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastMay.NUM_Forecast__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastJune.NUM_Forecast__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastJuly.NUM_Forecast__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastAugust.NUM_Forecast__c = forecastUnit + 1;
                                resto = resto - 1;
                            }                                                          
                        }
                        
                        //Total Units
                        if(item.forecastSeptember.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastSeptember.NUM_Forecast__c);
                        if(item.forecastOctober.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastOctober.NUM_Forecast__c);
                        if(item.forecastNovember.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastNovember.NUM_Forecast__c);
                        if(item.forecastDecember.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastDecember.NUM_Forecast__c);
                        if(item.forecastJanuary.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastJanuary.NUM_Forecast__c);
                        if(item.forecastFebruary.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastFebruary.NUM_Forecast__c);
                        if(item.forecastMarch.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastMarch.NUM_Forecast__c);
                        if(item.forecastApril.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastApril.NUM_Forecast__c);
                        if(item.forecastMay.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastMay.NUM_Forecast__c);
                        if(item.forecastJune.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastJune.NUM_Forecast__c);
                        if(item.forecastJuly.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastJuly.NUM_Forecast__c);
                        if(item.forecastAugust.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastAugust.NUM_Forecast__c);                   
                    }
                    
                    //RELS
                    if(country.Units_of_Measurement__c == 'Rels')
                    {
                        item.forecastSeptember.NUM_Forecast_Rel__c = 0; 
                        item.forecastOctober.NUM_Forecast_Rel__c = 0;
                        item.forecastNovember.NUM_Forecast_Rel__c = 0;
                        item.forecastDecember.NUM_Forecast_Rel__c = 0;
                        item.forecastJanuary.NUM_Forecast_Rel__c = 0;
                        item.forecastFebruary.NUM_Forecast_Rel__c = 0;
                        item.forecastMarch.NUM_Forecast_Rel__c = 0;
                        item.forecastApril.NUM_Forecast_Rel__c = 0;
                        item.forecastMay.NUM_Forecast_Rel__c = 0;
                        item.forecastJune.NUM_Forecast_Rel__c = 0;
                        item.forecastJuly.NUM_Forecast_Rel__c = 0;
                        item.forecastAugust.NUM_Forecast_Rel__c = 0;
                        
                        item.forecastSeptember.NUM_Forecast_Rel__c = item.forecastSeptember.NUM_Forecast_Rel__c + forecastUnit;
                        item.forecastOctober.NUM_Forecast_Rel__c = item.forecastOctober.NUM_Forecast_Rel__c + forecastUnit;
                        item.forecastNovember.NUM_Forecast_Rel__c = item.forecastNovember.NUM_Forecast_Rel__c + forecastUnit;
                        item.forecastDecember.NUM_Forecast_Rel__c = item.forecastDecember.NUM_Forecast_Rel__c + forecastUnit;
                        item.forecastJanuary.NUM_Forecast_Rel__c = item.forecastJanuary.NUM_Forecast_Rel__c + forecastUnit;
                        item.forecastFebruary.NUM_Forecast_Rel__c = item.forecastFebruary.NUM_Forecast_Rel__c + forecastUnit;
                        item.forecastMarch.NUM_Forecast_Rel__c = item.forecastMarch.NUM_Forecast_Rel__c + forecastUnit;
                        item.forecastApril.NUM_Forecast_Rel__c = item.forecastApril.NUM_Forecast_Rel__c + forecastUnit;
                        item.forecastMay.NUM_Forecast_Rel__c = item.forecastMay.NUM_Forecast_Rel__c + forecastUnit;
                        item.forecastJune.NUM_Forecast_Rel__c = item.forecastJune.NUM_Forecast_Rel__c + forecastUnit;
                        item.forecastJuly.NUM_Forecast_Rel__c = item.forecastJuly.NUM_Forecast_Rel__c + forecastUnit;
                        item.forecastAugust.NUM_Forecast_Rel__c = item.forecastAugust.NUM_Forecast_Rel__c + forecastUnit;
                        
                        if(resto > 0)
                        {
                            item.forecastSeptember.NUM_Forecast_Rel__c = forecastUnit + 1;
                            resto = resto - 1;                    
                            
                            if(resto > 0)
                            {
                                item.forecastOctober.NUM_Forecast_Rel__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastNovember.NUM_Forecast_Rel__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastDecember.NUM_Forecast_Rel__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            
                            if(resto > 0)
                            {
                                item.forecastJanuary.NUM_Forecast_Rel__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            
                            if(resto > 0)
                            {
                                item.forecastFebruary.NUM_Forecast_Rel__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastMarch.NUM_Forecast_Rel__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastApril.NUM_Forecast_Rel__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastMay.NUM_Forecast_Rel__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastJune.NUM_Forecast_Rel__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastJuly.NUM_Forecast_Rel__c = forecastUnit + 1;
                                resto = resto - 1;
                            }
                            if(resto > 0)
                            {
                                item.forecastAugust.NUM_Forecast_Rel__c = forecastUnit + 1;
                                resto = resto - 1;
                            }                                                          
                        }                    
                        
                        //Total Rels
                        if(item.forecastSeptember.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastSeptember.NUM_Forecast_Rel__c);
                        if(item.forecastOctober.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastOctober.NUM_Forecast_Rel__c);
                        if(item.forecastNovember.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastNovember.NUM_Forecast_Rel__c);
                        if(item.forecastDecember.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastDecember.NUM_Forecast_Rel__c);
                        if(item.forecastJanuary.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastJanuary.NUM_Forecast_Rel__c);
                        if(item.forecastFebruary.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastFebruary.NUM_Forecast_Rel__c);
                        if(item.forecastMarch.NUM_Forecast_Rel__c  != null) sumRel += Integer.valueOf(item.forecastMarch.NUM_Forecast_Rel__c);
                        if(item.forecastApril.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastApril.NUM_Forecast_Rel__c);
                        if(item.forecastMay.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastMay.NUM_Forecast_Rel__c);
                        if(item.forecastJune.NUM_Forecast_Rel__c  != null) sumRel += Integer.valueOf(item.forecastJune.NUM_Forecast_Rel__c);
                        if(item.forecastJuly.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastJuly.NUM_Forecast_Rel__c);
                        if(item.forecastAugust.NUM_Forecast_SKU_Rel__c != null) sumRel += Integer.valueOf(item.forecastAugust.NUM_Forecast_Rel__c);                
                    }
                    
                    if(sum == 0)
                        item.totalUnits = '';
                    else item.totalUnits = sum.format();
                    if(sumRel == 0)
                        item.totalRels = '';
                    else item.totalRels = sumRel.format();
                    
                    forecastEditable.add(item);                
                }              
            }
        }       
    }
    
    public void getForecast()
    {
       forecastPreview = new List<itemForecast>();
       forecastEditable = new List<itemForecast>();
       initializeAplForecast();
       Integer sum, sumrel;
       
       for(SelectOption acc : selectedDistributors)
        {           
            for(SelectOption prod : selectedProducts)
            {                                
                sum = 0;
                sumrel = 0;
                itemForecast item = new itemForecast(recordTypeAPL, acc.getValue().substring(0,15), prod.getValue().substring(0,15));
                item.account = acc.getlabel();
                item.product = prod.getlabel();
                //September                        
                item.forecastSeptember.NUM_Forecast__c  = mapActionPlanForecast.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + String.valueOf(Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1) + '-' + '09'); 
                item.forecastSeptember.NUM_Forecast_Rel__c = mapActionPlanForecastRel.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + String.valueOf(Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1) + '-' + '09');                
                //October
                item.forecastOctober.NUM_Forecast__c  = mapActionPlanForecast.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + String.valueOf(Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1) + '-' + '10');
                item.forecastOctober.NUM_Forecast_Rel__c = mapActionPlanForecastRel.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + String.valueOf(Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1) + '-' + '10');                
                //November
                item.forecastNovember.NUM_Forecast__c  = mapActionPlanForecast.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + String.valueOf(Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1) + '-' + '11');
                item.forecastNovember.NUM_Forecast_Rel__c = mapActionPlanForecastRel.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + String.valueOf(Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1) + '-' + '11');                
                //December
                item.forecastDecember.NUM_Forecast__c  = mapActionPlanForecast.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + String.valueOf(Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1) + '-' + '12');
                item.forecastDecember.NUM_Forecast_Rel__c = mapActionPlanForecastRel.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + String.valueOf(Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1) + '-' + '12');                
                //January
                item.forecastJanuary.NUM_Forecast__c = mapActionPlanForecast.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '01');
                item.forecastJanuary.NUM_Forecast_Rel__c = mapActionPlanForecastRel.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '01');                
                //February
                item.forecastFebruary.NUM_Forecast__c  = mapActionPlanForecast.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '02');
                item.forecastFebruary.NUM_Forecast_Rel__c = mapActionPlanForecastRel.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '02');
                //March           
                item.forecastMarch.NUM_Forecast__c  = mapActionPlanForecast.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '03');
                item.forecastMarch.NUM_Forecast_Rel__c = mapActionPlanForecastRel.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '03');
                //April
                item.forecastApril.NUM_Forecast__c = mapActionPlanForecast.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '04');
                item.forecastApril.NUM_Forecast_Rel__c = mapActionPlanForecastRel.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '04');
                //May
                item.forecastMay.NUM_Forecast__c  = mapActionPlanForecast.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '05');
                item.forecastMay.NUM_Forecast_Rel__c = mapActionPlanForecastRel.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '05');
                //June
                item.forecastJune.NUM_Forecast__c  = mapActionPlanForecast.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '06');
                item.forecastJune.NUM_Forecast_Rel__c = mapActionPlanForecastRel.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '06');
                //July
                item.forecastJuly.NUM_Forecast__c  = mapActionPlanForecast.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '07');
                item.forecastJuly.NUM_Forecast_Rel__c = mapActionPlanForecastRel.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '07');
                //August
                item.forecastAugust.NUM_Forecast__c  = mapActionPlanForecast.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '08');
                item.forecastAugust.NUM_Forecast_Rel__c = mapActionPlanForecastRel.get(acc.getValue().substring(0,15) + '-' + prod.getValue().substring(0,15) + '-' + aplFY.PICK_Forecast_Fiscal_Year__c + '-' + '08');
                
                //Total Units
                if(item.forecastSeptember.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastSeptember.NUM_Forecast__c);
                if(item.forecastOctober.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastOctober.NUM_Forecast__c);
                if(item.forecastNovember.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastNovember.NUM_Forecast__c);
                if(item.forecastDecember.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastDecember.NUM_Forecast__c);
                if(item.forecastJanuary.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastJanuary.NUM_Forecast__c);
                if(item.forecastFebruary.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastFebruary.NUM_Forecast__c);
                if(item.forecastMarch.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastMarch.NUM_Forecast__c);
                if(item.forecastApril.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastApril.NUM_Forecast__c);
                if(item.forecastMay.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastMay.NUM_Forecast__c);
                if(item.forecastJune.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastJune.NUM_Forecast__c);
                if(item.forecastJuly.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastJuly.NUM_Forecast__c);
                if(item.forecastAugust.NUM_Forecast__c != null) sum += Integer.valueOf(item.forecastAugust.NUM_Forecast__c);
                
                //Total Rels
                if(item.forecastSeptember.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastSeptember.NUM_Forecast_Rel__c);
                if(item.forecastOctober.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastOctober.NUM_Forecast_Rel__c);
                if(item.forecastNovember.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastNovember.NUM_Forecast_Rel__c);
                if(item.forecastDecember.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastDecember.NUM_Forecast_Rel__c);
                if(item.forecastJanuary.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastJanuary.NUM_Forecast_Rel__c);
                if(item.forecastFebruary.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastFebruary.NUM_Forecast_Rel__c);
                if(item.forecastMarch.NUM_Forecast_Rel__c  != null) sumRel += Integer.valueOf(item.forecastMarch.NUM_Forecast_Rel__c);
                if(item.forecastApril.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastApril.NUM_Forecast_Rel__c);
                if(item.forecastMay.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastMay.NUM_Forecast_Rel__c);
                if(item.forecastJune.NUM_Forecast_Rel__c  != null) sumRel += Integer.valueOf(item.forecastJune.NUM_Forecast_Rel__c);
                if(item.forecastJuly.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastJuly.NUM_Forecast_Rel__c);
                if(item.forecastAugust.NUM_Forecast_Rel__c != null) sumRel += Integer.valueOf(item.forecastAugust.NUM_Forecast_Rel__c);                
                
                if(sum == 0)
                    item.totalUnits = '';
                else item.totalUnits = sum.format();
                if(sumRel == 0)
                    item.totalRels = '';
                else item.totalRels = sumRel.format();                
                
                forecastPreview.add(item);
                forecastEditable.add(item);
            }
        }    
    }
    
    private void initializeAplForecast()
    {       
       List<Id> listProduct = new List<Id>();
       List<Id> listAccounts = new List<Id>();
       
       for(SelectOption prod : selectedProducts)
       {
           listProduct.add(prod.getValue());
       }
       
       for(SelectOption acc : selectedDistributors)
       {
           listAccounts.add(acc.getValue());
       }
        
       for(Action_Plan_Line__c apl : [SELECT Id, TXT_External_ID__c, NUM_Forecast__c, NUM_Forecast_Rel__c FROM Action_Plan_Line__c WHERE RecordTypeID =: recordTypeAPL.Id AND LKP_SKU__c IN :listProduct AND LKP_Account__c IN :listAccounts])
       {
           mapActionPlanForecast.put(apl.TXT_External_ID__c, Integer.valueOf(apl.NUM_Forecast__c));
           mapActionPlanForecastRel.put(apl.TXT_External_ID__c, Integer.valueOf(apl.NUM_Forecast_Rel__c));
       }       
    }
    
    public PageReference saveForecast()
    {
        List<Action_Plan_Line__c> aplUpserted = new List<Action_Plan_Line__c>();
        Integer sumAux, sumAuxRel;        
        for(itemForecast item : forecastEditable)
        {
            sumAux = 0;
            sumAuxRel = 0;
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
            
            system.debug('elem: '+item.forecastMay);
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
            
            if(sumAux == 0)
                item.totalUnits = '';
            else   item.totalUnits = sumAux.format();         
            if(sumAuxRel == 0)
                item.totalRels = '';
            else item.totalRels = sumAuxRel.format();
        }
        
        Schema.SObjectField f = Action_Plan_Line__c.Fields.TXT_External_ID__c;
        Database.upsert(aplUpserted, f, false);
        getForecast();
        return null;
    }
    
    public String previousFY
    {
        get
        {
           return String.valueOf((Integer.valueOf(aplFY.PICK_Forecast_Fiscal_Year__c)-1));
        }
        set{}
    }
    
    public List<SelectOption> fiscalYears
    {
        get
        {
            // Retrieve the picklist values
            Schema.DescribeFieldResult apl= Action_Plan_Line__c.PICK_Forecast_Fiscal_Year__c.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = apl.getPicklistValues();
            
            // Add picklist values to a SelectOption list
            List<SelectOption> fiscalYearSelect = new List<SelectOption>();
            for (Schema.PicklistEntry ple : picklistEntries)
            {
                fiscalYearSelect .add(new SelectOption(ple.getLabel(), ple.getValue()));
            }
            return fiscalYearSelect;
        }
    }
    
    public class itemForecast
    {
        public String account{get; set;}
        public String product{get; set;}
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
        public String totalUnits {get; set;}
        public String totalRels {get; set;}
        
        itemForecast( RecordType recordTypeForecast, String acc, String sku)
        {
            Integer fiscalYear = System.Date.today().month() > 8? System.Date.today().year()+1:System.Date.today().year();
            forecastSeptember = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast.Id, TXT_External_ID__c = string.valueOf(acc).substring(0,15) + '-' + string.valueOf(sku).substring(0,15) + '-' + String.valueOf(fiscalYear - 1) + '-' + '09', LKP_SKU__c = sku, LKP_Account__c = acc, PICK_Period__c = String.valueOf(fiscalYear - 1) + '-' + '09');
            forecastOctober= new Action_Plan_Line__c(RecordTypeId = recordTypeForecast.Id, TXT_External_ID__c = string.valueOf(acc).substring(0,15) + '-' + string.valueOf(sku).substring(0,15) + '-' + String.valueOf(fiscalYear - 1) + '-' + '10', LKP_SKU__c = sku, LKP_Account__c = acc, PICK_Period__c = String.valueOf(fiscalYear - 1) + '-' + '10');
            forecastNovember = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast.Id, TXT_External_ID__c = string.valueOf(acc).substring(0,15) + '-' + string.valueOf(sku).substring(0,15) + '-' + String.valueOf(fiscalYear - 1) + '-' + '11', LKP_SKU__c = sku, LKP_Account__c = acc,  PICK_Period__c = String.valueOf(fiscalYear - 1) + '-' + '11');
            forecastDecember = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast.Id, TXT_External_ID__c = string.valueOf(acc).substring(0,15) + '-' + string.valueOf(sku).substring(0,15) + '-' + String.valueOf(fiscalYear - 1) + '-' + '12', LKP_SKU__c = sku, LKP_Account__c = acc, PICK_Period__c = String.valueOf(fiscalYear - 1) + '-' + '12');
            forecastJanuary= new Action_Plan_Line__c(RecordTypeId = recordTypeForecast.Id, TXT_External_ID__c = string.valueOf(acc).substring(0,15) + '-' + string.valueOf(sku).substring(0,15) + '-' + String.valueOf(fiscalYear) + '-' + '01', LKP_SKU__c = sku, LKP_Account__c = acc, PICK_Period__c = String.valueOf(fiscalYear) + '-' + '01');
            forecastFebruary = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast.Id, TXT_External_ID__c = string.valueOf(acc).substring(0,15) + '-' + string.valueOf(sku).substring(0,15) + '-' + String.valueOf(fiscalYear) + '-' + '02', LKP_SKU__c = sku, LKP_Account__c = acc, PICK_Period__c = String.valueOf(fiscalYear) + '-' + '02');
            forecastMarch = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast.Id, TXT_External_ID__c = string.valueOf(acc).substring(0,15) + '-' + string.valueOf(sku).substring(0,15) + '-' + String.valueOf(fiscalYear) + '-' + '03',LKP_SKU__c = sku, LKP_Account__c = acc, PICK_Period__c = String.valueOf(fiscalYear) + '-' + '03');
            forecastApril= new Action_Plan_Line__c(RecordTypeId = recordTypeForecast.Id, TXT_External_ID__c = string.valueOf(acc).substring(0,15) + '-' + string.valueOf(sku).substring(0,15) + '-' + String.valueOf(fiscalYear) + '-' + '04', LKP_SKU__c = sku, LKP_Account__c = acc, PICK_Period__c = String.valueOf(fiscalYear) + '-' + '04');
            forecastMay = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast.Id, TXT_External_ID__c = string.valueOf(acc).substring(0,15) + '-' + string.valueOf(sku).substring(0,15) + '-' + String.valueOf(fiscalYear) + '-' + '05', LKP_SKU__c = sku, LKP_Account__c = acc, PICK_Period__c = String.valueOf(fiscalYear) + '-' + '05');
            forecastJune = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast.Id, TXT_External_ID__c = string.valueOf(acc).substring(0,15) + '-' + string.valueOf(sku).substring(0,15) + '-' + String.valueOf(fiscalYear) + '-' + '06', LKP_SKU__c = sku, LKP_Account__c = acc, PICK_Period__c = String.valueOf(fiscalYear) + '-' + '06');
            forecastJuly= new Action_Plan_Line__c(RecordTypeId = recordTypeForecast.Id, TXT_External_ID__c = string.valueOf(acc).substring(0,15) + '-' + string.valueOf(sku).substring(0,15) + '-' + String.valueOf(fiscalYear) + '-' + '07', LKP_SKU__c = sku, LKP_Account__c = acc, PICK_Period__c = String.valueOf(fiscalYear) + '-' + '07');
            forecastAugust = new Action_Plan_Line__c(RecordTypeId = recordTypeForecast.Id, TXT_External_ID__c = string.valueOf(acc).substring(0,15) + '-' + string.valueOf(sku).substring(0,15) + '-' + String.valueOf(fiscalYear) + '-' + '08', LKP_SKU__c = sku, LKP_Account__c = acc, PICK_Period__c = String.valueOf(fiscalYear) + '-' + '08');           
        }
    }    
}