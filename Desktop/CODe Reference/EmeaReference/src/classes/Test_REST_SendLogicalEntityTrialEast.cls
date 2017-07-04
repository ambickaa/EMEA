@isTest
public class Test_REST_SendLogicalEntityTrialEast{
      
    public static testMethod void TestSendTrials() {
     
        User u = new User(Id=Userinfo.getUserId(), CountryISOCode__c='BU');
        update u;
        system.debug('va a buscar: '+Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER');
        
        Test.startTest();
        Test_REST_DataFactoryEast.TestData();
        Systemsettings__c s;
        try{
        	List<Systemsettings__c> mcs = Systemsettings__c.getall().values();
            mcs[0].value__c = 'all';
            update mcs;
            //s = [SELECT id, value__c from Systemsettings__c where name='EAST_REST_SVC_JSON_SAVE'];
            //s.value__c='all';
            //update s;
        }
        catch(Exception e)
        {
        	s = new Systemsettings__c(name='EAST_REST_SVC_JSON_SAVE', value__c ='all');
        	insert s;
        }
        Systemsettings__c s2 = new Systemsettings__c(name='BU_REST_LOG_FOLDER', value__c ='BulgariaLogs');
        insert s2;
        
        System.debug(Limits.getQueries());
        system.debug('enter log');
     
        REST_SendLogicalEntityTrialEast.REST_SendLogicalEntityTrial params = new REST_SendLogicalEntityTrialEast.REST_SendLogicalEntityTrial();
        params.statuscode=null;
        params.statusDescription='';
        params.trials = new list<REST_SendLogicalEntityTrialEast.REST_TrialObject>();
    
        for(Integer i=0; i< Test_REST_DataFactoryEast.regPerEntity; i++){
            REST_SendLogicalEntityTrialEast.REST_TrialObject rclis = new REST_SendLogicalEntityTrialEast.REST_TrialObject();
            rclis.action='Insert';
            rclis.GroupIdIdDevice=100+i;    
            rclis.trial=new CampaignLineItem__c(
                   CampaignRef__c=Test_REST_DataFactoryEast.ca.id,
                   FarmRef__c=Test_REST_DataFactoryEast.aList.get(i).id,
                   ProductRef__c=Test_REST_DataFactoryEast.pList.get(1).id,
                   ProductCatalogEntryRef__c=Test_REST_DataFactoryEast.pceList.get(1).id, 
                   RecordTypeId=Util.recordType.get('CampaignLineItem__c:Trial'),  
                   Yield__c=100+i,
                   idDevice__c=200+i);      
          params.trials.add(rclis);}    
          
        Test_REST_DataFactoryEast.tList.clear();
        Test.stopTest();
        
        Test_REST_DataFactoryEast.tList = [SELECT ID,CampaignRef__c,FarmRef__c,ProductRef__c,ProductCatalogEntryRef__c,RecordTypeId,Yield__c,idDevice__c, LastModifiedDate
                FROM CampaignLineItem__c 
                WHERE RecordTypeId=:Util.recordType.get('CampaignLineItem__c:Trial')];
        
        for(Integer i=0; i<Test_REST_DataFactoryEast.regPerEntity; i++){
            REST_SendLogicalEntityTrialEast.REST_TrialObject rclis = new REST_SendLogicalEntityTrialEast.REST_TrialObject();
                if(Math.mod(i,2)==0) rclis.action='Update';
                    else rclis.action='Delete';
            rclis.GroupIdIdDevice=0; 
            rclis.LastModifiedDate=system.now();   
            rclis.trial=Test_REST_DataFactoryEast.tList.get(i);   
            params.trials.add(rclis);}   


        params.groups = new list<REST_SendLogicalEntityTrialEast.REST_GroupObject>(); 
        REST_SendLogicalEntityTrialEast.REST_GroupObject rCLI;
    
        for(Integer i=0; i<Test_REST_DataFactoryEast.regPerEntity;i++){
            rCLI = new REST_SendLogicalEntityTrialEast.REST_GroupObject();     
            rCLI.action='Insert'; 
                rCLI.cligroup=new CampaignLineItemGroup__c(
                  AccountRef__c=Test_REST_DataFactoryEast.aList.get(i).id,
                  CampaignRef__c=Test_REST_DataFactoryEast.ca.id,
                  Comments__c='Test Trial'+String.valueof(i),
                  HarvestedBy__c='TD',  
                  Latitude__c='100',
                  Longitude__c='100',
                  RecordTypeId='012D000000035B0IAI',
                  Status__c='ongoing', 
                  Type__c='Demo',
                  idDevice__c=100+i);    
            params.groups.add(rCLI);}
 
        Test_REST_DataFactoryEast.gList.clear();
    
        Test_REST_DataFactoryEast.gList = [ SELECT Id,AccountRef__c,CampaignRef__c,Comments__c,HarvestedBy__c,Latitude__c,Longitude__c,RecordTypeId,Status__c,Type__c,LastModifiedDate
                  FROM CampaignLineItemGroup__c];
           
        for(Integer i=0;i<Test_REST_DataFactoryEast.regPerEntity;i++){
            rCLI = new REST_SendLogicalEntityTrialEast.REST_GroupObject();     
            rCLI.action='Update'; 
            rCLI.LastModifiedDate=system.now();
            rCLI.cligroup=Test_REST_DataFactoryEast.gList.get(i);               
            params.groups.add(rCLI);}   
      
        REST_SendLogicalEntityTrialEast.REST_SendLogicalEntityTrial outTrial=REST_SendLogicalEntityTrialEast.sendTrials(params);    
        /*System.assertEquals(100,outTrial.statusCode);
        for(REST_SendLogicalEntityTrialEast.REST_GroupObject rgo : outTrial.groups){
          System.assertEquals(100,rgo.statusCode);}   
    
        for(REST_SendLogicalEntityTrialEast.REST_TrialObject rto : outTrial.trials){
          System.assertEquals(100,rto.statusCode);}*/
        
    }
    public static testmethod void PrevDel(){
    
        User u = new User(Id=Userinfo.getUserId(), CountryISOCode__c='BU');
        update u;
        system.debug('va a buscar: '+Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER');
        
        Test.startTest();
        Test_REST_DataFactoryEast.TestData();
        Systemsettings__c s;
        try{
        	List<Systemsettings__c> mcs = Systemsettings__c.getall().values();
            mcs[0].value__c = 'all';
            update mcs;
            //s = [SELECT id, value__c from Systemsettings__c where name='EAST_REST_SVC_JSON_SAVE'];
            //s.value__c='all';
            //update s;
        }
        catch(Exception e)
        {
        	s = new Systemsettings__c(name='EAST_REST_SVC_JSON_SAVE', value__c ='all');
        	insert s;
        }
        Systemsettings__c s2 = new Systemsettings__c(name='BU_REST_LOG_FOLDER', value__c ='BulgariaLogs');
        insert s2;
        
        System.debug(Limits.getQueries());
        system.debug('enter log');
     	
        CampaignLineitem__c TriTest= new CampaignLineItem__c(
                   CampaignRef__c=Test_REST_DataFactoryEast.ca.id,
                   FarmRef__c=Test_REST_DataFactoryEast.Farm.id,
                   ProductRef__c=Test_REST_DataFactoryEast.pList.get(1).id,
                   ProductCatalogEntryRef__c=Test_REST_DataFactoryEast.pceList.get(1).id, 
                   RecordTypeId=Util.recordType.get('CampaignLineItem__c:Trial'),  
                   Yield__c=100,
                   idDevice__c=200);
        insert TriTest;           
        CampaignLineItemGroup__c CLITest= new CampaignLineItemGroup__c(
                  AccountRef__c=Test_REST_DataFactoryEast.Farm.id,
                  CampaignRef__c=Test_REST_DataFactoryEast.ca.id,
                  Comments__c='Test Trial',
                  HarvestedBy__c='TD',  
                  Latitude__c='100',
                  Longitude__c='100',
                  RecordTypeId='012D000000035B0IAI',
                  Status__c='ongoing', 
                  Type__c='Demo',
                  idDevice__c=100); 
        insert CLItest;     
     
        REST_SendLogicalEntityTrialEast.REST_SendLogicalEntityTrial params = new REST_SendLogicalEntityTrialEast.REST_SendLogicalEntityTrial();
        params.statuscode=null;
        params.statusDescription='';
        params.trials = new list<REST_SendLogicalEntityTrialEast.REST_TrialObject>();
        params.groups = new list<REST_SendLogicalEntityTrialEast.REST_GroupObject>();
        
        REST_SendLogicalEntityTrialEast.REST_TrialObject rclis = new REST_SendLogicalEntityTrialEast.REST_TrialObject();
        rclis.action='Update';
        rclis.GroupIdIdDevice=100;    
        rclis.trial= TriTest;
        params.trials.add(rclis);
         
        REST_SendLogicalEntityTrialEast.REST_GroupObject rCLI = new REST_SendLogicalEntityTrialEast.REST_GroupObject();     
        rCLI.action='Update'; 
        rCLI.cligroup=CLITest;    
        params.groups.add(rCLI);
        
        Test.stopTest();
        
        delete CLITest;
        delete TriTest;
        
        REST_SendLogicalEntityTrialEast.REST_SendLogicalEntityTrial outTrial=REST_SendLogicalEntityTrialEast.sendTrials(params);    
        System.assertEquals(201, outTrial.statusCode);
        for(REST_SendLogicalEntityTrialEast.REST_GroupObject rgo : outTrial.groups){
          System.assertEquals(201,rgo.statusCode);}   
    
        for(REST_SendLogicalEntityTrialEast.REST_TrialObject rto : outTrial.trials){
          System.assertEquals(201,rto.statusCode);}
          
    }
        public static testmethod void Mismatch(){
    
        User u = new User(Id=Userinfo.getUserId(), CountryISOCode__c='BU');
        update u;
        system.debug('va a buscar: '+Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER');
        
        Test.startTest();
        Test_REST_DataFactoryEast.TestData();
        Systemsettings__c s;
        try{
        	List<Systemsettings__c> mcs = Systemsettings__c.getall().values();
            mcs[0].value__c = 'all';
            update mcs;
            //s = [SELECT id, value__c from Systemsettings__c where name='EAST_REST_SVC_JSON_SAVE'];
            //s.value__c='all';
            //update s;
        }
        catch(Exception e)
        {
        	s = new Systemsettings__c(name='EAST_REST_SVC_JSON_SAVE', value__c ='all');
        	insert s;
        }
        Systemsettings__c s2 = new Systemsettings__c(name='BU_REST_LOG_FOLDER', value__c ='BulgariaLogs');
        insert s2;
        
        System.debug(Limits.getQueries());
        system.debug('enter log');
        CampaignLineitem__c TriTest= new CampaignLineItem__c(
                   CampaignRef__c=Test_REST_DataFactoryEast.ca.id,
                   FarmRef__c=Test_REST_DataFactoryEast.Farm.id,
                   ProductRef__c=Test_REST_DataFactoryEast.pList.get(1).id,
                   ProductCatalogEntryRef__c=Test_REST_DataFactoryEast.pceList.get(1).id, 
                   RecordTypeId=Util.recordType.get('CampaignLineItem__c:Trial'),  
                   Yield__c=100,
                   idDevice__c=200);
        insert TriTest;           
        CampaignLineItemGroup__c CLITest= new CampaignLineItemGroup__c(
                  AccountRef__c=Test_REST_DataFactoryEast.Farm.id,
                  CampaignRef__c=Test_REST_DataFactoryEast.ca.id,
                  Comments__c='Test Trial',
                  HarvestedBy__c='TD',  
                  Latitude__c='100',
                  Longitude__c='100',
                  RecordTypeId='012D000000035B0IAI',
                  Status__c='ongoing', 
                  Type__c='Demo',
                  idDevice__c=100); 
        insert CLItest;   
     
        REST_SendLogicalEntityTrialEast.REST_SendLogicalEntityTrial params = new REST_SendLogicalEntityTrialEast.REST_SendLogicalEntityTrial();
        params.statuscode=null;
        params.statusDescription='';
        params.trials = new list<REST_SendLogicalEntityTrialEast.REST_TrialObject>();
        params.groups = new list<REST_SendLogicalEntityTrialEast.REST_GroupObject>();
        
        REST_SendLogicalEntityTrialEast.REST_TrialObject rclis = new REST_SendLogicalEntityTrialEast.REST_TrialObject();
        rclis.action='Update';
        rclis.GroupIdIdDevice=100;    
        rclis.trial= TriTest;
        params.trials.add(rclis);
         
        REST_SendLogicalEntityTrialEast.REST_GroupObject rCLI = new REST_SendLogicalEntityTrialEast.REST_GroupObject();     
        rCLI.action='Update'; 
        rCLI.cligroup=CLITest;    
        params.groups.add(rCLI);
        
        Test.stopTest();
        
        update CLITest;
        update TriTest;
        
        REST_SendLogicalEntityTrialEast.REST_SendLogicalEntityTrial outTrial=REST_SendLogicalEntityTrialEast.sendTrials(params);    
        System.assertEquals(200, outTrial.statusCode);
        for(REST_SendLogicalEntityTrialEast.REST_GroupObject rgo : outTrial.groups){
          System.assertEquals(200,rgo.statusCode);}   
    
        for(REST_SendLogicalEntityTrialEast.REST_TrialObject rto : outTrial.trials){
          System.assertEquals(200,rto.statusCode);}
    }
        public static testmethod void Unknown(){
    
    	Test.startTest();
        Test_REST_DataFactoryEast.TestData();

        CampaignLineitem__c TriTest= new CampaignLineItem__c(
                   CampaignRef__c=Test_REST_DataFactoryEast.ca.id,
                   FarmRef__c=Test_REST_DataFactoryEast.Farm.id,
                   ProductRef__c=Test_REST_DataFactoryEast.pList.get(0).id,
                   ProductCatalogEntryRef__c=Test_REST_DataFactoryEast.pceList.get(0).id, 
                   RecordTypeId=Util.recordType.get('CampaignLineItem__c:Trial'),  
                   Yield__c=100,
                   idDevice__c=200);
        insert TriTest;           
        CampaignLineItemGroup__c CLITest= new CampaignLineItemGroup__c(
                  AccountRef__c=Test_REST_DataFactoryEast.Farm.id,
                  CampaignRef__c=Test_REST_DataFactoryEast.ca.id,
                  Comments__c='Test Trial',
                  HarvestedBy__c='TD',  
                  Latitude__c='100',
                  Longitude__c='100',
                  RecordTypeId='012D000000035B0IAI',
                  Status__c='ongoing', 
                  Type__c='Demo',
                  idDevice__c=100); 
        insert CLItest;   
     
        REST_SendLogicalEntityTrialEast.REST_SendLogicalEntityTrial params = new REST_SendLogicalEntityTrialEast.REST_SendLogicalEntityTrial();
        params.statuscode=null;
        params.statusDescription='';
        params.trials = new list<REST_SendLogicalEntityTrialEast.REST_TrialObject>();
        params.groups = new list<REST_SendLogicalEntityTrialEast.REST_GroupObject>();
        
        REST_SendLogicalEntityTrialEast.REST_TrialObject rclis = new REST_SendLogicalEntityTrialEast.REST_TrialObject();
        rclis.action='Insert';
        rclis.GroupIdIdDevice=100;    
        rclis.trial= TriTest;
        params.trials.add(rclis);
         
        REST_SendLogicalEntityTrialEast.REST_GroupObject rCLI = new REST_SendLogicalEntityTrialEast.REST_GroupObject();     
        rCLI.action='Insert'; 
        rCLI.cligroup=CLITest;    
        params.groups.add(rCLI);
        
        Test.stopTest();
        
        update CLITest;
        update TriTest;
        
        REST_SendLogicalEntityTrialEast.REST_SendLogicalEntityTrial outTrial=REST_SendLogicalEntityTrialEast.sendTrials(params);    
        System.assertEquals(999, outTrial.statusCode);
        for(REST_SendLogicalEntityTrialEast.REST_GroupObject rgo : outTrial.groups){
          System.assertEquals(999,rgo.statusCode);}   
    
        for(REST_SendLogicalEntityTrialEast.REST_TrialObject rto : outTrial.trials){
          System.assertEquals(998,rto.statusCode);}
    }    
   
}