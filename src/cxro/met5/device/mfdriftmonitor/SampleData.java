//@license@
package cxro.met5.device.mfdriftmonitor;

import java.util.logging.Logger;

/**
 * Manage the CXRO MfDriftMonitor Sample Data.
 * <p>
 *
 * @author Carl Cork &lt;cwcork@lbl.gov&gt;
 */
public final class SampleData
{
  //----------------------- STATIC FIELDS AND INITIALIZERS ---------------------------------------
  private static final Logger logger = Logger.getLogger(SampleData.class.getName());
  //
  //----------------------- STATIC METHODS --------------------------------------------------------
  //
  //----------------------- INSTANCE FIELDS -------------------------------------------------------
  private final int[] hsData;
  private final int[] dmiData;
  //
  //----------------------- INSTANCE INITIALIZERS -------------------------------------------------
  //----------------------- INSTANCE CONSTRUCTORS -------------------------------------------------
  /**
   * Buffer storage for MET5 HS and DMI data.
   * @param hsData  HS sample data.
   * @param dmiData DMI sample data.
   */
  public SampleData(int[] hsData, int[] dmiData)
  {
    this.hsData = hsData;
    this.dmiData = dmiData;
  }
  //
  //----------------------- INSTANCE METHODS ------------------------------------------------------
  //----------------------- PUBLIC INSTANCE METHODS -----------------------------------------------
  // ---------- Data Methods -----------------------------------------------
  /**
   * Get HS sample data.
   * @return reference to HS raw data (not a copy)
   */
  public int[] getHsData()
  {
    return hsData;
  }
  
  /**
   * Get HS sample data array length.
   * @return length of HS raw data array.
   */
  public int getHsDataLength()
  {
    return hsData.length;
  }

  /**
   * Get DMI sample data.
   * @return reference to DMI raw data (not a copy)
   */
  public int[] getDmiData()
  {
    return dmiData;
  }
  
  /**
   * Get DMI sample data array length.
   * @return length of DMI raw data array.
   */
  public int getDmiDataLength()
  {
    return dmiData.length;
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
