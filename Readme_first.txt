TRIKE GEOMETRY
This application is intended to design a trike (or quad) geometry and steering.
It is mainly studied for human powered cycles, but you can also use it
 for larger motorised machines.
It simply generate the blueprint and no calculations (except trail) are done.
Note that this application also exist in french, see "Lisez_moi.txt".

Steering is designed with pure Ackermann geometry without compensation.
After defining the geometry, you have to project the model on planes to be
 able to export drawings in DXF format to be used in any CAD.

By default, rider and transmission are not shown, you can display them in
 [Display] tab. They will be removed when projecting the geometry blueprint.

Projection is done in [Display] tab by selecting the [view type] 'Projection'. 
This requires some time to be calculated.
Another option is to project the 3D model sideview (which can include rider
and transmission), but the calculation time is significant (a few minutes).

There are basic element for modeling (wheels, rider and transmission)
 but this program is not intended as a full fledged cycle modeler.
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
You shall at least use the last official version (2019.05).

*The complete path of the directory where you install this application
 (Trike geometry or any other) shall only use ASCII characters, without
 spaces, accented letters, any diacritic, umlaut or other character set.
Without these conditions, Customizer dataset cannot be saved.

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
*Any field modification is validated after an [enter] or after a move to
 another field. A modified field validation automatically run a new preview.
*You may want to impose camera position by ticking [Dictate the camera position],
 then untick it to free the camera (in the [Display] tab).
*Images can be exported from a simple preview ([F5])
*You cannot export DXF file from a preview, you need to do a render first ([F6]),
directly or after a preview.

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

Copyright 2019 Pierre ROUZEAU, AKA "PRZ"
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