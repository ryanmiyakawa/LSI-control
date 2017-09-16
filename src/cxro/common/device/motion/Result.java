// @license
package cxro.common.device.motion;

/**
 * Command results from MotionControl devices.
 * <p>
 * @author cwcork
 * @version 2014-11-19 : Initial
 * HISTORY:
 * 2014-11-30 : Convert to Enum.
 */
public enum Result
{
  // *************************** static fields ******************************
  /**
   * OK = 0
   * <p>
   * Indicates that method completed successfully.
   */
  OK(0),
  
  /**
   * BUSY = 2
   * <p>
   * Indicates that the system is busy moving.
   */
  BUSY(2),
  
  /**
   * UNREACHABLE = 3
   * <p>
   * Indicates that move would take stage outside of working envelope.
   */
  UNREACHABLE(3),
  
  /**
   * LIMIT_ERROR = 4
   * <p>
   * Indicates that move encountered either a soft or hard limit.
   */
  LIMIT_ERROR(4),
  
  /**
   * STOPPED = 5
   * <p>
   * Indicates that axis was stopped abnormally during its move.
   */
  STOPPED(5),
  
  /**
   * LOCKED = 6
   * <p>
   * Indicates that axis is locked by another thread which is performing a sequence of
   * uninterruptable operations.
   */
  LOCKED(6),
  
  /**
   * DISABLED = 7
   * <p>
   * Indicates that axis is disabled and unable to move.
   */
  DISABLED(7),
  
  /**
   * UNINITIALIZED = 8
   * <p>
   * Indicates that axis is not initialized.
   */
  UNINITIALIZED(8),
  
  /**
   * DISCONNECTED = 9
   * <p>
   * Indicates that the motion control subsystem is disconnected.
   */
  DISCONNECTED(9),
  
  /**
   * OTHER = 255
   * <p>
   * Unspecified result.
   */
  OTHER(255);
  
  private final int value;

  Result(int value)
  {
    this.value = value;
  }
  
  /**
   * Return Result corresponding to value.
   * <p>
   * Return OTHER if value doesn't match any Result constants.
   * @param value corresponding integer value.
   * @return corresponding Result constant.
   */
  public static Result fromInt(int value)
  {
   for (Result result : values())
   {
     if (result.value == value)
     {
       return result;
     }
   }
   
   // else return default
   return OTHER;
  }
  
  /**
   * Return integer value.
   * @return value.
   */
  public int toInt()
  {
    return value;
  }
}
