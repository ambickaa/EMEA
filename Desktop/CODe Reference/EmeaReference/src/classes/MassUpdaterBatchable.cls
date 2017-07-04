global class MassUpdaterBatchable implements Database.Batchable<sObject>{  

public Boolean BudgetMode=false;
public Boolean EastCLIPY=false;
public Boolean StockUpdater=false;
public Boolean TotAcrSales=false;
public String Country='';

public String query='';

global MassUpdaterBatchable()
{
}

global Database.querylocator start(Database.BatchableContext BC){
  if(BudgetMode)
  {
     query='SELECT Id, ProductRef__c,SalesApril__c,SalesAugust__c,SalesDecember__c,SalesFebruary__c, SalesJanuary__c,SalesJuly__c,SalesJune__c,SalesMarch__c,SalesMay__c,SalesNovember__c,SalesOctober__c,SalesRep__c,SalesSeptember__c,YearRef__r.Name FROM Budget__c ';
  }else if(EastCLIPY)
  {
    Id rType='012D000000035B2IAI';
    List<String> EastCountries = new List<String> {'Hungary', 'Russia', 'Ukraine', 'Romania','Turkey','Bulgaria'};
    query='SELECT Id FROM CampaignLineItem__c WHERE Country__c in:EastCountries and CampaignRef__r.StatusCode__c=200 AND POGPY__C=null AND RecordTypeId=:rType';
  
  }else if(StockUpdater)
  {
    query='SELECT Id FROM Stock__c';
  }else if(TotAcrSales)
  {
    ID FarmType=Util.recordType.get('Account:GroupFarmSite');
        query='SELECT ID  from Account where CountryRef__r.Name=:Country AND RecordTypeID=:FarmType';    
  }
   
    return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){

  if(BudgetMode)
  {
      Map<String,Map<String,Integer>> Sales= new Map<String,Map<String,Integer>>();
      Map<String,Map<String,Integer>> Confirmed= new Map<String,Map<String,Integer>>();
      List<Budget__c> BudgetToUpdate = new List<Budget__c> ();
      List<Budget__c> BudgetList = new List<Budget__c>();
      List<ID> SalesRepToQuery = new List<ID> ();
      List<ID> PCEtoQuery = new List<ID>();
          
    
      for(sObject s : scope)
      {
                 Budget__c b = (Budget__c)s;
              PCEtoQuery.add(b.ProductRef__c);
                  SalesRepToQuery.add(b.SalesRep__c);
                  Sales.put((String)b.SalesRep__c+'_'+(String)b.ProductRef__c +'_'+(String)b.YearRef__r.Name,
                  new Map<String,Integer>{'Jan'=> 0, 'Feb' => 0,'Mar'=> 0, 'Apr' => 0, 'May' => 0,'Jun' => 0,
                              'Jul' => 0,'Aug' =>0,'Sep'=>0,'Oct'=>0,'Nov'=>0,'Dec'=>0});   
                  Confirmed.put((String)b.SalesRep__c+'_'+(String)b.ProductRef__c +'_'+(String)b.YearRef__r.Name,
                  new Map<String,Integer>{'Jan'=> 0, 'Feb' => 0,'Mar'=> 0, 'Apr' => 0, 'May' => 0,'Jun' => 0,
                              'Jul' => 0,'Aug' =>0,'Sep'=>0,'Oct'=>0,'Nov'=>0,'Dec'=>0});   
                      
                BudgetList.add(b);
      }
      
      Sales=SalesMap(Sales,PCEtoQuery,SalesRepToQuery);
      Confirmed=ConfirmedMap(Confirmed,PCEtoQuery,SalesRepToQuery);
              
          for(Budget__c b: BudgetList)
          {
                  if(b.ProductRef__c!=null && b.SalesRep__c!=null && b.YearRef__r.Name!=null)
                  {      
                      b=assignConfirmed(b,Confirmed); 
                    b=assignSales(b,Sales);              
                  BudgetToUpdate.add(b);  
                  }     
          }  
          update BudgetToUpdate;           
      
  }else if(EastCLIPY)
  {
    List<CampaignLineItem__c> cliToUpdate = new List<CampaignLineItem__c>();
    
    for(sObject s : scope)
    {
           CampaignLineItem__c cli = (CampaignLineItem__c)s;
           cliToUpdate.add(cli);
    }
    update(cliToUpdate);
           
  }else if(StockUpdater)
  {
    Set<Id> stockToUpdate = new set<Id>();
    
    for(sObject s : scope)
    {
           Stock__c st = (Stock__c)s;
           stockToUpdate.add(st.Id);
    }
    TriggerOrderUpdateStocks2.updateStocks(stockToUpdate,stockToUpdate);
    
    
  }else if(TotAcrSales)
  {
    Set<Id> anAccsList = new Set<Id>();
    
    for(sObject s : scope)
    {
       Account anAcc = (Account)s;
           anAccsList.add(anAcc.Id);
    }
        AccountTriggerHelper.updateSummaryAcreages(anAccsList);
        AccountTriggerHelper.updateSummaryCampaignLineItem(anAccsList);
  
  }
}
global void finish(Database.BatchableContext BC){

}

private Budget__c assignSales (Budget__c budget, Map<String,Map<String,Integer>> SalesMap)
{
  Budget__c bu=budget;
  
  bu.SalesJanuary__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Jan');
    bu.SalesFebruary__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Feb');
  bu.SalesMarch__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Mar');
  bu.SalesApril__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Apr');
                  
  bu.SalesMay__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('May');
  bu.SalesJune__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Jun');
  bu.SalesJuly__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Jul');
  bu.SalesAugust__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Aug');
                  
  bu.SalesSeptember__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Sep');
  bu.SalesOctober__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Oct');
  bu.SalesNovember__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Nov');
  bu.SalesDecember__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Dec');
  
  return bu;
}

private Budget__c assignConfirmed (Budget__c budget, Map<String,Map<String,Integer>> ConfirmedMap)
{
  Budget__c bu=budget;
  
  bu.AgreedJanuary__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Jan');
    bu.AgreedFebruary__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Feb');
  bu.AgreedMarch__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Mar');
  bu.AgreedApril__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Apr');
                  
  bu.AgreedMay__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('May');
  bu.AgreedJune__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Jun');
  bu.AgreedJuly__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Jul');
  bu.AgreedAugust__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Aug');
                  
  bu.AgreedSeptember__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Sep');
  bu.AgreedOctober__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Oct');
  bu.AgreedNovember__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Nov');
  bu.AgreedDecember__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Dec');
  
  return bu;
}

private Map<String,Map<String,Integer>> SalesMap (Map<String,Map<String,Integer>> SalesMap, List<ID> PCE, List<ID> SalesRep)
{
          for(AggregateResult a0 : [
                    SELECT sum(PoG__c) PoG, ProductRef__c PCE, OwnerId OwnerCLI, CALENDAR_MONTH(CreatedDate) M,CALENDAR_YEAR(CreatedDate) Y
                    FROM CampaignLineItem__c WHERE (FinalOrderRef_RSA__r.Status_RSA__c='Closed' OR FinalOrderRef_RSA__r.Status_RSA__c='Approved')
                        AND FinalOrderRef_RSA__r.Signed_RSA__c=true AND ProductRef__c in:PCE  AND OwnerId in: SalesRep
                    GROUP BY ProductRef__c, OwnerId, CALENDAR_MONTH(CreatedDate),CALENDAR_YEAR(CreatedDate) 
  
                                      ])
          {          
      if(a0.get('PoG')!=null && SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y')))!=null  )
             {  if(a0.get('M')==1)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Jan',Integer.valueof(a0.get('PoG')));
              if(a0.get('M')==2)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Feb',Integer.valueof(a0.get('PoG')));
              if(a0.get('M')==3)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Mar',Integer.valueof(a0.get('PoG')));
              if(a0.get('M')==4)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Abr',Integer.valueof(a0.get('PoG')));
              if(a0.get('M')==5)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('May',Integer.valueof(a0.get('PoG')));
              if(a0.get('M')==6)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Jun',Integer.valueof(a0.get('PoG')));
              if(a0.get('M')==7)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Jul',Integer.valueof(a0.get('PoG')));
              if(a0.get('M')==8)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Aug',Integer.valueof(a0.get('PoG')));
              if(a0.get('M')==9)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Sep',Integer.valueof(a0.get('PoG')));
              if(a0.get('M')==10)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Oct',Integer.valueof(a0.get('PoG')));
              if(a0.get('M')==11)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Nov',Integer.valueof(a0.get('PoG')));
              if(a0.get('M')==12)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Dec',Integer.valueof(a0.get('PoG')));
             }
        
             }
             return SalesMap;
}


private Map<String,Map<String,Integer>> ConfirmedMap (Map<String,Map<String,Integer>> SalesMap, List<ID> PCE, List<ID> SalesRep)
{
          for(AggregateResult a0 : [
                    SELECT sum(Agreed__c) Agreed, ProductRef__c PCE, OwnerId OwnerCLI, CALENDAR_MONTH(CreatedDate) M,CALENDAR_YEAR(CreatedDate) Y
                    FROM CampaignLineItem__c WHERE PreliminaryOrderRef_RSA__r.Status_RSA__c='Closed' AND PreliminaryOrderRef_RSA__r.Signed_RSA__c=true
                        AND ProductRef__c in:PCE  AND OwnerId in: SalesRep
                    GROUP BY ProductRef__c, OwnerId, CALENDAR_MONTH(CreatedDate),CALENDAR_YEAR(CreatedDate) 
  
                                      ])
          {          
      if(a0.get('Agreed')!=null && SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y')))!=null  )
             {  if(a0.get('M')==1)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Jan',Integer.valueof(a0.get('Agreed')));
              if(a0.get('M')==2)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Feb',Integer.valueof(a0.get('Agreed')));
              if(a0.get('M')==3)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Mar',Integer.valueof(a0.get('Agreed')));
              if(a0.get('M')==4)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Abr',Integer.valueof(a0.get('Agreed')));
              if(a0.get('M')==5)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('May',Integer.valueof(a0.get('Agreed')));
              if(a0.get('M')==6)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Jun',Integer.valueof(a0.get('Agreed')));
              if(a0.get('M')==7)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Jul',Integer.valueof(a0.get('Agreed')));
              if(a0.get('M')==8)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Aug',Integer.valueof(a0.get('Agreed')));
              if(a0.get('M')==9)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Sep',Integer.valueof(a0.get('Agreed')));
              if(a0.get('M')==10)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Oct',Integer.valueof(a0.get('Agreed')));
              if(a0.get('M')==11)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Nov',Integer.valueof(a0.get('Agreed')));
              if(a0.get('M')==12)
                SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Dec',Integer.valueof(a0.get('Agreed')));
             }
        
             }
             return SalesMap;
}
    
}