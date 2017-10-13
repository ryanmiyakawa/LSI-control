// @license
package cxro.common.device.motion;

import cxro.common.device.Device;
import java.io.IOException;
import java.util.concurrent.Future;

/**
 * Interface for N Dimensional Motion Devices.
 * <p>
 * This describes a generic interface for both coordinated and independent axes devices.
 * The intention is to make it possible, at the top level, to do basic motion control
 * for all motion systems. As such, it does not try to do all possible motion combinations.
 * <p>
 * <b>REVISION NOTES:</b><br>
 * 2014-11-13 : Initial.<br>
 * 2014-11-19 : release candidate.<br>
 * 2014-12-20 : simplify return values.<br>
 * <p>
 * @author Carl Cork &lt;cwcork@lbl.gov&gt;
 */
public interface Stage
extends Device
{
  /**
   * Limit and home bit flags used in bytes returned by 
   * {@link #getAxesSwitches() getAxesSwitches} and {@link #getAxisSwitches(int) getAxisSwitches)}.
   */
  static final byte FORWARD_LIMIT = 0x01;
  static final byte REVERSE_LIMIT = 0x02;
  static final byte HOME_SWITCH = 0x04;

  // -------------------------------- CONTROLLER OPERATIONS ------------------------------------
  /**
   * Return number of axes.
   * @return Number of axes
   * @throws IOException Generic IO Exception Generic IO exception
   */
  int getSize()
  throws IOException;

  // ----------------------------- SYNCHRONIZED AXES OPERATIONS ---------------------------------
  /**
   * Return array of names associated with axes.
   * @return axisNames
   * @throws IOException  Generic IO exception
   */
  String[] getAxesNames()
  throws IOException;
  
  /**
   * Disable all axes.
   * This will turn all motors off.
   * @return {@link Result}
   * @throws IOException Generic IO Exception
   */
  Result disableAxes()
  throws IOException;

  /**
   * Enable all axes.
   * <p>
   * This will turn all motors on.
   * @return {@link Result}
   * @throws IOException Generic IO Exception
   */
  Result enableAxes()
  throws IOException;

  /**
   * Test for ENABLED condition, all axes.
   * <p>
   * This is a logical AND of all individual axis ENABLED conditions.
   * Most motion commands will return exceptions if the stage is not enabled.
   * @return true if ENABLED
   * @throws IOException Generic IO Exception
   */
  boolean getAxesIsEnabled() 
  throws IOException;

  /**
   * Test for LINEAR motion, all axes.
   * <p>
   * LINEAR = NOT ROTARY.
   * If true, units are in mm.
   * If false, units are in mrad.
   * @return array of axis linear vs rotary parameters, true if LINEAR.
   * @throws IOException Generic IO Exception
   */
  boolean[] getAxesIsLinear()
  throws IOException;

  /**
   * Test for AT_LIMIT condition, all axes.
   * <p>
   * One of the axis limit switches is active.
   * <p>
   * This is a logical OR of all individual axis AT_LIMIT conditions.
   * Use {@link #getAxesStatus() getAxesStatus} to determine individual limit switch status.
   * @return true if AT_LIMIT.
   * @throws IOException Generic IO Exception
   */
  boolean getAxesIsAtLimit()
  throws IOException;

  /**
   * Get status of hardware switches, all axes.
   * <p>
   * This method returns an array of bytes that represent the current status of the hardware
   * switches on the stage.
   * <p>
   * The return byte value, for each axis, is indexed as follows:<br>
   * <ul>
   * <li>bit 0x01 : {@link #FORWARD_LIMIT FORWARD_LIMIT} </li>
   * <li>bit 0x02 : {@link #REVERSE_LIMIT REVERSE_LIMIT} </li>
   * <li>bit 0x04 : {@link #HOME_SWITCH HOME_SWITCH} </li>
   * </ul>
   * When <u>set</u>, the switch is <u>active</u>.
   * <p>
   * Ex: <br>
   * &nbsp;&nbsp;&nbsp;byte[] switches = myStage.getStageSwitches();<br>
   * &nbsp;&nbsp;&nbsp;if((switches[0] &amp; 0x02) == 1) &#47;&#47; test Reverse_Switch for axis 0<br>
   * &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&#47;&#47;throw error or act accordingly.
   * @return array of current switch settings.
   * @throws IOException Generic IO exception
   */
  byte[] getAxesSwitches()
  throws IOException;

  /**
   * Get position, all axes.
   * <p>
   * Return array of axis positions.
   * @return array of axis positions (in scaled units).
   * @throws IOException Generic IO Exception
   */
  double[] getAxesPosition()
  throws IOException;

  /**
   * Define current position, all axes.
   * <p>
   * Sets the current position to any defined position in the SCALED coordinate system. 
   * <p>
   * NOTE1: This does not modify the UNSCALED controller position; 
   * rather, it modifies the OFFSET so that:
   * <p>
   * POS_SCALED = (POS_UNSCALED - OFFSET)&#47;SCALE<br>
   * <p>
   * NOTE2: This will have an effect on the software limits. The unscaled
   * value for the soft limits will remain fixed, but the scaled value for the
   * software limits will now be:
   * <p>
   * LIMIT_SCALED = (LIMIT_UNSCALED - OFFSET)&#47;SCALE<br>
   * @param pos New value for current position.
   * @throws IOException Generic IO Exception
   */
  void setAxesPosition(double[] pos)
  throws IOException;

  /**
   * Test for BUSY condition, all axes.
   * <p>
   * If true, the controller is busy with another operation.
   * This is a logical OR of all individual axis BUSY conditions.
   * @return true if BUSY
   * @throws IOException Generic IO Exception
   */
  boolean getAxesIsBusy()
  throws IOException;

  /**
   * Test for INITIALIZED status, all axes.
   * <p>
   * This is the logical AND of all individual axis INITIALIZED conditions.
   * Most motion commands are prohibited until all axes are initialized.
   * @return true if INITIALIZED
   * @throws IOException Generic IO Exception
   */
  boolean getAxesIsInitialized()
  throws IOException;

  /**
   * Test for MOVING condition, all axes.
   * <p>
   * MOVING = NOT STOPPED.
   * This is a logical OR of all individual axis MOVING conditions.
   * @return true if MOVING
   * @throws IOException Generic IO Exception
   */
  boolean getAxesIsMoving()
  throws IOException;

  /**
   * Test stage for READY status.
   * <p>
   * READY = DONE &#38; STOPPED &#38; ENABLED &#38; INITIALIZED
   * @return true if READY
   * @throws IOException Generic IO exception
   */
  boolean getAxesIsReady()
  throws IOException;
  
  /**
   * Determine if the destination is reachable, all axes.
   * <p>
   * For a system of independent axes, this will be a simple test of limits for the system.
   * For more complicated systems, this will involve a comparison with the working envelope.
   * @param dest multiaxis destination.
   * @return true if destination is within the working envelope.
   * @throws IOException Generic IO Exception Generic IO exception
   */
  boolean getAxesIsReachable(double[] dest)
  throws IOException;
  
  /**
   * Get stage status.
   * <p>
   * This returns an array of axis status objects that can be queried for a number of conditions.
   * @see Status
   * @return current axis status objects
   * @throws IOException Generic IO exception
   */
  Status[] getAxesStatus()
  throws IOException;

  /**
   * Stop motion, maximum deceleration, for all axes.
   * <p>
   * This operation can take some time.  The calling program should use
   * {@link #getAxesIsMoving() getAxesIsMoving} to determine when motion is stopped and
   * {@link #getAxesIsReady() getAxesIsReady} to determine when motion can be re-initiated.
   * @return  {@link Result}
   * @throws IOException Generic IO Exception
   */
  Result abortAxesMove()
  throws IOException;

  /**
   * Stop motion, normal deceleration, all axes.
   * <p>
   * This operation can take some time. Therefore it is handled by a separate thread in the driver.
   * <p>
   * An immediate command response is returned. The calling program should use
   * {@link #getAxesIsMoving() getAxesIsMoving} to determine when motion is stopped and
   * {@link #getAxesIsReady() getAxesIsReady} to determine when motion can be initiated.
   * @return  {@link Result}
   * @throws IOException Generic IO Exception
   */
  Result stopAxesMove()
  throws IOException;

  /**
   * Initialize all axes.
   * <p>
   * This initiates an initialization operation for all axes. In most cases, this is a homing
   * operation which finds either the home limit or encoder index and sets the UNSCALED position to
   * zero.
   * <p>
   * If the controller is aware of the system configuration, this method might involve a more
   * complex, coordinated, sequence of operations arriving at the final state.
   * <p>
   * An asynchronous {@link Future}&lt;{@link Result}&gt; is returned.
   * <p>
   * The calling program should test this object for {@link Future#isDone() isDone} to determine
   * when the move is complete. The result is then available by calling {@link Future#get() get}.
   * @return future {@link Result} at end of operation.
   * @throws IOException Generic IO Exception
   */
  Future<Result> initializeAxes()
  throws IOException;

  /**
   * Absolute move, all axes.
   * <p>
   * Coordinated move of all axes to target destination.
   * An asynchronous {@link Future}&lt;{@link Result}&gt; is returned.
   * <p>
   * The calling program should test this object for {@link Future#isDone() isDone} to determine
   * when the move is complete. The result is then available by calling {@link Future#get() get}.
   * @param dest move destination
   * @return future {@link Result} at end of move.
   * @throws IOException Generic IO Exception
   */
  Future<Result> moveAxesAbsolute(double[] dest)
  throws IOException;

  /**
   * Relative move, all axes.
   * <p>
   * Coordinated move of all axes by a specified distance from current position.
   * An asynchronous {@link Future}&lt;{@link Result}&gt; is returned.
   * <p>
   * The calling program should test this object for {@link Future#isDone() isDone} to determine
   * when the move is complete. The result is then available by calling {@link Future#get() get}.
   * @param dist move distance
   * @return future {@link Result} at end of move.
   * @throws IOException Generic IO Exception
   */
  Future<Result> moveAxesRelative(double[] dist)
  throws IOException;

  /**
   * Returns the current target destination, all axes.
   * <p>
   * If motion is completed, the target equals current position.
   * @return destination - current target destination, all axes.
   * @throws IOException Generic IO exception
   */
  double[] getAxesDestination()
  throws IOException;

  /**
   * Set target destination, all axes.
   * <p>
   * This updates the axes destinations and, possibly, initiates a move. The target destination is
   * specified by the input array <i>dest</i>.<br>
   * With most axes, the destination can be updated while a prior move is in progress. With some
   * stages, if the destination cannot be updated, this method will return an BUSY status.
   * <p>
   * Only the immediate command status is returned. Motion completion should be polled independently
   * using {@link #getAxesIsReady() getAxesIsReady}.
   * @param dest move destination, SCALED
   * @return {@link Result} at start of move.
   * @throws IOException Generic IO exception
   */
  Result setAxesDestination(double[] dest)
  throws IOException;

  
  // ----------------------------- INDEPENDENT AXES OPERATIONS ----------------------------------
  /**
   * Return single axis device name.
   * <p>
   * The name is a readonly parameter that is used to signify the path to configuration data that is
   * maintained by the driver. It represents a hierarchical path to the axis data via the associated
   * component and device elements.
   * <p>
   * For instance, the X axis of the zoneplate stage that is associated with the SHARP endstation,
   * would be given the following name:
   * <ul>
   * <li>cxro&#47;sharp&#47;zp_stage&#47;x</li>
   * </ul>
   * <p>
   * @param axis axis number [0..(size-1)]
   * <p>
   * @return Full device name
   * @throws IOException Generic IO Exception
   */
  String getAxisName(int axis)
  throws IOException;
  
  /**
   * Disable single axis.
   * <p>
   * This will turn the axis motor off.
   * <p>
   * NOTE: This will not assure that the motor is first stopped, nor that a brake will be applied.
   * This must be performed separately by the application program before calling this method.
   * @param axis axis number [0..(size-1)]
   * @return {@link Result}
   * @throws IOException Generic IO Exception
   */
  Result disableAxis(int axis)
  throws IOException;

  /**
   * Enable single axis.
   * <p>
   * This will turn axis motor on.
   * @param axis axis number [0..(size-1)]
   * @return {@link Result}
   * @throws IOException Generic IO Exception
   */
  Result enableAxis(int axis)
  throws IOException;

  /**
   * Test for ENABLED condition, single axes.
   * <p>
   * Test for axis enabled/powered.
   * Most motion commands will return exceptions if the stage is not enabled.
   * @param axis axis number [0..(size-1)]
   * @return true if ENABLED
   * @throws IOException Generic IO Exception
   */
  boolean getAxisIsEnabled(int axis)
  throws IOException;

  /**
   * Test for LINEAR motion, single axis.
   * <p>
   * LINEAR = NOT ROTARY.
   * If true, units are in mm.
   * If false, units are in mrad.
   * @param axis axis number [0..(size-1)]
   * @return true if LINEAR
   * @throws IOException Generic IO Exception
   */
  boolean getAxisIsLinear(int axis)
  throws IOException;
  
  /**
   * Test for AT_LIMIT condition, single axis.
   * <p>
   * Axis limit switch is active.
   * Use {@link #getAxisSwitches(int) getAxisSwitches} to determine individual limit switch status.
   * @param axis axis number [0..(size-1)]
   * @return true if AT_LIMIT.
   * @throws IOException Generic IO Exception.
   */
  boolean getAxisIsAtLimit(int axis)
  throws IOException;

  /**
   * Get status of hardware switches, single axis.
   * <p>
   * This method returns a byte that represent the current status of the hardware switches for a
   * single axis on the controller.
   * <p>
   * The return byte value, for this axis, is indexed as follows:<br>
   * <ul>
   * <li>bit 0x01 : {@link #FORWARD_LIMIT FORWARD_LIMIT} </li>
   * <li>bit 0x02 : {@link #REVERSE_LIMIT REVERSE_LIMIT} </li>
   * <li>bit 0x04 : {@link #HOME_SWITCH HOME_SWITCH} </li>
   * </ul>
   * When <u>set</u>, the switch is <u>active</u>.
   * <p>
   * Ex: <br>
   * &nbsp;&nbsp;&nbsp;byte switches = myStage.getAxisSwitches(0);<br>
   * &nbsp;&nbsp;&nbsp;if((switches &amp; 0x02) == 1) &#47;&#47; test Reverse_Switch for axis 0<br>
   * &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&#47;&#47;throw error or act accordingly.
   * @param axis axis number [0..(size-1)]
   * @return current switch settings.
   * @throws IOException Generic IO exception
   */
  byte getAxisSwitches(int axis)
  throws IOException;

  /**
   * Return the current position, single axis.
   * <p>
   * POS_SCALED = (POS_UNSCALED - OFFSET)&#47;SCALE<br>
   * <p>
   * @param axis axis number [0..(size-1)]
   * @return SCALED position
   * @throws IOException Generic IO Exception
   */
  double getAxisPosition(int axis) 
  throws IOException;

  /**
   * Define current position, for single axis.
   * <p>
   * Sets the current position to <i>pos</i>.
   * <p>
   * NOTE: this does not modify the internal UNSCALED controller position; rather, it modifies the
   * software managed OFFSET such that:<br>
   * POS = (POS_UNSCALED - OFFSET)&#47;SCALE<br>
   * @param axis axis number [0..(size-1)]
   * @param pos  New value for current position.
   * @throws IOException Generic IO Exception
   */
  void setAxisPosition(int axis, double pos)
  throws IOException;

  /**
   * Test for BUSY condition, single axis.
   * <p>
   * Controller busy with another operation, single axis.
   * @param axis axis number [0..(size-1)]
   * @return true if BUSY
   * @throws IOException Generic IO Exception.
   */
  boolean getAxisIsBusy(int axis)
  throws IOException;

  /**
   * Test for INITIALIZED status, single axis.
   * <p>
   * Test for axis homed/initialized.
   * Most motion commands are prohibited until the axis is initialized.
   * @param axis axis number [0..(size-1)]
   * @return true if INITIALIZED
   * @throws IOException Generic IO Exception
   */
  boolean getAxisIsInitialized(int axis)
  throws IOException;

  /**
   * Test for MOVING condition, single axis.
   * <p>
   * MOVING = NOT STOPPED, single axis.
   * @param axis axis number [0..(size-1)]
   * @return true if MOVING
   * @throws IOException Generic IO Exception
   */
  boolean getAxisIsMoving(int axis)
  throws IOException;

  /**
   * Test for READY status, single axis.
   * <p>
   * If true, the axis is ready to receive move commands.
   * <p>
   * <b>isReady = isEnabled &amp;&amp; !isFaulted &amp;&amp; !isBusy</b>
   * If true, the axis is ready to receive move commands.
   * @param axis axis number [0..(size-1)]
   * @return true if READY
   * @throws IOException Generic IO Exception
   */
  boolean getAxisIsReady(int axis)
  throws IOException;
  /**
   * Determine if the destination is reachable, single axis.
   * <p>
   * For a system of independent axes, this will be a simple test of limits for the given axis.
   * For more complicated systems, this will involve a comparison with the working envelope.
   * @param axis axis number [0..(size-1)]
   * @param dest single axis destination.
   * @return true if destination is within the working envelope.
   * @throws IOException Generic IO Exception Generic IO exception
   */
  boolean getAxisIsReachable(int axis, double dest)
  throws IOException;
  
  /**
   * Get axis status.
   * <p>
   * This returns a status object that can be queried for a number of conditions.
   * @see cxro.common.device.motion.Status
   * @param axis axis number [0..(size-1)]
   * @return current status {@link Status}
   * @throws IOException Generic IO Exception Generic IO exception
   */
  Status getAxisStatus(int axis)
  throws IOException;

  /**
   * Stop motion, maximum deceleration, for all axes.
   * <p>
   * This operation can take some time. Therefore it is handled by a separate thread in the driver.
   * An immediate command response is returned. The calling program should use
   * {@link #getAxisIsMoving(int)  getAxisIsMoving} to determine when motion is stopped and
   * {@link #getAxisIsReady(int) getAxisIsReady} to determine when motion can be initiated.
   * @param axis axis number [0..(size-1)]
   * @return {@link Result}
   * @throws IOException Generic IO Exception
   * @see Result
   */
  Result abortAxisMove(int axis)
  throws IOException;

  /**
   * Stop motion, normal deceleration, single axis.
   * <p>
   * This operation can take some time. Therefore it is handled by a separate thread in the driver.
   * <p>
   * An immediate command response is returned. The calling program should use
   * {@link #getAxisIsMoving(int) getAxesIsMoving(axis)} to determine when motion is stopped and
   * {@link #getAxisIsReady(int) getAxesIsReady(axis)} to determine when motion can be initiated.
   * @param axis axis number [0..(size-1)]
   * @return Status
   * @throws IOException Generic IO Exception
   * @see Result
   */
  Result stopAxisMove(int axis)
  throws IOException;

  /**
   * Initialize single axis.
   * <p>
   * This initiates an initialization operation for a single axis. In most cases, this is a homing
   * operation which finds either the home limit or encoder index and sets the UNSCALED position to
   * zero. For most coordinated axes systems require simultaneous initialization of all axes.
   * In this case, this method will return an {@link UnsupportedOperationException}.
   * <p>
   * This operation typically takes a long time and generally spawns a background thread to perform
   * the operation. The calling program should use {@link #getAxisIsBusy(int) getAxesIsBusy(axis)} and
   * {@link #getAxisIsInitialized(int) getAxesIsInitialized(axis)} to determine when the operation is complete.
   * @param axis axis number [0..(size-1)]
   * @return future {@link Result} at end of operation.
   * @throws IOException Generic IO Exception
   */
  Future<Result> initializeAxis(int axis)
  throws IOException;

  /**
   * Absolute move, single axis.
   * <p>
   * Move single axis to target destination.
   * An asynchronous {@link Future} integer result is returned.
   * <p>
   * The calling program should test this object for {@link Future#isDone() isDone} to determine
   * when the move is complete. The result is then available by calling {@link Future#get() get}.
   * @param axis axis number [0..(size-1)]
   * @param dest move destination, SCALED
   * @return Future {@link Result}
   * @throws IOException Generic IO Exception
   * @see Result
   */
  Future<Result> moveAxisAbsolute(int axis, double dest)
  throws IOException;

  /**
   * Relative move, single axis.
   * <p>
   * Move single axis by a specified distance from current position.
   * <p>
   * The calling program should test this object for {@link Future#isDone() isDone} to determine
   * when the move is complete. The result is then available by calling {@link Future#get() get}.
   * @param axis axis number [0..(size-1)]
   * @param dist move distance, SCALED
   * @return future {@link Result} at end of move.
   * @throws IOException Generic IO Exception
   * @see Result
   */
  Future<Result> moveAxisRelative(int axis, double dist)
  throws IOException;
   
  /**
   * Return the destination for the current move (in SCALED units), single axis.
   * <p>
   * If motion is completed, the destination equals current position.
   * @param axis axis number [0..(size-1)]
   * @return destination - destination for current move
   * @throws IOException Generic IO Exception
   */
  double getAxisDestination(int axis)
  throws IOException;

  /**
   * Set target destination, single axis.
   * <p>
   * This updates the axis destination and, possibly, initiates a move. The target destination is
   * specified by the input <i>dest</i>.<br>
   * With most axes, the destination can be updated while a prior move is in progress. With some
   * stages, if the destination cannot be updated, this method will return an BUSY status.
   * <p>
   * Only the immediate command status is returned. Motion completion should be polled independently
   * using {@link #getAxisIsReady(int) getAxisIsReady}.
   * @param axis axis number [0..(size-1)]
   * @param dest move destination, SCALED
   * @return {@link Result} at start of move.
   * @throws IOException Generic IO exception
   * @see Result
   */
  Result setAxisDestination(int axis, double dest)
  throws IOException;
}
