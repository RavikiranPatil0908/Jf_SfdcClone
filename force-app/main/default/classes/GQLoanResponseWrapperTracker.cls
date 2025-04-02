/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-11-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class GQLoanResponseWrapperTracker {

    @isTest
    static void testParse() {
		String json=		'{'+
		'   "success": true,'+
		'   "status_code": 201,'+
		'   "message": "Application Created successfully",'+
		'   "data": {'+
		'       "redirection_url": "https://rapid.graydev.tech/anand-ay?sbdc=e756c865-51ca-40f4-a9a0-cf5efcc951ef&uid=6e898686-59c0-434e-875f-558c82e869e8"'+
		'   }'+
		'}';

        GQLoanResponseWrapper obj = GQLoanResponseWrapper.parse(json);
		System.assert(obj != null, 'Wrapper Should not be Blank');
	}
}