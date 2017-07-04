@isTest
private class Test_TriggerTerritoryManagementContact {
    
    private static Account testDistributoroAccount = TestInit.createNewDistributor();
    private static Account testCompetitorAccount = TestInit.createNewCompetitor();
    private static Account testAccount =TestInit.createNewFarmer();
    
    @isTest
    static void init()
    {
    
        Country__c toCountry1= new Country__c(Name='Germany', TacticalPlanSetting__c='German', DE_EnableAccountSharing__c=true);
        insert toCountry1;
        
        Division__c toDivision= new Division__c(name='CP');
        insert toDivision;
        
        TerritoryManagement__c TM1 = new TerritoryManagement__c( Name='06682 - Teuchern Wildschütz - Burgenlandkreis' ,DE_CountryRef__c=toCountry1.ID, DE_StateProvince__c='Sachsen-Anhalt',DE_LandKreis__c='Burgenlandkreis - 59523000',DE_Landkreis2__c='Burgenlandkreis',
        DE_CP__c='06682', DE_PrimaryKey__c='06682 - Teuchern Wildschütz - Sachsen-Anhalt - Burgenlandkreis - 59523000 - Germany',DE_Ort__c='Teuchern Wildschütz');
        
        
        TerritoryManagement__c TM2 = new TerritoryManagement__c( Name='01552 - Großenhain - Meißen', DE_CountryRef__c=toCountry1.ID, DE_StateProvince__c='Sachsen',DE_LandKreis__c='Meißen - 19152500',DE_Landkreis2__c='Meißen',DE_CP__c='01552',
            DE_PrimaryKey__c='01552 - Großenhain - Sachsen - Meißen - 19152500 - Germany',DE_Ort__c='Großenhain');
         
              
        insert TM1;
        insert TM2;
        

        CountryAdapter.allCountryMap=null;

        // contact test
        
        Contact toContact= new Contact( LastName='Baelish', Status__c='Active', CountryRef__c=toCountry1.ID, DE_PrivateCountry__c=toCountry1.ID, DE_Private_Territory_Key__c=TM2.ID, DE_Territory_Key__c=TM1.ID );

        insert toContact;
        
        System.debug('Jonathan3 ' + toContact);
        
        Contact toContact2;
        
        toContact2=[
                    SELECT  DE_ZIP_PLZ__c, StateProvince__c , City__c ,DE_Landkreis__c, DE_PrivateZIP__c , DE_Private_State_Province__c ,DE_PrivateCity__c ,DE_Private_Landkreis__c
                    FROM Contact WHERE ID=:toContact.ID
                   ];
                               
    
        System.assertEquals(toContact2.DE_ZIP_PLZ__c,'06682');
        System.assertEquals(toContact2.StateProvince__c ,'Sachsen-Anhalt');
        System.assertEquals(toContact2.City__c ,'Teuchern Wildschütz');
        System.assertEquals(toContact2.DE_Landkreis__c,'Burgenlandkreis - 59523000');
        
        System.assertEquals(toContact2.DE_PrivateZIP__c ,'01552');
        System.assertEquals(toContact2.DE_Private_State_Province__c ,'Sachsen');
        System.assertEquals(toContact2.DE_Private_Landkreis__c,'Meißen - 19152500');
        System.assertEquals(toContact2.DE_PrivateCity__c ,'Großenhain');


   }     

  }