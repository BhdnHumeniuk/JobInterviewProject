/**
 * HttpCalloutMockTest class is used to mock HTTP callouts during testing.
 * It implements the HttpCalloutMock interface and provides a response with a 200 status code and an empty JSON body.
 */
@isTest
global class HttpCalloutMockTest implements HttpCalloutMock {
  global HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new HttpResponse();
    response.setHeader('Content-Type', 'application/json');
    response.setBody('');
    response.setStatusCode(200);
    return response;
  }
}
