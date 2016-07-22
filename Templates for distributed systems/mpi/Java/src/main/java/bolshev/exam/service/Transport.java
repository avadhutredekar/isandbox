package bolshev.exam.service;

import soap.service.transport.ExportableMessage;
import soap.service.transport.MessageType;
import soap.service.transport.Status;
import soap.service.transport.TransportMessage;
import utils.DsLogger;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.net.UnknownHostException;

/**
 * Created by Никита on 17.01.2016.
 */
public class Transport {

    protected Socket socket = null;
    protected DataInputStream streamIn = null;
    protected DataOutputStream streamOut = null;

    private Transport(String serverName, int serverPort) {
        try
        {
            socket = new Socket(serverName, serverPort);
            System.out.println("Connected: " + socket);
        }
        catch(UnknownHostException uhe){
            System.out.println("Host unknown: " + uhe.getMessage());
            uhe.printStackTrace();
        }
        catch(IOException ioe){
            System.out.println("Unexpected exception: " + ioe.getMessage());
            ioe.printStackTrace();
        }
    }

    private void init() throws Exception
    {
        streamIn   = new DataInputStream(new BufferedInputStream(socket.getInputStream()));
        streamOut = new DataOutputStream(socket.getOutputStream());
    }

    public void stop() throws Exception
    {
        if (streamIn   != null)  streamIn.close();
        if (streamOut != null)  streamOut.close();
        if (socket    != null)  socket.close();
    }

    public static Transport generateTransport(String serverName, int port) throws Exception{
        Transport ts = new Transport(serverName, port);
        ts.init();
        return ts;
    }

    public String sendRequestToServer(String message) {
        String response = null;
        try{
            streamOut.write(message.getBytes());
            streamOut.flush();

            byte[] buffers=new byte[5];
            streamIn.read(buffers);
            response=new String(buffers);
            System.out.println("Response: " + response);
        }
        catch(Exception ex){
            System.out.println("Exception: " + ex.getMessage());
            ex.printStackTrace();
        }
        return response;
    }
}
