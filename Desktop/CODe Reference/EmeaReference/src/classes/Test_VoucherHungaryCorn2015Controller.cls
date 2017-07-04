@isTest 
public class Test_VoucherHungaryCorn2015Controller{
    static testMethod void testVoucherHungary() {
       // Add test method logic using System.assert(), System.assertEquals()
       // and System.assertNotEquals() here.
    
    Profile p = [SELECT Id FROM Profile WHERE Name='HU_Sales Representative']; 
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com.emea.fullbox', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Country='Hungary',
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.emea.fullbox');
    
    System.runAs(u){
     //Create new Country
    Country__c country = new Country__c(Name='Hungary');
    insert country;
    
    
    Year__c y = new Year__c(Name='2015');
    insert y;
    
    Division__c d = new Division__c(Name='Corn');
    insert d;
    
    VoucherCampaign__c vc = new VoucherCampaign__c(Name='Voucher Hungary',yearref__c=y.id,CountryRef__c=country.id,BagSize__c=80, DivisionRef__c=d.id, EndDate__c=date.parse('12/12/2018'), MinProducts__c=5, MinTotalBags__c=80, StartDate__c=date.parse('12/12/2009'));
    insert vc;
     
     //Create new Account
    Account a = new Account(Name='Test Account',CountryRef__c=country.id);
    insert a;
    
     //Create new CLI
    Campaignlineitem__c cli = new CampaignLineItem__c(FarmRef__c=a.id);
    insert cli;
    
    Voucher__c v = new Voucher__c(AccountRef__c=a.id,status__c='cancelled',VoucherCampaignRef__c=vc.id,TotalBags__c=100);
    insert v;
    
    voucherlineitem__c vl = new voucherlineitem__c(voucherRef__c=v.id,PICK_TYPE__c='Free of Charge',Campaignlineitemref__c=cli.id, HybridName__c='DKC',bags__c=100);
    insert vl;
    
       }
     }
}