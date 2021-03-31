GEOMETRY AND MODELING OF A RECUMBENT
Complete user manual: http://rouzeau.net/bentsimh

This application is made to design the geometry of a recumbent
bicycle, tricycle or quadricycle and in particular its steering blueprint.
It simply generates the blueprint and does not make any calculations (except for
the trail and "wheel flop").
The steering is designed according to pure Ackermann geometry with possible adjustment.
This application uses OpenSCAD as a visualization engine.
After defining the geometry, you must project the model in order to be able to
export it in DXF format, usable in any CAD software.

It is also possible to make a relatively complete visual model with a single
tube frame. This model can be exported as a simple volume (without colors) in
stl format.
You can also project all or part of the model in 2D and export these 2D views
in DXF format. Typically, we will make a projection of the frame.

The size of the rider's model can vary and for the same size, the proportion
between the length of the legs and the length of the torso is adjustable.
Two sizes of riders can be displayed simultaneously on the model.

By default, rider and transmission are not shown, you can display them in
 [Display] tab. They will be removed when projecting the geometry blueprint.

Projection is done in [Display] tab by selecting the [view type] 'Projection'. 
This requires some time to be calculated.
Another option is to project the 3D model sideview (which can include rider
and transmission), but the calculation time is significant (a few minutes).

There are basic element for modeling (wheels, rider, frame, transmission and
steering) but this program is not intended as a full fledged cycle modeler.
Wheels are bicycle wheels according ETRTO standard.
Most of the modelling stuff originate from my Velassi recumbent model which
 is a much more complete model, but not yet published. See my webpage:
http://rouzeau.net/TheVelassi/TheVelassi
The trike/quad steering geometry part was made from scratch.

This application need to have prealably installed OpenSCAD (a free parametric
 3D modeler), see here:
* http://www.openscad.org/downloads.html#snapshots
Snapshot versions of OpenScad are recommended as they are frequently updated
 and are reliable.
*You shall at least use the last official version (2021.01).
*All files shall be installed in a directory on your computer, though you
 don't really need the 'Images' directory to run the app.

*How to install the application ?
At address https://github.com/PRouzeau/Trike-geometry under gray line, on
the right there is a button [Clone or Download] which open a small window
where you will find a link [Download ZIP], to click.
This open a window 'Downloading...' with two buttons proposing to 'sign up'
or 'sign in'. You don't need either. In parallel, your browser download the
file 'Trike-geometry-master.zip' and may propose to record it somewhere (this
depends from your browser config). Open the zip file, it includes a directory
'Trike-geometry-master', its content shall be installed anywhere on your
computer (however, look below paragraph for restriction on the complete
 directory name).
 
*The complete path of the directory where you install this application
 (Trike geometry or any other) shall only use ASCII characters, without
 spaces, accented letters, any diacritic, umlaut or other character set.
Without these conditions, Customizer dataset cannot be saved.
 
*To start the application, click on the file 'Trike_geometry.scad'.
This will open OpenSCAD with application loaded. Click on [F5] to run
default example.

Since the 2019.05 version, Customizer is automatically activated.

*In [View] menu, you shall now have an option [Hide customizer],
 which shall be unticked, so the Customizer panel appear on the right.

*In same [View] menu, you may want to hide the programming editor
 with ticking [Hide editor].

*Interface use local language (as configured on your machine) by default.
 To deactivate: menu [Edit][Preferences] tab [Advanced], untick the option
 (in the bottom) [Enable user interface localization (requires restart of
 openSCAD)]. 

*After program loading, Customizer is not activated, you need first to do a
 preview, either with [F5] key or by clicking the first icon below the view.
 
*Previewing run the default example, so you shall have a model shown in the
 viewing windows (after clicking [view all] button: third on bottom line)
 
*If you don't see anything after a preview, there is an installation problem,
 so check that you have downloaded all files and that the directory name is
 compliant with the specification as described in above paragraph.
 There shall be no error message in the console window.
 
*Any field modification is validated after an [enter] or after a move to
 another field. A modified field validation automatically run a new preview.
 
*You may want to impose camera position by ticking [Dictate the camera position],
 then untick it to free the camera (in the [Display] tab).
 
*Images can be exported from a simple preview ([F5]) with the command
 [File][Export][export as image].

*You cannot export DXF file from a preview, you need to do a render first ([F6]),
directly or after a preview, then do [File][Export][export as DXF].

Note that in the projection view, the view on the right bottom is not the front 
view but a view of the plane going through king pin axis.
 
When happy with a design, customizer can record it in a dataset, use the 
 button [+] to create a new dataset then [save preset] to save further
 modifications, each dataset can be recalled by selecting it in the dropdown menu.
 NOTHING is saved automatically.
If dataset recording don't work, see above note about the directory character sets.

Note that for variables with spinboxes (small box with top/down arrows),
 when you click in the value box, you can then use the mouse scroll wheel
 to modify the value. 

To export one par one your Customizer dataset and transfer to someone else or
to save your designs before an update, there is now the possibility to export
and import individual dataset with macros in a Libre Office text document.
You shall have Libre Office installed on your machine. The document is:
'Dataset_macros.odt'

Copyright 2019-2021 Pierre ROUZEAU, AKA "PRZ"
Program license GPL 3.0
documentation licence cc BY-SA 4.0 and GFDL 1.2
This uses my OpenSCAD library, attached, but if curious you can find details here:
https://github.com/PRouzeau/OpenScad-Library
This also use a rider model derived with significant modifications from the model
published in openbike.org/python wiki. See the file for details. 
This model still need improvement to better accept human body variability.

This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
