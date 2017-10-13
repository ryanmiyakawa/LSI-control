/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package cxro.common.device.Camera;

import java.io.IOException;

/**
 *
 * @author cwcork
 */
public interface PixisCamera
extends Camera
{
  /**
   * Pixis Specific settings. Behaves identically to cameraSettings but
   * includes pixis specific binning xbin, ybin.
   *
   * @param captureMode
   * @param exposureTime
   * @param x0
   * @param x1
   * @param y0
   * @param y1
   * @param xbin
   * @param ybin
   * @return TRUE if the given settings are valid.
   */
  boolean cameraSettings(boolean captureMode, long exposureTime, int x0, int x1, int y0, int y1, short xbin, short ybin);

  /**
   * Stops the capture sequence of the camera base on the passed option.
   *
   * @param option
   *               - {0) CCS_NO_CHANGE: No change
   *               - (1) CCS_HALT: Halt all CCS activity, put in idle state
   *               - (2) CCS_HALT_CLOSE_SHTR: Close the shutter, then do CCS_HALT
   *               - (3) CCS_CLEAR: Put the CCS in the continuous clearing state
   *               - (4) CCS_CLEAR_CLOSE_SHTR: Close the shutter, then do CCS_CLEAR
   *               - (5) CCS_OPEN_SHTR: Open the shutter, then do CCS_HALT
   *               - (6) CCS_CLEAR_OPEN_SHTR: Open the shutter, then to CCS_CLEAR
   * @return
   */
  boolean stopCapture(int option);

  /**
   * Get the bit depth for the currently selected speed choice.
   *
   * @return the bit depth
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getBits()
  throws IOException;

  /**
   * Retrieve the status of the camera control subsystem (CCS)
   *
   * @return ccs_status
   *         The CCS status. One of:
   *         - (0) IDLE
   *         - (1) INITIALIZING
   *         - (2) RUNNING
   *         - (3) CONTINUOUSLY_CLEARING
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getCcsStatus()
  throws IOException;

  /**
   * Retrieve the clear cycles parameter
   *
   * @return the number of times the CCD is cleared
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getClearCycles()
  throws IOException;

  /**
   * Retrieve the clear strips parameter
   *
   * @return the number of strips per clear
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getClearStrips()
  throws IOException;

  /**
   * Determine whether this camera can run in frame transfer mode
   * (set through PARAM_PMODE)
   *
   * @return 1 if the camera is frame capable, 0 if not
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getFrameCapable()
  throws IOException;

  /**
   * Get the current gain setting
   *
   * @return the gain setting (the meaning of the gain
   *         is camera dependent)
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getGain()
  throws IOException;

  /**
   * Retrieve the on/off indicator for the gain multiplication functionality
   *
   * @return 1 if enabled, 0 if not
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getGainMultEnable()
  throws IOException;

  /**
   * Retrieve the gain multiplication factor
   *
   * @return the multiplication factor
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getGainMultFactor()
  throws IOException;

  /**
   * Get the maximum gain setting for the camera
   *
   * @return the maximum gain setting (camera dependent; may
   *         be as high as 16)
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getMaxGain()
  throws IOException;

  /**
   * Get the CCD readout port
   * <p>
   * Possible readout port values (the available ports are camera-specific;
   * use ccd_get_readout_port_entries to determine the number of available ports):
   * <ul><li>READOUT_PORT_MULT_GAIN = 0</li>
   * <li>READOUT_PORT_NORMAL = 1</li>
   * <li>READOUT_PORT_LOW_NOISE = 2</li>
   * <li>READOUT_PORT_HIGH_CAP = 3</li></ul>
   * @return the port number
   * @throws java.io.IOException when a communication error has occurred.
   */
  short getReadoutPort()
  throws IOException;

  /**
   * Get the number of available readout ports
   *
   * @return the number of entries in the speed table
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getReadoutPortEntries()
  throws IOException;

  /**
   * Get the maximum number of command retries. This should normally
   * not be changed since it "is matched to the
   * communications link, hardware platform, and operating
   * system" [PVCAM 2.6 Manual, p. 36]
   *
   * @return the maximum number of retries
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getRetries()
  throws IOException;

  /**
   * Retrieve the shutter close delay in milliseconds
   *
   * @return the delay in msec
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getShtrCloseDly()
  throws IOException;

  /**
   * Retrieve the shutter open delay in milliseconds
   *
   * @return the delay in msec
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getShtrOpenDly()
  throws IOException;

  /**
   * Retrieve the status of the shutter
   *
   * @return The shutter status. One of:
   *         - (0) SHTR_FAULT: Shutter has overheated
   *         - (1) SHTR_OPENING: Shutter is opening
   *         - (2) SHTR_OPEN: Shutter is open
   *         - (3) SHTR_CLOSING: Shutter is closing
   *         - (4) SHTR_CLOSED: Shutter is closed
   *         - (5) SHTR_UNKNOWN: The system cannot determine the shutter state
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getShtrStatus()
  throws IOException;

  /**
   * Get the time for each pixel in nanoseconds
   *
   * @return the actual speed for the current speed setting
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getSpeed()
  throws IOException;

  /**
   * Get the number of speed table entries
   *
   * @return the number of entries in the speed table
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getSpeedEntries()
  throws IOException;

  /**
   * Get the CCD readout speed from a table of available choices
   *
   * @return the table index
   * @throws java.io.IOException when a communication error has occurred.
   */
  short getSpeedMode()
  throws IOException;

  /**
   * Get the maximum time to wait for acknowledgement. This should normally
   * not be changed since it "is matched to the
   * communications link, hardware platform, and operating
   * system" [PVCAM 2.6 Manual, p. 36]
   *
   * @return the timeout setting in milliseconds
   * @throws java.io.IOException when a communication error has occurred.
   */
  int getTimeout()
  throws IOException;

  /**
   * Retrieve the current temperature of the ccd
   *
   * @return the measured temperature of the CCD, in degrees centigrade
   * @throws java.io.IOException when a communication error has occurred.
   */
  float getTmp()
  throws IOException;

  /**
   * Get the temperature setpoint of the ccd
   *
   * @return the desired temperature of the CCD, in degrees centigrade
   * @throws java.io.IOException when a communication error has occurred.
   */
  float getTmpSetpoint()
  throws IOException;

  /**
   * Set the clear cycles parameter
   *
   * @param clearCycles the number of times the CCD is cleared
   * @return 1 on success, 0 on failure
   */
  boolean setClearCycles(int clearCycles);

  /**
   * Set the clear strips parameter
   *
   * @param strips the number of strips per clear
   * @return 1 on success, 0 on failure
   */
  boolean setClearStrips(int strips);

  /**
   * Set the current gain setting
   *
   * @param gain the gain setting (the meaning of the gain
   *             is camera dependent)
   * @return 1 on success, 0 on failure
   */
  boolean setGain(int gain);

  /**
   * Turn the gain multiplication functionality on or off
   *
   * @param enabled 1 if enabled, 0 if not
   * @return 1 on success, 0 on failure
   */
  boolean setGainMultEnable(int enabled);

  /**
   * Set the gain multiplication factor
   *
   * @param factor 1 if enabled, 0 if not
   * @return 1 if enabled, 0 if not
   */
  boolean setGainMultFactor(int factor);

  /**
   * Set the CCD readout port choice
   * <p>
   * NOTE: The gain, speed, and bit depth may be altered as a result of
   * setting this parameter. You should maintain a list of available readout
   * ports and associated settings, and set all of them after calling this function.
   * @param port the readout port index
   * @return 1 on success, 0 on failure
   */
  boolean setReadoutPort(short port);

  /**
   * Set the maximum number of command retries. This should normally
   * not be changed since it "is matched to the
   * communications link, hardware platform, and operating
   * system" [PVCAM 2.6 Manual, p. 36]
   *
   * @param retries the maximum number of retries
   * @return 1 on success, 0 on failure
   */
  boolean setRetries(int retries);

  /**
   * Set the shutter close delay in milliseconds
   *
   * @param shtrCloseDly the delay in msec
   * @return 1 on success, 0 on failure
   */
  boolean setShtrCloseDly(int shtrCloseDly);

  /**
   * Set the shutter open delay in milliseconds
   *
   * @param shtrOpenDly the delay in msec
   * @return 1 on success, 0 on failure
   */
  boolean setShtrOpenDly(int shtrOpenDly);

  /**
   * Set the CCD readout speed from a table of available choices.
   *
   * @param speed the table index
   * @return 1 on success, 0 on failure
   */
  boolean setSpeedMode(short speed);

  /**
   * Set the maximum time to wait for acknowledgement. This should normally
   * not be changed since it "is matched to the
   * communications link, hardware platform, and operating
   * system" [PVCAM 2.6 Manual, p. 36]
   *
   * @param mSec the timeout setting in milliseconds
   * @return 1 on success, 0 on failure
   */
  boolean setTimeout(int mSec);

  /**
   * Set the temperature setpoint of the ccd
   *
   * @param tmpSetpoint the desired temperature of the CCD, in degrees centigrade
   * @return 1 on success, 0 on failure
   */
  boolean setTmpSetpoint(float tmpSetpoint);

  /**
   * Close the shutter, and do not open it during exposures.
   * <p>
   * Equivalent to setting the PARAM_SHTR_OPEN_MODE parameter to
   * OPEN_NEVER
   *
   * @return 1 on success, 0 on failure
   */
  boolean shtrOpenNever();

  /**
   * Open the shutter during exposures.
   * <p>
   * Equivalent to setting the PARAM_SHTR_OPEN_MODE parameter to
   * OPEN_PRE_EXPOSURE
   *
   * @return 1 on success, 0 on failure
   */
  boolean shtrOpenNormal();

}
