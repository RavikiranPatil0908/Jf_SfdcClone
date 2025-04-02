/**
 * @File Name          : Encryption.cls
 * @Description        : 
 * @Author             : Balakrishnan
 * @Group              : 
 * @Last Modified By   : Balakrishnan
 * @Last Modified On   : 26/3/2019, 12:45:01 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    26/3/2019, 12:23:19 PM   Balakrishnan     Initial Version
**/
public interface Encryption {

	
	/**
	* @description
	* @author Balakrishnan | 26/3/2019
	* @param ;
	* @return String
	*/
	String encrypt(String data, String Key);

	/**
	* @description
	* @author Balakrishnan | 26/3/2019
	* @param ;
	* @return String
	*/
	String decrypt(String toDecrypt, String key);
}