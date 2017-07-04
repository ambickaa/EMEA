public with sharing class TacticalPlanGermanyFactory extends TacticalPlanCountryFactory implements AccountListObjectFactory
{
  /*public Set<String>selectFields
  {
    get
    {
      if(selectFields == null)
      {
        selectFields = new Set<String> { 'id', 'ProductRef__c', 'ProductRef__r.Name', 'ProductCatalogEntryRef__c', 'POG__c', 'Inventory__c', 'Treatment__c', 'Status__c ', 'Inventory__c', 'Type__c', 'PlantingDensity__c', 'DistributorRef__c', 'PoS__c', 'Forecast__c', 'FarmRef__c', 'ChargedElement__c', 'CampaignRef__c', 'Agreed__c', 'FreeOfChargeElement__c'};
      }
      return selectFields;
    }
    set;
  }*/
  public List<AccountListObjectWrapper> createObjectWrapperForAccountId( String accountId )
    {
      List<AccountListObjectWrapper> result = new List<CampaignLineItem>();
        
      
      sortCampaignLineItemsAndCreateMapsFromIt();
      
      Map<String, CampaignLineItem>prevCampaignLineItems = new Map<String, CampaignLineItem>();
      prevCampaignLineItems = combineCampaignLineItemsChargedAndFreeOfCharge(prevCCampaignLineItems, prevFOCCampaignLineItems);
      
      Map<String, CampaignLineItem>nextCampaignLineItems = new Map<String, CampaignLineItem>();
      nextCampaignLineItems = combineCampaignLineItemsChargedAndFreeOfCharge(nextCCampaignLineItems, nextFOCCampaignLineItems);
      
      result = combineByCampaigns(prevCampaignLineItems, nextCampaignLineItems).values();
      
      
    
    
        return result;
    }
    
    
    public Map<String, CampaignLineItem> combineCampaignLineItemsChargedAndFreeOfCharge(Map<String, CampaignLineItem>campainLineItemCMap, Map<String, CampaignLineItem>campainLineItemFOCMap)
    {
      Map<String, CampaignLineItem>result = new Map<String, CampaignLineItem>();
      
      for(CampaignLineItem c : campainLineItemCMap.values())
      {
        if(campainLineItemFOCMap.containsKey(c.key))
        {
          c.freeOfChargeElement = campainLineItemFOCMap.get(c.key);
          campainLineItemFOCMap.remove(c.key);
        }
        else
        {
          c.freeOfChargeElement = c.deepClone();
          c.freeOfChargeElement.record.CampaignRef__c = c.record.CampaignRef__c;
          c.freeOfChargeElement.record.Type__c = 'Free of charge';
        }
        result.put(c.key, c);
      }
      
      for(CampaignLineItem c : campainLineItemFOCMap.values())
      {
        CampaignLineItem tempLineItem = c.deepClone();
        tempLineItem.record.CampaignRef__c = c.record.CampaignRef__c;
        tempLineItem.record.Type__c = 'Charged';
        tempLineItem.freeOfChargeElement = c;
        result.put(tempLineItem.key, tempLineItem);
      }
      return result;
    }
    
    public Map<String, CampaignLineItem> combineByCampaigns(Map<String, CampaignLineItem>prevCampaignLineItems, Map<String, CampaignLineItem>nextCampaignLineItems)
    {
      Map<String, CampaignLineItem>result = new Map<String, CampaignLineItem>();
      //Util.addWarningMessage(prevCampaignLineItems);
      //Util.addWarningMessage(nextCampaignLineItems);
      for(CampaignLineItem c : prevCampaignLineItems.values())
      {
        if(nextCampaignLineItems.containsKey(c.key))
        {
          c.nextPeriodeElement = nextCampaignLineItems.get(c.key);
          nextCampaignLineItems.remove(c.key);
        }
        else
        {
          c.nextPeriodeElement = c.deepClone();
          c.nextPeriodeElement.record.Type__c = 'Charged';
          if(Util.currentCampaign<> null)
          {
            c.nextPeriodeElement.record.CampaignRef__c = Util.currentCampaign.id;
          }
          
          c.nextPeriodeElement.freeOfChargeElement = c.deepClone();
          c.nextPeriodeElement.freeOfChargeElement.record.Type__c = 'Charged';
          if(Util.currentCampaign<> null)
          {
            c.nextPeriodeElement.freeOfChargeElement.record.CampaignRef__c = Util.currentCampaign.id;
          }          
        }
        
        
        result.put(c.key, c);
      }
      
      
      for(CampaignLineItem c : nextCampaignLineItems.values())
      {
        CampaignLineItem tempPrevCampaignLineItem = c.deepClone();
        
        System.debug(':::::::::::::clone' + tempPrevCampaignLineItem.record.Id);
        tempPrevCampaignLineItem.freeOfChargeElement = c.deepClone();
        tempPrevCampaignLineItem.nextPeriodeElement = c;
        result.put(tempPrevCampaignLineItem.key, tempPrevCampaignLineItem);
      }
      return result;
    }
    
    
    
    
    public AccountListObjectWrapper createAnEmptyRecord( String accountId )
    {
      CampaignLineItem cli = new CampaignLineItem();
      cli.freeOfChargeElement = cli.deepClone();
      cli.nextPeriodeElement = cli.deepClone();
      cli.nextPeriodeElement.freeOfChargeElement = cli.deepClone();
      if(Util.currentCampaign <> null)
      {
        cli.nextPeriodeElement.freeOfChargeElement.record.CampaignRef__c = Util.currentCampaign.id;
        cli.nextPeriodeElement.record.CampaignRef__c = Util.currentCampaign.id;
      }
        return cli;
    }
    
    /*
    // generates SOQL QUERY for current Campaign and Last Campaign Line Items
    private al.SoqlBuilder generateQuery()
    {
      // Campaign Condition
      al.OrCondition campaignCondition = new al.OrCondition();
      if(Util.currentCampaign <> null)
      {
          campaignCondition.add
          (
              new al.FieldCondition( 'CampaignRef__c' ).equals( Util.currentCampaign.id )
            );
      }
      
      if(Util.previewsCampaign <> null)
      {
          campaignCondition.add
          (
              new al.FieldCondition( 'CampaignRef__c' ).equals( Util.previewsCampaign.id )
            );
      }
      
      // Generate SOQL
      al.SoqlBuilder query = new al.SoqlBuilder();
      query
      .selectx(selectFields)
      .fromx('CampaignLineItem__c')
      .wherex
      (
        new al.AndCondition()
        .add
        (
          new al.FieldCondition( 'FarmRef__c' ).equals(Util.currentAccount.id)
        )
         .add
            (
                new al.FieldCondition( 'RecordTypeId' ).equals( Util.recordType.get('CampaignLineItem__c:Sales') )
            )
            .add
            (
                campaignCondition
            )
      );
      return query;
    } 
    */
}