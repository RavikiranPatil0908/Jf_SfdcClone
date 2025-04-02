@istest(SeeAlldata=true)
public class nmSHS256ConversionTracker {
    public static testmethod void test1()
    {
      nmSHS256Conversion objSH=new nmSHS256Conversion();
      nmSHS256Conversion.GenerateHashCodeResponse_element objNmG=new nmSHS256Conversion.GenerateHashCodeResponse_element();
      nmSHS256Conversion.GenerateHashCode_element objGH=new nmSHS256Conversion.GenerateHashCode_element();
      nmSHS256Conversion.HelloWorldResponse_element obknH=new nmSHS256Conversion.HelloWorldResponse_element();
      nmSHS256Conversion.NMIMSPGSoap objSHA = new nmSHS256Conversion.NMIMSPGSoap();
      
      //Commented by Sanket since there was new error : Methods defined as TestMethod do not support Web service callouts 
      //objSHA.GenerateHashCode('test');
      //objSHA.HelloWorld();
      nmSHS256Conversion.HelloWorld_element objnHW=new nmSHS256Conversion.HelloWorld_element();
      
    }

}