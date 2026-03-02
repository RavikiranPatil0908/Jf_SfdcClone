/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 26--02--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   24--02--2026   @Ravi   Initial Version
**/
public class AESUtil {


/**
* @description 
* @author @Ravi | 26--02--2026 
* @param Long randomLong 
* @return Blob 
**/
public static Blob getKey(Long randomLong) {
        Long multiplier = Math.abs(Math.mod(randomLong, 10));
        if (multiplier == 0) multiplier = 9;

        String output = String.valueOf(randomLong * multiplier);
        String finalKeyStr = (output + output).substring(0, 16);
        
        return Blob.valueOf(finalKeyStr);
    }

    /**
    * @description Generates the 16-byte IV based on the randomLong logic
    * @author @Ravi | 26--02--2026 
    * @param Long randomLong 
    * @return Blob 
    **/
    public static Blob getIV(Long randomLong) {
        String s = String.valueOf(randomLong);
        // (randomLong + randomLong).substring(0, 16)
        String ivStr = (s + s).substring(0, 16);
        
        return Blob.valueOf(ivStr);
    }

    /**
    * @description Encrypts the plaintext using AES-128 CBC PKCS7 
    * @author @Ravi | 26--02--2026 
    * @param String payload 
    * @param Long randomLong 
    * @return String 
    **/
    public static String encryptAES(String payload, Long randomLong) {
          Blob key = getKey(randomLong);
        //  Blob key = Crypto.generateAesKey(128);
        Blob iv = getIV(randomLong);
        Blob data = Blob.valueOf(payload);

        // 'AES128' in Apex corresponds to 16-byte keys
        Blob encrypted = Crypto.encrypt('AES128', key, iv, data);
        
        // Return 
        return EncodingUtil.base64Encode(encrypted);
    }

    /**
    * @description 
    * @author @Ravi | 26--02--2026 
    * @param String CpherText 
    * @param Long randomLong 
    * @return String 
    **/
    public static String decryptAES(String CpherText, Long randomLong) {
        Blob key = getKey(randomLong);
        Blob iv = getIV(randomLong);
        Blob data = EncodingUtil.base64Decode(CpherText);

        Blob decrypted = Crypto.decrypt('AES128', key, iv, data);
        return decrypted.toString();
    }

}