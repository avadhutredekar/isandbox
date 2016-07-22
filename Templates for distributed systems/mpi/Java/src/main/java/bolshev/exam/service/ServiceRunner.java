package bolshev.exam.service;

import javax.xml.ws.Endpoint;

/**
 * Created by Никита on 17.01.2016.
 */


public class ServiceRunner {
    public static final IService testService = new TestService();
    public static void main(String[] args) {
        Endpoint.publish(IService.ipAddress,testService ); // ide deployment
    }
}
