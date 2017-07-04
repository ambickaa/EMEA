public class AccountTrialManagementListController extends AccountListVirtualController
{
    public static final String JUMPER_TRIALS = 'AccountTrialList';
    public static final String MODE_EDIT = 'trailEdit';
    public transient User infoUser { get;set;}

    public String numberOfLines
    {
        get
        {
            if (numberOfLines == null)
            {
                if (Util.urlParameters.containsKey('numberOfLines'))
                {
                    numberOfLines = Util.urlParameters.get('numberOfLines');
                } else 
                {
                    numberOfLines = '1';
                }
            }
            return numberOfLines;
        
        }
         set;
    }
    
    
    public FieldSetMemberxManager innerFieldSetManager {get; set;}
    
    public AccountTrialManagementListController()
    {
        
        //Choose factory
        TrialManagementFactory tempFactory = new TrialManagementFactory();
        
        fieldSetManager = new FieldSetMemberxManager(Schema.SObjectType.CampaignLineItemGroup__c, JUMPER_TRIALS);
        innerFieldSetManager = new FieldSetMemberxManager(Schema.SObjectType.CampaignLineItem__c, JUMPER_TRIALS);
        
        // jumper / anchor for pagereferences
        jumperTag = JUMPER_TRIALS;
        mode = MODE_EDIT;
        
        
        for(String s : fieldSetManager.getSOQLFields())
        {
            tempFactory.selectFields.add(s);
        }
        
        for(String s : innerFieldSetManager.getSOQLFields())
        {
            tempFactory.innerSelectFields.add(s);
        }
        
        
        objectFactory = tempFactory;
    }

    //getTrails for VF-Component
    public List<CampaignLineItemGroup>getTrialManagements()
    {
        return ( List<CampaignLineItemGroup> ) wrapperObjects;
    }
    
    
    public override PageReference newRecord()
    {
        return URLx.setURL( '/apex/'+Util.countryView.country.AccountViewPage__c+'?id='+accountId+'&action=newLine&mode='+mode+'&division='+Util.divisionId+'&numberOfLines='+numberOfLines+'#'+jumperTag );
    }

    
    //for Trial button visibility ( for country lead)
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