@isTest
public class Test_REST_DelLogicalEntityLookupEast{
	
    public static testmethod void DelTest(){
    
        Test_REST_DataFactoryEast.TestData();
        
        Test.startTest();
        
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
      
        //REST_DelLogicalEntityLookupEast.REST_DelLogicalEntity_Lookup params = new REST_DelLogicalEntityLookupEast.REST_DelLogicalEntity_Lookup();
        REST_DelLogicalEntityLookupEastSM.REST_DelLogicalEntity_Lookup paramsSM = new REST_DelLogicalEntityLookupEastSM.REST_DelLogicalEntity_Lookup();
        /*
        params.years=ForDelYea;
        params.countries=ForDelCou;
        params.divisions=ForDelDiv;
        params.productgroups=ForDelPGr;
        params.producttypes=ForDelPTy;
        params.discounts=ForDelDis;
        */
        paramsSM.years=ForDelYea;
        paramsSM.countries=ForDelCou;
        paramsSM.divisions=ForDelDiv;
        paramsSM.productgroups=ForDelPGr;
        paramsSM.producttypes=ForDelPTy;
        paramsSM.discounts=ForDelDis;
             
        //REST_DelLogicalEntityLookupEast.REST_DelLogicalEntity_Lookup returned = REST_DelLogicalEntityLookupEast.getDeletedAccounts(params);
        REST_DelLogicalEntityLookupEastSM.REST_DelLogicalEntity_Lookup returnedSM = REST_DelLogicalEntityLookupEastSM.getDeletedAccounts(paramsSM);

		//System.debug('TEST EAST'+returned.countries.get(0) );
		System.debug('TEST EAST'+cou.ID );
		/*
        System.AssertEquals(returned.countries.get(0).ID,cou.ID);
        System.AssertEquals(returned.years.Size(),0);
        System.AssertEquals(returned.divisions.Size(),0);
        System.AssertEquals(returned.productgroups.Size(),0);
        System.AssertEquals(returned.producttypes.Size(),0);
        System.AssertEquals(returned.discounts.Size(),2);
        */
        System.AssertEquals(returnedSM.countries.get(0).ID,cou.ID);
        System.AssertEquals(returnedSM.years.Size(),0);
        System.AssertEquals(returnedSM.divisions.Size(),ForDelDiv.size());
        System.AssertEquals(returnedSM.productgroups.Size(),0);
        System.AssertEquals(returnedSM.producttypes.Size(),0);
        //System.AssertEquals(returnedSM.discounts.Size(),2);
		Test.stopTest();
		
     }
    public static testmethod void ExTest(){
          
        Test_REST_DataFactoryEast.TestData();

		Test.startTest();
        //REST_DelLogicalEntityLookupEast.REST_DelLogicalEntity_Lookup params = new REST_DelLogicalEntityLookupEast.REST_DelLogicalEntity_Lookup();
        REST_DelLogicalEntityLookupEastSM.REST_DelLogicalEntity_Lookup paramsSM = new REST_DelLogicalEntityLookupEastSM.REST_DelLogicalEntity_Lookup();
        //params = REST_DelLogicalEntityLookupEast.getExample();
        paramsSM = REST_DelLogicalEntityLookupEastSM.getExample(); 
        
        /*
        System.Assert(params.countries.Size()==1);
        System.Assert(params.divisions.Size()==1);
        System.Assert(params.productgroups.Size()==1);
        System.Assert(params.producttypes.Size()==1);
        System.Assert(params.years.Size()==1);
        System.Assert(params.discounts.Size()==1);
        */
        System.Assert(paramsSM.countries.Size()==1);
        System.Assert(paramsSM.divisions.Size()==1);
        System.Assert(paramsSM.productgroups.Size()==1);
        System.Assert(paramsSM.producttypes.Size()==1);
        System.Assert(paramsSM.years.Size()==1);
        System.Assert(paramsSM.discounts.Size()==1);
        Test.stopTest();

     }
}