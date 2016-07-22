package bolshev.exam.service;

import javax.jws.WebService;

/**
 * Created by Никита on 17.01.2016.
 */

/**
 * SOAP web service implementation
 */
@WebService(endpointInterface = "bolshev.exam.service.IService")
public class TestService implements IService {

    public TestService() {
        System.out.println("Test service started on "+ipAddress);
    }

    @Override
    public String someMethod(String someParameter) {
        System.out.println("Client request++");
        String response = "";
        /**
         *  your code
         */
        try {
            Transport ts = Transport.generateTransport("192.168.200.129", 5001);
            response = ts.sendRequestToServer(someParameter);
        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
        String result = "Response: "+response;

        return result;
    }

}
