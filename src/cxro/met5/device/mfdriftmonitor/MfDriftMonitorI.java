// @license
package cxro.met5.device.mfdriftmonitor;

import cxro.common.device.Device;
import java.io.IOException;

/**
 * Interface for MET5 MF Drift Monitor Controls.
 * <p>
 * This describes the interface to the MET5 height sensor and Dmi drift monitor subsystem.
 * <p>
 * <b>REVISION NOTES:</b><br>
 * 2017-08-03 : Initial.<br>
 * <p>
 * @author Carl Cork &lt;cwcork@lbl.gov&gt;
 */
public interface MfDriftMonitorI
extends Device
{
  // -------------------------------- DRIFT MONITOR OPERATIONS ----------------------------------
  /**
   * Start DriftMonitor updates.
   * <p>
   * Except during resets, the HS and DMI are continuously monitored at the HS 1 kHz fixed data rate.
   * However, this method will first set the DMI incremental axis positions to zero,
   * and then initiate updates of the MfDriftData database at 100 Hz. 
   * @throws IOException general IO Exception
   */
  void monitorStart()
  throws IOException;

  /**
   * Stop DriftMonitor updates.
   * <p>
   * This will stop updates of the MfDriftData database.
   * However, this does not stop the continuous monitoring of the HS and DMI data.
   * Data monitoring is only interrupted, briefly, during a reset operation.
   * @throws IOException general IO Exception
   */
  void monitorStop()
  throws IOException;
  
  /**
   * Test DriftMonitor status.
   * <p>
   * Internal scanner is usually in one of two states: IDLE or MONITORING (other states are STARTING and REFERENCING).
   * This method tests is scanner is in MONITORING state.
   * @return true if scanner is monitoring drift.
   * @throws IOException general IO Exception
   */
  boolean isMonitoring()
  throws IOException;

  /**
   * Get a copy of the current drift data.
   * <p>
   * Get the most recent drift data values, relative to monitorStart() time.
   * This is updated at 10 ms intervals.
   * @return most recent DriftData object.
   * @throws IOException general IO Exception
   */
  DriftData getDriftData()
  throws IOException;
  
  /**
   * Get a copy of the next sample data.
   * <p>
   * SampleData contains a snapshot of HS and DMI raw data.
   * @return next scanner data sample.
   * @throws IOException general IO Exception
   */
  SampleData getSampleData()
  throws IOException;
  
  /**
   * Get averaged sample data.
   * <p>
   * Average over the next nSamples samples.
   * @param nSamples number of samples for averaging.
   * @return average over the next nSamples samples.
   * @throws IOException general IO Exception
   */
  SampleData getSampleDataAvg(int nSamples)
  throws IOException;

  // ---------------------------- HS METHODS ----------------------------------------------------
  /**
   * Get HS channel calibration offsets.
   * <p>
   * Such that,<br>
   * <BLOCKQUOTE><code>position[i] = slope[i] * (dos[i] + offset[i])</code></BLOCKQUOTE>
   * Where,<br>
   * <BLOCKQUOTE><code>dos[i] = (raw_T[i] - raw_B[i])/(raw_T[i] + raw_B[i])</code></BLOCKQUOTE>
   * @return array of channel offset values.
   * @throws IOException general IO Exception
   */
  double[] hsGetCalibrationOffsets()
  throws IOException;
  
  /**
   * Get HS channel calibration slopes.
   * <p>
   * Such that,<br>
   * <BLOCKQUOTE><code>position[i] = slope[i] * (dos[i] + offset[i])</code></BLOCKQUOTE>
   * Where,<br>
   * <BLOCKQUOTE><code>dos[i] = (raw_T[i] - raw_B[i])/(raw_T[i] + raw_B[i])</code></BLOCKQUOTE>
   * @return array of channel slope values.
   * @throws IOException general IO Exception
   */
  double[] hsGetCalibrationSlopes()
  throws IOException;
  
  /**
   * Set HS channel calibration offsets.
   * <p>
   * Such that,<br>
   * <BLOCKQUOTE><code>position[i] = slope[i] * (dos[i] + offset[i])</code></BLOCKQUOTE>
   * Where,<br>
   * <BLOCKQUOTE><code>dos[i] = (raw_T[i] - raw_B[i])/(raw_T[i] + raw_B[i])</code></BLOCKQUOTE>
   * @param offsets array of offset values.
   * @throws IOException general IO Exception
   */
  void hsSetCalibrationOffsets(double[] offsets)
  throws IOException;
  
  /**
   * Set HS channel calibration slopes.
   * <p>
   * Such that,<br>
   * <BLOCKQUOTE><code>position[i] = slope[i] * (dos[i] + offset[i])</code></BLOCKQUOTE>
   * Where,<br>
   * <BLOCKQUOTE><code>dos[i] = (raw_T[i] - raw_B[i])/(raw_T[i] + raw_B[i])</code></BLOCKQUOTE>
   * @param slopes array of slope values.
   * @throws IOException general IO Exception
   */
  void hsSetCalibrationSlopes(double[] slopes)
  throws IOException;
  
  /**
   * Get all channel positions, given single or averaged sample data.
   * @param sample single or averaged data sample.
   * @return array of channel position values.
   * @throws IOException general IO Exception
   */
  double[] hsGetPositions(SampleData sample)
  throws IOException;
  
  /**
   * Get the height sensor Z position, given single or averaged sample data.
   * <p>
   * Return units are Angstroms (0.1nm).
   * Zero corresponds to the center of the HS range (i.e. the design focal point).
   * @param sample single or averaged data sample.
   * @return zValue in Angstroms (0.1nm).
   * @throws IOException general IO Exception
   */
  double hsGetzPosition(SampleData sample)
  throws IOException;
  
  // ---------------------------- DMI METHODS ----------------------------------------------------
  /**
   * Reset DMI position to zero, all axes.
   * <p>
   * Does an AXIS_RESET for all DMI axes. This also resets the current axis position to zero.
   * @throws IOException general IO Exception
   */
  void dmiResetPosition()
  throws IOException;

  /**
   * Get XY position for single or average sample data.
   * <p>
   * Get the XY drift error in the reticle frame.
   * XY coordinates are rotated 45 degrees relative to DMI axes.
   * This method does rotation and scaling from axis units (1.5 Angstroms).
   * @param sample single or averaged data sample.
   * @return XY position, in Angstroms (0.1nm).
   * @throws IOException general IO Exception
   */
  double[] dmiGetxyPosition(SampleData sample)
  throws IOException;

}
