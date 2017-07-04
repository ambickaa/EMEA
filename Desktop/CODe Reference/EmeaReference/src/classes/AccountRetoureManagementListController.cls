public class AccountRetoureManagementListController extends AccountListVirtualController
{
    public static final String JUMPER_RETOURE = 'AccountRetoureList';
    public static final String MODE_EDIT = 'retoureEdit';
    public transient User infoUser { get;set;}
    public Division__c currentDivision { get { return Util.currentDivision; } set;}
    public AccountActionPlanGermanySTController germanySTController {get;set;}

    
   public FieldSetMemberxManager innerFieldSetManager {get; set;}
    
   public AccountRetoureManagementListController(){
        
        String year;
        If(Util.currentCampaign!=null)year=Util.CurrentCampaign.YearV2__r.Name;
        else if(Util.currentCampaign==null)year=Util.currentYear.Name;
       
       List<Retoure__c> retoures = [
            SELECT Division__c, EximusRabat__c, Extrarabatt__c, FruekaufMenge__c, FruekaufRabatt__c, Id, Retoure2__c, Retoure1__c, Retoure3__c, NUM_ExceptionRabatt__c, NUM_ExpansionRabatt__c,
            RabattMenge__c , NUM_MENGE_TAX__c, TXT_Bemerkung__c, Vorlieferant2__r.Name, Vorlieferant1__r.Name, Vorlieferant3__r.Name, Clemente_Rabatt__c, TXT_year__c 
            FROM Retoure__c 
            WHERE Account__c =: Util.currentAccount.Id and Division__c =: Util.currentDivision.Id and TXT_year__c =: year LIMIT 1 ];  
       if (retoures.size() > 0)
            Retoure = retoures.get(0);
       else
            Retoure = new Retoure__c ( Account__c = Util.currentAccount.ID, Division__c = Util.currentDivision.Id, TXT_year__c = year);


        mode = MODE_EDIT;
        jumperTag = JUMPER_RETOURE;
    }
    
     
    public boolean getIsGermanView()
    {
        return Util.countryView.isGermanActionPlan;
    }
   
}