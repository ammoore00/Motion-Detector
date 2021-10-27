import java.net.*;
import java.io.*;
import javax.swing.*;
import java.awt.*;
import java.awt.image.*;
import javax.imageio.*;

public class UDPReceiver
{
    public static void main(String[] args) throws Exception
    {
        //Socket for UDP packet manipulation
        DatagramSocket socket = new DatagramSocket(20000);
        
        boolean loop = true;
        
        //Used for displaying the image
        JFrame frame = new JFrame("Display");
        ImageIcon imageIco = null;
        JLabel picture = new JLabel();
        
        while (loop)
        {
            //Creates a data packet, reveives data over the network, and inserts that data in
            //the packet object
            byte[] rawData = new byte[1];
            DatagramPacket packet = new DatagramPacket(rawData, rawData.length);
            socket.receive(packet);
            
            rawData = packet.getData();
            String data = new String(rawData);
            
            try
            {
                //Sets image to display based off of packet data
                switch (data)
                {
                    case "Y":
                        imageIco = new ImageIcon("/home/pi/Documents/EPICS/NoTurn.png");
                        break;
                    case "N":
                        imageIco = new ImageIcon("/home/pi/Documents/EPICS/Blank.png");
                        break;
                    default:
                        //loop = false;
                }
                
                //Displays the appropriate image
                picture.setIcon(imageIco);
                frame.getContentPane().add(picture, BorderLayout.CENTER);
                
                frame.pack();
                frame.setLocationRelativeTo(null);
                frame.setVisible(true);
            }
            catch (Exception e)
            {
                System.out.println(e.getMessage());
            }
        }
    }
}
