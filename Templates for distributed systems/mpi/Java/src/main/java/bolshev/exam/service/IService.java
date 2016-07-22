package bolshev.exam.service;

import javax.jws.WebMethod;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

/**
 * Created by Никита on 17.01.2016.
 */
@SOAPBinding( style = SOAPBinding.Style.RPC)
@WebService
public interface IService {
    String ipAddress = "http://127.0.0.1:9876/ts";
    String serviceWsdl = "http://127.0.0.1:9876/ts?wsdl";

    @WebMethod
    public String someMethod(String someParameter);
}
