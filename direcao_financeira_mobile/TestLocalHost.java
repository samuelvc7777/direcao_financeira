import java.net.*;
public class TestLocalHost {
  public static void main(String[] args) throws Exception {
    InetAddress local = InetAddress.getLocalHost();
    System.out.println(local.getHostName()+" -> "+local.getHostAddress());
    System.out.println("canonical=" + local.getCanonicalHostName());
  }
}
