public with sharing class TrialNew{
    private ApexPages.standardController standardController;
    public String retURL {get; set;}
    public String saveNewURL {get; set;}
    public String rType {get; set;}
    public String cancelURL {get; set;}
    public String ent {get; set;}
    public String confirmationToken {get; set;}
    public List <RecordType> Rec;
    public PageReference returnURL;
    public String strRecName;
    public String accName {get; set;}
    public String accId {get; set;}
    
    
    public TrialNew(ApexPages.StandardController controller){
        this.standardController = standardController;
    }

    public Pagereference redirectCampaign(){
        Id  IdAc = urlParameters.get('id');
        
        returnURL = new PageReference('/a0Y/e?');
        returnURL.getParameters().put('nooverride', '1');
        
        retURL = urlParameters.get('retURL');
        returnURL.getParameters().put('retURL',retURL);
        
        cancelURL = urlParameters.get('cancelURL');
        returnURL.getParameters().put('cancelURL',cancelURL);
                
        ent = urlParameters.get('ent');
        returnURL.getParameters().put('ent',ent);
        
        confirmationToken = urlParameters.get('_CONFIRMATIONTOKEN');
        returnURL.getParameters().put('_CONFIRMATIONTOKEN',confirmationToken );
        
        saveNewURL = urlParameters.get('save_new_url');
        returnURL.getParameters().put('save_new_url',saveNewURL);
        
        rType = urlParameters.get('RecordType');
        returnURL.getParameters().put('RecordType',rType);
        
        //Account
        accName= urlParameters.get('CF00ND0000005kzcz');
        returnURL.getParameters().put('CF00ND0000005kzcz',accName);
        
        accId= urlParameters.get('CF00ND0000005kzcz_lkid');
        returnURL.getParameters().put('CF00ND0000005kzcz_lkid',accId);
        
        //Campaign        
        if(rtype <> null){
            rec = [SELECT Name FROM RecordType WHERE ID =: rType];
            if(rec.size() > 0){
            
                String DivName = 'OSR';
                if(rec[0].name == 'Grain' ||rec[0].name == 'Silage') DivName = 'Corn';
              
                List<Division__c> Div = [SELECT id FROM Division__c WHERE name =: DivName];
                if(Div.size() >0){
                  List<Campaign> Ca = [SELECT id, name FROM Campaign WHERE DivisionRef__c =: Div[0].id AND OwnerId =: UserInfo.getUserId() AND YearV2__c =: Util.currentYear.id];
                    if(Ca.size() >0){
                        returnURL.getParameters().put('CF00ND0000005kzd1',Ca[0].name);
                        returnURL.getParameters().put('CF00ND0000005kzd1_lkid',Ca[0].id);
                    }
                }
            } 

        }else{
            returnURL.getParameters().put('CF00ND0000005kzd1',util.currentCampaign.name);
            returnURL.getParameters().put('CF00ND0000005kzd1_lkid',util.currentCampaign.id);
        }
        
        returnURL.setRedirect(true);
        return returnURL;
    }
    
    public static Map<String, String>urlParameters{
        get{   
            if (urlParameters == null || urlParameters.isEmpty()){ //Fix for components with reRender
                if (ApexPages.currentPage() != null)
                    urlParameters = ApexPages.currentPage().getParameters();
                else
                    urlParameters = new Map<String, String>();
            }
            return urlParameters;
        } set;
    }
}