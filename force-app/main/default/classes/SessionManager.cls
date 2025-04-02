/**
 * @description       : Manages user sessions using cookies and custom cache partition
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-09-2024
 * @last modified by  : @BK
**/
public class SessionManager {
    private Cache.OrgPartition objCache;
    private static final String PARTITION_NAME = 'local.StudentLogin';
    private static final Integer DEFAULT_SESSION_TIMEOUT_MINUTES = String.isNotBlank(System.Label.SessionTimeLimit) 
                                                                    ? Integer.valueOf(System.Label.SessionTimeLimit)
                                                                    : 30;

    public SessionManager() {
        objCache = Cache.Org.getPartition(PARTITION_NAME);
    }

    /**
     * @description Generates a random alphanumeric string of specified length.
     * @author @BK | 25-07-2024
     * @param len Length of the random string to generate.
     * @return Random alphanumeric string.
     **/
    public String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        
        if(objCache.contains(randStr)) {
            randStr = generateRandomString(50);
        }
        return randStr; 
    }

    /**
     * @description Logs in the user and creates a session.
     * @author @BK | 25-07-2024
     * @param recordId Id of the record associated with the session.
     * @param objectType Type of the object associated with the session.
     * @param mapOfUrlParams Map of URL parameters associated with the session.
     * @return Boolean indicating if login was successful.
     **/
    public Boolean loginSuccessFull(String recordId, String objectType, Map<String,String> mapOfUrlParams) {
        try {
            String ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
            String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');

            // Delete existing session of that student.
            Cookie sessionId = ApexPages.currentPage().getCookies().get('JSESSIONID');
            if (sessionId != null) {
                String sessionToken = sessionId.getValue();
                if (objCache.contains(sessionToken)) {
                    objCache.remove(sessionToken);
                }
            }

            // Generate Session Token
            String generatedSessionId = generateRandomString(50);

            // Set Session Params
            SessionUser objSession = new SessionUser();
            objSession.startTime = System.now();
            objSession.recordId = recordId;
            objSession.objType = objectType;
            objSession.mapOfParameters = mapOfUrlParams;
            objSession.ipAddress = ipAddress;
            objSession.userAgent = userAgent;
            objSession.timeLimit = DEFAULT_SESSION_TIMEOUT_MINUTES;
            objCache.put(generatedSessionId, objSession);

            // Set Cookies
            sessionId = new Cookie('JSESSIONID', generatedSessionId, null, objSession.timeLimit * 60, true, 'None');
            ApexPages.currentPage().setCookies(new Cookie[]{sessionId});

        } catch (Exception error) {
            System.debug('Exception during login: ' + error.getMessage());
            return false;
        }
        return true;
    }

    /**
    * @description Checks if a valid session is available
    * @author @BK | 25-07-2024 
    * @return SessionUser object indicating session availability and validity. 
    **/
    public SessionUser isSessionAvailable() {
        SessionUser objSessionUser = new SessionUser();
        objSessionUser.isVerified = false;
        try {
            String ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
            String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
            Cookie sessionId = ApexPages.currentPage().getCookies().get('JSESSIONID');

            if (sessionId == null) {
                clearSession();
                return objSessionUser;
            } 

            String sessionToken = sessionId.getValue();
            if (!objCache.contains(sessionToken)) {
                clearSession();
                return objSessionUser;
            }

            objSessionUser = (SessionUser) objCache.get(sessionToken);
            System.debug('Now ==>'+System.now());
            System.debug('Session Time ==>'+objSessionUser.timeLimit);
            System.debug('Session Start Time ==>'+objSessionUser.startTime);
            System.debug('Session minutes ==>'+objSessionUser.startTime.addMinutes(objSessionUser.timeLimit));
            System.debug('userAgent ==>'+objSessionUser.userAgent);
            System.debug('userAgent ==>'+userAgent);
            System.debug('ipAddress ==>'+objSessionUser.ipAddress);
            System.debug('ipAddress ==>'+ipAddress);
            if (objSessionUser.startTime.addMinutes(objSessionUser.timeLimit) <= System.now() || 
                !objSessionUser.userAgent.equals(userAgent)) {
                clearSession();
                return objSessionUser;
            } 

            objSessionUser.isVerified = true;
        } catch (Exception e) {
            System.debug('Exception during session check: ' + e.getMessage());
        }
        return objSessionUser;
    }


    /**
    * @description Clears the current session.
    * @author @BK | 23-05-2024  
    **/
    public void clearSession() {
        Cookie sessionId = ApexPages.currentPage().getCookies().get('JSESSIONID');
        if (sessionId != null) {
            String sessionToken = sessionId.getValue();
            if (String.isNotBlank(sessionToken) && objCache.contains(sessionToken)) {
                objCache.remove(sessionToken);
            }
            sessionId = new Cookie('JSESSIONID', null, null, 0, true, 'None');
            ApexPages.currentPage().setCookies(new Cookie[]{sessionId});
        }
    }


    /**
    * @description To add Additional details to Session
    * @author @BK | 09-02-2024 
    * @param mapOfParameters 
    **/
    public void updateSessionData(Map<String,String> mapOfParameters) {
        Cookie sessionId = ApexPages.currentPage().getCookies().get('JSESSIONID');
        if (sessionId != null) {
            String sessionToken = sessionId.getValue();
            if (String.isNotBlank(sessionToken) && objCache.contains(sessionToken)) {
                SessionUser objSessionUser = (SessionUser) objCache.get(sessionToken);
                objSessionUser.mapOfParameters = mapOfParameters;
                objCache.put(sessionToken, objSessionUser);
            }
        }
    }

    /**
    * @description 
    * @author @BK | 09-02-2024 
    * @return Map<String, String> 
    **/
    public Map<String,String> getSessionData() {
        Map<String,String> mapOfParameters = new Map<String,String>();
        Cookie sessionId = ApexPages.currentPage().getCookies().get('JSESSIONID');
        if (sessionId != null) {
            String sessionToken = sessionId.getValue();
            if (String.isNotBlank(sessionToken) && objCache.contains(sessionToken)) {
                SessionUser objSessionUser = (SessionUser) objCache.get(sessionToken);
                mapOfParameters = objSessionUser.mapOfParameters != null 
                    ? objSessionUser.mapOfParameters
                    : new Map<String,String>();
            }
        }
        return mapOfParameters;
    }
}