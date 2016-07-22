package bolshev.exam.client;

import bolshev.exam.service.IService;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;
import java.net.URL;

/**
 * Created by Никита on 17.01.2016.
 */
public class Client {
    private static final String WSDL_URL = IService.serviceWsdl;
    private static final String SERVICE_NAMESPACE = "http://service.exam.bolshev/";
    private static final String SERVICE_INSTANCE_NAME = "TestServiceService"; // second Service for mark that it`s SOAP service
    private IService serviceForTest;

    public void init() throws Exception
    {
        URL url = new URL(WSDL_URL);
        QName qname = new QName(SERVICE_NAMESPACE, SERVICE_INSTANCE_NAME);
        Service service = Service.create(url, qname);
        serviceForTest = service.getPort(IService.class);
    }

    public String doRequest(String message) {
        String response = serviceForTest.someMethod(message);
        return response;
    }
}
