@IsTest
private class SFMCEServiceTest {

    private class MultiCalloutMock implements HttpCalloutMock {
        // ✅ instance fields (not static)
        public HttpRequest lastAuthReq;
        public HttpRequest lastEventReq;
        Integer count = 0;

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();

            if (req.getEndpoint().contains('.auth.marketingcloudapis.com/v2/token')) {
                lastAuthReq = req;
                res.setStatusCode(200);
                res.setHeader('Content-Type','application/json');
                res.setBody('{"access_token":"dummy_token"}');
                return res;
            }
            if (req.getEndpoint().contains('/interaction/v1/events')) {
                lastEventReq = req;
                res.setStatusCode(202);
                res.setHeader('Content-Type','application/json');
                res.setBody('{"message":"ok"}');
                return res;
            }
            res.setStatusCode(404);
            res.setBody('{"message":"not found"}');
            return res;
        }
    }

    @IsTest
    static void testAddToJourney_invocable() {
        // Keep a handle to the mock so we can read its instance fields later
        MultiCalloutMock mock = new MultiCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);

        // Build the *correct* invocable payload
        SFMCEService.AddToJourneyRequest r = new SFMCEService.AddToJourneyRequest();
        r.contactKey = 'ck-001';
        r.emailAddress = 'test@example.com';
        r.conversationDescription = 'Test Conversation';

        Test.startTest();
        SFMCEService.addToJourney(new List<SFMCEService.AddToJourneyRequest>{ r });
        Test.stopTest(); // runs the @future call

        // Assertions using the *instance* fields on our mock
        System.assertNotEquals(null, mock.lastAuthReq, 'Auth should be called');
        System.assertNotEquals(null, mock.lastEventReq, 'Event should be called');
    }
}
