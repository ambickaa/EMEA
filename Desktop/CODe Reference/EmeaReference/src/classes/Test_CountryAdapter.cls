/*
  @description test choose country by currentUser and AccountId from URL.
  @copyright PARX
*/
@isTest
private class Test_CountryAdapter
{
  private static Country__c testItalyCountry;
  private static Country__c testGermanyCountry;
  private static Account testAccount = TestInit.createNewFarmer();
  
  private static void init()
  {
    Map<String, Object> aCountryParams = new Map<String, String>
    {
      'Name' => 'Germany',
      'TacticalPlanSetting__c' => 'Standard'
    };
    testGermanyCountry = (Country__c)SmartFactory.createSobject('Country__c', aCountryParams);
    insert testGermanyCountry;
    
    aCountryParams.put('Name', 'Italy');
    aCountryParams.put('TacticalPlanSetting__c', 'Italian');
    aCountryParams.put('Area__c', testGermanyCountry.Id);
    testItalyCountry = (Country__c)SmartFactory.createSobject('Country__c', aCountryParams);
    insert testItalyCountry;
    CountryAdapter.allCountryMap = null;
    testAccount.CountryRef__c = testItalyCountry.Id;
    insert testAccount;

    PageReference aPage = ApexPages.currentPage();
    aPage.getParameters().put('id', testAccount.Id);
    Test.setCurrentPageReference(aPage);

    
  }
  
  /*
    @description test choose country by currentUser and AccountId from URL.
  */
  private static testMethod void testChooseCountry()
  {
    init();
    
    Test.startTest();
    
    //Choose country by Area__c lookup.
    CountryAdapter anAdapter = new CountryAdapter();
    System.assertEquals(testGermanyCountry.Id, anAdapter.country.Id, 'Country should be Area__c lookup.');
    System.assert(!anAdapter.isItalianTacticalPlan, 'Tactical plan should be Germany');
    System.assertEquals(CountryAdapter.CountryEnum.germany, anAdapter.countryCode, 'Tactical plan should be Germany');
    
    //
    /*
    User anUser = [SELECT CountryISOCode__c FROM User WHERE Id = :UserInfo.getUserId()];
    anUser.CountryISOCode__c = 'DE';
    update anUser;
    
    //Choose country by User CountryISOCode__c.
    anAdapter = new CountryAdapter(anUser);
    System.assertEquals(testCountries[1].Id, anAdapter.country.Id, 'Country should be Germany.');
    System.assert(!anAdapter.isItalianTacticalPlan, 'Tactical plan should be Germany');
    System.assertEquals(CountryAdapter.CountryEnum.germany, anAdapter.countryCode, 'Tactical plan should be Germany');*/
    Test.stopTest();
  }
  private static testMethod void testFranceCountry(){
    Map<String, Object> aCountryParams = new Map<String, String>
    {
      'Name' => 'France',
      'TacticalPlanSetting__c' => 'French'
    };
    Country__c testFranceCountry = (Country__c)SmartFactory.createSobject('Country__c', aCountryParams);
    testFranceCountry.DE_EnableAccountSharing__c = true;
    testFranceCountry.AcreageSetting__c = 'French';
    testFranceCountry.TrialSetting__c = 'Standard';
    testFranceCountry.TacticalPlanSetting__c = 'French';
    
    insert testFranceCountry;
    CountryAdapter.allCountryMap = null;
    User usr = [SELECT CountryISOCode__c FROM User WHERE Id = :UserInfo.getUserId()];
    usr.CountryISOCode__c = 'FR1';
    update usr;
    
    Test.startTest();
    CountryAdapter ca = new CountryAdapter(testFranceCountry.Id);
    boolean ase = ca.isAccountSharingEnabled;
    ase = ca.isFrenchAcreages;
    ase = ca.isFRTacticalPlan;
    ase = ca.isGenericTacticalPlan;
    ase = ca.isRSATacticalPlan;
    ase = ca.isStandardTrial;

    List<Selectoption> vouch = ca.getVoucherTemplates();

    ase = ca.isAccountNameDuplicateBlockerEnabled();
    
    CountryAdapter ca2 = new CountryAdapter(usr);
    Test.stopTest();
  }

  private static testMethod void testGermanCountry(){
    Map<String, Object> aCountryParams = new Map<String, String>
    {
      'Name' => 'Germany',
      'TacticalPlanSetting__c' => 'German'
    };
    Country__c testGermany1Country = (Country__c)SmartFactory.createSobject('Country__c', aCountryParams);
    
    testGermany1Country.DE_EnableAccountSharing__c = true;
    testGermany1Country.AcreageSetting__c = 'Generic';
    testGermany1Country.TrialSetting__c = 'Standard';
    testGermany1Country.TacticalPlanSetting__c = 'German';
    
    insert testGermany1Country;
    CountryAdapter.allCountryMap = null;
    User usr = [SELECT CountryISOCode__c FROM User WHERE Id = :UserInfo.getUserId()];
    usr.CountryISOCode__c = 'DE1';

    update usr;
    
    Test.startTest();
    CountryAdapter ca = new CountryAdapter(testGermany1Country.Id);
    boolean ase = ca.isAccountSharingEnabled;
    ase = ca.isGenericAcreages;
    ase = ca.isGermanActionPlan;
    ase = ca.isGermanCPActionPlan;
    ase = ca.isGenericTacticalPlan;
    ase = ca.isRSATacticalPlan;
    ase = ca.isStandardTrial;
    ase = ca.isBlockFields;
    ase = ca.isUKTacticalPlan;
    ase = ca.isCancelledStatusValueForTacticalPlan;
    ase = ca.isAutoCreateAcreages();
    ase = ca.isShownAcreageProductList();
    ase = ca.isHideCPDivision();
    List<Selectoption> vouch = ca.getVoucherTemplates();
    ase = ca.isAccountNameDuplicateBlockerEnabled();
    
    CountryAdapter ca2 = new CountryAdapter(usr);
    Test.stopTest();
  }

  private static testMethod void checkCountryAdapter(){

    CountryAdapter.allCountryMap = null;
    User usr = [SELECT CountryISOCode__c FROM User WHERE Id = :UserInfo.getUserId()];
    usr.CountryISOCode__c = 'DE';

    update usr;
    
    Test.startTest();
    CountryAdapter ca2 = new CountryAdapter(usr);
  
    Test.stopTest();
  }

 private static testMethod void testItalia1Country(){
    Map<String, Object> aCountryParams = new Map<String, String>
    {
      'Name' => 'Italy',
      'TacticalPlanSetting__c' => 'Italian'
    };
    Country__c testItalia1Country = (Country__c)SmartFactory.createSobject('Country__c', aCountryParams);
    
    testItalia1Country.DE_EnableAccountSharing__c = true;
    testItalia1Country.AcreageSetting__c = 'Generic';
    testItalia1Country.TrialSetting__c = 'Standard';
    testItalia1Country.TacticalPlanSetting__c = 'Italian';
    
    insert testItalia1Country;
    CountryAdapter.allCountryMap = null;
    User usr = [SELECT CountryISOCode__c FROM User WHERE Id = :UserInfo.getUserId()];
    usr.CountryISOCode__c = 'IT';

    update usr;
    
    Test.startTest();
    CountryAdapter ca = new CountryAdapter(testItalia1Country.Id);
    
    CountryAdapter ca2 = new CountryAdapter(usr);
    List<Selectoption> vouch = ca2.getVoucherTemplates();
    Test.stopTest();
  }

  private static testMethod void testRomania1Country(){
    Map<String, Object> aCountryParams = new Map<String, String>
    {
      'Name' => 'Romania',
      'TacticalPlanSetting__c' => 'Romanian'
    };
    Country__c testRomania1Country = (Country__c)SmartFactory.createSobject('Country__c', aCountryParams);
    
    testRomania1Country.DE_EnableAccountSharing__c = true;
    testRomania1Country.AcreageSetting__c = 'Generic';
    testRomania1Country.TrialSetting__c = 'Standard';
    testRomania1Country.TacticalPlanSetting__c = 'Standard';
    
    insert testRomania1Country;
    CountryAdapter.allCountryMap = null;
    User usr = [SELECT CountryISOCode__c FROM User WHERE Id = :UserInfo.getUserId()];
    usr.CountryISOCode__c = 'RO';

    update usr;
    
    Test.startTest();
    CountryAdapter ca = new CountryAdapter(testRomania1Country.Id);
    
    CountryAdapter ca2 = new CountryAdapter(usr);
    List<Selectoption> vouch = ca2.getVoucherTemplates();
    Test.stopTest();
  }

}