// @license
package cxro.common.device.motion;

/**
 * Interface for motion status from Stage devices.
 * <p>
 * @author cwcork
 * @version release candidate, 2014-11-19
 */
public final class Status
{
  //----------------------- STATIC FIELDS -------------------------------------
  /* Status bit masks.
   * Package access only.
   */
  static final int DONE  = 0x0001;
  static final int STOPPED = 0x0002;  
  static final int ENABLED  = 0x0004;
  static final int INITIALIZED = 0x0008; 
  static final int AT_NEGATIVE_LIMIT  = 0x0010;
  static final int AT_POSITIVE_LIMIT  = 0x0020;
  static final int AT_HOME_LIMIT  = 0x0040;
  static final int DRIVE_ERROR  = 0x1000;
  static final int CONTROL_ERROR = 0x2000;

  /*
   * Combined bit masks
   */
  static final int READY = 0x000F; // DONE & STOPPED & ENABLED & INITIALIZED
  static final int AT_LIMIT  = 0x0030; // AT_POSITIVE_LIMIT | AT_NEGATIVE_LIMIT
  static final int FAULTED = 0x3000; // DRIVE_ERROR | CONTROL_ERROR
  //
  //----------------------- STATIC INITIALIZERS -------------------------------
  //----------------------- STATIC METHODS ------------------------------------
  //
  //----------------------- INSTANCE FIELDS -----------------------------------
  /**
   * status is package accessible.
   * <p>
   * Controllers which are part of this package may directly modify the integer value.
   */
  int status;
  //
  //----------------------- INSTANCE INITIALIZERS -----------------------------
  //----------------------- INSTANCE CONSTRUCTORS -----------------------------
  /**
   * Default constructor, all bits off.
   * <p>
   * Constructor is only package accessible.
   */
  Status()
  {
    // Default initializer is all bits off
    this.status = 0x0000;
  }
  
  /**
   * Alternative constructor with preset status bits.
   * <p>
   * Constructor is only package accessible.
   * @param status 
   */
  Status(int status)
  {
    this.status = status;
  }
  
  //----------------------- INSTANCE METHODS ----------------------------------
  /**
   * Return raw status value.
   * <p>
   * For diagnostic/debug purposes.
   * @return raw status value
   */
  public final int getValue()
  {
    return status;
  }
  
  /**
   * Test for AT_HOME_LIMIT condition,.
   * @return true if axis currently is AT_HOME_LIMIT.
   */
  public final boolean isAtHomeLimit()
  {
    return ((status & AT_HOME_LIMIT) != 0);
  }
  //

  /**
   * Test for AT_LIMIT condition.
   * @return true if AT_LIMIT.
   */
  public final boolean isAtLimit()
  {
    return ((status & AT_LIMIT) != 0);
  }
  
  /**
   * Test for AT_NEGATIVE_LIMIT condition.
   * @return true if AT_NEGATIVE_LIMIT.
   */
  public final boolean isAtNegativeLimit()
  {
    return ((status & AT_NEGATIVE_LIMIT) != 0);
  }
  
  /**
   * Test for AT_POSITIVE_LIMIT condition.
   * @return true if AT_POSITIVE_LIMIT.
   */
  public final boolean isAtPositiveLimit()
  {
    return ((status & AT_POSITIVE_LIMIT) != 0);
  }

  /**
   * Test for DONE condition.
   * @return true if operation is DONE
   */
  public final boolean isDone()
  {
    return ((status & DONE) != 0);
  }

  /**
   * Test for ENABLED condition.
   * @return true if ENABLED
   */
  public final boolean isEnabled()
  {
    return ((status & ENABLED) != 0);
  }

  /**
   * Test for INITIALIZED status.
   * @return true if INITIALIZED
   */
  public final boolean isInitialized()
  {
    return ((status & INITIALIZED) != 0);
  }

  /**
   * Test for STOPPED condition.
   * @return true if MOVING
   */
  public final boolean isStopped()
  {
    return ((status & STOPPED) != 0);
  }

  /**
   * Test for READY status.
   * @return true if READY
   */
  public final boolean isReady()
  {
    return ((status & READY) == READY);
  }
  
  /**
   * Test for FAULTED condition.
   * <p>
   * FAULTED = CONTROL_ERROR | DRIVE_ERROR
   * @return true if FAULTED.
   */
  public final boolean isFaulted()
  {
    return ((status & FAULTED) != 0);
  }
  
  /**
   * Test for DRIVE_ERROR condition.
   * @return true if DRIVE_ERROR.
   */
  public final boolean isDriveError()
  {
    return ((status & DRIVE_ERROR) != 0);
  }
  
  /**
   * Test for CONTROL_ERROR condition.
   * @return true if CONTROL_ERROR.
   */
  public final boolean isControlError()
  {
    return ((status & CONTROL_ERROR) != 0);
  }
  //----------------------- DEFAULT   METHODS --------------------------------
  void setAtHomeLimit(boolean on)
  {
    if (on)
    {
      status |= AT_HOME_LIMIT;
    }
    else
    {
      status &= ~AT_HOME_LIMIT;
    }
  }

  void setAtNegativeLimit(boolean on)
  {
    if (on)
    {
      status |= AT_NEGATIVE_LIMIT;
    }
    else
    {
      status &= ~AT_NEGATIVE_LIMIT;
    }
  }

  void setAtPositiveLimit(boolean on)
  {
    if (on)
    {
      status |= AT_POSITIVE_LIMIT;
    }
    else
    {
      status &= ~AT_POSITIVE_LIMIT;
    }
  }

  void setControlError(boolean on)
  {
    if (on)
    {
      status |= CONTROL_ERROR;
    }
    else
    {
      status &= ~CONTROL_ERROR;
    }
  }

  void setDone(boolean on)
  {
    if (on)
    {
      status |= DONE;
    }
    else
    {
      status &= ~DONE;
    }
  }

  void setDriveError(boolean on)
  {
    if (on)
    {
      status |= DRIVE_ERROR;
    }
    else
    {
      status &= ~DRIVE_ERROR;
    }
  }

  void setEnabled(boolean on)
  {
    if (on)
    {
      status |= ENABLED;
    }
    else
    {
      status &= ~ENABLED;
    }
  }

  void setInitialized(boolean on)
  {
    if (on)
    {
      status |= INITIALIZED;
    }
    else
    {
      status &= ~INITIALIZED;
    }
  }

  void setStopped(boolean on)
  {
    if (on)
    {
      status |= STOPPED;
    }
    else
    {
      status &= ~STOPPED;
    }
  }
  //----------------------- PROTECTED METHODS --------------------------------
  //----------------------- PRIVATE   METHODS --------------------------------
}
