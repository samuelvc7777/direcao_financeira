import java.net.*;
public class TestLoopback {
  public static void main(String[] args) throws Exception {
    System.out.println("localhost=" + InetAddress.getByName("localhost") + " loop=" + InetAddress.getByName("localhost").isLoopbackAddress());
    InetAddress local = InetAddress.getLocalHost();
    System.out.println("localHost=" + local + " loop=" + local.isLoopbackAddress());
    ServerSocket s = new ServerSocket(0, 1, InetAddress.getLoopbackAddress());
    System.out.println("bound=" + s.getInetAddress() + ":" + s.getLocalPort());
    s.close();
  }
}
