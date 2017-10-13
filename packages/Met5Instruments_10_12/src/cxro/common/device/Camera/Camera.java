/**
 * Written July 2013 by William Cork
 * <p>
 * Copyright (c) 2013 Lawrence Berkeley National Laboratory
 */
package cxro.common.device.Camera;

import java.io.IOException;

/**
 *
 * @author William Cork
 * <p>
 * Copyright (c) 2013 Lawrence Berkeley National Laboratory
 * <p>
 */
public interface Camera
{
  /**
   * Initializes this camera object to the indexed camera.
   * Once paired with the given index, this object controls that camera
   * via the remaining methods in this class.
   * @param index
   * @return
   *         true if init sequence succeeded otherwise, false
   */
  boolean initCamera(int index);

  /**
   * Disconnects class from the camera at the index designated in initCamera
   * @return Status of the uninit
   */
  boolean uninitCamera();

  /**
   * The initialization status of the camera.
   * Unnecessary if initCamera returned true.
   * @return True if the camera is initialized
   */
  boolean isInitialized();

  /**
   * Gives the sensor size of the camera in a formatted array.
   * And integer array with the formatting [width, height]
   * @return int[] {Horizontal size, Vertical size}
   * @throws java.io.IOException when a communication error has occurred.
   */
  int[] getSensorSize()
  throws IOException;

  /**
   * Returns the status of the local image buffer.
   * @deprecated
   * This method can be replaced by using getImage and testing for null.
   * @return
   *         true if local image buffer has an image.
   *         false if no image has been obtained.
   * @throws java.io.IOException when a communication error has occurred.
   */
  @Deprecated
  boolean checkStatus()
  throws IOException;

  /**
   * Returns the latest image in the buffer.
   * @return
   *         The latest image.
   *         If no image is in the buffer, null is returned.
   * @throws java.io.IOException when a communication error has occurred.
   */
  byte[] getImage()
  throws IOException;

  /**
   * Camera setup for a capture.
   * <p>
   * @param captureMode
   *                     Modifies the camera to use single or continuous capture mode. true = continuous, false = single.
   * @param exposureTime
   *                     The exposure time per image.
   * @param x0
   *                     The starting horizontal corner of an image region
   * @param x1
   *                     The ending horizontal corner of an image region.
   * @param y0
   *                     The starting vertical corner of an image region
   * @param y1
   *                     The ending vertical corner of an image region
   * @return true if settings were set correctly, false otherwise.
   */
  boolean cameraSettings(boolean captureMode, long exposureTime, int x0, int x1, int y0, int y1);

  /**
   * Returns the current capture mode of the camera.
   * @return
   *         true if the camera is in continuous capture mode.
   *         false if the camera is in single capture mode.
   */
  boolean getCaptureMode();

  /**
   * Begins image acquisition.
   * cameraSetting should be called before beginning to capture images.
   * @return true if the capture has started correctly. False otherwise.
   */
  boolean startCapture();

  /**
   * Stops the image capture sequence.
   * @return True if the camera has stopped correctly. False, otherwise.
   */
  boolean stopCapture();

  /**
   * Returns the lest error on the camera.
   * @return A string containing the last error.
   */
  String getError();
}
