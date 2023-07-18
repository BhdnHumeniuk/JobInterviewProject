@IsTest
private class CalloutServiceTest {
  @IsTest
  static void testMakePostCallout() {
    String endpointUrl = 'https://example.com/api';
    String requestBody = '{"key": "value"}';

    Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest());

    HttpResponse response = CalloutService.makePostCallout(endpointUrl, requestBody);

    System.assertEquals(200, response.getStatusCode(), 'Expected status code 200');
    System.assertEquals('application/json', response.getHeader('Content-Type'), 'Expected content type application/json');
    System.assertEquals('', response.getBody(), 'Expected empty response body');
  }

  @IsTest
  static void testMakePostCallout_Error() {
    String endpointUrl = 'https://example.com/api';
    String requestBody = '{"key": "value"}';

    Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest_Error());

    HttpResponse response = CalloutService.makePostCallout(endpointUrl, requestBody);

    System.assertEquals(500, response.getStatusCode(), 'Expected status code 500 for error response');
  }

  private class HttpCalloutMockTest_Error implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{"error": "Something went wrong"}');
      response.setStatusCode(500);
      return response;
    }
  }
}
