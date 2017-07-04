@isTest

public class Test_VFC_QueueMemberAssignController{
   
    public static testMethod void Test_VFC_QueueMemberAssignController() { 
    
        Test.setCurrentPage(Page.VFP_QueueMemberAssignController);
        Profile p = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        
        User u = new User(Alias = 'standt', Email='testprofile@testorg.com', 
                EmailEncodingKey='UTF-8',firstName='test', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='testprofile@testorg.com');

        insert u;
        
        User u2 = new User(Alias = 'standt', Email='testprofile2@testorg.com', 
                EmailEncodingKey='UTF-8',firstName='test', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='testprofile2@testorg.com');

        insert u2;

        system.runAs(u)
        {
                Test.Starttest();
            VFC_QueueMemberAssignController controller = new VFC_QueueMemberAssignController();
            controller.getIsMemberOfRole();
            Controller.groupUsers=new List<User>();
            Controller.isMemberOfRole=true;
            controller.addUserToGroup();
            controller.userIdToRemove = null;
            controller.removeUserFromGroup();
            Group g1= new Group(Name='test group', Type='Queue');
            insert g1;
            system.debug('1+++ group :: g1' + g1);
             controller.selectedGroupId = g1.id;
           system.debug('2+++ controller.selectedGroupId = g1.id;' + g1.id);
            
            Group g2= new Group(Name='test group1', Type='Queue');
            insert g2;
    
            Group g3= new Group(Name='test group2', Type='Queue');
            insert g3;
            
            List<QueuesObject> lstque = new List<QueuesObject>();
            QueuesObject testQueue = new QueueSObject(QueueID = g1.id, SObjectType = 'Case');
            lstque.add(testQueue);
            QueuesObject testQueue1 = new QueueSObject(QueueID = g2.id, SObjectType = 'Case');
            lstque.add(testQueue1);

            QueuesObject testQueue2 = new QueueSObject(QueueID = g3.id, SObjectType = 'Case');
            lstque.add(testQueue2);
            
            insert lstque;
        
        GroupMember gm1= new GroupMember(groupId =g1.id,UserOrGroupId=u.id);
        insert gm1;
          
        controller.addUserToGroup();
        controller.userIdToRemove = u.id;
        controller.memberToAdd = gm1;

        controller.refresh();
        controller.addUserToGroup();
            
        controller.removeUserFromGroup();   
        controller.getGroupOptions();
        controller.getUserById(u.id);
        
        
        
        controller.selectedGroupId =null;
        controller.removeUserFromGroup();
        controller.addUserToGroup();
        
        
        test.stopTest();

    }
    }
    
    public static testMethod void Test_VFC_QueueMemberAssignController2() 
    {
        Test.setCurrentPage(Page.VFP_QueueMemberAssignController);
        Profile p = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        
        User u = new User(Alias = 'standt', Email='testprofile@testorg.com', 
                EmailEncodingKey='UTF-8',firstName='test', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='testprofile@testorg.com');

        insert u;
        
        User u2 = new User(Alias = 'standt', Email='testprofile2@testorg.com', 
                EmailEncodingKey='UTF-8',firstName='test', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='testprofile2@testorg.com');

        insert u2;
        system.runAs(u)
        {       
            Test.Starttest();
            Test.setCurrentPage(Page.VFP_QueueMemberAssignController);
            VFC_QueueMemberAssignController controller = new VFC_QueueMemberAssignController();
            controller.userIdToRemove = null;
            controller.removeUserFromGroup();         
            List<Group> g1List= new List<Group>();
            Group g1= new Group();
            g1.Name='test group';
            g1.Type='Queue';
            g1List.add(g1);
            insert g1List;  
            controller.selectedGroupId = g1.id;
             controller.removeUserFromGroup();   
            controller.selectedgroup=g1List[0];
            Controller.groupUsers=new List<User>();
            Controller.selectedGroup=g1;
            system.assertEquals(false,g1List.isEmpty());
            test.stopTest();
        }
    }

}