public with sharing class AccountListContactController extends AccountListVirtualController
{
    public AccountListContactController()
    {
        // Initialization standard factory for contacts
        ContactxFactory tempFactory = new ContactxFactory();
        jumperTag = 'AccountContactList';
        mode = 'contactEdit';
        fieldSetManager = new FieldSetMemberxManager(Schema.SObjectType.Contact, jumperTag);
         for(String s : fieldSetManager.getSOQLFields())
        {
            tempFactory.selectFields.add(s);
        }
        
        objectFactory = tempFactory;
    }

    // getter for contacts used by component
    public List<Contactx> getContacts()
    {
        return ( List<Contactx> ) wrapperObjects;
    }
    
    public static boolean getisAccountOwner()
    {
      return Util.isAccountOwner;
    }
}