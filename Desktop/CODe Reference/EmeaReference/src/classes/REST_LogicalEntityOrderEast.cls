@RestResource(urlMapping='/getLogicalEntity/OrderEast_2/*')
global with sharing class REST_LogicalEntityOrderEast { 
    
    public static final Integer queryLimit =1000; 
    public static final ID OtherRecordType = '012D000000038IgIAI';
    public static final ID SalesRecordType = '012D000000035B2IAI';
    
    @HttpPost
    global static REST_LogicalEntity_Order getOrders(REST_Request paramInfo)
    {
        
        
        REST_Request oRequest = paramInfo;
        
        REST_LogicalEntity_Order returned = new REST_LogicalEntity_Order ();
        returned.pagetimestamp=oRequest.pagetimestamp;        
        returned.lastItem=oRequest.lastItem;
        returned.lastId='';
        returned.mode=oRequest.mode;
            
        returned.orders= new List<Order__c> ();
        returned.actionPlans = new List<CampaignLineItem__c> ();
        
        
        SET<ID> voucherCampaingIds= new SET<ID>();  
            
        Id OSRCampaign=UtilREST.OSRCurrentCampaign;
        Id CornCampaign=UtilREST.CornCurrentCampaign;
        Id MonfastCampaign=UtilREST.MonfastCurrentCampaign;
        Id LatitudeCampaign=UtilREST.LatitudeCurrentCampaign;
        Id RoundupCampaign=UtilREST.RoundupCurrentCampaign;
        Id MonitorCampaign=UtilREST.MonitorCurrentCampaign;
       
        oRequest.pagetimestamp=UtilREST.resetTimestamp(oRequest.pagetimestamp);  
                    
        returned.campaigns= new List<Campaign> ();
        returned.voucherConfig=new List<VoucherConfigObject>();        
        Map<Id,VoucherConfigObject> voucherConfigMap = new Map<Id,VoucherConfigObject>();
        Integer rows=0;
        
        
        if(oRequest.mode==0 )
        {
            
            for(Campaign cmp : [
                SELECT        
                    IsActive,
                    Name,
                    RecordTypeId,
                    StartDate,
                    EndDate,
                    Status,
                    TotalAllocatedBudget__c,
                    TotalAllocatedCharged__c,
                    TotalAllocatedFOC__c,
                    TotalCampaignBudget__c,
                    TotalCampaignBudgetFOC__c,
                    TotalPendingBudget__c,
                  //TotalPendingCharged__c,
                    TotalPendingAgreedBudget__c,  
                    TotalPendingPoGBudget__c,
                    TotalForecastCharged__c,
                    TotalForecastFOC__c,
                    TotalAgreedCharged__c,
                    TotalSalesCharged__c,
                    TotalPendingForecastBudget__c,
                    CreatedById,
                    YearV2__c,
                    CountryRef__c,
                    DivisionRef__c,
                    CompetitorPCMRef__c,
                    SalesPCMRef__c,
                    TrialPCMRef__c,
                    LastModifiedDate,
                    ApprovalStatus_RSA__c,
                    OwnerID,
                    StatusCode__c,
                    DisableAgreedStatus__c,
                    DisableForecastStatus__c,
                    NUM_TotalFOCAllowed__c
                FROM
                    Campaign
                WHERE
                    StatusCode__c=200 
                ] )
            {
                returned.campaigns.add(cmp);
                voucherConfigMap.put(cmp.Id,new VoucherConfigObject(false,0,cmp.DivisionRef__c,0,cmp.Id, false,'','', false, false, false,'',false));            
            }
            
            
           for(VoucherCampaign__c vc: [
                    SELECT isActive__c, 
                        BagSize__c,
                        CountryRef__c, 
                        CreatedDate,
                        DivisionRef__c, 
                        endDate__c,  
                        LastModifiedDate,
                        MinProducts__c,
                        OwnerId, 
                        Id, 
                        StartDate__c,
                        Name,
                        isDataPrivacy__c,
                        isTermsAndConditions__c,
                        isTechnology__c,
                        VoucherHungary__c, 
                        Currency__c,
                        Discount_Type__c,
                        MPICK_PRODUCTFIELDS__c,
                        CHK_MARKETING_AGREED__c,
                        TXT_LegalTerms1__c,
                        TXT_LegalTerms2__c


                    FROM VoucherCampaign__c
                    WHERE isActive__c=true AND CountryRef__r.Name=:Util.currentUser.Country
                    ])
            {
                        system.debug('TEST CAMPAIGN ' +vc);
                        
                         if(vc.Name.contains('- Corn -'))
                        {
                        string a;
                        }
                         if( CornCampaign!=null)
                        {
                        string b;
                        }
                        if(vc.Name.contains('- Corn -') && CornCampaign!=null)
                        {
                            voucherCampaingIds.add(vc.ID) ;             
                            voucherConfigMap.get(CornCampaign).Active=true;
                            voucherConfigMap.get(CornCampaign).BagSize=(Integer)vc.BagSize__c;  
                            voucherConfigMap.get(CornCampaign).MinProducts=(Integer)vc.MinProducts__c; 
                            voucherConfigMap.get(CornCampaign).VoucherCampaignRef=vc.ID; 
                            voucherConfigMap.get(CornCampaign).VoucherHungary=vc.VoucherHungary__c;  
                            voucherConfigMap.get(CornCampaign).Currency_voucher=vc.Currency__c; 
                            voucherConfigMap.get(CornCampaign).DiscountType=vc.Discount_Type__c;                        
                            voucherConfigMap.get(CornCampaign).isTermsAndConditions=vc.isTermsAndConditions__c;
                            voucherConfigMap.get(CornCampaign).isTechnology=vc.isTechnology__c;
                            voucherConfigMap.get(CornCampaign).isDataPrivacy=vc.isDataPrivacy__c;
                            voucherConfigMap.get(CornCampaign).MPICK_PRODUCTFIELDS=vc.MPICK_PRODUCTFIELDS__c;
                            voucherConfigMap.get(CornCampaign).isMarketingAgreement=vc.CHK_MARKETING_AGREED__c;
                            voucherConfigMap.get(CornCampaign).LegalTerms1=vc.TXT_LegalTerms1__c;
                            voucherConfigMap.get(CornCampaign).LegalTerms2=vc.TXT_LegalTerms2__c;
                        }
                        if(vc.Name.contains('- OSR -') && OSRCampaign!=null)
                        {           
                            voucherCampaingIds.add(vc.ID) ; 
                            voucherConfigMap.get(OSRCampaign).Active=true;
                            voucherConfigMap.get(OSRCampaign).BagSize=(Integer)vc.BagSize__c;  
                            voucherConfigMap.get(OSRCampaign).MinProducts=(Integer)vc.MinProducts__c;    
                            voucherConfigMap.get(OSRCampaign).VoucherCampaignRef=vc.ID;
                            voucherConfigMap.get(OSRCampaign).VoucherHungary=vc.VoucherHungary__c; 
                            voucherConfigMap.get(OSRCampaign).Currency_voucher=vc.Currency__c;   
                            voucherConfigMap.get(OSRCampaign).DiscountType=vc.Discount_Type__c;                     
                            voucherConfigMap.get(OSRCampaign).isTermsAndConditions=vc.isTermsAndConditions__c;   
                            voucherConfigMap.get(OSRCampaign).isTechnology=vc.isTechnology__c;  
                            voucherConfigMap.get(OSRCampaign).isDataPrivacy=vc.isDataPrivacy__c;
                            voucherConfigMap.get(OSRCampaign).MPICK_PRODUCTFIELDS=vc.MPICK_PRODUCTFIELDS__c;  
                            voucherConfigMap.get(OSRCampaign).isMarketingAgreement=vc.CHK_MARKETING_AGREED__c;
                            voucherConfigMap.get(OSRCampaign).LegalTerms1=vc.TXT_LegalTerms1__c;
                            voucherConfigMap.get(OSRCampaign).LegalTerms2=vc.TXT_LegalTerms2__c;
                        }
             }
                    
             for(Id vco : voucherConfigMap.keyset())
             {
                    returned.voucherConfig.add(voucherConfigMap.get(vco));
             }
             oRequest.mode=1;
             returned.mode=1;
        }       
                                
        if(oRequest.mode==1) 
        {
            
            List<ID> accShared = new List<ID> ();
            List<ID> cliShared = new List<ID>();
            
            for(AccountShare acc:[ SELECT AccountId
                                                FROM AccountShare 
                                                WHERE UserOrGroupId=:Util.currentUser.Id AND AccountAccessLevel='Edit' ])
            {
                accShared.add(acc.AccountID);
            }
            
            if(accShared.size()>0)
            {           
                for(CampaignLineItem__Share  cliS :  [  SELECT ParentId
                                                        FROM CampaignLineItem__Share 
                                                        WHERE Parent.LastModifiedDate > :oRequest.pagetimestamp AND 
                                                        UserOrGroupId=:Util.currentUser.Id AND( NOT( AccessLevel!='Edit' AND AccessLevel!='Read' AND AccessLevel!='All'  ))
                                                        AND Parent.RecordTypeId=:SalesRecordType                                                                                        
                                                        AND (NOT( Parent.FarmRef__c NOT in :accShared AND Parent.FarmRef__r.OwnerId!=:Util.currentUser.Id))                                                             
                                                ])
                {
                    cliShared.add(cliS.ParentId);
                }           
            }
            
            for(CampaignLineItem__c cli : [ 
                        SELECT
                            Name,
                            OwnerId,
                            CreatedById,
                            RecordTypeId,
                            Type__c,
                            PlantingDensity__c,
                            Provider__c,
                            Status__c,
                            Agreed__c,
                            Forecast__c,
                            POG__c,
                            Quantity__c,
                            ProductCatalogEntryRef__c,
                            ProductRef__c,
                            CampaignRef__c,
                            Treatment__c,
                            Yield__c,
                            CampaignName__c,
                            Country__c,
                            Year__c,
                            DistributorRef__c,
                            FarmRef__c, 
                            PoS__c,
                            Ultrashort_Irrigation_RSA__c,
                            LastModifiedDate,
                            CatalogType_RSA__c,
                            Price_Copy__c,
                            Inventory__c,
                            PoGPY__c,
                            ProductCatalogEntryRef__r.ProductRef__c               
                        FROM
                            CampaignLineItem__c
                        WHERE
                            LastModifiedDate > :oRequest.pagetimestamp
                            AND ProductRef__c!=null
                            AND RecordTypeId=:SalesRecordType
                            AND ProductCatalogEntryRef__c!=null
                            AND ProductCatalogEntryRef__r.ProductCatalogRef__c != null
                            AND ProductCatalogEntryRef__r.ProductCatalogRef__c in : UtilREST.activeSalesCatalogs_CLI
                            AND FarmRef__c!=null 
                            AND FarmRef__r.Name!=null
                            AND CampaignName__c!=null
                            AND FarmRef__r.RecordTypeId!=null
                            AND FarmRef__r.RecordTypeId!=:OtherRecordType//recordtype Others
                            AND ( NOT( Id NOT in :cliShared AND (NOT((OwnerID=:Util.currentUser.Id AND FarmRef__r.OwnerId=:Util.currentUser.Id )))))
                            AND ID> : oRequest.lastId
                            ORDER BY ID 
                            LIMIT : queryLimit      
                            
                        ])
            {
                if(cli.CampaignName__c.contains('- OSR -') && cli.CampaignRef__c!=OSRCampaign)
                    cli.CampaignRef__c=OSRCampaign;
                else if(cli.CampaignName__c.contains('- Corn -') && cli.CampaignRef__c!=CornCampaign)
                    cli.CampaignRef__c=CornCampaign;
                else if(cli.CampaignName__c.contains('Monitor') && cli.CampaignRef__c!=MonitorCampaign)
                    cli.CampaignRef__c=MonitorCampaign;
                else if(cli.CampaignName__c.contains('Monfast') && cli.CampaignRef__c!=MonfastCampaign)
                    cli.CampaignRef__c=MonfastCampaign;
                else if(cli.CampaignName__c.contains('Latitude') && cli.CampaignRef__c!=LatitudeCampaign)
                    cli.CampaignRef__c=LatitudeCampaign;
                else if(cli.CampaignName__c.contains('Roundup') && cli.CampaignRef__c!=RoundupCampaign)
                    cli.CampaignRef__c=RoundupCampaign;
    
                if(cli.CampaignRef__c!=null && cli.ProductRef__c==cli.ProductCatalogEntryRef__r.ProductRef__c)
                    returned.actionPlans.add(cli);
            }
            
            rows=returned.actionPlans.size();
            if(rows==queryLimit)
            {
                oRequest.lastId=returned.actionPlans.get(rows-1).Id;
            }                  
            
        }
        
        returned.calculateTimestamp(oRequest.maxtimestamp);  
        
        return returned;
    }
    
     public class VoucherConfigObject{
         
         Boolean Active  {get;set;}
         Integer BagSize  {get;set;}
         ID DivisionRef  {get;set;} 
         Integer MinProducts  {get;set;}      
         ID CampaignRef  {get;set;}
         Id VoucherCampaignRef {get;set;}
         Boolean VoucherHungary {get;set;}
         String Currency_voucher {get;set;}
         String DiscountType {get;set;}
         Boolean isTermsAndConditions {get;set;}
         Boolean isDataPrivacy {get;set;}
         Boolean isTechnology {get;set;}
         String MPICK_PRODUCTFIELDS {get;set;}
         Boolean isMarketingAgreement {get;set;}
         String LegalTerms1 {get;set;}
         String LegalTerms2 {get;set;}


         
         public VoucherConfigObject(Boolean act, Integer bag, Id div, Integer mp, Id cr, Boolean vh, String cu, String dt, Boolean Terms, Boolean Priv, Boolean Tech, String MPICK, Boolean isMarkAgr)
         {
            Active=act;
            BagSize=bag;
            DivisionRef=div;
            MinProducts=mp;
            CampaignRef=cr;
            isTermsAndConditions=Terms;
            isDataPrivacy=Priv;
            isTechnology=Tech;
            VoucherHungary=vh;
            Currency_voucher=cu;
            DiscountType=dt;
            MPICK_PRODUCTFIELDS=MPICK;
            isMarketingAgreement= isMarkAgr;


         }

    }

    global class REST_LogicalEntity_Order {
        
        public List<Order__c> orders {get;set;}
        public List<CampaignLineItem__c> actionPlans {get;set;}
        public List<Campaign> campaigns {get;set;}
        public List<Map<String,String>> signatures {get;set;}
        public List<VoucherConfigObject> voucherConfig {get;set;}
        
        public DateTime timestamp {get;set;}
        public DateTime maxtimestamp {get;set;}     
        public DateTime pagetimestamp {get;set;}
        public Boolean queryMore {get;set;}        
        public Integer mode {get;set;}         
        public Integer lastItem {get;set;}  
        public String lastId {get;set;}
        
        public void calculateTimestamp(Datetime reqMaxTimestamp)
        {   
            maxtimestamp=reqMaxTimestamp;         
                        
            for(CampaignLineItem__c cli : actionPlans){
                if(maxtimestamp == null || maxtimestamp < cli.LastModifiedDate)maxtimestamp = cli.LastModifiedDate;
            }
            
            for(Campaign c : campaigns){
                if(maxtimestamp == null || maxtimestamp < c.LastModifiedDate)maxtimestamp = c.LastModifiedDate;
            }
                                                        
            if(actionPlans.size()<queryLimit)
            {
                timestamp=maxtimestamp;
                queryMore=false;
                pagetimestamp=maxtimestamp;
                mode=0;
                lastItem=0;
                LastId='';              
            }   
            else
            {
                lastId=(String)actionPlans.get(queryLimit-1).ID;
                queryMore=true;
            }
            timestamp=pagetimestamp;                   
        }
    }
  
}