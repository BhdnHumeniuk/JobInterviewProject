/**
 * CalloutService class provides a static method to make HTTP POST callouts.
 * It includes a method to create and send an HTTP request with the specified endpoint URL and request body.
 */
public with sharing class CalloutService {
  public static HttpResponse makePostCallout(String endpointUrl, String requestBody) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(endpointUrl);
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json');
    request.setBody(requestBody);

    Http http = new Http();
    HttpResponse response = http.send(request);

    return response;
  }
}
