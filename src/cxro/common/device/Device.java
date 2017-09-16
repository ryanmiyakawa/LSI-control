// @license
package cxro.common.device;

import java.io.IOException;

/**
 * Base interface for all devices.
 * @author cwcork
 */
public interface Device
{
  /**
   * Returns the axes given device name.
   * <p>
   * The name is a readonly parameter that is used to signify the device name within the individual
   * system.
   * @return Stage device name.
   * @throws IOException Generic IO exception
   */
  String getDeviceName() 
  throws IOException;

  /**
   * Establish connection to motion subsystem.
   * <p>
   * The connection mechanism is not defined here. Rather, it is defined in the concrete,
   * implementation, class.
   * <p>
   * Will return false if connection fails; otherwise returns true.
   * @return true if operation succeeds
   * @throws IOException Generic IO Exception
   */
  boolean connect()
  throws IOException;

  /**
   * Disconnect from motion subsystem.
   * <p>
   * @throws IOException Generic IO Exception
   */
  void disconnect()
  throws IOException;

  /**
   * A test if the motion subsystem is connected.
   * <p>
   * Most motion commands will return exceptions if the stage is not connected.
   * @see #connect()
   * @see #disconnect()
   * @return true if connected
   * @throws IOException Generic IO exception
   */
  boolean isConnected()
  throws IOException;
  
  /**
   * Test device for operational condition.
   * <p>
   * If is operational, return true. Otherwise return false. Device testing might result
   * in exception with reason message.
   * @return true if operational
   * @throws IOException
   */
  boolean ping()
  throws IOException;

  /**
   * Reset controller.
   * <p>
   * Equivalent to a power off/on reset.
   * Use with extreme caution.
   * @return  true if successful
   * @throws IOException 
   */
  boolean reset()
  throws IOException;
}
