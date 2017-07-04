@isTest
public class Test_AccountRetoureMgmtListController {
    private static User user1;
    public static testmethod void Test1(){
        Country__c Country= new Country__c(Name='Germany', TacticalPlanSetting__c='German', DE_EnableAccountSharing__c=true);   
        insert Country;
        Division__c Division= new Division__c();
        insert Division;
        Profile p = [SELECT Id FROM Profile WHERE Name='DE_Sales Representative S&T'];
        user1 = new User (Username=' user1@test.fullbox.com', FirstName = 'user1',LastName='user1',Email='user1@monsanto.com.fullbox', Alias='USR1',Country='Germany',CountryISOCode__c='DE', CommunityNickname='test1',TimeZoneSidKey = 'America/New_York',LocaleSidKey = 'en_US', ProfileId = p.Id, EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US');
        insert user1;
        Account Account= new Account(OwnerId = user1.id, DE_ID_STATUS__c = 'Sonstige',DE_Owners__c = 'BURZLAFF', 
                                     CountryRef__c=Country.ID,PrimaryDistributor__c = null,
                                     ImportId__c = null, PrimaryPoS__c = null,
                                     Name='DETestAccount',GC_VATIN_Number__c =  null, Street__c = 'street test', ZIPPostalCode__c = '12345',
                                     City__c = 'Berlin', GC_Mobile_Phone__c = '123456789', RecordTypeId=Util.recordType.get('Account:DistRetPoS'),Phone = '124356753',
                                     Category__c = 'Farm', IsCreateCampaignLineItem__c = true);
        insert Account;
        ApexPages.currentPage().getParameters().put('id', Account.ID) ;
        ApexPages.currentPage().getParameters().put('Division', Division.ID) ;   
        retoure__c Retoure= new retoure__c(Account__C=Account.id, Division__c = Division.id, EximusRabat__c = 4, Extrarabatt__c = 4, 
                                           FruekaufMenge__c = 2, FruekaufRabatt__c = 2, 
                                           Retoure1__c = 0, Retoure2__c = 0, Retoure3__c = 0, RabattMenge__c = 4, NUM_MENGE_TAX__c = 0,
                                           TXT_Bemerkung__c = 'test4',TXT_year__c='2016', NUM_ExceptionRabatt__c=5, 
                                           Clemente_Rabatt__c = 0, NUM_ExpansionRabatt__c=5);
        insert Retoure;
        Year__c year1 = new Year__c(Name='2016',Current_Year__c=true,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2015,1,1));
        insert year1;
        
        ApexPages.currentPage().getParameters().put('Year', year1.ID) ; 
        
        // test starts //
        Test.startTest();
        AccountListVirtualController alvc = new AccountListVirtualController();
        AccountRetoureManagementListController arml = new AccountRetoureManagementListController();
        User user3 = arml.infoUser;
        Division__c div3 = arml.currentDivision;
        arml.getIsGermanView();
        // we finish our test //
        Test.stopTest();
    }
    
    public static testmethod void Test2(){
        Country__c Country= new Country__c(Name='Germany', TacticalPlanSetting__c='German', DE_EnableAccountSharing__c=true);   
        insert Country;
        Division__c Division= new Division__c();
        insert Division;
        Profile p = [SELECT Id FROM Profile WHERE Name='DE_Sales Representative S&T'];
        user1 = new User (Username=' user1@test.fullbox.com', FirstName = 'user1',LastName='user1',Email='user1@monsanto.com.fullbox', Alias='USR1',Country='Germany',CountryISOCode__c='DE', CommunityNickname='test1',TimeZoneSidKey = 'America/New_York',LocaleSidKey = 'en_US', ProfileId = p.Id, EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US');
        insert user1;
        
        Account Account2= new Account(OwnerId = user1.id, DE_ID_STATUS__c = 'Sonstige',DE_Owners__c = 'BURZLAFF', 
                                     CountryRef__c=Country.ID,PrimaryDistributor__c = null,
                                     ImportId__c = null, PrimaryPoS__c = null,
                                     Name='DETestAccount',GC_VATIN_Number__c =  null, Street__c = 'street test', ZIPPostalCode__c = '12345',
                                     City__c = 'Berlin', GC_Mobile_Phone__c = '1235646789', RecordTypeId=Util.recordType.get('Account:DistRetPoS'),Phone = '1243564543',
                                     Category__c = 'Farm', IsCreateCampaignLineItem__c = true);
        insert Account2;
        Year__c year2 = new Year__c(Name='2016',Current_Year__c=true,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2015,1,1));
        insert year2;
        ApexPages.currentPage().getParameters().put('id', Account2.ID) ;
        ApexPages.currentPage().getParameters().put('Division', Division.ID) ;  
        ApexPages.currentPage().getParameters().put('Year', year2.ID) ; 
        
        // test starts //
        Test.startTest();
        AccountListVirtualController alvc2 = new AccountListVirtualController();
        AccountRetoureManagementListController arml2 = new AccountRetoureManagementListController();

        // we finish our test //
        Test.stopTest();
    }
}