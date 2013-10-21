# alignvolumedata

alignvolumedata is developed by Kendrick Kay (kendrick@post.harvard.edu).

To get started with alignvolumedata, add it to your MATLAB path:
  addpath(genpath('alignvolumedata'));
Then, change to the alignvolumedata directory and try calling alignvolumedata.

History of major code changes:
- 2013/10/20 - Initial check-in to github.

## CONTENTS

These are top-level functions:
- alignvolumedata.m - manually align two 3D volumes (reference volume, target volume)
- alignvolumedata_auto.m - automatically adjust transformation parameters
- alignvolumedata_exporttransformation.m - report the current transformation parameters
- alignvolumedata_preferences.m - query and set preferences
- extractslices.m - extract slices from the reference or target volume
- maketransformation.m - given a set of parameters, make a transformation struct
- matrixtotransformation.m - convert 4x4 transformation matrix to a transformation struct
- transformationtomatrix.m - convert transformation struct to a 4x4 transformation matrix

These directories contain various utilities:
- external - A directory containing external MATLAB toolboxes
- private - A directory containing various utility functions

These are additional files:
- README.md - The file you are reading

## DEPENDENCIES

DNB requires knkutils (http://github.com/kendrickkay/knkutils/).

## INSTRUCTIONS

===== THE BASICS =====

The function alignvolumedata.m is useful for determining and/or verifying the affine transformation parameters that are needed to align one volume (target) to another (reference).  A volume is represented by a matrix and its associated voxel lengths (e.g. [0.5 0.5 3] can be interpreted to mean 0.5 mm x 0.5 mm x 3 mm).  We take the x-, y-, and z-axes to correspond to the first, second, and third dimensions of a matrix.  A volume is taken to be initially positioned such that the "first" corner of the volume lies at (.5,.5,.5).  The point of this is so that if the lengths associated with a volume are [1 1 1], then coordinate (x,y,z) corresponds to the exact center of matrix element [x y z].

===== THE RENDER WINDOWS =====

There are three render windows.  The window in the upper left shows the current slice of the target volume.  The window in the lower left shows the current slice of the reference volume.  (Note that when calculating slices through the reference volume, we automatically upsample the in-plane dimensions if appropriate.)  The window in the upper right shows the current slice of the overlay.

===== THE GUI WINDOW =====

=== ALIGNMENT ===

The TX, TY, TZ controls are text boxes indicating the current translation coordinates as well as buttons that allow for decrementing and incrementing.

The RX, RY, RZ controls are text boxes indicating the current rotation amounts (in degrees) as well as buttons that allow for decrementing and incrementing.

The ESX, ESY, ESZ controls are text boxes indicating the current scale factors as well as buttons that allow for decrementing and incrementing.  Scale factors must be non-zero but can be negative (which allows for flipping).

The ETX, ETY, ETZ controls are text boxes indicating the current in-plane translation factors as well as buttons that allow for decrementing and incrementing.  Note that these in-plane translation factors are just for convenience and do not add any extra transformation flexibility (beyond that afforded by TX, TY, and TZ).

The EHX, EHY, EHZ controls are text boxes indicating the current shear factors, buttons that allow for decrementing and incrementing, and a checkbox that flips the shear direction.  Note that flipping the shear direction is just for convenience and does not add any extra transformation flexibility.  (Also, note that EHX actually refers to shearing with respect to the x- and y-axes; EHX actually refers to shearing with respect to the y- and z-axes; and EHX actually refers to shearing with respect to the x- and z-axes.)

=== SLICE ===

The SLICE controls consist of an editable text box indicating the current slice number, a slider controlling the slice number, and a text box for the step size.  The step size controls how much the slider jumps when clicking in the slider bar region (not the arrows).

The SLICE DIMENSION control indicates the dimension of the target volume along which slices are obtained.

The SLICE AVERAGE control is a nonzero integer, where the magnitude indicates how many extracted slices are averaged to produce the displayed slice.  A positive sign means to avoid matrix element boundaries, while a negative sign means to coincide on matrix element boundaries.  Extracted slices are equally spaced within the matrix space they are extracted from.  Example: slice 15 with a slice average value of 2 means to average slices 14.75 and 15.25.  Another example: slice 15 with a slice average value of -3 means to average slices 14.5, 15, and 15.5.

=== DISPLAY/OTHER ===

The ROTATE controls consist of buttons that cause counterclockwise and clockwise rotation of the images displayed in the render windows.  Note that such rotation is only for display purposes and do not affect the actual transformations that are performed.

The INTERPOLATION control is a popup menu indicating the interpolation method for extracting slices from the reference volume.  Using anything other than 'nearest' requires extra memory.  Also note that the 'cubic' method is computationally intensive.

The OVERLAY MODE control is a popup menu with three options: 'single', 'subtract', and 'checker'.  In the 'single' state, the image shown in the overlay render window is determined by the state of the OVERLAY MAIN button.  In the 'subtract' state, the image shown in the overlay render window is the subtraction of the reference and target images: when the OVERLAY MAIN button is in the 'ref' state, the subtraction is ref-target; when the OVERLAY MAIN button is in the 'target' state, the subtraction is target-ref.  In the 'checker' state, the image shown in the overlay render window is a composite checkerboard that is constructed from the reference and target images.  The size of the checks is controlled through alignvolumedata_preferences.m.  (Note: in the 'subtract' and 'checker' states, the target image is resampled via nearest neighbor interpolation to match the resolution of the reference image.)  The state of the OVERLAY MAIN button determines the image shown within the first check (the check located in the upper left) as well as the colormap that is used for the entire image.

The T/R STEP control is a text box indicating the step size for the TX, TY, TZ, RX, RY, RZ, ETX, ETY, ETZ, EHX, EHY, and EHZ decrement and increment buttons.

The S STEP control is a text box indicating the step size for the ESX, ESY, and ESZ decrement and increment buttons.

The REF CONTRAST and TARGET CONTRAST settings specify the minimum and maximum values of the reference and target volumes for display purposes.

The RENDER control consists of a 'redraw' button that, when clicked, causes the render windows to be redrawn.  Since all GUI controls automatically cause the render window to be updated, the 'redraw' button is probably needed only when the contents of the render window are mangled for some unexpected reason.

=== KEYBOARD CONTROL ===

While one of the figure windows is active, you can use the keyboard to control various aspects of the alignment:

  q w --> tx down up
  a s --> tx down up
  z x --> tz down up
  e r --> rx down up
  d f --> ry down up
  c v --> rz down up
  t y --> esx down up
  g h --> esy down up
  b n --> esz down up
  u i --> etx down up
  j k --> ety down up
  m , --> etz down up
  o p --> ehx down up
  l ; --> ehy down up
  . / --> ehz down up
  [ ] --> slice down up (single)
  { } --> slice down up (jump)
  '   --> toggle OVERLAY MAIN
  1   --> set slice dimension to 'x'
  2   --> set slice dimension to 'y'
  3   --> set slice dimension to 'z'

=== NOTES AND TIPS ===

- Getting automatic alignment of volumes with different tissue contrasts is tricky, and probably requires use of the mutual information metric.
- Automatic alignment will not work if your starting point is way off.  Note that this includes the case of volumes being flipped!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Copyright (c) 2013, Kendrick Kay
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this
list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

The name of its contributors may not be used to endorse or promote products 
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
