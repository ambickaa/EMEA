@RestResource(urlMapping='/getLogicalEntity/Order_5/*')
global with sharing class REST_LogicalEntityOrderController2{

    public static final Integer queryLimit = 10000;

    @HttpPost
    global static REST_LogicalEntity_Order getOrders(REST_Request paramInfo)
    {
    
        REST_Request tRequest = paramInfo;      
    
        //REST_OrderPdfGenerator.generateSignedPdfs();
        REST_LogicalEntity_Order returned = new REST_LogicalEntity_Order ();
        
        returned.orders = new List<Order__c>();
        returned.actionPlans = new List<CampaignLineItem__c>();
        returned.campaigns = new List<Campaign> ();    
        returned.signatures = new List<Map<String,String>>();
        returned.consignments = new List<Consignment__c>();
        
        if(UtilREST.currentCampaignRSA!=null){
        returned.orders = [
            SELECT
                Name,
                VAT_RSA__c,
                RecordTypeId, 
                Status_RSA__c,
                Signed_RSA__c,
                Price_RSA__c, //(TODO Rename)
                AmountTotalDiscount_RSA__c,
                AccountRef_RSA__c,
                Type_RSA__c,
                PreliminaryOrderRef_RSA__c,
                EarlyPayment_RSA__c,
                EarlyDelivery_RSA__c,
                VolumeDiscount_RSA__c,
                Discretionary_Discount_RSA__c,
                Reason_RSA__c,
                FinalPrice_RSA__c,
                LastModifiedDate,
                //copy fields
                Bank_Account_Number_Copy_RSA__c,
                Bank_Branch_Copy_RSA__c,
                Bank_Name_Copy_RSA__c,
                Buyer_Copy_RSA__c,
                Buyer_MobilePhone_Copy__c,
                Buyer_Name_Copy__c,
                BankAccountHolder_copy_RSA__c,
                Buyer_Officenumber_Copy_RSA__c,
                City_Copy__c,
                CoopMember_RSA_Copy__c,
                CoopName_RSA_Copy__c,
                Email_Copy__c,
                Fax_Copy__c,
                IDNumber_Copy_RSA__c,
                Latitude_Copy__c,
                Longitude_Copy__c,
                Name_Copy__c,
                Office_number_Copy__c,
                PostalAddress_Region_Copy_RSA__c,
                SAP_Number_Copy_RSA__c,
                StateProvince_Copy__c,
                Trust_CC_Mpy_Copy_RSA__c,
                Trust_CC_Mpy_Value_Copy_RSA__c,
                VAT_Copy__c,
                ZIPPostalCode_Copy__c,          
                EarlyPaymentName_Copy_RSA__c,
                EarlyPaymentDiscount_Copy_RSA__c,
                EarlyDeliveryName_Copy_RSA__c,
                EarlyDeliveryDiscount_Copy_RSA__c,
                Cancellation_Reason_RSA__c,
                version_Id_RSA__c,
                DeliveryInstructions__c,
                DeliveryDate__c,
                Reason__c,
                ApprovalComments__c,
                Language__c ,
                Consigned__c
                    
            FROM
                Order__c
            WHERE
                LastModifiedDate > :tRequest.maxtimestamp
                AND CreatedDate >= :UtilREST.currentCampaignRSA.StartDate AND CreatedDate<=:UtilREST.currentCampaignRSA.EndDate
                AND OwnerId =:Util.currentUser.ID
                AND AccountRef_RSA__r.Name!=null
                
            ];
        
        returned.actionPlans = new List<CampaignLineItem__c>();
        for(CampaignLineItem__c cli: [
            SELECT
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
                DistributorRef__c,
                FarmRef__c,
                PoS__c,
                Ultrashort_Irrigation_RSA__c,
                PreliminaryOrderRef_RSA__c, //TODO Rename
                FinalOrderRef_RSA__c, // TODO Rename
                LastModifiedDate,
                CatalogType_RSA__c,
                //copy field
                Price_Copy__c,
                POGPY__c,
                ProductCatalogEntryRef__r.ProductRef__c,
                Consigned__c
            FROM
                CampaignLineItem__c
            WHERE
                (LastModifiedDate > :tRequest.maxtimestamp OR
                 PreliminaryOrderRef_RSA__c in :new Map<ID,Order__c>(returned.orders).keySet() OR
                 FinalOrderRef_RSA__c in :new Map<ID,Order__c>(returned.orders).keySet()) AND
                 ProductCatalogEntryRef__r.ProductCatalogRef__c in : UtilREST.activeSalesCatalogsRSA_CLI
                 AND CampaignRef__c =:UtilREST.currentCampaignRSA.ID
                 AND ProductRef__c!=null AND ProductCatalogEntryRef__c!=null 
                 AND OwnerId =:Util.currentUser.ID    
                 AND FarmRef__r.Name!=null
             
            ])
        {
            if(cli.ProductCatalogEntryRef__r.ProductRef__c==cli.ProductRef__c)
                returned.actionPlans.add(cli);
        }
        
        returned.campaigns = [
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
                TotalForecastCharged__c,
                TotalForecastFOC__c,
                TotalAgreedCharged__c,
                TotalPendingForecastBudget__c,
                CreatedById,
                YearV2__c,
                CountryRef__c,
                DivisionRef__c,
                CompetitorPCMRef__c,
                TrialPCMRef__c,
                SalesPCMRef__c,
                LastModifiedDate,
                ApprovalStatus_RSA__c,
                OwnerID,
                CHK_enableGeneralSales__c,
                CHK_enableFebReceipts__c
            FROM
                Campaign
            WHERE
                lastModifiedDate > :tRequest.maxtimestamp
                AND OwnerId=:Util.currentUser.ID
                AND StatusCode__c=200
                AND ID= :UtilREST.currentCampaignRSA.ID                
            ];
        
        
        returned.consignments = [
            SELECT  
                Id,
                LastModifiedDate,
                ProductCatalogEntryRef__c,
                Requested__c,
                Name,
                Status__c
            FROM Consignment__c 
            WHERE Status__c='Accepted' AND UserRef__c=:Util.currentUser.Id AND lastModifiedDate > :tRequest.maxtimestamp
             AND ProductCatalogEntryRef__r.ProductCatalogRef__c in : UtilREST.activeRegularCatalogRSA
            ];      
        } 
 
        returned.calculateTimestamp(tRequest.maxtimestamp);
                     
        return returned;
    }
    
    global class REST_LogicalEntity_Order {
        
        public List<Order__c> orders {get;set;}
        public List<CampaignLineItem__c> actionPlans {get;set;}
        public List<Campaign> campaigns {get;set;}
        public List<Consignment__c> consignments {get;set;}
        
        List<Map<String,String>> signatures {get;set;}
        
        public DateTime timestamp {get;set;}
        public DateTime pagetimestamp {get;set;}               
        public DateTime maxtimestamp {get;set;}
        public Boolean queryMore {get;set;}
        public Integer mode {get;set;} //1 owner, 2 shared, 3 others
        public Integer lastItem {get;set;}      
        public String lastId {get;set;}
        
        public void calculateTimestamp(Datetime reqMaxTimestamp){

            maxtimestamp=reqMaxTimestamp;
            
            for(Order__c o : orders){
                if(maxtimestamp == null || maxtimestamp < o.LastModifiedDate)maxtimestamp = o.LastModifiedDate;
            }
            
            for(CampaignLineItem__c cli : actionPlans){
                if(maxtimestamp == null || maxtimestamp < cli.LastModifiedDate)maxtimestamp = cli.LastModifiedDate;
            }
            
            for(Campaign c : campaigns){
                if(maxtimestamp == null || maxtimestamp < c.LastModifiedDate)maxtimestamp = c.LastModifiedDate;
            }
            
            for(Consignment__c co : consignments){
                if(maxtimestamp == null || maxtimestamp < co.LastModifiedDate)maxtimestamp = co.LastModifiedDate;
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
                queryMore=true;
                lastId=(String)actionPlans.get(queryLimit-1).ID;          
            }
           timestamp=pagetimestamp;            
            
        }
    }
    
    
    
    
}