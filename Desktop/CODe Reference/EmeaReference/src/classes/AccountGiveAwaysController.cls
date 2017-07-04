public class AccountGiveAwaysController extends AccountListVirtualController
{
    public static final String JUMPER_GIVEAWAYS = 'AccountGiveAways';
    public static final String MODE_EDIT = 'merchandiseManagementEdit';
    public transient User infoUser { get;set;}

    public AccountGiveAwaysController()
    {
        // Initialization standard factory for give aways
        GiveAwayFactory tempFactory = new GiveAwayFactory();
        
        fieldSetManager = new FieldSetMemberxManager(Schema.SObjectType.CampaignLineItem__c, JUMPER_GIVEAWAYS);
        // jumper / anchor for pagereferences
        jumperTag = JUMPER_GIVEAWAYS;
        mode = MODE_EDIT;
        
        for(String s : fieldSetManager.getSOQLFields())
        {
            tempFactory.selectFields.add(s);
        }
        objectFactory = tempFactory;
    }
    // getter for give aways used by component
    public List<CampaignLineItem> getMerchandiseManagements()
    {
        return ( List<CampaignLineItem> ) wrapperObjects;
    }
    
        //for Give Away button visibility ( for country lead)
    public boolean getIsGermanyAPCountryLead()
    {
        if(Util.CountryView.isGermanActionPlan)
        {    infoUser =[
                        SELECT Is_Country_Manager__c, Is_Regional_Manager__c, Is_Sales_Rep__c, Profile.Name, StandardDivision__c
                        FROM User 
                        WHERE ID = :userInfo.getUserID()
                        ];
    
            if(infoUser.Is_Country_Manager__c==true)
            {
                return true;
            }
            else 
                return false;
         }else
             return false;
            
    }   

}