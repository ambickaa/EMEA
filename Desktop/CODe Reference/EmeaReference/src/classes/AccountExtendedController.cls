public with sharing class AccountExtendedController
{
    /*
      private static Integer info = 0;
      private static Integer error = 0;
      private static Integer confirm = 0;
      private static Integer warning = 0;
      private Map<ID,TrialManagement__c> trialsMap;
      public Account account {get;set;}
      public Boolean displayPopUp {get;set;}
      public OpportunityLineItem currentRecord {get;set;}
      public String prodId {get;set;}
      public List<Acreage__c> acreages {get;set;}
      public List<Merchandise_management__c> merchandise {get;set;}
      public List<Opportunity> tacticalPlan {get;set;}
      public List<TrialManagement__c> trials{get;set;}
     */
    public AccountExtendedController (ApexPages.StandardController controller)
    {
    }
    /*   try{
         account = (Account)controller.getRecord();
         trials = new List<TrialManagement__c>();
         acreages = new List <Acreage__c>();
         merchandise = new List<Merchandise_management__c>();
         tacticalPlan = new List<Opportunity> ();


         acreages = [
                     select id,name,AcrProductFamilyRef__c,AcrTotalAcreages__c, AcrComment__c, AcrSoilType__c, AcrYearRef__c
                     from   Acreage__c
                     where AcrFarmRef__c =:account.Id
                     //and year__c =: currentyear or year__c=: lastyear
                    ];

         merchandise =  [
                     select id,name, MMProductRef__c,MMProductRef__r.name, MMQuantity__c
                     from   Merchandise_management__c
                     where MMFarmRef__c =:account.Id
                     //and year__c =: currentyear or year__c=: lastyear
                    ];
         Map<ID,TrialManagement__c> trialsMap= new Map <ID,TrialManagement__c>( [select id,name,TrialComment__c,TrialStatus__c,
                                                                                        TrialFarmerRef__c,TrialType__c,TrialYearRef__c,(Select PPTHybridRef__c,PPTStatus__c From ProductsPerTrial__r)
                                                                                 from TrialManagement__c
                                                                                 where TrialFarmerRef__c =:account.Id
                                                                                ] );
        trials= trialsMap.values();


      }catch(Exception e){}


    }



      */



}