@isTest
public with sharing class Test_SalesOrders 
{
     static testmethod void TriggerOpportunityAutoInfoCreator()
      {
          //insert product
        /*  Product2 p = new Product2(name='testproduct');
          insert p;
          
           Product2 p2 = new Product2(name='testproduct', ProductCartonPerPallet__c=10);
          insert p2;
          
          //insert pricebook
          Pricebook2 pb = new Pricebook2 (name='testpricebook');
          insert pb;
          pricebookentry pbeStandard = new pricebookentry (UnitPrice=0, Pricebook2Id=Test.getStandardPricebookId(), isActive=true, Product2Id=p.Id);
          insert pbeStandard;
          
          pricebookentry pbeStandard2 = new pricebookentry (UnitPrice=0, Pricebook2Id=Test.getStandardPricebookId(), isActive=true, Product2Id=p2.Id);
          insert pbeStandard2;
          
          //insesrt pricebookentry
          pricebookentry pbe2 = new pricebookentry (UnitPrice =0, Pricebook2Id=pb.Id, isActive=true, Product2Id=p2.Id);
          insert pbe2;
          
          pricebookentry pbe = new pricebookentry (UnitPrice =0, Pricebook2Id=pb.Id, isActive=true, Product2Id=p.Id);
          insert pbe;
          
          //insert country
          Country__c TestCountry= new Country__c(name='Spain');
          insert TestCountry;
          
          //insert account
          Account acc = new Account (name='account test', Category__c='Farm', GC_Status_Descr__c='active', CountryRef__c=TestCountry.Id);
          insert acc;
          
          //insert soldto
          Sold_to__c sold = new Sold_to__c (name='soldToTest');
          insert sold;
          
          //insertshipto
          ShipTo__c ship = new ShipTo__c (name='shipToTest');
          insert ship;
          
          //insert opportunity
          Opportunity opp = new Opportunity(lkp_sold_to__c=sold.id, recordtypeid='012D00000003084', ownerid=Userinfo.getUserId(), name='pepe', CloseDate=Date.today(), StageName='New');
          insert opp;
          
          OpportunityLineItem  OppProduct = new OpportunityLineItem  (OpportunityId = opp.Id, pricebookentryId=pbe.Id, NUM_Quantity_palets_CP__c=decimal.valueof('10'), Type__c='Charged');
          insert OppProduct;
          
          Opportunity opp2 = new Opportunity(lkp_sold_to__c=sold.id, recordtypeid='012D00000003084', ownerid=Userinfo.getUserId(), name='pepe', CloseDate=Date.today(), StageName='New');
          insert opp2;
          
        OpportunityLineItem  OppProduct2 = new OpportunityLineItem  (OpportunityId = opp2.Id, pricebookentryId=pbe2.Id, NUM_Quantity_litres_CP__c=decimal.valueof('20'), Type__c='Free of charge');
          insert OppProduct2;
          */ 
      }
      
      private static testmethod void TriggerOpportunityProductConverter()
      {
          
      }
     
      private static testmethod void TriggerOpportunityPreventNameUpdate()
      {
           
      }
     
      private static testmethod void onOpportunityLineItem()
      {
      }
     
      private static testmethod void onOpportunity()
      {
      }
  }