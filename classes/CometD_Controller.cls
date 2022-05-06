public without sharing class CometD_Controller {
    @AuraEnabled(cacheable=true)
        public static String getSessionId() {
        return UserInfo.getSessionId();
    }
}