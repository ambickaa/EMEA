@isTest
private class ObservationSheetTest {
 
@isTest static void test1() {

        Country__c TestCountry= new Country__c(Name='Hungary', TacticalPlanSetting__c='Generic', DE_EnableAccountSharing__c=true);
        insert TestCountry;
        Division__c TestDivision= new Division__c();
        insert TestDivision;
        
        User TestCoach=new User( Alias='O01234', Email='testcoach@test.com',Username='testcoach@test.com', LastName='TESTCOACH', TimeZoneSidKey='Europe/Berlin',LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',ProfileId='00eD00000012mS4', LanguageLocaleKey='en_US', 
        Division='S&T', StandardDivision__c='Corn', Country='Hungary', CountryISOCode__c='HU', isActive=true );
        insert TestCoach;
        
        User TestCoachee=new User( Alias='O56789', Email='testcoachee@test.com',Username='testcoachee@test.com', LastName='TESTCOACHEE', TimeZoneSidKey='Europe/Berlin',LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',ProfileId='00eD00000012jpu', LanguageLocaleKey='en_US',
        Division='S&T', StandardDivision__c='Corn', Country='Hungary', CountryISOCode__c='HU', isActive=true, ManagerId=TestCoach.Id);
        insert TestCoachee;

		System.runAs(TestCoach) {
			Observation_Sheet__c Obs = new Observation_Sheet__c(Coach__c = UserInfo.getUserId(), Coachee__c = TestCoachee.Id);
			insert Obs;
		}
}

}