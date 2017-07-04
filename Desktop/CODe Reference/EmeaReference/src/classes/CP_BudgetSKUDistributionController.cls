public class CP_BudgetSKUDistributionController
{
    public List<SelectOption> selectedproducts{get; set;}
    public List<itemBudget> budgetPreview{get;set;}
    public Action_Plan_Line__c aplFY {get; set;}
    public Id recordTypeBudget;
    public Country__c country {get; set;}
    private List<Product2> listProduct = new List<Product2>();
    private List<String> listPeriods = new List<String>();
    private Map<String, Decimal> mapActionPlanBudget = new Map<String, Decimal>();


    public CP_BudgetSKUDistributionController()
    {
       selectedproducts = new List<SelectOption>();       
       List<ID> listaCatalogosId = new List<ID>();
       List<ID> listaCatalogosFiltrada = new List<ID>();       
        aplFY = new Action_Plan_Line__c();
        if((System.Date.today().month() >= 9) && (System.Date.today().month() <= 12))  aplFY.PICK_Budget_Fiscal_Year__c = String.valueOf(System.Date.today().year()+1);
        else if((System.Date.today().month() >= 1) && (System.Date.today().month() <= 8)) aplFY.PICK_Budget_Fiscal_Year__c = String.valueOf(System.Date.today().year());
       
       //Record Type ActionPlanLine Budget
       recordTypeBudget = Util.recordtype.get('Action_Plan_Line__c:CP_Budget');
       
       //Get Units of Mesurement
       User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
       if(currentUser.Country != null) country = [SELECT Id, Units_of_Measurement__c, Name FROM Country__c WHERE Name =: currentUser.Country];
        
       for(pricebook2 itemP : [select id from pricebook2 WHERE CP_Account_Type__c = 'Distributor' AND isActive = true AND CountryRef__r.Name =: country.Name])
       {
           listaCatalogosId.add(itemP.id);
       }
       for(UserRecordAccess itemU : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE userid=:Userinfo.getUserId() and RecordID IN :listaCatalogosId ])
       {
            if(itemU.HasReadAccess)
               listaCatalogosFiltrada.add(itemU.RecordId);
       }
       
       listProduct = [SELECT Id, Name, TXT_commercial_name__c FROM Product2 WHERE Id IN (SELECT Product2Id FROM PriceBookEntry where pricebook2id in :listaCatalogosFiltrada) order by name];       
       getData();     
    }
    
    public void getData()
    {
      
       budgetPreview = new List<itemBudget>();
       mapActionPlanBudget = initializeAplBudget();
       for(Product2 p : listProduct)
       {           
           //Create Action Plan Line Budget item
           itemBudget item = new itemBudget(recordTypeBudget, p.Id, aplFY.PICK_Budget_Fiscal_Year__c, UserInfo.getUserId());           
           item.product = p.TXT_commercial_name__c;           
           //FY Action Plan Line
           if(country.Units_of_Measurement__c == 'Basic Units') item.budget.NUM_Budget__c = mapActionPlanBudget.get(String.valueOf(p.Id).substring(0,15) + '-' + aplFY.PICK_Budget_Fiscal_Year__c + '-' + String.valueOf(UserInfo.getUserId()).substring(0,15) + '-' + 'budget');
           if(country.Units_of_Measurement__c == 'Rels') item.budget.NUM_Budget_Rel__c = mapActionPlanBudget.get(String.valueOf(p.Id).substring(0,15) + '-' + aplFY.PICK_Budget_Fiscal_Year__c + '-' + String.valueOf(UserInfo.getUserId()).substring(0,15) + '-' + 'budget');           
           budgetPreview.add(item);
       }    
    }
    
    public void saveBudgetSKU()
    {
        List<Action_Plan_Line__c> aplUpserted = new List<Action_Plan_Line__c>();
        for(itemBudget item : budgetPreview)
        {
            aplUpserted.add(item.budget);
        }
        Database.upsert(aplUpserted, Action_Plan_Line__c.TXT_External_id__c);        
    }
    
    private Map<String, Decimal> initializeAplBudget()
    {               
       for(Action_Plan_Line__c apl : [SELECT Id, TXT_External_ID__c, NUM_Budget__c, NUM_Budget_Rel__c FROM Action_Plan_Line__c WHERE RecordTypeID =: recordTypeBudget AND LKP_SKU__c IN :listProduct  AND OwnerId =:userinfo.getuserid()])
       {
           if(country.Units_of_Measurement__c == 'Basic Units') mapActionPlanBudget.put(apl.TXT_External_ID__c, apl.NUM_Budget__c);
           else if(country.Units_of_Measurement__c == 'Rels') mapActionPlanBudget.put(apl.TXT_External_ID__c, apl.NUM_Budget_Rel__c);
       }       
       return mapActionPlanBudget;
    }
  
    public class itemBudget
    {
        public String product {get; set;}
        public Action_Plan_Line__c budget {get; set;}
        
        itemBudget(Id recordTypeBudget, String sku, String fy, Id userId)
        {
            budget = new Action_Plan_Line__c(RecordTypeId = recordTypeBudget, TXT_External_ID__c = sku.substring(0,15) + '-' + fy + '-' + String.valueOf(userId).substring(0,15) + '-' + 'budget' , lkp_sku__c = sku, PICK_Budget_Fiscal_Year__c = fy, PICK_Period__c = fy + '-' + '01');          
        }
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
    
}