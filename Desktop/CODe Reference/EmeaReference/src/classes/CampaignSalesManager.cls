public with sharing class CampaignSalesManager
{
    public static final String CAMPAIGN_SALES_RM_TEMPLEATE = 'CAMPAIGN_SALES_RM_TEMPLEATE';
    public static final String CAMPAIGN_SALES_SR_TEMPLEATE = 'CAMPAIGN_SALES_SR_TEMPLEATE';
    
    /**
    * List of fields that will be copied from the parent campaign to all the cmapaigns of subordinates.
    */
    private static final List<String> CAMPAIGNS_FIELDS_TO_TRANSFER = new List<String>
    {
        'RecordTypeId', 'YearV2__c', 'CompetitorPCMRef__c', 'CountryRef__c', 'TrialPCMRef__c', 
        'SalesPCMRef__c', 'GiveAwayPCMRef__c', 'StatusCode__c', 'DivisionRef__c', 'ArchiveDate__c',
        'StartDate', 'EndDate', 'IsActive', 'TaxSalesPCMRef_RSA__c', 'DE_Season__c'
    };
    
    /**
    * List of fields for campaign that we need in addition to the general list.
    */
    private static final List<String> CAMPAIGNS_FIELDS_ADDITIONAL = new List<String>
    {
        'Id', 'Name', 'ParentCampName__c', 'TotalCampaignBudget__c', 'OwnerId'
    };

    /**
    * Current campaing.
    */
    private Campaign currentCampaign;
    
    /**
    * Current User
    */
    private User currentUser;
    
    private String notificationTemplateId;
    
    /**
    * List of current campaigns for subordinates.
    */
    public List<Campaign> childrenCampaigns{get;set;}
    
    public Campaign getCurrentCampaign()
    {
        return currentCampaign;
    }
    
    /**
    * Creates manager by campaign Id.
    * Loads current children campaigns from DB.
    */
    public CampaignSalesManager(Id theCampaignId)
    {
        currentCampaign = getCampaign(theCampaignId);
        currentUser = getUser(currentCampaign.OwnerId);
        notificationTemplateId = Util.getSetting(currentUser.Is_Country_Manager__c ? CAMPAIGN_SALES_RM_TEMPLEATE :
                  currentUser.Is_Regional_Manager__c ? CAMPAIGN_SALES_SR_TEMPLEATE : '');
        childrenCampaigns = getCurrentChildrenCampaigns(currentCampaign.Id);
    }
    
    /**
    * Creates list of all campaigns for all the subordinates.
    * It uses campaigns, that were already saved and creates new ones with 0 budget.
    * (No changes in DB).
    */
    public void loadFullCampaignsList()
    {
        //get list of subordinate users.
        List<User> aUserList = getSubordinates(currentUser);
        //get map of UserId -> campaign with current budget allocation.
        Map<Id, Campaign> aCampaignsMap = new Map<Id, Campaign>();
        for (Campaign aCampaign: childrenCampaigns)
        {
            aCampaignsMap.put(aCampaign.OwnerId, aCampaign);
        }
        childrenCampaigns = new List<Campaign>();
        for (User aUser: aUserList)
        {
            Campaign aCampaign = aCampaignsMap.get(aUser.Id);
            //Create new campaigns for the users, that we currently don't have a campaign with budget allocation.
            if (aCampaign == null)
            {
                aCampaign = createCampaignChild(currentCampaign, aUser);
            }
            childrenCampaigns.add(aCampaign);
        }
    }
    
    /**
    * Check if we allocated budget to the children campaigns c
    */
    private boolean validateCampaigns()
    {
        Decimal aTotalSum = 0;
        for (Campaign aCamp: childrenCampaigns)
        {
            aTotalSum += aCamp.TotalCampaignBudget__c;
        }
        
        if (aTotalSum > currentCampaign.TotalCampaignBudget__c)
        {
            throw new SalesCampaignSaveException (System.Label.ErrorCampaignSalesOverlimit + '(' + currentCampaign.TotalCampaignBudget__c +  '/' + aTotalSum +')');
        } else if(aTotalSum < currentCampaign.TotalCampaignBudget__c)
        {
            throw new SalesCampaignSaveException (System.Label.ErrorCampaignSalesUnderlimit + '(' + currentCampaign.TotalCampaignBudget__c +  '/' + aTotalSum + ')');
        }
        return true;
    }
    
    /*
    * Saves current budget allocation.
    */
    public void saveChildrenCampaign()
    {
        if (!validateCampaigns())
        {
            throw new SalesCampaignSaveException(System.Label.ErrorCampaignSalesException);
        }
        new withoutSharingMethods().myUpsert(childrenCampaigns);
    }
    
    public Boolean getIsAllocatedAndSaved()
    {
        for (Campaign aCampaign: childrenCampaigns)
        {
            if (aCampaign.Id == null)
            {
                return false;
            }
        }
        return childrenCampaigns.size() > 0;
    }
    
    /**
    * Checks if the budget was allocated correctly. If so, sends notification emails to the all children campaigns' owners.
    */
    public void notifyUsers()
    {
        if (!validateCampaigns())
        {
            throw new SalesCampaignSaveException(System.Label.ErrorCampaignSalesException);
        }
        if (!getIsAllocatedAndSaved())
        {
            throw new SalesCampaignSaveException(System.Label.ErrorCampaignSalesNotification);
        }
        List<Messaging.Singleemailmessage> aMessagesList = new List<Messaging.Singleemailmessage>();
        for (Campaign aCampaign: childrenCampaigns)
        {
            Messaging.Singleemailmessage aMessage = new Messaging.Singleemailmessage();
            aMessage.setTemplateId(notificationTemplateId);
            aMessage.setWhatId(aCampaign.Id);
            aMessage.setTargetObjectId(aCampaign.OwnerId);
            aMessage.setSaveAsActivity(false);
            aMessagesList.add(aMessage);
        }
        Messaging.sendEmail(aMessagesList);
    }
    
    /**
    * Get's campaign data from DB.
    */
    private Campaign getCampaign(Id theCampaignId)
    {
        al.SoqlBuilder aQueryBuilder = new al.SoqlBuilder();
        List<String> aFields = new List<String>{};
        aFields.addAll(CAMPAIGNS_FIELDS_TO_TRANSFER);
        aFields.addAll(CAMPAIGNS_FIELDS_ADDITIONAL);
        aQueryBuilder.selectx(aFields).fromx('Campaign');
        al.AndCondition aConditions = new al.AndCondition();
        aConditions.add(new al.FieldCondition('Id').equals(theCampaignId));
        aQueryBuilder.wherex(aConditions);
        List<sObject> aRes = Database.query(aQueryBuilder.toSOQL());
        return aRes == null || aRes.size() == 0 ? null : (Campaign)aRes.get(0);
    }
    
    /**
    * Gets info about current user.
    */
    private User getUser(Id theUserId)
    {
        al.SoqlBuilder aQueryBuilder = new al.SoqlBuilder();
        aQueryBuilder.selectx(new List<String>{'Id', 'Is_Country_Manager__c', 'Is_Regional_Manager__c'}).fromx('User');
        al.AndCondition aConditions = new al.AndCondition();
        aConditions.add(new al.FieldCondition('Id').equals(theUserId));
        aQueryBuilder.wherex(aConditions);
        return (User)Database.query(aQueryBuilder.toSOQL()).get(0);
    }
        
    /**
    * Gets all active subordinate users.
    * For Country leads - all reginal managers.
    * For Regional managers - all sales representitives.
    */
    private List<User> getSubordinates(User theUser)
    {
        al.SoqlBuilder aQueryBuilder = new al.SoqlBuilder();
        aQueryBuilder.selectx(new List<String>{'Id', 'Name', 'Is_Sales_Rep__c', 'Is_Regional_Manager__c', 'Is_Country_Manager__c'}).fromx('User');
        al.AndCondition aConditions = new al.AndCondition();
        aConditions.add(new al.FieldCondition('ManagerId').equals(theUser.Id));
        aConditions.add(new al.FieldCondition('IsActive').equals(true));
        if (theUser.Is_Country_Manager__c)
        {
            aConditions.add( new al.FieldCondition('Is_Regional_Manager__c').equals(true));
        } else if (theUser.Is_Regional_Manager__c)
        {
            aConditions.add(new al.FieldCondition('Is_Sales_Rep__c').equals(true));
        }
        aQueryBuilder.wherex(aConditions);
        return (List<User>) Database.query(aQueryBuilder.toSOQL());
    }
    
    /**
    * Get all campaigns with the parentId == current campaign
    */
    private List<Campaign> getCurrentChildrenCampaigns(Id theCampaignId)
    {
        al.SoqlBuilder aQueryBuilder = new al.SoqlBuilder();
        aQueryBuilder.selectx(new List<String>{'Id', 'Name', 'TotalCampaignBudget__c', 'OwnerId'}).fromx('Campaign');
        al.AndCondition aConditions = new al.AndCondition();
        aConditions.add(new al.FieldCondition('ParentId').equals(theCampaignId));
        aQueryBuilder.wherex(aConditions);
        List<Campaign> aCampList = (List<Campaign>) Database.query(aQueryBuilder.toSOQL());
        return aCampList;
    }
    
        
    /**
    * Creates new campaign for the subordinate user.
    * It copies all the neccessary information from the current campaign.
    */
    private Campaign createCampaignChild(Campaign theCampaign, User theUser)
    {
        Campaign aResult = new Campaign();
        for (String aField: CAMPAIGNS_FIELDS_TO_TRANSFER)
        {
            aResult.put(aField, theCampaign.get(aField));
        }
        aResult.Name = theUser.Is_Sales_Rep__c && theCampaign.ParentCampName__c != null  ? theCampaign.ParentCampName__c : theCampaign.Name;
        aResult.Name += ' for ' + theUser.Name;
        aResult.ParentId = theCampaign.Id;
        aResult.TotalCampaignBudget__c = 0;
        aResult.RecordTypeId = theCampaign.RecordTypeId;
        aResult.OwnerId = theUser.Id;
        return aResult;
    }
    
    /**
    * Exceptions on save to DB, other exceptions on Sales Campaigns actions.
    */
    public class SalesCampaignSaveException extends Exception
    {
    }
    
    private without sharing class withoutSharingMethods{
        public void myUpsert(List<sObject> paraminfo){
            upsert paramInfo;
        }
    }
}