@isTest
private class Test_PDP_TabTxtFileController{
        

    @isTest
    static void init()
    {
    
     User SysAdmin=new User( Alias='SYSADMI', Email='everis.salesforce24@gmail.com',Username='testAS4C2jseoanem@everis.com', LastName='test123', TimeZoneSidKey='Europe/Prague',LocaleSidKey='en_ZA',EmailEncodingKey='ISO-8859-1',UserRoleId='00ED0000000tBNCMA2',ProfileId='00eD0000001lv5NIAQ', LanguageLocaleKey='es', 
       Division='S&T', StandardDivision__c='Corn', Country='Spain', isActive=true, OrderPrefix_RSA__c='BIN');
     	insert SysAdmin;
     
       User UserTest2=new User( Alias='LEVEL2', Email='everis.salesforce4@gmail.com',Username='testASC4jsem@everis.com', LastName='test123', TimeZoneSidKey='Europe/Prague',LocaleSidKey='en_ZA',EmailEncodingKey='ISO-8859-1',UserRoleId='00ED0000000tJ8yMAE',ProfileId='00eD00000012lqkIAA', LanguageLocaleKey='es', 
       Division='S&T', StandardDivision__c='Corn', Country='Spain', isActive=true,   SAP_Partner_Code__c='22222', OrderPrefix_RSA__c='BIN');
       User UserTest3=new User( Alias='LEVEL3', Email='everis.salesforce3@gmail.com',Username='testASC3jsanem@everis.com', LastName='test123', TimeZoneSidKey='Europe/Prague',LocaleSidKey='en_ZA',EmailEncodingKey='ISO-8859-1',UserRoleId='00ED0000000tJ8yMAE',ProfileId='00eD00000012lqkIAA', LanguageLocaleKey='es', 
       Division='S&T', StandardDivision__c='Corn', Country='Spain', isActive=true,  SAP_Partner_Code__c='33333',  OrderPrefix_RSA__c='BIN');       
       User UserTest4=new User( Alias='LEVEL4A', Email='everis.salesforce1@gmail.com',Username='testASC1jsem@everis.com', LastName='test123', TimeZoneSidKey='Europe/Prague',LocaleSidKey='en_ZA',EmailEncodingKey='ISO-8859-1',UserRoleId='00ED0000000tJ8yMAE',ProfileId='00eD00000012lqkIAA', LanguageLocaleKey='es', 
       Division='S&T', StandardDivision__c='Corn', Country='Spain', isActive=true,  SAP_Partner_Code__c='44444',  OrderPrefix_RSA__c='BIN');
       User UserTest5=new User( Alias='LEVEL4B', Email='everis.salesforce2@gmail.com',Username='testASC2jsnem@everis.com', LastName='test123', TimeZoneSidKey='Europe/Prague',LocaleSidKey='en_ZA',EmailEncodingKey='ISO-8859-1',UserRoleId='00ED0000000tJ8yMAE',ProfileId='00eD00000012lqkIAA', LanguageLocaleKey='es', 
       Division='S&T', StandardDivision__c='Corn', Country='Spain', isActive=true,	SAP_Partner_Code__c='55555',  OrderPrefix_RSA__c='BIN');
      
       List<User> Users2Update= new List<User>();
        Users2Update.add(UserTest2);
        insert  Users2Update;
  	
       System.runAs(SysAdmin)
       {
          PDPCountryGroup__c cg1 = new PDPCountryGroup__c( Name='PDP_ES',  Repeat_L1__c=true, Repeat_L2__c=false, Repeat_L3__c=true, Country_LVL_2__c=false, Grouping__c='A', SAP_Country_Code__c='777771');
          PDPCountryGroup__c cg3 = new PDPCountryGroup__c( Name='PDP_HU',  Repeat_L1__c=true, Repeat_L2__c=false, Repeat_L3__c=true, Country_LVL_2__c=false, Grouping__c='A', SAP_Country_Code__c='777772');
          PDPCountryGroup__c cg4 = new PDPCountryGroup__c( Name='PDP_AK',  Repeat_L1__c=true, Repeat_L2__c=false, Repeat_L3__c=true, Country_LVL_2__c=false, Grouping__c='A', SAP_Country_Code__c='777779');   
          PDPCountryGroup__c cg2 = new PDPCountryGroup__c( Name='PDP_PT',  Repeat_L1__c=true, Repeat_L2__c=false, Repeat_L3__c=true, Country_LVL_2__c=true, Grouping__c='A', SAP_Country_Code__c='777778');
       

	       insert cg2;         
      
			UserTest2.PDP_LVL_1__c='PDP_PT';
			UserTest2.PDP_Level__c='PDP Level 2';
			UserTest3.PDP_LVL_1__c='PDP_PT';
			UserTest3.PDP_Level__c='PDP Level 3';
			UserTest3.PDP_Manager__c=UserTest2.Id;
			UserTest4.PDP_LVL_1__c='PDP_PT';
			UserTest4.PDP_Level__c='PDP Level 4';
			UserTest4.PDP_Manager__c=UserTest3.Id;
			UserTest5.PDP_LVL_1__c='PDP_PT';
			UserTest5.PDP_Level__c='PDP Level 4';
			UserTest5.PDP_Manager__c=UserTest3.Id;
			TriggerUserPDPValidateFields.fromTest=true;
			
			update UserTest2;

			insert cg3;
			insert cg4;
			cg4.Name='PDP_AX';
			update cg4;
			delete cg4;
			
		               
      }
}}