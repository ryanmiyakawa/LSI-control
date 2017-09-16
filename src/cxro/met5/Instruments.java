//@license
package cxro.met5;

import cxro.common.device.motion.Stage;
import cxro.met5.device.diag142.Diag142Stage;
import cxro.met5.device.lsi.goniometer.LsiGoniometer;
import cxro.met5.device.lsi.hexapod.LsiHexapod;
import cxro.met5.device.m141.M141Stage;
import cxro.met5.device.m143.M143Stage;
import cxro.met5.device.fm.FmStage;
import cxro.met5.device.mfdriftmonitor.MfDriftMonitor;
import cxro.met5.device.mfdriftmonitor.MfDriftMonitorI;
import java.io.FileReader;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.ini4j.Ini;

/**
 * Handler for an assortment of MET5 files.
 * 
 * NOTE: CXRO standard units for stages are mm for linear and mRadian for angular.
 * @author Carl Cork &lt;cwcork@lbl.gov&gt;
 */
public class Instruments
{
  private static final Logger logger = Logger.getLogger(Instruments.class.getName());

  static // static configuration
  {
    logger.setLevel(null);
  }
  // 
  // instance fields
  private M141Stage m141Stage;
  private Diag142Stage diag142Stage;
  private M143Stage m143Stage;
  private LsiGoniometer lsiGoniometer;
  private LsiHexapod lsiHexapod;
  private FmStage fmStage;
  private MfDriftMonitor mfDriftMonitor;

  // ------------------------------- CONSTRUCTORS -------------------------------------------
  /**
   * Construct a MET5 Instrumentation service locator using the specified base directory.
   * @param appHome base directory for configuration and library files.
   * @throws IOException Generic IO Exception
   */
  public Instruments(String appHome) 
  throws IOException
  {
    // Set working directory.
    logger.log(Level.INFO, "Instrument base directory: {0}", appHome);
    
    // Get ini file and devices
    Ini ini = new Ini(new FileReader(appHome + "/Instruments.ini"));
    Ini.Section section = ini.get("main");
    logger.log(Level.INFO, "main.domain: {0}", section.get("domain"));
    
    section = ini.get("M141Stage");
    m141Stage = new M141Stage(section.get("nodename"), section.get("locator"));
    
    section = ini.get("Diag142Stage");
    diag142Stage = new Diag142Stage(section.get("nodename"), section.get("locator"));
    
    section = ini.get("M143Stage");
    m143Stage = new M143Stage(section.get("nodename"), section.get("locator"));
    
    section = ini.get("LsiGoniometer");
    lsiGoniometer = new LsiGoniometer(section.get("nodename"), section.get("locator"));
    
    section = ini.get("LsiHexapod");
    lsiHexapod = new LsiHexapod(section.get("nodename"), section.get("locator"));
    
    section = ini.get("FmStage");
    fmStage = new FmStage(section.get("nodename"), section.get("locator"));
    
    section = ini.get("MfDriftMonitor");
    mfDriftMonitor = new MfDriftMonitor(section.get("nodename"), section.get("locator"));
    
    // Register shutdown handler.
    Runtime.getRuntime().addShutdownHook(new DestroyHook());
  }

  /**
   * Construct a MET5 Instrumentation service locator using the current working directory.
   * <p>
   * Uses the current value for user.dir.
   * @throws IOException Generic IO Exception
   */
  public Instruments() 
  throws IOException
  {
    // Default for appHome is current working directory
    this(System.getProperty("user.dir"));
  }

  @Override
  protected void finalize() 
  throws Throwable
  {
    try
    {
      disconnect();
    }
    finally
    {
      super.finalize();
    }
  }
  // ---------------------------------- PUBLIC METHODS ---------------------------------------
  /**
   * Disconnect from devices.
   * 
   * All device objects are nullified and should not be used.
   */
  public final void disconnect()
  {
    if (m141Stage != null)
    {
      m141Stage.disconnect();
    }
    
    if (diag142Stage != null)
    {
      diag142Stage.disconnect();
    }
    
    if (m143Stage != null)
    {
      m143Stage.disconnect();
    }
    
    if (lsiGoniometer != null)
    {
      lsiGoniometer.disconnect();
    }
    
    if (lsiHexapod != null)
    {
      lsiHexapod.disconnect();
    }    
    
    if (fmStage != null)
    {
      fmStage.disconnect();
    }
    
    if (mfDriftMonitor != null)
    {
      mfDriftMonitor.disconnect();
    }
  }
  
  public final Stage getM141Stage()
  {
    return m141Stage.getStage();
  }
  
  public final Stage getDiag142Stage()
  {
    return diag142Stage.getStage();
  }
  
  public final Stage getM143Stage()
  {
    return m143Stage.getStage();
  }
  
  public final Stage getLsiGoniometer()
  {
    return lsiGoniometer.getStage();
  }
  
  public final Stage getLsiHexapod()
  {
    return lsiHexapod.getStage();
  }
  
  public final Stage getFmStage()
  {
    return fmStage.getStage();
  }
  
  public final MfDriftMonitorI getMfDriftMonitor()
  {
    return mfDriftMonitor.getMfDriftMonitor();
  }

  // ------------------------- INNER CLASSES ------------------------------
  private class DestroyHook
  extends Thread
  {
    @Override
    public void run()
    {
      disconnect();
    }
  }
}
