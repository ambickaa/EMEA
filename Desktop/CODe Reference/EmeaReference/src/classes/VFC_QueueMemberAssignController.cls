public class VFC_QueueMemberAssignController{

    public ID selectedGroupId { get; set; }  
     public Boolean isMemberOfRole
{ set; } 
    public Group selectedGroup {
        get {
            return [SELECT id, name from Group 
                    where id = :selectedGroupId];
        }
        set;
    }

    public GroupMember memberToAdd { get; set; }
    public ID userIdToRemove { get; set; }
    public Set<Id> groupIds = new Set<Id>();

    public List<User> groupUsers{
        get {
            return new List<User>([SELECT id, firstName, lastName, username, email, isActive
                                   from User where Id IN ( SELECT userOrGroupId FROM groupmember WHERE groupId = :selectedGroupId )
                                   AND
                                   isActive = true
                                   ORDER BY firstName]);
        }
        set;
    }

    public VFC_QueueMemberAssignController() {
        selectedGroupId = ApexPages.currentPage().getParameters().get('selectedGroupId');
        memberToAdd = new GroupMember(); 
    }
       
     // Returns whether the current user is in a certain Role or not
public Boolean getIsMemberOfRole()
    {
        if(UserInfo.getUserRoleId() != null)
        {
            UserRole g = [SELECT id, Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId()];
            

            
                if(g.name == System.Label.CS_Repren)
                    return false; 
            
        }
        return true;
    }      


    public PageReference refresh() {
        return null;
    }

    public PageReference addUserToGroup() {
        if (String.isBlank( selectedGroupId ) ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please choose a queue' ) );
            return null;
        }
        if (memberToAdd == null || String.isBlank( memberToAdd.userOrGroupId ) ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please choose a user' ) );
            return null;
        }       
        
        List<GroupMember> members = new List<GroupMember>([Select id from groupmember where groupId = :selectedGroupId
                                                          and userOrGroupId =: memberToAdd.userOrGroupId]);
        if (members.size()>0) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'User is already present in queue' ) );
        } else{       
        GroupMember gm = new GroupMember(groupId = selectedGroupId, userOrGroupId = memberToAdd.userOrGroupId);      
        insert gm;
        User user = getUserById(memberToAdd.userOrGroupId );
        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.CONFIRM, user.name + ' added to queue!' ) );
        memberToAdd = new GroupMember();
        } 
        return null;
    }

    public PageReference removeUserFromGroup() {
        if ( String.isblank( selectedGroupId ) ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please choose a queue' ) );
            return null;
        }

        if ( String.isblank( userIdToRemove ) ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please choose a user' ) );
            return null;
        }
       
        List<GroupMember> members = new List<GroupMember>([Select id from groupmember where groupId = :selectedGroupId
                                                            AND userOrGroupId = :userIdToRemove]);
            if (!members.isEmpty() ) {
                delete members;
        }

        User user = getUserById( userIdToRemove );
        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.CONFIRM, user.name + ' removed from queue!' ) );
        userIdToRemove = null;
        return null; 
    }

    public List<SelectOption> getGroupOptions() {

        List<SelectOption> options = new List<SelectOption>();

        options.add( new SelectOption( '', '- Select -' ) );
        for ( Group grp : [SELECT id, name from group where type = 'Queue'
                           AND ( NOT name LIKE '%(inactive)%' ) ORDER BY name]) {
            options.add( new SelectOption( grp.id, grp.name ) );
        }
        return options;
    }

    public User getUserById(ID userId ) {
        return [ SELECT id, name FROM user WHERE id = :userId ];
    }
    
}