/*
  If exist Country record with Name how currentUser.CountryName then in URL will add two parameters : 
  1. Country.Id
  2. Country.Name
*/
@isTest
private class Test_AccountCreateNewController
{
  private static User user1;
  static testmethod void Test1()
  {
    Country__c Country= new Country__c(Name='Germany', TacticalPlanSetting__c='German', DE_EnableAccountSharing__c=true);   
     insert Country;
    Profile p = [SELECT Id FROM Profile WHERE Name='DE_Sales Representative S&T'];
    user1 = new User (Username=' user1@test.fullbox.com', FirstName = 'user1',LastName='user1',Email='user1@monsanto.com.fullbox', Alias='USR1',Country='Germany',CountryISOCode__c='DE', CommunityNickname='test1',TimeZoneSidKey = 'America/New_York',LocaleSidKey = 'en_US', ProfileId = p.Id, EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US');
     insert user1;
     ApexPages.currentPage().getParameters().put('User', User1.id) ;
     ApexPages.currentPage().getParameters().put('country', Country.Id) ;
    Test.setCurrentPage(Page.CreateNewAccount);
    Test.startTest();
    AccountCreateNewController aController = new AccountCreateNewController(new ApexPages.StandardController(new Account()));
    aController.doRedirect();
    Test.stopTest();
  }
}