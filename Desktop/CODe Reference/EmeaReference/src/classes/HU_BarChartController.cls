//https://developer.salesforce.com/forums/?id=906F0000000Ah2gIAC
//http://salesforce.stackexchange.com/questions/15916/visualforce-gauge-with-breakpoints
//http://developer.force.com/cookbook/recipe/easy-visualforce-charts-with-javascript-remoting--google-charts-api
//https://google-developers.appspot.com/chart/interactive/docs/gallery/gauge

global with sharing class HU_BarChartController{
    
    global Id UserId {get;set;}
    global String CurrentYear {get;set;}
        
    public HU_BarChartController() {
        
        UserId = system.UserInfo.getUserId();
        system.debug('user:' + UserId);
        
        //List<User> UserInfo = new List<User>();
        User UserInfo = [SELECT Id, name, country from User where Id=:UserId];
        system.debug('Debug1 User Country: ' + UserInfo.country);
        
        String CountryName = UserInfo.country;
        system.debug('Debug2 '+ CountryName);
        
        List<Country__c> Country = new List<Country__c>();
        Country = [SELECT id, name, LKP_CurrentYear__c FROM Country__c WHERE name=:CountryName];
        system.debug('Debug3 '+ Country[0].LKP_CurrentYear__c);
        CurrentYear = Country[0].LKP_CurrentYear__c;
        
    }
    
    @RemoteAction
    global static List<Volume> getDataVolume() {
        
        HU_BarChartController RR =new HU_BarChartController();
 
        /* Obtaining all parameters from the Custom label ChartHomePage */
        List<String> Values = (label.ChartHomePage.replaceAll('(\\s+)', '')).split('#',0);
        map<String, String> Limits = new map<String, String>();
        
        for (integer i=0;i<Values.size();i=i+2)
        {
            Limits.put(Values[i],Values[i+1]);
        }
        
        //RecordType Sales Campaign
        RecordType CampRecType = [Select Id From RecordType  Where SobjectType = 'Campaign' and DeveloperName = 'Sales_camp'];
        
        //Recordtype Sales
        RecordType CliRecType = [Select Id From RecordType  Where SobjectType = 'CampaignLineItem__c' and DeveloperName = 'Sales'];
        
        list<Campaign> CurrentCampaign = new list<Campaign>(); 
        CurrentCampaign = [SELECT Id, Name FROM Campaign WHERE IsActive = true and DivisionRef__c='a0ED000000E23kn' and Parent.OwnerId<>'005D0000002EIDm' and RecordTypeId=: CampRecType.Id and OwnerId=:RR.UserId];
     
        //system.debug('Campaign Data: ' + CurrentCampaign.Id);
        

        if (CurrentCampaign.size() >0) {    
        //Actuals
        decimal actual1 = 0;
        for (CampaignLineItem__c CLI : [SELECT Id, actuals__c FROM Campaignlineitem__c WHERE CampaignRef__r.ParentId=:CurrentCampaign[0].Id and RecordTypeId=:CliRecType.Id and (Account_Status__c='To be reviewed' or Account_Status__c='Active') and (not FarmRef__r.name like '%other%') and actuals__c>0 and Provider__c like '%Monsanto%'])
        {
            actual1 = actual1 + CLI.actuals__c;
        }
        
        system.debug('volume Data: ' + actual1);
        
        //Penetration
        decimal actual2 = 0;
        for (CampaignLineItem__c CLI : [SELECT Id, actuals__c FROM Campaignlineitem__c WHERE CampaignRef__r.ParentId=:CurrentCampaign[0].Id and RecordTypeId=:CliRecType.Id and (Account_Status__c='To be reviewed' or Account_Status__c='Active') and (not FarmRef__r.name like '%other%') and actuals__c>0 and ProductRef__r.name like '%CL%' and Provider__c like '%Monsanto%'])
        {
            actual2 = actual2 + CLI.actuals__c;
        }
        system.debug('Penetration Data: ' + actual2);
    
        //Others
        
        decimal actual3 = 0;
        for (CampaignLineItem__c CLI : [SELECT Id, actuals__c FROM Campaignlineitem__c WHERE CampaignRef__r.ParentId=:CurrentCampaign[0].Id and RecordTypeId=:CliRecType.Id and (Account_Status__c='To be reviewed' or Account_Status__c='Active') and (FarmRef__r.name like '%other%') and actuals__c>0 and ProductRef__r.name like '%CL%' and Provider__c like '%Monsanto%'])
        {
            actual3 = actual3 + CLI.actuals__c;
        }
        system.debug('Others Data: ' + actual3);
        
        List<Volume> dataVolume = new List<Volume>();
        dataVolume.add(new Volume((String)('Volume'),Integer.ValueOf(actual1), Integer.ValueOf(actual2), Integer.ValueOf(actual3), Limits.get('HU_RM_Chart_1_Min'), Limits.get('HU_RM_Chart_1_Max'), Limits.get('HU_RM_Chart_1_BP1'), Limits.get('HU_RM_Chart_1_BP2'), Limits.get('HU_RM_Chart_2_Min'), Limits.get('HU_RM_Chart_2_Max'), Limits.get('HU_RM_Chart_2_BP1'), Limits.get('HU_RM_Chart_2_BP2'), Limits.get('HU_RM_Chart_3_Min'), Limits.get('HU_RM_Chart_3_Max'), Limits.get('HU_RM_Chart_3_BP1'), Limits.get('HU_RM_Chart_3_BP2')));
        return dataVolume;
        }
        
        else {
            
        List<Volume> dataVolume = new List<Volume>();
        dataVolume.add(new Volume((String)('Volume'),0, 0, 0, Limits.get('HU_RM_Chart_1_Min'), Limits.get('HU_RM_Chart_1_Max'), Limits.get('HU_RM_Chart_1_BP1'), Limits.get('HU_RM_Chart_1_BP2'), Limits.get('HU_RM_Chart_2_Min'), Limits.get('HU_RM_Chart_2_Max'), Limits.get('HU_RM_Chart_2_BP1'), Limits.get('HU_RM_Chart_2_BP2'), Limits.get('HU_RM_Chart_3_Min'), Limits.get('HU_RM_Chart_3_Max'), Limits.get('HU_RM_Chart_3_BP1'), Limits.get('HU_RM_Chart_3_BP2')));
        return dataVolume;
            
        }
        
    }
    global class Volume {
        public String name { get; set; }
        public decimal actuals { get; set; }
        public decimal penetration { get; set; }
        public decimal others { get; set; }
        public String Chart1Min { get; set; }
        public String Chart1Max { get; set; }
        public String Chart1BP1 { get; set; }
        public String Chart1BP2 { get; set; }
        public String Chart2Min { get; set; }
        public String Chart2Max { get; set; }
        public String Chart2BP1 { get; set; }
        public String Chart2BP2 { get; set; }
        public String Chart3Min { get; set; }
        public String Chart3Max { get; set; }
        public String Chart3BP1 { get; set; }
        public String Chart3BP2 { get; set; }

        public Volume(String name, decimal actuals, decimal penetration, decimal others, String Chart1Min, String Chart1Max, String Chart1BP1, String Chart1BP2, String Chart2Min, String Chart2Max, String Chart2BP1, String Chart2BP2, String Chart3Min, String Chart3Max, String Chart3BP1, String Chart3BP2) {
            this.name = name;
            this.actuals = actuals;
            this.penetration = penetration;
            this.others = others;
            this.Chart1Min = Chart1Min;
            this.Chart1Max = Chart1Max;
            this.Chart1BP1 = Chart1BP1;
            this.Chart1BP2 = Chart1BP2;
            this.Chart2Min = Chart2Min;
            this.Chart2Max = Chart2Max;
            this.Chart2BP1 = Chart2BP1;
            this.Chart2BP2 = Chart2BP2;
            this.Chart3Min = Chart3Min;
            this.Chart3Max = Chart3Max;
            this.Chart3BP1 = Chart3BP1;
            this.Chart3BP2 = Chart3BP2;
        }
    } 
    
        public String getUserProfile(){
        
            String profile = (UserInfo.getProfileId()).subString(0,15);
            system.debug('profile: '+profile);
            return profile;
        } 
}