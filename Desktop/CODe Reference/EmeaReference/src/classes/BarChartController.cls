/*** Romanian sales representative home page charts controller ***/
/* This controller gets information to create 3 charts on the home page of the Romanian sales representatives */

// Formulas:
// Retention = [number of farmers with Agreed CY (and PY)]/number of farmers with Agreed in PY -> Percentage. How many farms who were clients on PY are clients again on CY.
// Penetration = clients CY /total accounts in Romania's data base -> Percentage. How many accounts out of the total are clients on CY
// Inventory = Agreed - POG

public class BarChartController{
    
    public Id UserId {get;set;}
    map<String, List<Decimal>> ProductMixData = new map<String, List<Decimal>>();
    public Id CountryID {get;set;}
    public String CurrentYear {get;set;}
    public String UserName {get;set;}
    public String PreviousYear {get;set;}
    public RecordType Rec{get;set;}
    public String CliRecType {get;set;}
    public String ARecType {get;set;}
    
    //Global variables
    decimal Nclasic=0;
    decimal Nclearfield=0;
    decimal Ntotal=0;
    decimal PDclasic=0;
    decimal PDclearfield=0;
    decimal Pclasic=0;
    decimal Pclearfield=0;
    
    decimal NSmall=0;
    decimal NMedium=0;
    decimal NKey=0;
    
    //Controller
    public BarChartController(ApexPages.StandardController controller){
        
        //User data
        
        UserId = system.UserInfo.getUserId();
        system.debug('user:' + UserId);
        
        User UserInfo = [SELECT Id, name, country from User where Id=:UserId];
        system.debug('Debug1 User Country: ' + UserInfo.country);
        
        UserName = UserInfo.name;
        String CountryName = UserInfo.country;      
        system.debug('Debug2 '+ CountryName);
        
        List<Country__c> Country = new List<Country__c>();
        Country = [SELECT id, name, LKP_CurrentYear__r.name From Country__c where name=:CountryName];
        system.debug('Debug3 '+ Country[0].LKP_CurrentYear__r.name);
        CountryID = Country[0].id;
        CurrentYear = Country[0].LKP_CurrentYear__r.name;
        
        //Recordtype sales
        RecordType Rec= [Select Id From RecordType Where SobjectType = 'CampaignLineItem__c' and DeveloperName = 'Sales'];
        CliRecType = Rec.Id;
        System.debug ('**** Record inicial: '+CliRecType);
        
        //Recordtype Group/Farm/Site
        RecordType ARec= [Select Id From RecordType Where SobjectType = 'Account' and DeveloperName = 'GroupFarmSite'];
        ARecType = ARec.Id;
    }

/*** Volume By Status CHART 1***/
    public List<volumeByStatus> getDataVolumeByStatus() {
        
        system.debug('**** user ' + UserId);
        system.debug('**** year ' + CurrentYear);
        system.debug('**** Record ' + CliRecType);
                
        AggregateResult[] ARs = [SELECT owner.name acc , SUM(POG__C) pog, SUM(Forecast_Charged__c) forecast, SUM(Agreed__c) agreed, SUM(CampaignRef__r.TotalCampaignBudget__c) budget, SUM(FarmRef__r.OSRDekalbMarketshareCY__c) MS FROM CampaignLineItem__c 
                                 where ownerId=:UserId and recordtypeID=: CliRecType and year__c=:CurrentYear GROUP BY ownerID , owner.name];
        
        List<VolumeByStatus> volumeByStatusdata = new List<VolumeByStatus>();
        
        // Variables chart 1
        decimal APY=0; //Accounts with sales PY
        decimal ACY=0; //Accounts with agreed CY
        decimal AA=0; //All accounts
        decimal AACY=0; //All accounts CY
        decimal ret=0;
        decimal pen=0;
        decimal retd=0;
        decimal pend=0;
        decimal inv=0;
        
        //Retention
        for (Account Acc: [SELECT id FROM Account WHERE OwnerId=:UserID and CornTotalSalesPY__c>0 and RecordTypeId=: ARecType]) {
            
            APY++;
        }
        
        for (Account Acc: [SELECT id FROM Account WHERE OwnerId=:UserID and (NUM_AGREED_CORN_CHARGED_PY__c>0 or NUM_AGREED_OSR_PY__c>0) and (NUM_AGREED_CORN_CHARGED_CY__c>0 or NUM_AGREED_OSR_CY__c>0) and RecordTypeId=: ARecType]) {
            
            ACY++;
        }
        
        if (APY != 0 && APY != null){
        retd = (ACY/APY)*100;
        } else {
            retd=0;
        }
        ret = retd.setScale(2);
        
        //Penetration
        for (Account Acc: [SELECT id FROM Account WHERE countryRef__c=:CountryID and RecordTypeId=: ARecType]) {
            
            AA++;
        }
        
        system.debug('All accounts: '+AA);
        
        for (Account Acc: [SELECT id FROM Account WHERE OwnerId=:UserID and (NUM_AGREED_CORN_CHARGED_CY__c>0 or NUM_AGREED_OSR_CY__c>0)and RecordTypeId=: ARecType]) {
            
            AACY++;
        }
        
        system.debug('All accounts current year: '+AACY);
        
        if(AA != 0 && AA != null){
        pend = (AACY/AA)*100;
        } else {
            pend=0;
        }
        
        pen = pend.setScale(2);
        
        system.debug('penetration: '+pen);
        
        for(AggregateResult volumeByStatusitem : ARs)
        {    
            if (Integer.ValueOf(volumeByStatusitem.get('agreed'))!=null){
                if (Integer.ValueOf(volumeByStatusitem.get('pog'))!=null){
                inv = (Integer.ValueOf(volumeByStatusitem.get('agreed')) - Integer.ValueOf(volumeByStatusitem.get('pog'))); //Small account inventory formula = Agreed - POG 
                }
                else{
                    inv = Integer.ValueOf(volumeByStatusitem.get('agreed'));
                }
            }
            volumeByStatusdata.add(new volumeByStatus((String)volumeByStatusitem.get('acc'), Integer.ValueOf(volumeByStatusitem.get('budget')),Integer.ValueOf(volumeByStatusitem.get('forecast')), Integer.ValueOf(volumeByStatusitem.get('agreed')), Integer.ValueOf(volumeByStatusitem.get('pog')), Integer.ValueOf(volumeByStatusitem.get('MS')), ret, pen, inv));
        }
        
        
        system.debug('volumeByStatus Data: '+volumeByStatusdata);
        
        return volumeByStatusdata;
    }
    
    
    public class volumeByStatus{
        
        public String acc{ get; set; }
        public Integer budget{get;set;}
        public Integer forecast{ get; set; }
        public Integer agreed{get;set;}
        public Integer pog{get;set;}
        public Integer MS{get;set;}
        public decimal retention{get;set;}
        public decimal penetration{get;set;}
        public decimal inventory{get;set;}
        
        public volumeByStatus(String name, Integer budget, Integer forecast, Integer agreed, Integer pog, Integer MS, decimal retention, decimal penetration, decimal inventory) {
            
            this.acc= name;
            this.budget = budget;
            this.forecast= forecast;
            this.agreed = agreed;
            this.pog = pog; 
            this.MS = MS;
            this.retention = retention;
            this.penetration = penetration;
            this.inventory = inventory;
        }
    }
    
    /***Crop Size CHART 2***/
    
    public void DataFarmSize() {
        
        /* Small account chart 2 */
        
        //Varaibles
        decimal SAPY=0; //All accounts PY Small farm
        decimal SACY=0; //Accounts CY Small farm
        decimal SAA=0; //all accounts Small farm
        decimal SAACY=0; //All accounts CY Small farm
        decimal Sret=0; //Small farms retention
        decimal Spen=0; //Small farms penetration
        decimal Sretd=0; 
        decimal Spend=0;
        decimal Sinv=0; //Small farms inventory
        
        //Retention calculation
        for (Account Acc: [SELECT id FROM Account WHERE OwnerId=:UserID and (NUM_AGREED_CORN_CHARGED_PY__c>0 or NUM_AGREED_OSR_PY__c>0) and Farm_Auto_Segmentation__c = 'Small Account' and RecordTypeId=: ARecType]) {
            
            SAPY++;
        }
        for (Account Acc: [SELECT id FROM Account WHERE OwnerId=:UserID and (NUM_AGREED_CORN_CHARGED_PY__c>0 or NUM_AGREED_OSR_PY__c>0) and (NUM_AGREED_CORN_CHARGED_CY__c>0 or NUM_AGREED_OSR_CY__c>0) and Farm_Auto_Segmentation__c = 'Small Account' and RecordTypeId=: ARecType]) {
            
            SACY++;
        }
        if(SAPY != 0 && SAPY != null){
        Sretd = (SACY/SAPY)*100; //retention formula
        } else {
            Sretd=0;
        }
        Sret = Sretd.setScale(2);
        
        
        //Penetration calculation
        for (Account Acc: [SELECT id FROM Account WHERE countryRef__c=: CountryID and Farm_Auto_Segmentation__c = 'Small Account' and RecordTypeId=: ARecType]) {
            
            SAA++;
        }
        
        for (Account Acc: [SELECT id FROM Account WHERE OwnerId=:UserID and (NUM_AGREED_CORN_CHARGED_CY__c>0 or NUM_AGREED_OSR_CY__c>0) and Farm_Auto_Segmentation__c = 'Small Account' and RecordTypeId=: ARecType]) {
            
            SAACY++;
        }
        if(SAA!=0 && SAA !=null){
        Spend = (SAACY/SAA)*100; //Penetration formula
        } else {
            Spend=0;
        }
        Spen = Spend.setScale(2);
        
        //Add values
            
        for(AggregateResult ARs : [ SELECT COUNT(Id) NID, owner.name acc , SUM(POG__C) pog, SUM(Forecast_Charged__c) forecast, SUM(Agreed__c) agreed, SUM(CampaignRef__r.TotalCampaignBudget__c) budget, SUM(FarmRef__r.OSRDekalbMarketshareCY__c) MS FROM CampaignLineItem__c 
                                 where ownerId=:UserId and recordtypeID=:CliRecType and FarmRef__r.Farm_Auto_Segmentation__c = 'Small Account' and year__c=:CurrentYear GROUP BY ownerID , owner.name]){
            
            if (Integer.ValueOf(ARs.get('agreed'))!=null){
                if (Integer.ValueOf(ARs.get('pog'))!=null){
                Sinv = (Integer.ValueOf(ARs.get('agreed')) - Integer.ValueOf(ARs.get('pog'))); //Small account inventory
                }
                else{
                    Sinv = Integer.ValueOf(ARs.get('agreed'));
                }
            }
            
          List<Decimal> FSize = new List<Decimal>{Integer.ValueOf(ARs.get('budget')),Integer.ValueOf(ARs.get('forecast')),Integer.ValueOf(ARs.get('agreed')),Integer.ValueOf(ARs.get('pog')), Integer.ValueOf(ARs.get('MS')), Sret, Spen, Sinv};
          NSmall = Integer.ValueOf(ARs.get('NID'));
          
          system.debug('DataFarmSize Data: '+FSize);
          ProductMixData.put('Small Account',FSize);
          system.debug('DataFarmSize Data: '+FSize);
        }
        
        /* Medium account chart 2 */
        
        //Variables        
        decimal MAPY=0; //Accounts PY Medium farm
        decimal MACY=0; //Medium accounts CY
        decimal MAA=0; //all accounts
        decimal MAACY=0; //All medium accounts CY
        decimal Mret=0;
        decimal Mpen=0;
        decimal Mretd=0;
        decimal Mpend=0;
        decimal Minv=0;
        
        //Retention calculation
        for (Account Acc: [SELECT id FROM Account WHERE OwnerId=:UserID and (NUM_AGREED_CORN_CHARGED_PY__c>0 or NUM_AGREED_OSR_PY__c>0) and Farm_Auto_Segmentation__c = 'Medium Account' and RecordTypeId=: ARecType]) {
            
            MAPY++;
        }
        
        for (Account Acc: [SELECT id FROM Account WHERE OwnerId=:UserID and (NUM_AGREED_CORN_CHARGED_PY__c>0 or NUM_AGREED_OSR_PY__c>0) and (NUM_AGREED_CORN_CHARGED_CY__c>0 or NUM_AGREED_OSR_CY__c>0) and Farm_Auto_Segmentation__c = 'Medium Account' and RecordTypeId=: ARecType]) {
            
            MACY++;
        }
        if(MAPY!=0 && MAPY != null) {
        Mretd = (MACY/MAPY)*100; //Retention formula
        } else {
            Mretd=0;
        }
        Mret = Mretd.setScale(2);
        
        //Penetration calculation
        for (Account Acc: [SELECT id FROM Account WHERE countryRef__c=: CountryID and Farm_Auto_Segmentation__c = 'Medium Account' and RecordTypeId=: ARecType]) {
            
            MAA++;
        }
        
        for (Account Acc: [SELECT id FROM Account WHERE OwnerId=:UserID and (NUM_AGREED_CORN_CHARGED_CY__c>0 or NUM_AGREED_OSR_CY__c>0) and Farm_Auto_Segmentation__c = 'Medium Account' and RecordTypeId=: ARecType]) {
            
            MAACY++;
        }
        if(MAA!=0 && MAA!=null){
        Mpend = (MAACY/MAA)*100; //Penetration formula
        } else {
            Mpend=0;
        }
        Mpen = Mpend.setScale(2);
        
        
        for(AggregateResult ARs : [ SELECT COUNT(Id) NID, owner.name acc , SUM(POG__C) pog, SUM(Forecast_Charged__c) forecast, SUM(Agreed__c) agreed, SUM(CampaignRef__r.TotalCampaignBudget__c) budget, SUM(FarmRef__r.OSRDekalbMarketshareCY__c) MS FROM CampaignLineItem__c 
                                 where ownerId=:UserId and recordtypeID=:CliRecType and FarmRef__r.Farm_Auto_Segmentation__c = 'Medium Account' and year__c=:CurrentYear GROUP BY ownerID , owner.name]){      

            if (Integer.ValueOf(ARs.get('agreed'))!=null){
                if (Integer.ValueOf(ARs.get('pog'))!=null){
                Minv = (Integer.ValueOf(ARs.get('agreed')) - Integer.ValueOf(ARs.get('pog'))); //Medium account inventory
                }
                else{
                    Minv = Integer.ValueOf(ARs.get('agreed'));
                }
            }
          
          List<Decimal> FSize = new List<Decimal>{Integer.ValueOf(ARs.get('budget')),Integer.ValueOf(ARs.get('forecast')),Integer.ValueOf(ARs.get('agreed')),Integer.ValueOf(ARs.get('pog')), Integer.ValueOf(ARs.get('MS')), Mret, Mpen, Minv};
          NMedium = Integer.ValueOf(ARs.get('NID'));
          system.debug('DataFarmSize Data: '+FSize);
          ProductMixData.put('Medium Account',FSize);
          system.debug('DataFarmSize Data: '+FSize);
        }
                
       /* Key account chart 2 */
        
        //Variables
        decimal KAPY=0; //Key accounts PY
        decimal KACY=0; //Key accounts CY
        decimal KAA=0; //all accounts
        decimal KAACY=0; //All key accounts CY
        decimal Kret=0;
        decimal Kpen=0;
        decimal Kretd=0;
        decimal Kpend=0;
        decimal Kinv=0;
        
        //Retention calculation
        for (Account Acc: [SELECT id FROM Account WHERE OwnerId=:UserID and (NUM_AGREED_CORN_CHARGED_PY__c>0 or NUM_AGREED_OSR_PY__c>0) and Farm_Auto_Segmentation__c = 'Key Account' and RecordTypeId=: ARecType]) {
            
            KAPY++;
        }
        
        for (Account Acc: [SELECT id FROM Account WHERE OwnerId=:UserID and (NUM_AGREED_CORN_CHARGED_PY__c>0 or NUM_AGREED_OSR_PY__c>0) and (NUM_AGREED_CORN_CHARGED_CY__c>0 or NUM_AGREED_OSR_CY__c>0) and Farm_Auto_Segmentation__c = 'Key Account' and RecordTypeId=: ARecType]) {
            
            KACY++;
        }
        if(KAPY!=0 && KAPY!=null){
        Kretd = (KACY/KAPY)*100;
        } else {
            Kretd=0;
        }
        Kret = Kretd.setScale(2);
        
        //Penetration calculation
        for (Account Acc: [SELECT id FROM Account WHERE countryRef__c=: CountryID and Farm_Auto_Segmentation__c = 'Key Account' and RecordTypeId=: ARecType]) {
            
            KAA++;
        }
        
        for (Account Acc: [SELECT id FROM Account WHERE OwnerId=:UserID and (NUM_AGREED_CORN_CHARGED_CY__c>0 or NUM_AGREED_OSR_CY__c>0) and Farm_Auto_Segmentation__c = 'Key Account' and RecordTypeId=: ARecType]) {
            
            KAACY++;
        }
        if(KAA!=0 && KAA!=null){
        Kpend = (KAACY/KAA)*100;
        } else {
            Kpend=0;
        }
        Kpen = Kpend.setScale(2);
        
        
        for(AggregateResult ARs : [ SELECT COUNT(Id) NID, owner.name acc , SUM(POG__C) pog, SUM(Forecast_Charged__c) forecast, SUM(Agreed__c) agreed, SUM(CampaignRef__r.TotalCampaignBudget__c) budget, SUM(FarmRef__r.OSRDekalbMarketshareCY__c) MS FROM CampaignLineItem__c 
                                 where ownerId=:UserId and recordtypeID=:CliRecType and FarmRef__r.Farm_Auto_Segmentation__c = 'Key Account' and year__c=:CurrentYear GROUP BY ownerID , owner.name]){      
            
            if (Integer.ValueOf(ARs.get('agreed'))!=null){
                if (Integer.ValueOf(ARs.get('pog'))!=null){
                Kinv = (Integer.ValueOf(ARs.get('agreed')) - Integer.ValueOf(ARs.get('pog'))); //Key account inventory
                }
                else{
                    Kinv = Integer.ValueOf(ARs.get('agreed'));
                }
            }
          
          List<Decimal> FSize = new List<Decimal>{Integer.ValueOf(ARs.get('budget')),Integer.ValueOf(ARs.get('forecast')),Integer.ValueOf(ARs.get('agreed')),Integer.ValueOf(ARs.get('pog')), Integer.ValueOf(ARs.get('MS')), Kret, Kpen, Kinv};
          NKey = Integer.ValueOf(ARs.get('NID'));
          system.debug('DataFarmSize Data: '+FSize);
          ProductMixData.put('Key Account',FSize);
          system.debug('DataFarmSize Data: '+FSize);
        }
    }
    
        public FarmSize[] Farm{
            
            get{
                DataFarmSize();
                Farm = new FarmSize[]{};
                
                if(ProductMixData.get('Small Account')!=null)
                  Farm.add(new FarmSize('Small Crop Farms('+NSmall+')',ProductMixData.get('Small Account')[0], ProductMixData.get('Small Account')[1], ProductMixData.get('Small Account')[2], ProductMixData.get('Small Account')[3], ProductMixData.get('Small Account')[4], ProductMixData.get('Small Account')[5], ProductMixData.get('Small Account')[6], ProductMixData.get('Small Account')[7]));
                    else {
                        Farm.add(new FarmSize('Small Crop Farms(0)',0,0,0,0,0,0,0,0));
                    }
                if(ProductMixData.get('Medium Account')!=null)
                  Farm.add(new FarmSize('Medium Crop Farms('+NMedium+')',ProductMixData.get('Medium Account')[0], ProductMixData.get('Medium Account')[1], ProductMixData.get('Medium Account')[2], ProductMixData.get('Medium Account')[3], ProductMixData.get('Medium Account')[4], ProductMixData.get('Medium Account')[5], ProductMixData.get('Medium Account')[6], ProductMixData.get('Medium Account')[7]));
                    else {
                        Farm.add(new FarmSize('Medium Crop Farms(0)',0,0,0,0,0,0,0,0));
                    }
                if(ProductMixData.get('Key Account')!=null)
                  Farm.add(new FarmSize('Key Crop Farms('+NKey+')',ProductMixData.get('Key Account')[0], ProductMixData.get('Key Account')[1], ProductMixData.get('Key Account')[2], ProductMixData.get('Key Account')[3], ProductMixData.get('Key Account')[4], ProductMixData.get('Key Account')[5], ProductMixData.get('Key Account')[6], ProductMixData.get('Key Account')[7]));
                    else {
                        Farm.add(new FarmSize('Key Crop Farms(0)',0,0,0,0,0,0,0,0));
                    }
                return Farm;
                }
            set;
        }
    
    public class FarmSize{
        
        public String acc{ get; set; }
        public decimal budget{get;set;}
        public decimal forecast{ get; set; }
        public decimal agreed{get;set;}
        public decimal pog{get;set;}
        public decimal MS{get;set;}
        public decimal retention{get;set;}    
        public decimal penetration{get;set;}
        public decimal inventory{get;set;}
        
        public FarmSize(String name, decimal budget, decimal forecast, decimal agreed, decimal pog, decimal MS, decimal retention, decimal penetration, decimal inventory) {
            
            this.acc= name;
            this.budget = budget;
            this.forecast= forecast;
            this.agreed = agreed;
            this.pog = pog; 
            this.MS = MS;   
            this.retention = retention;
            this.penetration = penetration; 
            this.inventory = inventory;
        }
    }
    
    /*** Product Mix CHART 3***/
    
    public void DataProductMix() {
        
        Decimal CLEARinv=0;
        Decimal CLASICinv=0;
        
        for(AggregateResult ARs : [ SELECT COUNT(Id) NID, owner.name acc , SUM(POG__C) pog, SUM(Forecast_Charged__c) forecast, SUM(Agreed__c) agreed FROM CampaignLineItem__c 
                                 where ownerId=:UserId and recordtypeID=:CliRecType and ProductRef__r.ProductHybridGroup__c='CLASIC' and year__c=:CurrentYear GROUP BY ownerID , owner.name]){
          
            if (Integer.ValueOf(ARs.get('agreed'))!=null){
                if (Integer.ValueOf(ARs.get('pog'))!=null){
                CLASICinv = (Integer.ValueOf(ARs.get('agreed')) - Integer.ValueOf(ARs.get('pog'))); //Clasic inventory
                }
                else{
                    CLASICinv = Integer.ValueOf(ARs.get('agreed'));
                }
            }

       system.debug('ei1 ' + ARs);
        system.debug('ei2 ' + ARs.get('agreed'));       
          List<Decimal> productMixdata1 = new List<Decimal>{Integer.ValueOf(ARs.get('forecast')),Integer.ValueOf(ARs.get('agreed')),Integer.ValueOf(ARs.get('pog')), CLASICinv};
          Nclasic = Integer.ValueOf(ARs.get('NID'));
          system.debug('ProductMixClasic Data: '+productMixdata1);
          ProductMixData.put('Clasic',productMixdata1);
          system.debug('ProductMixClasic Data: '+productMixdata1);
         }
        
        for(AggregateResult ARs : [ SELECT COUNT(Id) NID, owner.name acc , SUM(POG__C) pog, SUM(Forecast_Charged__c) forecast, SUM(Agreed__c) agreed FROM CampaignLineItem__c 
                                 where ownerId=:UserId and recordtypeID=:CliRecType and ProductRef__r.ProductHybridGroup__c='CLEARFIELD' and year__c=:CurrentYear GROUP BY ownerID , owner.name]){
          
            if (Integer.ValueOf(ARs.get('agreed'))!=null){
                if (Integer.ValueOf(ARs.get('pog'))!=null){
                CLEARinv = (Integer.ValueOf(ARs.get('agreed')) - Integer.ValueOf(ARs.get('pog'))); //Clasic inventory
                }
                else{
                    CLEARinv = Integer.ValueOf(ARs.get('agreed'));
                }
            }
                      
          List<Decimal> productMixdata1 = new List<Decimal>{Integer.ValueOf(ARs.get('forecast')),Integer.ValueOf(ARs.get('agreed')),Integer.ValueOf(ARs.get('pog')), CLEARinv};
          Nclearfield = Integer.ValueOf(ARs.get('NID')); 
          ProductMixData.put('Clearfield',productMixdata1);
          system.debug('ProductMixClearfield Data: '+productMixdata1);
        }
        
        for(AggregateResult ARs : [ SELECT owner.name acc , SUM(POG__C) pog, SUM(Forecast_Charged__c) forecast, SUM(Agreed__c) agreed FROM CampaignLineItem__c 
                                 where ownerId=:UserId and recordtypeID=:CliRecType and (ProductRef__r.ProductHybridGroup__c= 'CLEARFIELD' or ProductRef__r.ProductHybridGroup__c='CLASIC') and year__c=:CurrentYear GROUP BY ownerID , owner.name]){
          List<Decimal> productMixdata1 = new List<Decimal>{Integer.ValueOf(ARs.get('forecast')),Integer.ValueOf(ARs.get('agreed')),Integer.ValueOf(ARs.get('pog'))};
          
          ProductMixData.put('Total',productMixdata1);
          system.debug('ProductMixTotal Data: '+productMixdata1);
        }
        
        Ntotal = Nclasic + Nclearfield;
        PDclasic = (Nclasic/Ntotal)*100;
        PDclearfield = (Nclearfield/Ntotal)*100;
        Pclasic = PDclasic.setScale(2);
        Pclearfield = PDclearfield.setScale(2);
        
        
    }

        public ProductMix[] ProdMix{

            get{
                DataProductMix();
                ProdMix = new ProductMix[]{};
                
                if(ProductMixData.get('Clasic')!=null)
                  ProdMix.add(new ProductMix('Clasic OSR ('+Pclasic+'%)',ProductMixData.get('Clasic')[0], ProductMixData.get('Clasic')[1], ProductMixData.get('Clasic')[2], ProductMixData.get('Clasic')[3]));
                    else {
                        ProdMix.add(new ProductMix('Clasic OSR (0%)',0,0,0,0));
                    }                
                if(ProductMixData.get('Clearfield')!=null)
                  ProdMix.add(new ProductMix('Clearfield OSR ('+Pclearfield+'%)',ProductMixData.get('Clearfield')[0], ProductMixData.get('Clearfield')[1], ProductMixData.get('Clearfield')[2], ProductMixData.get('Clearfield')[3]));
                    else {
                        ProdMix.add(new ProductMix('Clearfield OSR (0%)',0,0,0,0));
                    }  
                if(ProductMixData.get('Total')!=null)
                  ProdMix.add(new ProductMix('Total OSR',ProductMixData.get('Total')[0], ProductMixData.get('Total')[1], ProductMixData.get('Total')[2], 0));
                    else {
                        ProdMix.add(new ProductMix('Total OSR',0,0,0,0));
                    } 
                return ProdMix;
                }
            set;
        }


    public class ProductMix{

        public String acc{ get; set; }
        public Decimal forecast{ get; set; }
        public Decimal agreed{get;set;}
        public Decimal pog{get;set;}
        public Decimal inventory{get;set;}

        public ProductMix(String name, Decimal forecast, Decimal agreed, Decimal pog, Decimal inventory) {

            this.acc= name;
            this.forecast= forecast;
            this.agreed = agreed;
            this.pog = pog;
            this.inventory = inventory;
        }
    }
    
    
    
        public String getUserProfile(){
        
            String profile = (UserInfo.getProfileId()).subString(0,15);
            system.debug('profile: '+profile);
            return profile;
        }
    }