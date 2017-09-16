# About

Run `launch_app` to begin.

This an application that builds a UI for a made-up instrument.  The made-up instrument has two motorized stages (x, and y), an internal text setting, and a binary switch.  It is assumed that the vendor provided a device API that lets MATLAB talk to the instrument from the command line.  Our job is to build a UI.  

This example demonstrates how to hook up an arbitrary vendor-provided API to `mic.ui.device.*` UI controls.  This process involves building “translators“ that translate the vendor-provided API into the `mic.interface.device.*` interfaces that the UI controls are expecting.  It also demonstrates how consume data from the UI controls using their internal API. 

# /vendor

Provides a fake device API that mimics something a vendor might provide.  The vendor-provided device API does not match the `mic.interface.device.*` interface that the `mic.ui.device.*` UI classes need

# /src/+app/+device

Set of “Translators” that implement `mic.interface.device.*` from a VendorDevice instance