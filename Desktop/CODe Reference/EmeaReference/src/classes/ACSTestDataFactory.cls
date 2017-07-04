@isTest
public class ACSTestDataFactory {
    
    //Method to generate Admin Email Group custom setting
    public static List<AdminEmailGroup__c> generateAdminEmailGroup(Integer count)
    {
        List<AdminEmailGroup__c> listOfAdminEmailGroup = new List<AdminEmailGroup__c>();
        for(Integer iterator = 0;iterator < count;iterator++)
        {
            AdminEmailGroup__c newAdminEmailGroup = new AdminEmailGroup__c();
            newAdminEmailGroup.Name = 'Test ' + iterator;
            newAdminEmailGroup.Email__c = 'test' + iterator + '@test.com';
            listOfAdminEmailGroup.add(newAdminEmailGroup);
        }
        return listOfAdminEmailGroup;
    }

}