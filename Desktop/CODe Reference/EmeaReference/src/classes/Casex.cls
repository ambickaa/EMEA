public class Casex  implements AccountListObjectWrapper
{
    public Case record {get; set;}
    public String id {get; set;}
    public boolean checked {get; set;}
    public LookupValue lookupValue {get; set;}
    
    public List<CaseComment> commentList
    {
        get
        {
            if (commentList == null)
            {
                readComments();
            }
            return commentList;
        }
        set;
    }
    public List<Attachment> attachmentList
    {
        get
        {
            if (attachmentList == null)
            {
                attachmentList = readAttachments();
            }
            return attachmentList;
        }
        set;
    }

    public Casex()
    {
        record = new Case();
    }

    public Casex( String accountId )
    {
        this();
        this.record.AccountId = accountId;
        this.lookupValue = new LookupValue(null, 'Please select');
    }

    public Casex( Case record )
    {
        this();
        this.id = record.id;
        this.record = record;
        this.lookupValue = new LookupValue(record.GC_Product_SFID__c, record.GC_Product_SFID__r.Name);
    }

    public List<sObject> getSelectedRecords()
    {
        List<sObject> result = new List<sObject>();

        if( checked != null && checked )
        {
            result.add( record );
        }

        return result;
    }

    public List<sObject> getFilledRecords()
    {
        return null;
    }

    public void readComments()
    {
        if (record != null && record.id != null)
        {
            commentList = [Select c.IsPublished, c.IsDeleted, c.Id, c.CreatedDate,
                           c.CreatedBy.Name, c.CreatedBy.Id, c.CreatedById, c.CommentBody
                           From CaseComment c where c.ParentId = :record.id
                                   Order By CreatedDate desc];
        }
        else
        {
            commentList = null;
        }
    }

    private List<Attachment> readAttachments()
    {
        if (record != null && record.id != null)
        {
            // change this ;-)
            return [Select a.ParentId, a.Owner.Name, a.Owner.Id, a.OwnerId,
                    a.Name, a.LastModifiedDate, a.Id
                    From Attachment a where a.ParentId = :record.id
                            Order By CreatedDate desc];
        }
        else
        {
            return null;
        }
    }

}