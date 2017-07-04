public with sharing class Contactx implements AccountListObjectWrapper
{
    public Contact record {get; set;}
    public boolean checked {get; set;}


    public Contactx()
    {
        record = new Contact(OwnerId = UserInfo.getUserId());
    }

    public Contactx( Contact record )
    {
        this();
        this.record = record;
    }

    public Contactx( String accountId )
    {
        this();
        this.record.AccountId = accountId;
    }

    public List<sObject> getFilledRecords()
    {
        List<Contact> contacts = new List<Contact>();

        if( record.Lastname != null )
        {
            contacts.add( record );
        }

        return contacts;
    }
    public List<sObject> getSelectedRecords()
    {
        List<Contact> contacts = new List<Contact>();

        if( checked != null && checked ) contacts.add( record );

        return contacts;
    }
}