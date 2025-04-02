global class generateToken {
	@AuraEnabled
    webservice static String getToken(String sapId)
    {
        system.debug('sapId '+sapId);
        // generate Time Token
        DateTime myDateTime = DateTime.now();
        system.debug(myDateTime.getTime());
        Blob key = EncodingUtil.base64Decode(Label.studentZone_PrivateKey); // privateKey
        Blob data = Blob.valueOf(sapId+'~'+myDateTime.getTime());
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key, data);
        String token = EncodingUtil.base64Encode(encryptedData);
        String urlEncodedToken = EncodingUtil.urlEncode(token, 'UTF-8');
        urlEncodedToken = EncodingUtil.urlDecode(urlEncodedToken, 'UTF-8');
        system.debug('urlEncodedToken '+urlEncodedToken);
        return urlEncodedToken;
    }

}