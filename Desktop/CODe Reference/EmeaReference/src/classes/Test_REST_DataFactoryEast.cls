@isTest  
public class Test_REST_DataFactoryEast{
    
    public static Country__c c { get; set; }
    
    public static Year__c Year { get; set; }
    public static Year__c Last { get; set; }
    
    public static Division__c Divi { get; set; }
    public static Division__c DiviOSR { get; set; }
    
    public static TerritoryManagement__c TM { get; set; }
    
    public static Product_Grouping__c pgt { get; set; }                                       
    public static Product_Grouping__c pgg { get; set; } 
                                          
    public static Campaign ca { get; set; }
    public static Campaign caOSR { get; set; }
    public static Campaign cain { get; set; }
    
    public static Integer regPerEntity { get; set; }
   
    public static List<Account> aList { get; set; }  
    public static Account Farm { get; set; }
    public static Account Farmii { get; set; }
    public static Account Provider { get; set; }
    
    public static List<Contact> conList { get; set; }
    public static Contact Con { get; set; }
    
    public static List<Touchpoint_Program__c> tppList { get; set; }
    public static Touchpoint_Program__c TPP { get; set; }
  
    public static Product2 pr1 { get; set; }                                                    
    public static Product2 pr2 { get; set; }                                                    
    public static List<Product2> pList { get; set; }
  
    public static ProductCatalog__c prcat { get; set; }
    public static ProductCatalog__c trcat { get; set; }
    public static ProductCatalog__c procat { get; set; }
    public static ProductCatalog__c pastcat { get; set; }
    
    public static ProductCatalogEntry__c pce { get; set; }                                             
    public static ProductCatalogEntry__c pcepast { get; set; }                                             
    public static List<ProductCatalogEntry__c> pceList { get; set; } 
  
    public static CampaignLineItem__c cli { get; set; }
    public static List <CampaignLineItem__c> cList { get; set; }
    public static List <CampaignLineItem__c> tList { get; set; }
  
    public static CampaignLineItemGroup__c clig { get; set; }
    public static List <CampaignLineItemGroup__c> gList { get; set; }

    public static RecordType App { get; set; }    
    public static RecordType Appg { get; set; }
    public static Acreage__c acr { get; set; }
    public static List <Acreage__c> acrList { get; set; }

    public static VoucherCampaign__c vca { get; set; }
    public static VoucherCampaign__c vcaOSR { get; set; }
    
    public static Voucher__c vou { get; set; }
    public static List <Voucher__c> vList { get; set; }
    
    public static VoucherLineItem__c vli { get; set; }
    public static List <VoucherLineItem__c> vlList { get; set; }

    public static Order__c ord { get; set; }
    public static List<Order__c> poList { get; set; }
    public static List<Order__c> foList { get; set; }
    
    public static Discount__c Disc { get; set; }
    
    public static Budget__c Bud { get; set; }
    
    public static Stock__c Sto { get; set; }

    public static void TestData(){
        
        SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        
       
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7};
        insert ssList;
        
        regPerEntity=20;
        
        c = new Country__c(Name ='HQ', TacticalPlanSetting__c = 'Standard');      
            insert c;
            
        Last = new Year__c (Name='2012', Current_Year__c=false, YearEndDate__c=date.newinstance(2012, 12, 31), 
            YearStartDate__c=date.newinstance(2012, 1, 1)); 
            
        insert Last;
            
        Year= new Year__c (Name='2013', Current_Year__c=true, YearEndDate__c=date.newinstance(2014, 12, 31), 
            YearStartDate__c=date.newinstance(2013, 1, 1), YearPreviousYear__c=Last.id,CurrentYear_RSA__c=true); 
            
        insert Year;
            
        TM= new TerritoryManagement__c (Name='111', DE_CountryRef__c=c.id, DE_CP__c='09000',DE_Landkreis__c='City',DE_StateProvince__c='Province',DE_Landkreis2__c='County',DE_Ort__c='123'); 
        insert TM;
            
        Divi= new Division__c(Name='Corn',Standard__c=true);
        DiviOSR= new Division__c(Name='OSR',Standard__c=true);
        insert new List<Division__c>{Divi, DiviOSR};
            
        pgt = new Product_Grouping__c(name = 'CornSilage', RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductType'));
        pgg = new Product_Grouping__c(name = 'Corn', RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductGroup'));
        insert new List<Product_Grouping__c>{pgg,pgt};
            
        Farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                           Category__c='Farm');
        Farmii= new Account (CountryRef__c=c.ID, Name='FarmiiTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                           Category__c='Farm');
        Provider= new Account(CountryRef__c=c.ID, Name='Monsanto Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                           Category__c='Distributor', GC_VATIN_Number__c='5' );
        List<Account> account2insert=  new List<Account> { Farm, Farmii, Provider};
        aList = new List<Account>();
        for(Integer i=0;i<regPerEntity;i++)
        {
            String AccountName='Account Test '+String.valueof(i);
            Account Acc = new Account(CountryRef__c=c.Id, Name=AccountName, Category__c='Farm', IdDevice__c=(800+i), 
                                      RecordTypeId=Util.recordType.get('Account:GroupFarmSite')); 
            aList.add(Acc);
        }
        account2insert.addAll(aList);        
        insert account2insert;
            
        ConList = new List<Contact>();
            for(integer i=0;i<regPerEntity;i++){
                con= new Contact(LastName='Van '+String.ValueOf(i),CountryRef__c=c.id, idDevice__c='900', 
                                 AccountId=aList.get(i).id);
                conList.add(con);
            }
            insert conList;
        
        TPPList = new List<Touchpoint_Program__c>();
            for(integer i=0;i<regPerEntity;i++){
            tpp = new Touchpoint_Program__c(LKP_ACCOUNT__c= aList.get(i).id, LKP_YEAR__c=year.Id,LKP_CROP__c=divi.id,CHK_AGREED__c=true,CHK_PLAN__c=true,DAT_PLAN__c=system.today());
                TPPList.add(tpp);
            }
            insert TPPList;
        
        //App = Util.recordType.get('Acreage__c:AcreagesPerProduct');
        //Appg = Util.recordType.get('Acreage__c:AcreagesPerProductGroup');

        //App = [SELECT Id, Name FROM RecordType WHERE Id =: Util.recordTypeId.get('Acreage__c:AcreagesPerProduct')];
        //Appg = [SELECT Id, Name FROM RecordType WHERE Id =: Util.recordTypeId.get('Acreage__c:AcreagesPerProductGroup')];

        for( RecordType r : [SELECT Name, SobjectType, Id FROM RecordType  WHERE SobjectType = 'Acreage__c'])
        {
            if (r.Name == 'Acreages per Product') App = r;
            else if (r.Name == 'Acreages per Product Group') Appg = r;
        }

        prcat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=Util.recordType.get('ProductCatalog__c:SalesProductCatalog'));
        pastcat = new ProductCatalog__c(name = 'Product Catalog Past',countryRef__c=c.id,RecordTypeId=Util.recordType.get('ProductCatalog__c:SalesProductCatalog'));
        trcat = new ProductCatalog__c(name = 'Product Trial Catalog',countryRef__c=c.id,RecordTypeId=Util.recordType.get('ProductCatalog__c:TrialsProductCatalog'));
        procat = new ProductCatalog__c(name = 'Catalog ii',countryRef__c=c.id);
           
        insert new List<ProductCatalog__c> { prcat, pastcat, trcat, procat} ;
            
        ca = new Campaign(name = 'Test Campaign Acti', YearV2__c=Year.id, CountryRef__c=c.id, OwnerId=Util.CurrentUser.id,
                          EndDate=Date.newinstance(2018,11,11), statuscode__c=200, recordtypeId=Util.recordType.get('Campaign:Sales_camp'),
                          SalesPCMRef__c=prcat.id,StartDate=Date.newinstance(2013,02,02), DivisionRef__c = Divi.id, CompetitorPCMRef__c=procat.id,
                          TrialPCMRef__c=trcat.id);
        caOSR = new Campaign(name = 'Test Campaign Acti', YearV2__c=Year.id, CountryRef__c=c.id, OwnerId=Util.CurrentUser.id,
                          EndDate=Date.newinstance(2018,11,11), statuscode__c=200, recordtypeId=Util.recordType.get('Campaign:Sales_camp'),
                          SalesPCMRef__c=prcat.id,StartDate=Date.newinstance(2013,02,02), DivisionRef__c = DiviOSR.id, CompetitorPCMRef__c=procat.id,
                          TrialPCMRef__c=trcat.id);
        cain = new Campaign(name = 'Test Campaign Acti', YearV2__c=Last.id, CountryRef__c=c.id, OwnerId=Util.CurrentUser.id,
                          EndDate=Date.newinstance(2012,12,12), statuscode__c=300, SalesPCMRef__c=pastcat.id, recordtypeId=Util.recordType.get('Campaign:Sales_camp'),
                          StartDate=Date.newinstance(2012,01,01), DivisionRef__c = Divi.id, CompetitorPCMRef__c=pastcat.id,
                          TrialPCMRef__c=pastcat.id, TaxSalesPCMRef_RSA__c=pastcat.id);                 
       
        insert new List<Campaign>{ca,cain,caOSR};


        pr1 = new Product2(Name='Monsanto Product',ProductSAPCode__c = '12123213',DivisionRef__c=Divi.id);
        pr2 = new Product2(name='Competitor Product',ProductSAPCode__c = '12444444',DivisionRef__c=Divi.id);
        
        List<Product2> prod2insert= new List<Product2> { pr1,pr2}; 
    
        pList= new List<Product2>();
            for(Integer i=0;i<regPerEntity;i++){
               Product2 prod=new Product2(Name='ProductNumber '+String.ValueOf(i),ProductSAPCode__c=String.ValueOf(83741+i),
                    DivisionRef__c=Divi.id);
                pList.add(prod);}
        prod2insert.addAll(pList);
        
        insert prod2insert;   
        
        pcepast = new ProductCatalogEntry__c (ProductCatalogRef__c=pastcat.id, NewProduct__c=true, Price__c=500, productRef__c=pr2.id, 
                                              Ownerid=Util.CurrentUser.id); 
                                                  
        pce = new ProductCatalogEntry__c (ProductCatalogRef__c=procat.id, NewProduct__c=true, Price__c=500, productRef__c=pr1.id, 
                                          Ownerid=Util.CurrentUser.id);
        
        List<ProductCatalogEntry__c> pce2insert= new List<ProductCatalogEntry__c> { pce,pcepast}; 
                
        pceList = new List<ProductCatalogEntry__c>();
        for(Product2 prodx : pList){
            ProductCatalogEntry__c procaten = new ProductCatalogEntry__c(ProductCatalogRef__c=prcat.id, NewProduct__c=true,
                                                                             Price__c=500, productRef__c=prodx.id);
            pceList.add(procaten);
        }
        pce2insert.addAll(pceList);
        insert pce2insert;
            
        poList = new List<Order__c>();
            for (integer i=0;i<regPerEntity;i++){
                 ord = new Order__c( AccountRef_RSA__c=Farm.id, Status_RSA__c='Closed',
                                     RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), shouldCopy_RSA__c=false);     
                 poList.add(ord);}
        //insert poList;    
            
        foList = new List<Order__c>();
            for (integer i=0;i<regPerEntity;i++){
                ord = new Order__c( AccountRef_RSA__c=Farm.id, RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), 
                                    PreliminaryOrderRef_RSA__c=poList.get(i).id, Status_RSA__c='Closed', shouldCopy_RSA__c=false); 
                foList.add(ord);} 
        //insert foList;
        List<Order__c> ordersToInsert = new List<Order__c>();
        ordersToInsert.addAll(poList);
        ordersToInsert.addAll(foList);
        insert ordersToInsert;

                                               
        gList = new list<CampaignLineItemGroup__c>();
            for(Integer i=0; i<regPerEntity; i++){
               clig=new CampaignLineItemGroup__c( AccountRef__c=Provider.id, CampaignRef__c=ca.id, HarvestedBy__c='TD',
                                                  Comments__c='Test Trial Update'+String.valueof(i), OwnerId=Util.currentUser.ID, 
                                                  Latitude__c='100', Longitude__c='100', Status__c='ongoing', idDevice__c=100+i, 
                                                  RecordTypeId=Util.recordType.get('CampaignLineItemGroup__c:Trial'), 
                                                  Type__c='Demo'); 
               gList.add(clig);}
            insert gList;
        
        tList= new List<CampaignLineItem__c>();
            for(Integer i=0; i<regPerEntity; i++){
                cli=new CampaignLineItem__c( CampaignLineItemGroupRef__c=gList.get(i).id, CampaignRef__c=ca.id, 
                                             OwnerId=Util.currentUser.ID,DistributorRef__c=Provider.id, 
                                             FarmRef__c=aList.get(i).id, ProductRef__c=pList.get(i).id, 
                                             Yield__c=400+i, ProductCatalogEntryRef__c=pceList.get(i).id, 
                                             RecordTypeId=Util.recordType.get('CampaignLineItem__c:Trial')); 
                tList.add(cli);}

        cList= new List<CampaignLineItem__c>();
            for(Integer i=0; i<regPerEntity; i++){
                cli=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                             DistributorRef__c=Provider.id, Forecast__c=500+i, Agreed__c=600+i,
                                             PoG__c=700+i, ProductCatalogEntryRef__c= pceList.get(i).id,
                                             Ownerid=Util.currentUser.ID, FarmRef__c= Farm.id, CampaignRef__c= cain.id,
                                             PreliminaryOrderRef_RSA__c=poList.get(i).id, FinalOrderRef_RSA__c=foList.get(i).id,
                                             Type__c= 'Charged', PlantingDensity__c= '30000', ProductRef__c= pList.get(i).id);
                cList.add(cli);}
        
        List<CampaignLineItem__c> clisToInsert = new List<CampaignLineItem__c>();
        clisToInsert.addAll(tList);
        clisToInsert.addAll(cList);
        insert clisToInsert;

        acrList = new List<Acreage__c>();      
            for(Integer i=0; i<regPerEntity; i++){ 
                acr=new Acreage__c( AcrFarmRef__c=aList.get(i).id, AcrProviderRef__c=Provider.id, AcrTotalAcreages__c=100,
                                    Land_fallow__c=false, Dry_Land__c=false, Irrigation__c=false, AcrSecondHarvest__c=false,
                                    RecordTypeId=Util.recordType.get('Acreage__c:AcreagesPerProduct'), idDevice__c=100+i,
                                    AcrYearRef__c=Year.ID, AcrProductGroupRef__c=pgg.id, AcrProductTypeRef__c=pgt.id);
                acrList.add(acr);}
            insert acrList;                                

        vcaOSR = new VoucherCampaign__c (Name='VoucherCampaign',YearRef__c = Year.id, StartDate__c = Date.newinstance(2013,02,02), EndDate__c= Date.newinstance(2018,11,11), 
                                      CountryRef__c= c.id, BagSize__c=80, DivisionRef__c= DiviOSR.id, MinProducts__c=1, Currency__c='EUR',
                                      MinTotalBags__c=1, isTechnology__c=true, Discount_Type__c='In Bags',Template__c='VouchersGenerators',isDataPrivacy__c=true, isTermsAndConditions__c=true);
        
        vca = new VoucherCampaign__c (Name='VoucherCampaign',YearRef__c = Year.id, StartDate__c = Date.newinstance(2013,02,02), EndDate__c= Date.newinstance(2018,11,11), 
                                      CountryRef__c= c.id, BagSize__c=80, DivisionRef__c= Divi.id, MinProducts__c=1, Currency__c='EUR',
                                      MinTotalBags__c=1, isTechnology__c=true, Discount_Type__c='In Bags',Template__c='VouchersGenerators',isDataPrivacy__c=true, isTermsAndConditions__c=true);
        
        insert new List<VoucherCampaign__c> {vcaOSR, vca}; 

        Disc = new Discount__c(MaxBags__c=59, MinBags__c=10,Ownerid=Util.currentUser.ID,VoucherCampaignRef__c=vca.id,
                               PercentIncreaseInBags__c=5, DiscountInPrice__c=125);
        insert Disc;
             
        Hybrid__c Hyb=new Hybrid__c(UserRef__c=util.currentuser.id,ProductCatalogRef__c=procat.id, Name='DKC123');
        insert Hyb;
        
        Sto= new Stock__c( Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000,HybridRef__c=Hyb.id,
                           ProductCatalogEntryRef_RSA__c = pce.id, User_RSA__c=Util.CurrentUser.id );
        insert Sto;

        Bud= new Budget__c ( ProductRef__c=pr1.id, YearRef__c=Year.id, SalesRep__c=Util.currentUser.id, BudgetApril__c=100, 
                             BudgetJune__c=100, BudgetAugust__c=100, BudgetDecember__c=100, BudgetFebruary__c=100, 
                             BudgetJanuary__c=100, BudgetJuly__c=100,BudgetMarch__c=100, BudgetMay__c=100, BudgetNovember__c=100, 
                             BudgetOctober__c=100, BudgetSeptember__c=100);
        insert Bud; 
        
    }

}