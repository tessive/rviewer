RVIEWER

Tony Davis
tony@tessive.com

RVIEWER is a class that allows simple image display with resizing that will interpolate correctly for the display.  It accepts images just like the IMAGE function in MATLAB, and will create an axes if one is not specified.  See help RVIEWER for more detail on options.

RVIEWER requires the Matlab Image Processing Toolbox.

For ease of use, a utility RVIEW is also provided.  RVIEW creates a figure with as many RVIEWER objects as images provided to the constructor.  

RVIEWSC and RVIEWERSC are image intensity scaling versions of RVIEW and RVIEWER.  These work similarly to imagesc.

The cell-mode script userviewer.m provides examples of use for both RVIEW and RVIEWER.  

The GUIDE generated rviewerdemo.fig and rviewerdemo.m files show how to use RVIEWER with GUIDE created UIs.





Copyright 2014 Tessive LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

