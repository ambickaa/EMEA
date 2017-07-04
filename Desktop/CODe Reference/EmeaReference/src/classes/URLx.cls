public class URLx
{
    // returns a url to custom redirect. Input url will be set as a url parameter
    public static PageReference setURL( String url )
    {
        url = EncodingUtil.urlEncode( url, 'utf-8' );
        PageReference p = new PageReference( '/apex/customRedirect?param='+url );
        return p;
    }
}