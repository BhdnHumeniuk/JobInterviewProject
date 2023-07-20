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
