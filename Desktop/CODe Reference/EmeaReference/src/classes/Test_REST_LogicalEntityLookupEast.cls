@isTest 
public class Test_REST_LogicalEntityLookupEast{

/*
    public static testmethod void testOld(){
    Test_REST_DataFactoryEast.TestData();        
       
        System.Test.startTest();
        
        Datetime timecheck = System.now();
    	Country__c Cou2 = new Country__c(Name = 'HQ', TacticalPlanSetting__c = 'Standard');
        insert Cou2;
        User us = new User(Id = UserInfo.getUserId(), Country = 'HQ');
        update us;
        SystemSettings__c s1 = new SystemSettings__c( Name='RSA_MIN_VOLUME_DISCOUNT',Value__C='1');
        SystemSettings__c s2 = new SystemSettings__c( Name='RSA_STEPSIZE_VOLUME_DISCOUNT',Value__C='0.5');
        SystemSettings__c s3 = new SystemSettings__c( Name='RSA_MAX_VOLUME_DISCOUNT',Value__C='10');
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3};
        insert ssList;
        
        REST_Request req = new REST_Request();
        req.pageTimestamp = System.now();

        
        List<Year__c> ForDelYea= new List<Year__c>();
        List<Division__c> ForDelDiv= new List<Division__c>();
        List<Product_Grouping__c> ForDelPGr= new List<Product_Grouping__c>();
        List<Product_Grouping__c> ForDelPTy= new List<Product_Grouping__c>();
        List<Country__c> ForDelCou= new List<Country__c>();
        List<Discount__c> ForDelDis= new List<Discount__c>();
        
        Country__c Cou = new Country__c(Name = 'Romania', TacticalPlanSetting__c = 'Standard');
        insert Cou;
        ForDelCou.add(Cou);
        ForDelCou.add(Test_REST_DataFactoryEast.c);
        
        delete Cou;
             
        Year__c Yea= new Year__c (Name='YearTest', Current_Year__c=false, 
                                      YearEndDate__c=date.newinstance(2011, 12, 31), 
                                      YearStartDate__c=date.newinstance(2011, 1, 1)); 
        ForDelYea.add(Yea);
        insert ForDelYea;
        FordelYea.add(Test_REST_DataFactoryEast.Year);
            
        for(integer i=0;i<Test_REST_DataFactoryEast.RegPerEntity;i++){
            Product_Grouping__c PGr = new Product_Grouping__c (Name = 'PGRoup '+String.Valueof(i),
                                            RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductGroup'));      
            ForDelPGr.add(PGr);}
        insert FordelPGr;
            
        for(integer i=0;i<Test_REST_DataFactoryEast.RegPerEntity;i++){
            Product_Grouping__c PTy = new Product_Grouping__c (Name = 'PType '+String.Valueof(i),
                                      RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductType'));      
            ForDelPTy.add(PTy);}                                                  
        insert FordelPTy;
        
        for(integer i=0;i<Test_REST_DataFactoryEast.RegPerEntity;i++){
            Division__c Div= new Division__c(Name='Division '+String.Valueof(i)); 
            ForDelDiv.add(Div);}
        insert ForDelDiv;
            
        VoucherCampaign__c vcam = new VoucherCampaign__c (YearRef__c = Yea.id, StartDate__c = Yea.yearstartdate__c, 
                                                          MinProducts__c=1,EndDate__c= Yea.yearenddate__c,  
                                                          DivisionRef__c= Test_REST_DataFactoryEast.Divi.id, 
                                                          CountryRef__c= Test_REST_DataFactoryEast.c.id, 
                                                          BagSize__c=80,MinTotalBags__c=1);  
        insert vcam; 
        Discount__c Disco= new Discount__c (VoucherCampaignRef__c=vcam.id, DiscountInPrice__c=450, MaxBags__c=25, 
                                          MinBags__c=1, PercentIncreaseInBags__c=10); 
        insert Disco;
        ForDelDis.add(Disco);
        ForDelDis.add(Test_REST_DataFactoryEast.Disc);        
                          
        Util.currentCountry = Test_REST_DatafactoryEast.c;
        
        REST_LogicalEntityLookupEast_old.REST_LogicalEntity_Lookup_old params =REST_LogicalEntityLookupEast_old.getlookups(timecheck);
        System.debug('check '+params);
        System.Assert(params!=null);
        params.calculateTimestamp();
        
    }
    
     public static testmethod void testStandard(){
    Test_REST_DataFactoryEast.TestData();        
       
        System.Test.startTest();
        
        Datetime timecheck = System.now();
    	Country__c Cou2 = new Country__c(Name = 'HQ', TacticalPlanSetting__c = 'Standard');
        insert Cou2;
        User us = new User(Id = UserInfo.getUserId(), Country = 'HQ');
        update us;
        SystemSettings__c s1 = new SystemSettings__c( Name='RSA_MIN_VOLUME_DISCOUNT',Value__C='1');
        SystemSettings__c s2 = new SystemSettings__c( Name='RSA_STEPSIZE_VOLUME_DISCOUNT',Value__C='0.5');
        SystemSettings__c s3 = new SystemSettings__c( Name='RSA_MAX_VOLUME_DISCOUNT',Value__C='10');
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3};
        insert ssList;
        
        REST_Request req = new REST_Request();
        req.pageTimestamp = System.now();

        
        List<Year__c> ForDelYea= new List<Year__c>();
        List<Division__c> ForDelDiv= new List<Division__c>();
        List<Product_Grouping__c> ForDelPGr= new List<Product_Grouping__c>();
        List<Product_Grouping__c> ForDelPTy= new List<Product_Grouping__c>();
        List<Country__c> ForDelCou= new List<Country__c>();
        List<Discount__c> ForDelDis= new List<Discount__c>();
        
        Country__c Cou = new Country__c(Name = 'Romania', TacticalPlanSetting__c = 'Standard');
        insert Cou;
        ForDelCou.add(Cou);
        ForDelCou.add(Test_REST_DataFactoryEast.c);
        
        delete Cou;
             
        Year__c Yea= new Year__c (Name='YearTest', Current_Year__c=false, 
                                      YearEndDate__c=date.newinstance(2011, 12, 31), 
                                      YearStartDate__c=date.newinstance(2011, 1, 1)); 
        ForDelYea.add(Yea);
        insert ForDelYea;
        FordelYea.add(Test_REST_DataFactoryEast.Year);
            
        for(integer i=0;i<Test_REST_DataFactoryEast.RegPerEntity;i++){
            Product_Grouping__c PGr = new Product_Grouping__c (Name = 'PGRoup '+String.Valueof(i),
                                            RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductGroup'));      
            ForDelPGr.add(PGr);}
        insert FordelPGr;
            
        for(integer i=0;i<Test_REST_DataFactoryEast.RegPerEntity;i++){
            Product_Grouping__c PTy = new Product_Grouping__c (Name = 'PType '+String.Valueof(i),
                                      RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductType'));      
            ForDelPTy.add(PTy);}                                                  
        insert FordelPTy;
        
        for(integer i=0;i<Test_REST_DataFactoryEast.RegPerEntity;i++){
            Division__c Div= new Division__c(Name='Division '+String.Valueof(i)); 
            ForDelDiv.add(Div);}
        insert ForDelDiv;
            
        VoucherCampaign__c vcam = new VoucherCampaign__c (YearRef__c = Yea.id, StartDate__c = Yea.yearstartdate__c, 
                                                          MinProducts__c=1,EndDate__c= Yea.yearenddate__c,  
                                                          DivisionRef__c= Test_REST_DataFactoryEast.Divi.id, 
                                                          CountryRef__c= Test_REST_DataFactoryEast.c.id, 
                                                          BagSize__c=80,MinTotalBags__c=1);  
        insert vcam; 
        Discount__c Disco= new Discount__c (VoucherCampaignRef__c=vcam.id, DiscountInPrice__c=450, MaxBags__c=25, 
                                          MinBags__c=1, PercentIncreaseInBags__c=10); 
        insert Disco;
        ForDelDis.add(Disco);
        ForDelDis.add(Test_REST_DataFactoryEast.Disc);        
        
        REST_LogicalEntityLookupEast.REST_LogicalEntity_Lookup test1 = REST_LogicalEntityLookupEast.getLookups(req);  
    }
*/
     public static testmethod void testSM(){
    Test_REST_DataFactoryEast.TestData();        
       
        System.Test.startTest();
        
        Datetime timecheck = System.now();
    	Country__c Cou2 = new Country__c(Name = 'HQ', TacticalPlanSetting__c = 'Standard');
        insert Cou2;
        User us = new User(Id = UserInfo.getUserId(), Country = 'HQ');
        update us;
        SystemSettings__c s1 = new SystemSettings__c( Name='RSA_MIN_VOLUME_DISCOUNT',Value__C='1');
        SystemSettings__c s2 = new SystemSettings__c( Name='RSA_STEPSIZE_VOLUME_DISCOUNT',Value__C='0.5');
        SystemSettings__c s3 = new SystemSettings__c( Name='RSA_MAX_VOLUME_DISCOUNT',Value__C='10');
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3};
        insert ssList;
        
        REST_Request req = new REST_Request();
        req.pageTimestamp = System.now();

        
        List<Year__c> ForDelYea= new List<Year__c>();
        List<Division__c> ForDelDiv= new List<Division__c>();
        List<Product_Grouping__c> ForDelPGr= new List<Product_Grouping__c>();
        List<Product_Grouping__c> ForDelPTy= new List<Product_Grouping__c>();
        List<Country__c> ForDelCou= new List<Country__c>();
        List<Discount__c> ForDelDis= new List<Discount__c>();
        
        Country__c Cou = new Country__c(Name = 'Romania', TacticalPlanSetting__c = 'Standard');
        insert Cou;
        ForDelCou.add(Cou);
        ForDelCou.add(Test_REST_DataFactoryEast.c);
        
        delete Cou;
             
        Year__c Yea= new Year__c (Name='YearTest', Current_Year__c=false, 
                                      YearEndDate__c=date.newinstance(2011, 12, 31), 
                                      YearStartDate__c=date.newinstance(2011, 1, 1)); 
        ForDelYea.add(Yea);
        insert ForDelYea;
        FordelYea.add(Test_REST_DataFactoryEast.Year);
            
        for(integer i=0;i<Test_REST_DataFactoryEast.RegPerEntity;i++){
            Product_Grouping__c PGr = new Product_Grouping__c (Name = 'PGRoup '+String.Valueof(i),
                                            RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductGroup'));      
            ForDelPGr.add(PGr);}
        insert FordelPGr;
            
        for(integer i=0;i<Test_REST_DataFactoryEast.RegPerEntity;i++){
            Product_Grouping__c PTy = new Product_Grouping__c (Name = 'PType '+String.Valueof(i),
                                      RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductType'));      
            ForDelPTy.add(PTy);}                                                  
        insert FordelPTy;
        
        for(integer i=0;i<Test_REST_DataFactoryEast.RegPerEntity;i++){
            Division__c Div= new Division__c(Name='Division '+String.Valueof(i)); 
            ForDelDiv.add(Div);}
        insert ForDelDiv;
            
        VoucherCampaign__c vcam = new VoucherCampaign__c (YearRef__c = Yea.id, StartDate__c = Yea.yearstartdate__c, 
                                                          MinProducts__c=1,EndDate__c= Yea.yearenddate__c,  
                                                          DivisionRef__c= Test_REST_DataFactoryEast.Divi.id, 
                                                          CountryRef__c= Test_REST_DataFactoryEast.c.id, 
                                                          BagSize__c=80,MinTotalBags__c=1);  
        insert vcam; 
        Discount__c Disco= new Discount__c (VoucherCampaignRef__c=vcam.id, DiscountInPrice__c=450, MaxBags__c=25, 
                                          MinBags__c=1, PercentIncreaseInBags__c=10); 
        insert Disco;
        ForDelDis.add(Disco);
        ForDelDis.add(Test_REST_DataFactoryEast.Disc);        
        
        REST_LogicalEntityLookupEastSM.REST_LogicalEntity_Lookup test2 = REST_LogicalEntityLookupEastSM.getLookups(req);        
    }
}