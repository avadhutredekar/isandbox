package bolshev.exam.client;

/**
 * Created by Никита on 17.01.2016.
 */
public class ClientRunner {

    public static void main(String[] args) throws Exception{
        Client testClient = new Client();
        testClient.init();
        System.out.println("Response: "+testClient.doRequest("Kakoy to request"));

    }
}
