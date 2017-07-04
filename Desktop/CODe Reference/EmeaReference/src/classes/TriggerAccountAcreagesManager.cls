/** 
    CR000003 : Error message for Italy. 
    This trigger will show a message after the account update when any of these 3 fields is greater than 125% : PoGCustomerShareCornCY__c, AgreeedCustomerShareCornCY__c, ForecastCustomerShareCornCY__c

*/
public without sharing class TriggerAccountAcreagesManager implements Triggers.Handler
{
  public void handle()
  {
   /* THIS TRIGGER HAS BEEN DEACTIVATED IN 2015 CORN CAMPAIGN IN ORDER TO AVOID SYNCHRO PROBLEMS WITH THE IPAD. AS THE IPAD WAS NOT DOING THESE VALIDATIONS.  
    // CR000003  
    for (Account anAccount: (List<Account>)Trigger.new)
    {
      if (anAccount.CountryRef__c == 'a0CD000000PNdHG' &&
          ((anAccount.PoGCustomerShareCornCY__c>125 && systemSettings__c.getvalues('ITA_Control_POG').Value__c=='true') 
          || (anAccount.AgreeedCustomerShareCornCY__c>125 && systemSettings__c.getvalues('ITA_Control_Agreed').Value__c=='true')
          || (anAccount.ForecastCustomerShareCornCY__c>125 && systemSettings__c.getvalues('ITA_Control_Forecast').Value__c=='true' ) ) 
          &&
          (( ((Account)trigger.oldMap.get(anAccount.id)).PoGCustomerShareCornCY__c != anAccount.PoGCustomerShareCornCY__c && systemSettings__c.getvalues('ITA_Control_POG').Value__c=='true') 
          || (((Account)trigger.oldMap.get(anAccount.id)).AgreeedCustomerShareCornCY__c != anAccount.AgreeedCustomerShareCornCY__c && systemSettings__c.getvalues('ITA_Control_Agreed').Value__c=='true')  
          || ( ((Account)trigger.oldMap.get(anAccount.id)).ForecastCustomerShareCornCY__c != anAccount.ForecastCustomerShareCornCY__c)  && systemSettings__c.getvalues('ITA_Control_Forecast').Value__c=='true') )
        {
            anAccount.addError(system.label.ITA_ERROR_ACCOUNT);
        }
    else if(anAccount.CountryRef__c=='a0CD000000PNdHG' && (anAccount.CornTotalAcreagesCY__c==0 || anAccount.CornTotalAcreagesCY__c==null) && anAccount.CornTotalSalesCY__c>0 && (((Account)trigger.oldMap.get(anAccount.id)).CornTotalSalesCY__c != anAccount.CornTotalSalesCY__c)  )
        {
            if(systemSettings__c.getvalues('ITA_Control_Acreages0').Value__c=='true' || !UserInfo.getUserId().contains('005D0000002FcQu') || !UserInfo.getUserId().contains('005D0000002EQvb')) 
        	anAccount.addError(system.label.ITA_ERROR_ACCOUNT2);
        }
    }
    //END CR000003
    
    Set<Id> anAccountIdSet = new Set<Id>();
    //Get all account with updated values.
    for (Account anAccount: (List<Account>)Trigger.new)
    {
      if (anAccount.CountryRef__c != null && new CountryAdapter(anAccount).isAutoCreateAcreages())
      {
        Account anOldAccount = Trigger.isInsert ? new Account() : (Account)Trigger.oldMap.get(anAccount.Id);
        Map<String, Acreage__c> anAcreagesMap = new Map<String, Acreage__c>();
        if (anAccount.TotalCornAcreagesManualCY__c != anOldAccount.TotalCornAcreagesManualCY__c
          || anAccount.TotalOSRAcreagesManualCY__c != anOldAccount.TotalOSRAcreagesManualCY__c
          || anAccount.TotalOtherAcreagesManualCY__c != anOldAccount.TotalOtherAcreagesManualCY__c)
        {
          anAccountIdSet.add(anAccount.Id);
        }
      }
    }
    //Get acreages for the accounts.
    Map<Id, Account> anAccountMap = new Map<Id, Account>([SELECT Id, TotalCornAcreagesManualCY__c,
          TotalOSRAcreagesManualCY__c, TotalOtherAcreagesManualCY__c, OwnerId,
           (SELECT Id, AcrTotalAcreages__c, AcrProductGroupRef__r.Name, AcrYearRef__c
              FROM Acreages__r WHERE RecordTypeId = :Util.recordType.get('Acreage__c:AcreagesPerProductGroup')
              AND (AcrYearRef__c = :Util.currentYear.Id OR AcrYearRef__c = :Util.lastYear.Id))
          FROM Account WHERE Id IN :anAccountIdSet]);
    List<Acreage__c> anAcrToUpdate = new List<Acreage__c>();
    
    //For all accounts we update acreages or create new one.
    for (Id anAccountId: anAccountIdSet)
    {
      Account anAccount = anAccountMap.get(anAccountId);
      Account anOldAccount = Trigger.isInsert ? new Account() : (Account)Trigger.oldMap.get(anAccount.Id);
      Map<Id, Acreage__c> anAccountAcreagesCY = new Map<Id, Acreage__c>();
      Map<Id, Acreage__c> anAccountAcreagesPY = new Map<Id, Acreage__c>();
      if (anAccount.Acreages__r != null)
      {
        for (Acreage__c anAcreage: anAccount.Acreages__r)
        {
          if (anAcreage.AcrProductGroupRef__r != null)
          {
            if (anAcreage.AcrYearRef__c == Util.currentYear.Id)
            {
              anAccountAcreagesCY.put(anAcreage.AcrProductGroupRef__c, anAcreage);
            } else if (anAcreage.AcrYearRef__c == Util.lastYear.Id)
            {
              anAccountAcreagesPY.put(anAcreage.AcrProductGroupRef__c, anAcreage);
            }
          }
        }
      }
      if (anAccount.TotalCornAcreagesManualCY__c != anOldAccount.TotalCornAcreagesManualCY__c)
      {
        anAcrToUpdate.add(getAcreage(anAccountAcreagesCY, anAccountAcreagesPY, Util.getProductGroup(Util.PRODUCT_GROUP_CORN), anAccount, anAccount.TotalCornAcreagesManualCY__c));
      }
      if (anAccount.TotalOSRAcreagesManualCY__c != anOldAccount.TotalOSRAcreagesManualCY__c)
      {
        anAcrToUpdate.add(getAcreage(anAccountAcreagesCY, anAccountAcreagesPY, Util.getProductGroup(Util.PRODUCT_GROUP_OSR), anAccount, anAccount.TotalOSRAcreagesManualCY__c));
      }
      if (anAccount.TotalOtherAcreagesManualCY__c != anOldAccount.TotalOtherAcreagesManualCY__c)
      {
        anAcrToUpdate.add(getAcreage(anAccountAcreagesCY, anAccountAcreagesPY, Util.getProductGroup(Util.PRODUCT_GROUP_OTHER), anAccount, anAccount.TotalOtherAcreagesManualCY__c));
      }
    }
    upsert anAcrToUpdate;*/
  }
  

  /*private static Acreage__c getAcreage(Map<Id, Acreage__c> theAcrMapCY, Map<Id, Acreage__c> theAcrMapPY, Id theGroup, Account theAccount, Decimal theValue)
  {
    Acreage__c aResult = theAcrMapCY.get(theGroup);
    if (aResult == null)
    {
      aResult = new Acreage__c();
      aResult.AcrFarmRef__c = theAccount.Id;
      aResult.AcrProductGroupRef__c = theGroup;
      aResult.AcrProviderRef__c = Util.DEFAULT_HUNGARY_ACREAGE_PROVIDER;
      aResult.RecordTypeId = Util.recordType.get('Acreage__c:AcreagesPerProductGroup');
      aResult.AcrYearRef__c = Util.currentYear.Id;
      aResult.OwnerId = theAccount.OwnerId;
      Acreage__c aResultPY = theAcrMapPY.get(theGroup);
      if (aResultPY != null)
      {
        aResult.PreviousAcreageRef__c = aResultPY.Id;
      }
    }
    aResult.AcrTotalAcreages__c = theValue;
    return aResult;
  }*/
}