//@license@
package cxro.met5.device.mfdriftmonitor;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.IntBuffer;
import java.nio.ShortBuffer;
import java.util.logging.Logger;

/**
 * Manage the CXRO MfDriftMonitor DriftData organized in Modbus register image format.
 * <p>
 * The data format is according to the document ModbusDataMap (REV00).
 * @author Carl Cork &lt;cwcork@lbl.gov&gt;
 */
public final class DriftData
{
  //----------------------- STATIC FIELDS AND INITIALIZERS ---------------------------------------
  private static final Logger logger = Logger.getLogger(DriftData.class.getName());
  private static final int DATA_LENGTH = 108;
  //
  //----------------------- STATIC METHODS --------------------------------------------------------
  //
  //----------------------- INSTANCE FIELDS -------------------------------------------------------
  private final ByteBuffer buffer;
  private final ShortBuffer shortData;
  private final IntBuffer intData;
  //
  //----------------------- INSTANCE INITIALIZERS -------------------------------------------------
  //----------------------- INSTANCE CONSTRUCTORS -------------------------------------------------
  /**
   * Buffer storage for MET5 MF Modbus Data.
   */
  public DriftData()
  {
    // Process image is DATA_LEGNTH shorts
    this.buffer = ByteBuffer.allocate(2 * DATA_LENGTH).order(ByteOrder.LITTLE_ENDIAN);
    this.shortData = buffer.asShortBuffer();
    this.intData = buffer.asIntBuffer();
    
    setHsStatus((short) 0);
    setHsCounter(0);
    setDmiStatus((short) 0);
    setDmiCounter(0);
    setxValue(0);
    setyValue(0);
    setzValue(0);
  }
  //
  //----------------------- INSTANCE METHODS ------------------------------------------------------
  //----------------------- PUBLIC INSTANCE METHODS -----------------------------------------------
  // ---------- Data Methods -----------------------------------------------

  public short getHsStatus()
  {
    return shortData.get(1);
  }

  public void setHsStatus(short hsStatus)
  {
    shortData.put(1, hsStatus);
  }

  public int getHsCounter()
  {
    return intData.get(1);
  }

  public void setHsCounter(int hsCounter)
  {
    intData.put(1, hsCounter);
  }

  public int getxValue()
  {
    return intData.get(52);
  }

  public void setxValue(int xValue)
  {
    intData.put(52, xValue);
  }

  public int getyValue()
  {
    return intData.get(53);
  }

  public void setyValue(int yValue)
  {
    intData.put(53, yValue);
  }

  public int getzValue()
  {
    return intData.get(2);
  }

  public void setzValue(int zValue)
  {
    intData.put(2, zValue);
  }

  public int[] getHsRawData()
  {
    int[] res = new int[24];
    intData.position(3);
    intData.get(res);
    return res;
  }

  public void setHsRawData(int[] hsRawData)
  {
    intData.position(3);
    intData.put(hsRawData);
  }

  public short getDmiStatus()
  {
    return shortData.get(101);
  }

  public void setDmiStatus(short dmiStatus)
  {
    shortData.put(101, dmiStatus);
  }

  public int getDmiCounter()
  {
    return intData.get(51);
  }

  public void setDmiCounter(int dmiCounter)
  {
    intData.put(51, dmiCounter);
  }
  
  //----------------------- PROTECTED INSTANCE METHODS --------------------------------------------
  short[] getData()
  {
    short[] res = new short[DATA_LENGTH];
    
    shortData.position(0);
    shortData.get(res);
    
    return res;
  }
    
  void setData(short[] data)
  {
    shortData.position(0);
    shortData.put(data);
  }

  //----------------------- PRIVATE   INSTANCE METHODS --------------------------------------------
  //
  //--------------------------- INNER CLASSES -----------------------------------------------------
  //----------------------- PUBLIC    STATIC CLASSES ----------------------------------------------
  //----------------------- PROTECTED STATIC CLASSES ----------------------------------------------
  //----------------------- DEFAULT   STATIC CLASSES ----------------------------------------------
  //----------------------- PRIVATE   STATIC CLASSES ----------------------------------------------
  //----------------------- PUBLIC    INNER CLASSES -----------------------------------------------
  //----------------------- PROTECTED INNER CLASSES -----------------------------------------------
  //----------------------- DEFAULT   INNER CLASSES -----------------------------------------------
  //----------------------- PRIVATE   INNER CLASSES -----------------------------------------------

  
}
