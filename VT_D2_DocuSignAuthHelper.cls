/**
* @author: Dmitry Prozorovskiy
* @date: 16-Nov-18
* @description: Used to get access tokens and base URIs for Docusign
**/

public class VT_D2_DocuSignAuthHelper {

    public class Result {
        public String value;
        public VT_D1_HTTPConnectionHandler.Result calloutResult;

        public Result(String value) {
            this.value = value;
        }

        public Result(VT_D1_HTTPConnectionHandler.Result calloutResult){
            this.calloutResult = calloutResult;
        }
    }

    public class UserInfoResponse {
        public List<UserInfoAccount> accounts;
    }

    public class UserInfoAccount {
        public String account_id;
        public String account_name;
        public String base_uri;
    }

    public class TokenResponse {
        public String access_token;
        public Integer expires_in;
    }

    public static Result getAuthToken() {
        String token = (String)Cache.Org.get('DocuSignToken');
        return token != null ? new Result(token) : getTokenFromAPI(); 
    }

    public static Result getBaseUri(String token) {
        String baseUri = (String)Cache.Org.get('DocuSignBaseUri');
        return baseUri != null ? new Result(baseUri) : getBaseUriFromAPI(token);
    }

    public static Result getTokenFromAPI() {
        VTD2_Docusign_API_Settings__c dsSettings = VTD2_Docusign_API_Settings__c.getInstance();
        String method = 'POST';
        String endpointURL = 'https://' + dsSettings.VTD2_Auth_Domain__c + '/oauth/token';
        String action = 'Get DocuSign Access Token';
        VT_D1_RequestBuilder requestBuilder = new VT_D2_RequestBuilder_DocuSignAccessToken();
        Map<String, String> headerMap = new Map<String, String>();

        Result tokenResult = new Result(VT_D1_HTTPConnectionHandler.send(method, endpointURL, requestBuilder, action, headerMap, true));

        if (tokenResult.calloutResult.httpResponse != null && tokenResult.calloutResult.httpResponse.getStatusCode() == 200) {
            TokenResponse tokenResponse = (TokenResponse)JSON.deserialize(tokenResult.calloutResult.httpResponse.getBody(), TokenResponse.class);

            addValueToCache('DocuSignToken', tokenResponse.access_token, tokenResponse.expires_in);
            tokenResult.value = tokenResponse.access_token;
        }

        return tokenResult;
    }

    public static Result getBaseUriFromAPI(String token) {
        VTD2_Docusign_API_Settings__c dsSettings = VTD2_Docusign_API_Settings__c.getInstance();

        String method = 'GET';
        String endpointURL = 'https://' + dsSettings.VTD2_Auth_Domain__c + '/oauth/userinfo';
        String action = 'Get DocuSign Base URI';
        Map<String, String> headerMap = new Map<String, String>{
            'Authorization' => 'Bearer ' + token
        };

        Result uriResult = new Result(VT_D1_HTTPConnectionHandler.send(method, endpointURL, null, action, headerMap, true));

        if (uriResult.calloutResult.httpResponse != null && uriResult.calloutResult.httpResponse.getStatusCode() == 200) {
            UserInfoResponse userInfo = (UserInfoResponse)JSON.deserialize(uriResult.calloutResult.httpResponse.getBody(), UserInfoResponse.class);
            for (UserInfoAccount item : userInfo.accounts) {
                if (item.account_name == dsSettings.VTD2_Account_Name__c) {
                    uriResult.value = item.base_uri + '/restapi/v2/accounts/' + item.account_id;
                    addValueToCache('DocuSignBaseUri', uriResult.value, 60*60*24);
                    break;
                }
            }
        }

        return uriResult;
    }

    public static void addValueToCache(String key, String val, Integer expiresIn) {
        Cache.Org.put(key, val, expiresIn - 300); // set cache TTL to 5 minutes less than expiry to be safe
    }
}