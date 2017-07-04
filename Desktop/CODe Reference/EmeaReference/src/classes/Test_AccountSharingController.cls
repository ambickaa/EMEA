@isTest
private class Test_AccountSharingController {
    
    private static Account testDistributoroAccount = TestInit.createNewDistributor();
    private static Account testCompetitorAccount = TestInit.createNewCompetitor();
    private static Account testAccount =TestInit.createNewFarmer();
    
    @isTest
    static void Test1()
    {
        Country__c toCountry= new Country__c(Name='Germany', TacticalPlanSetting__c='German', DE_EnableAccountSharing__c=true);
        insert toCountry;
                Division__c toDivision= new Division__c();
        insert toDivision;
        
        TerritoryManagement__c TM1 = new TerritoryManagement__c( DE_CountryRef__c=toCountry.ID, DE_StateProvince__c='Sachsen-Anhalt',DE_LandKreis__c='Burgenlandkreis - 59523000',DE_Landkreis2__c='Burgenlandkreis',
        DE_CP__c='06682', DE_PrimaryKey__c='06682 - Teuchern Wildschütz - Sachsen-Anhalt - Burgenlandkreis - 59523000 - Germany',DE_Ort__c='Teuchern Wildschütz');
        TerritoryManagement__c TM2 = new TerritoryManagement__c( DE_CountryRef__c=toCountry.ID, DE_StateProvince__c='Sachsen',DE_LandKreis__c='Meißen - 19152500',DE_Landkreis2__c='Meißen',DE_CP__c='01552',
            DE_PrimaryKey__c='01552 - Großenhain - Sachsen - Meißen - 19152500 - Germany',DE_Ort__c='Großenhain');

        insert new List<TerritoryManagement__c>{TM1,TM2};
        
        
        User UserTest=new User( Alias='JSEO123', Email='jseoanem@everis.com',Username='testASCjseoanem@everis.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId='00eD00000012jpuIAA', LanguageLocaleKey='de', 
        Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );
        User UserTest2=new User( Alias='JMON123', Email='jseoanebcn@gmail.com',Username='testASCjseoanebcn@gmail.com', LastName='Montero', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId='00eD00000012jpuIAA', LanguageLocaleKey='de',
        Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );

        insert new List<User>{UserTest,UserTest2};
        
        TerritoryManagementUser__c TML1= new TerritoryManagementUser__c(DE_TerritoryManagementRef__c=TM1.ID,
            DivisionRef__c=toDivision.ID, DE_UserRef__c=UserTest.ID);
        TerritoryManagementUser__c TML2= new TerritoryManagementUser__c(DE_TerritoryManagementRef__c=TM2.ID,
            DivisionRef__c=toDivision.ID, DE_UserRef__c=UserTest2.ID);

        insert new List<TerritoryManagementUser__c>{TML1, TML2};
        
        CountryAdapter.allCountryMap=null;

        Account toAccount= new Account(CountryRef__c=toCountry.ID, Name='DETestDist',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),Category__c='Distributor', DE_Territory_Key__c=TM1.ID);
        insert  toAccount; 
        
        test.startTest();

        ApexPages.currentPage().getParameters().put('id', toAccount.ID); 
        
        AccountSharingController controller = new AccountSharingController();
        if(controller.possibleUsers != null && controller.possibleUsers.size() > 0 ){
            controller.possibleUsers.get(0).selected = true;
        }

        toAccount.DE_Territory_Key__c=TM2.ID;
        update toAccount;    

        controller.add();
        controller.save();
        test.stopTest();

    }    
    @isTest
    static void Test2()
    {
        Country__c toCountry= new Country__c(Name='Germany', TacticalPlanSetting__c='German', DE_EnableAccountSharing__c=true);
        insert toCountry;
                Division__c toDivision= new Division__c();
        insert toDivision;
        
        TerritoryManagement__c TM1 = new TerritoryManagement__c( DE_CountryRef__c=toCountry.ID, DE_StateProvince__c='Sachsen-Anhalt',DE_LandKreis__c='Burgenlandkreis - 59523000',DE_Landkreis2__c='Burgenlandkreis',
        DE_CP__c='06682', DE_PrimaryKey__c='06682 - Teuchern Wildschütz - Sachsen-Anhalt - Burgenlandkreis - 59523000 - Germany',DE_Ort__c='Teuchern Wildschütz');
        TerritoryManagement__c TM2 = new TerritoryManagement__c( DE_CountryRef__c=toCountry.ID, DE_StateProvince__c='Sachsen',DE_LandKreis__c='Meißen - 19152500',DE_Landkreis2__c='Meißen',DE_CP__c='01552',
            DE_PrimaryKey__c='01552 - Großenhain - Sachsen - Meißen - 19152500 - Germany',DE_Ort__c='Großenhain');

        insert new List<TerritoryManagement__c>{TM1,TM2};
        
        User UserTest=new User( Alias='JSEO123', Email='jseoanem@everis.com',Username='testASCjseoanem@everis.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId='00eD00000012jpuIAA', LanguageLocaleKey='de', 
        Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );
        User UserTest2=new User( Alias='JMON123', Email='jseoanebcn@gmail.com',Username='testASCjseoanebcn@gmail.com', LastName='Montero', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId='00eD00000012jpuIAA', LanguageLocaleKey='de',
        Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );

        insert new List<User>{UserTest,UserTest2};
        
        TerritoryManagementUser__c TML1= new TerritoryManagementUser__c(DE_TerritoryManagementRef__c=TM1.ID,
            DivisionRef__c=toDivision.ID, DE_UserRef__c=UserTest.ID);
        TerritoryManagementUser__c TML2= new TerritoryManagementUser__c(DE_TerritoryManagementRef__c=TM2.ID,
            DivisionRef__c=toDivision.ID, DE_UserRef__c=UserTest2.ID);

        insert new List<TerritoryManagementUser__c>{TML1, TML2};
        
        CountryAdapter.allCountryMap=null;

        test.startTest();

        Account toAccount= new Account(CountryRef__c=toCountry.ID, Name='DETestDist',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),Category__c='Distributor', DE_Territory_Key__c=TM1.ID);
        insert  toAccount;         

        ApexPages.currentPage().getParameters().put('id', toAccount.ID);
        
        AccountSharingController controller = new AccountSharingController();
        if(controller.possibleUsers != null && controller.possibleUsers.size()>0){
            controller.possibleUsers.get(0).selected = true;
        }

        toAccount.OwnerId=UserTest2.ID;
        update toAccount;

        controller.add();
        controller.save();
        test.stopTest();

    }    
}