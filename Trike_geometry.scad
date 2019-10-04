/*en+
Front steering tricycle ('tadpole') or quadricycle geometry and steering
*/
/*fr+
Géométrie et direction d'un tricycle à direction avant ou d'un quadricycle
*/
// Copyright 2019 Pierre ROUZEAU,  AKA PRZ
// Program license GPL 4.0
// documentation licence cc BY-SA 4 and GFDL 1.2
// First version: 0.0 - August, 10, 2019
// revised October, 4, 2019
 
/*en+
  This uses my OpenSCAD library, attached, but you can find details here:
 https://github.com/PRouzeau/OpenScad-Library
-- The rider came from elsewhere --
See comments in the rider file

There is two possible displays
- The 3D view, which can be exported as stl file (after rendering)
- The projection of steering axis on plane going through king pins, which can be exported as DXF file (CAD file). In this view, you will also find a pivot projection, seen in a plane perpendicular to king pin and top and side views. 
	For this view, you may prefer to cancel shaft display (in display tab on customizer panel)
	
	There is no complete steering simulation, yet only right wheel rotate to check clearances and you can have a look to wheel elevation when turning.

Note that in openscad the rendering may take some time. Projection also need some calculation time.
*/
/*fr+
  Cette application utilise ma librairie OpenSCAD, jointe, mais vous pouvez trouver des détails sur celle-ci ici:
	https://github.com/PRouzeau/OpenScad-Library

- Le modèle du cycliste vient d'une autre source, voir les commentaires dans son fichier.

Il y a deux types d'affichage possible
- La vue 3D, qui peut être exportée en stl (après calcul du rendu)
- La projection à plat des axes de direction (suivant un plan passant par les axes), qui peut être exportée comme un fichier DXF (fichier de dessin). Dans cette vue il y a aussi une projection du pivot dans un plan perpendiculaire à l'axe du pivot, ainsi qu'une vue de dessus et de coté.

	Dans cette vue, il peut être préférable de supprimer l'affichage des axes (onglet affichage dans le panneau de personnalisation).
	
	Il n'y a pas de simulation complète de la rotation des roues, seule la roue droite peut tourner pour vérifier les encombrements et l'élevation de la roue.

Il faut noter que le calcul de rendu est assez long avec OpenScad.
	La projection prend aussi un petit moment à calculer.
*/

//*******************************
include <Z_library.scad>
include <Velo_rider.scad>

/*[Hidden]*/ 
//mini_hole=false;
rider=false; //unactivate library model

//================================
/*fr:[Caméra]*/ 
/*[Camera]*/
//fr:Utilise la position de la caméra définie ci-dessous - peut être inactivé pour les animations
//Use the camera position defined below - could be unactivated for animations
Dictate_camera_position=false; 
//Dictate_camera_position=$firstpreview; 
// The camera variables shall NOT be included in a module - a module CANNOT export variables
//fr:Vue de dessus
//View from top
Top_view = false;

//Impose camera if rotation vector is default
Cimp = Dictate_camera_position||Top_view||$vpr==[55,0,25]; 

//fr:Distance de la caméra
//Camera distance
$vpd=Cimp?Top_view?6000:4000:$vpd; 
//fr:Vecteur de déplacement
//Camera translation 
$vpt=Cimp?[470,80,580]:$vpt; 
//fr:Vecteur de rotation
//Camera rotation
$vpr=Cimp?Top_view?[0,0,0]:[70,0,300]:$vpr; 
echo_camera();

/*fr:[Affichage]*/ 
/*[Display]*/ 
//fr:Affiche les arbres (sinon seulement les axes)
//Display shafts (else only axis)
display_shafts = true;
//fr:Affiche le cycliste
//Display rider
display_rider = false;
//fr:Affiche les roues (sinon modèle filaire)
//Display full wheels (else wire model)
display_wheels = true;
//fr:Affiche la transmission
//Display transmission
display_transmission = false;
//fr:Affiche info et avertissements dans la console
//Display information and warning in the console
inf_text = true;
//fr:Affiche avertissements et données dans la fenêtre de visualisation
//Display information and warning in the view windows
disp_text = true;
//fr:Type de vue
//View type
view_type = 0; // [0:3D view, 1:Projection, 2: 3D side projection]
//fr::view_type = 0; // [0:Vue 3D, 1:Projection, 2: projection latérale de la vue 3D]
//fr:Rotation de la direction (degrés), roue avant droite seulement
//Steering rot angle (deg), front right wheel only
steering_rot=0;

/*[Dimensions]*/ 
//fr:Référence projet
//Project reference
proj_ref = "Test project";
//fr::proj_ref = "Ref. projet";
//fr:Empattement
//Wheel base
wheel_base = 1150;
//fr:Voie avant
//Front wheels track
front_wheel_track = 700;
//fr:diamètre de jante roue avant
//Front wheel rim diameter
front_wheel_rim = 406; //[305,406,507,559,622]
//fr:Largeur du pneu avant
//Front tire width
front_wheel_tire = 47; //[22:125]
//fr:Voie arrière: 0 pour un tricycle
//Rear wheel track: 0 for a trike
rear_wheel_track = 0;
//fr:diamètre de jante roue arrière
//Rear wheel rim diameter
rear_wheel_rim = 559; //[305,406,507,559,622]
//fr:largeur du pneu arrière
//Rear tire width
rear_wheel_tire = 37; //[22:125]
//fr:Angle de chasse des pivots avant
//front steering caster angle
caster_angle = 15;
//fr:Angle de carrossage roues avant
//Front wheel camber angle
camber_angle = 5;
//fr:Déport de l'axe roue avant (si l'axe de direction n'est pas dans le même plan que l'axe des roues)
//Front wheel axis offset (rake - if steering axis is not in same plane as wheel shaft)
axis_offset= 0;
//fr:Angle de carrossage roues arrières
//Rear wheel camber angle
rear_camber_angle = 5;

//fr:Inclinaison du pivot de direction (dans le plan des pivots - incliné suivant l'angle de chasse)
//King pin axis angle (in steering axis plane, reclined per caster angle)
king_pin_angle = 15;
//fr:Extension de l'arbre de pivot au dessus de l'axe
//King pint shaft extenstion above wheel shaft
above_extent = 65;
//fr:Extension de l'arbre de pivot au dessous de l'axe
//King pin shaft extension below wheel shaft
below_extent = 40;

//fr:Hauteur du plan de tringlerie de direction au dessus de l'axe des roues
//Arm steering plane above wheel axis height
arm_position = 40;
//fr:Longueur du levier
//Arm (lever) length
arm_length = 60;
//fr:Correction hauteur du levier de direction
//Arm (lever) height correction
arm_height_correction = 3;

/*[Transmission]*/
//fr:Position longitudinale du pédalier
//Longitudinal bottom bracket position
BB_long_pos = -300;
//fr:Hauteur du pédalier
//Bottom bracket height
BB_height = 370;
//fr:Longueur des manivelles
//Crank arm length
crank_arm_length = 152;
//fr:Largeur de l'arbre de pédalier
//Crank shaft width
crankshaft_width = 117;
//fr:Nombre de dents du plateau
//Chainring teeth number
chainring_teeth = 38;
//fr:Position latérale de la ligne de chaîne
//Chainline side position
chainline_position = 50;

/*fr:[Cycliste]*/ 
/*[Rider]*/
//fr: Hauteur di siège
//Seat height
seat_height = 310;
//fr:Distance entre le siège et l'axe des roues avant
//Seat distance from front wheel axis
seat_front_distance = 475;
//fr: Angle des jambes par rapport au corps
//Leg angle / body
a_seat=60;
//fr:Angle du dossier de siège par rapport au sol
//Seat back angle from ground plane
seat_angle = 48;

//============================
/*fr:[Couleurs]*/ 
/*[Colors]*/
//fr:Couleur cadre
//Frame color
c_frame="orange";
//fr:Couleur pneus
//Tire color
c_tire=[0.4,0.4,0.4]; 
//fr:Couleur acier
//Steel color
c_steel="darkgray";
//fr:Couleur aluminium
//Aluminium color
c_alu=[0.8,0.8,0.8];
//fr:Couleur pédale
//Pedal color
c_pedal = [0.3,0.3,0.3];

/*[Hidden]*/ 
d_line = $preview?2:0.2;

//-- calculation -------------
function wheel_diam (rim,tire)= rim+2*tire+4;

front_wheel_hdia= wheel_diam(front_wheel_rim,front_wheel_tire)/2;

rear_wheel_hdia= wheel_diam(rear_wheel_rim,rear_wheel_tire)/2;

ground_length = front_wheel_hdia/cos(caster_angle);
trail_base = ground_length*sin(caster_angle);
trail = trail_base-axis_offset;

steering_length = 
	ground_length/cos(king_pin_angle-camber_angle);
shaft_length = steering_length * sin(king_pin_angle-camber_angle);
king_pin_offset = steering_length*sin(king_pin_angle);

pivot_height = (front_wheel_hdia/cos (king_pin_angle-camber_angle))*cos (king_pin_angle);

wheel_shaft_lg = atan(king_pin_angle-camber_angle)*ground_length;

arm_y_offset = arm_position*sin(king_pin_angle);
echo(arm_y_offset=arm_y_offset);
arm_z_plane = arm_position*cos(king_pin_angle);
arm_x_offset = arm_z_plane* sin(caster_angle);
arm_z_offset = arm_z_plane* cos(caster_angle);

headtube_angle = 90-caster_angle;

//this wheel flop calculation does not take into account king pin angle, so it is wrong
wheel_flop = cos(headtube_angle)*sin(headtube_angle)*trail;

//length of an half rear shaft for a quad
rear_shaft_lg = rear_wheel_track?rear_wheel_track/cos(rear_camber_angle)/2-rear_wheel_hdia*tan(rear_camber_angle):0;

//== Geometry data calc ======
x_ackermann = wheel_base-arm_x_offset-axis_offset;
y_ackermann = front_wheel_track/2-king_pin_offset-arm_y_offset;
ackermann_angle = atan(y_ackermann/x_ackermann);
echo(ackermann_angle=ackermann_angle);
lg_ackermann = x_ackermann/cos(ackermann_angle);

lgep = front_wheel_track/2-shaft_length-arm_y_offset;
lg_steer = lgep-arm_length*sin(ackermann_angle);

arm_z_dec = 
	arm_length*sin(caster_angle)+arm_height_correction; //?? composed angle, not caster angle ? 
arm_r_length= arm_length*cos(caster_angle)*0.99; //?? composed angle, not caster angle ? 

//effective rear camber angle - 0 when tricycle
rear_camb_a = rear_wheel_track?rear_camber_angle:0;

//== Console messages ========
techo("Front wheel diameter: ",front_wheel_hdia*2, "mm, Rim:",front_wheel_rim);
//fr::techo("Diamètre roue avant: ",front_wheel_hdia*2, "mm, Jante:",front_wheel_rim);
techo("Rear wheel diameter: ",rear_wheel_hdia*2,"mm, Rim:",rear_wheel_rim);
//fr::techo("Diamètre roue arrière: ",rear_wheel_hdia*2, "mm, Jante:",rear_wheel_rim);
techo("Wheel base: ",wheel_base," mm");
//fr::techo("Empattement: ",wheel_base," mm");
techo("Front wheel track: ",front_wheel_track," mm");
//fr::techo("Voie avant: ",front_wheel_track," mm");
techo("Rear wheel track: ",rear_wheel_track," mm");
//fr::techo("Voie arrière: ",rear_wheel_track," mm");
techo("Headtube angle: ",headtube_angle, " °");
//fr::techo("Angle du pivot de direction: ",headtube_angle, " °");
techo("Trail: ",r10(trail)," mm");
//fr::techo("Chasse: ",r10(trail)," mm");
techo("Shaft length from wheel center to king pin axis: ",r10(shaft_length)," mm");
//fr::techo("Longueur arbre entre le milieur de la roue et l'axe du pivot: ",r10(shaft_length)," mm");
techo ("Rear half shaft length (to wheel middle): ",rear_shaft_lg," mm");
//fr::techo ("Longueur du demi-arbre arrière (au milieu de la roue): ",rear_shaft_lg," mm");

//== Program =================

if (view_type==1)
	flat_view();
else if (view_type==2)
	projection() 
		r(-90) 
			3Dview();
else // 0
	3Dview();



//== 3D view =================
module 3Dview () {
	//ground
	gray() 
		cubex(wheel_base+1000, 1200, 1,-500);
	//
	w_track();
	arrow();
	all_wheels();
	rear_shafts(display_shafts);
	disp_rider();
	disp_transmission();
	steering(false,true,steering_rot);
	t(500,-400)
		print_info(30);
}

//== Flat view =================
module flat_view () {
	module p_arrow (ry=0,rz=0, tx = "") {
		r(0,ry,rz) {
			cubex(-100,5,5);
			dmirrorz() 
				r(0,15)
					cubex(-27,5,4);
			t(-75,0,12)
				r(90)
					linear_extrude (1)
						text(tx, 32, $fn=16);
		}
	}
	
	projection() {
		// Steering blueprint
		r(0,90-caster_angle)
			t(trail) {
				steering(true);
				// Arrow
				r(king_pin_angle)
					t(0,front_wheel_track/2, 420) 
						p_arrow(90,90, "A");
			}
		// Pivot
		t(front_wheel_hdia+50,600)
			r(king_pin_angle)
				r(0,-caster_angle)
					t(trail)
						steering(true,false);
		// Top view
		t(-1800) {
			steering(false, true, steering_rot);
			rear_shafts(false);
		}
		// Side view
		t(-1800,700) r(-90) {
			steering(false,true,steering_rot);
			rear_shafts(false);
			cubey(1800,10,d_line, 600);
			cylz(d_line,front_wheel_hdia, 0,front_wheel_track/2,0, 6);
			// Arrows
			tslz (front_wheel_hdia)
				r(0, caster_angle) {
					t(-70) p_arrow(0,0,"B");
					tslz (200)
						p_arrow(90,0,"A");
				}
		}
	}
		
	//-- TEXT --------------------
	t(-1000,-400)
		print_info(30);
	t(-1500,630)
		print_spec(30);
	t(400,100)
		multiLine(["View B"],32,false);
//fr::	multiLine(["Vue B"],32,false);
	t(400,600)
		multiLine(["View A"],32, false);
//fr::	multiLine(["Vue A"],32, false);
}

//--display transmission --------
module disp_transmission () {
	if (display_transmission)
		t(BB_long_pos,0,BB_height)
			pedals(crank_arm_length);
}

//-- display wheel track --------
module w_track () {
		blue()
		dmirrory() {
			cubez(120,1,5, -60,front_wheel_track/2);
		}
}
//-- display rider --------------
module disp_rider (){
	if(display_rider)
		t(seat_front_distance,0,seat_height)
			mirrory()
				veloRider(90-seat_angle);
}

// Line wheel symbol
module wheel_symb (dw=0, top_symb=true) {
	//if(view_type) {//view_type==0->3D
		difference() {
			cyly(-30,d_line, 0,0,0, 8);
			cyly(-10,10, 0,0,0, 8);
		}
		if(dw) {
			difference() {
				cyly(-dw,d_line, 0,0,0, 32);
				cyly(-dw+2*d_line,10, 0,0,0, 32);
			}
			if(top_symb)
				dmirrorx()
					cubex(-d_line,30,3, dw/2,0 ,0); 
		}
	//}
}

//-- display all wheels -------
module all_wheels () {
	//front wheels
	steer(steering_rot) 
		fwheel();
	mirrory()
		fwheel();
		//front wheel shafts
		front_wheel_shaft(display_shafts);
	//rear wheel(s)
	dmirrory(rear_wheel_track) 
		t(wheel_base,rear_wheel_track/2)
			r(rear_camb_a)
				tslz(rear_wheel_hdia)
					if (display_wheels)
						wheel(rear_wheel_rim,rear_wheel_tire, shaft_width = 85, , spa=6.8);
					else 
						wheel_symb(rear_wheel_hdia*2,true);
						
	
	//spa angle parameter to adjust spoke spacing, should be user accessible ??
	module fwheel() {
		t(0,front_wheel_track/2)
			r(camber_angle)
				t(0,0,front_wheel_hdia)
					if(display_wheels)
						wheel(front_wheel_rim,front_wheel_tire, shaft_width=66, spa=3.7);
					else 
						wheel_symb(front_wheel_hdia*2,true);
	}
	//following double partly what is in steering() module  - for axis
	module front_wheel_shaft (shaft=false) {
		// Wheel shaft
		steer(steering_rot)
			fwshaft();
		mirrory()
			fwshaft();
		module fwshaft () {
			d = shaft?15:d_line;
			clrx = shaft?"silver":"orange";
			//line
			color(clrx)
				t(0,front_wheel_track/2)
				r(camber_angle)
					cyly(d,-shaft_length,0,0,front_wheel_hdia);
		}
	}
} //all_wheels

module rear_shafts (shaft=true) {
	ds = shaft?15:d_line;
	dmirrory(rear_wheel_track) 
		t(wheel_base,rear_wheel_track/2)
			r(rear_camb_a)
				tslz(rear_wheel_hdia)
					red()
						if(rear_wheel_track) {
							cyly(ds, -rear_shaft_lg);
							wheel_symb(rear_wheel_hdia*2);
						}
						else {
							cyly(-ds,135, 0,0,0, 6);
							cyly(-d_line,150, 0,0,0, 6);
							wheel_symb(rear_wheel_hdia*2);
						}
}

//-- display 3D steering -----------
module steering (flat = false, mirr=true, rot=0) {
	steer(rot)
		hsteering (flat, rot);
	if (mirr)
		mirrory()
			hsteering (flat, 0);
}

//steer origin is 0,0
module steer (srot) {
	t(axis_offset,front_wheel_track/2-king_pin_offset, pivot_height)
		r(0,caster_angle)
			r(king_pin_angle) 
			 rotz(srot)
				r(-king_pin_angle)
					r(0,-caster_angle)
						t(-axis_offset,-front_wheel_track/2+king_pin_offset, -pivot_height)
							children();
}

module hsteering (flat = false, srot=0) {
		t(axis_offset,front_wheel_track/2-king_pin_offset, pivot_height) {
			//front wheel shaft axis
			r(camber_angle) {
				cyly(d_line,shaft_length, -axis_offset,0,0, 6);
				t(-axis_offset,shaft_length)
					if(view_type)
						wheel_symb(front_wheel_hdia*2, !flat);
			}
			//king pin
				r(0,caster_angle)
					r(king_pin_angle) {
						//axis
						red() 
							cylz(d_line,450, 0,0,-steering_length, 6);
						//shaft
						if(display_shafts)
							silver()
								difference() {
									cylz(15,above_extent+below_extent, 0,0,-below_extent);
									cylz(-8,400, 0,0,0, 6);
								}
					} //king pin
			t(arm_x_offset,-arm_y_offset,arm_z_offset)
				orange() {
					if (!flat)
						rotz(-srot)
							cyly(d_line,-lgep+1, 0,0,0, 6);
					t(arm_length*cos(ackermann_angle),-lgep+lg_steer+1)
					rotz(-srot)
						cyly(d_line,-lg_steer, 0,0,0,6);
					if (!flat)
						rotz(-ackermann_angle-srot) 
							cylx(d_line,lg_ackermann, 0,0,0, 6);
					// arm
					r(0,caster_angle)
						r(king_pin_angle) 
							rotz(-ackermann_angle*0.63)
								tslz (arm_z_dec) {
									duplx(arm_r_length) 
										cylz(-d_line,10,0,0,0, 6);
									cylx (d_line, arm_r_length, 0,0,0, 6)
									if(display_shafts)
										diff() {
											hull()
												duplx(-arm_r_length) //?? composed angle, not caster angle ? 
													cylz(-25,6);
											duplx(-arm_r_length) 
												cylz(-8,66,0,0,0, 6);
										} //diff
								}
				}
		}
} //Steering

//-- Ground arrow --------------
module arrow() {
	orange() {
		cubex(-200,30,1,-200,0,1);
		hull() {
			cubex(-2,80,1,-400,0,1);
			cubex(-50,1,1,-400,0,1);
		}
	}
}

//== LIBRARY ===================
module wheel (rim=559, tire=40, hubdia=60, hubwidth=60, spa=6.8, shaft_width = 140) {
	// spa is an angle allowing to adjust the spoke spacing
	w=rim+2*tire+4; 
	//echo ("wheel diam",w);
	spd = 2.2; // spoke diameter
	spr = hubdia/2+8; // spoke radius
	spkface = 12;
	//tire
	color(c_tire) 
		r(90)
			rotate_extrude(convexity = 10, $fn=64) {
				t(w/2-tire/2, 0, 0) 
					circle(r = tire/2, $fn=30); 
			} 
	color(c_alu) {
	//rim
		diff(){
			cyly(-(w-tire*2+10),0.6*tire); 
			cyly(-(w-tire*2-25),60, 0,0,0, 72); 
		}
	// shaft
		cyly(-9,shaft_width);
	//hub
		cyly(-hubdia,hubwidth);
		dmirrory()
			cyly(hubdia+25,3, 0,hubwidth/2-3);
	//spokes
		lgspoke = w/2-tire-10;
		spangle = atan((hubwidth/2+2)/lgspoke);
		spangle2 = atan((hubwidth/2-5)/lgspoke);
		droty(40,8){
			r(0,-spa) rotz(-spangle)
				cylx(spd,lgspoke, 0,hubwidth/2+1,spr, spkface);
			r(0,spa+30) rotz(-spangle2)
				cylx(spd,lgspoke, 0,hubwidth/2-5,-spr, spkface);
			// other side
			r(0,10) {
				r(0,-spa) rotz(spangle)
					cylx(spd,lgspoke, 0,-hubwidth/2-1,spr, spkface);
				r(0,spa+30) rotz(spangle2)
					cylx(spd,lgspoke, 0,-hubwidth/2+5,-spr, spkface);
			}
		}
	}
} //wheel

module pedals (manlength=170, cr_ang=-35, ped_ang=90, top_lg=900, top_ang=13,bot_lg=900,bot_ang=5) {
	cr2 = crankshaft_width/2;
	//chainring diam
	dch = chainring_teeth*12.7/PI;
	color (c_steel) {
	//inside bottom bracket
	cyly(-32.5,68);
	//cup sides
	dmirrory()
		cyly(41,2,0,34);
	}
	module crank_arm (cr2, ang) {
		color (c_alu) {
			//shaft
			cyly (20,cr2);
			//crank arm
			cyly(30,14, 0,cr2-15);
			hull() {
				cyly(30,16, 0,cr2-1);
				cyly(22,12, manlength/2,cr2+10);
			}
			hull() {
				cyly(22,12, manlength/2,cr2+10);
				cyly(22,12, manlength,cr2+10);
			}
		}
		//pedals
		color (c_pedal)
			t(manlength,cr2+22) {
				cyly (16,105);
				r(0,ped_ang) 
					hull() {
						cyly(18,95, 0,9);
						dmirrorx() 
							cyly(18,70, 45,9+12);
					}
			}
	} //crank_arm()
	r(0,cr_ang) {
		crank_arm(cr2,-80);
	mirrory()
		r(0,180)
			crank_arm(cr2,-85);
		//chainring
		color(c_steel) 
			cyly(-dch,5, 0,-chainline_position);
	}
	//chain
	mlg = top_lg; // top chainring to idler
	mlg2 = bot_lg; // bottom chain length
	modsp = 0;
	color (c_steel) {
	r(0,top_ang) // chainring to idler
		cylx(10,mlg,0,-chainline_position,dch/2); 

	
  //direct chain (over double wheel tensioner)
	r(0,bot_ang)
		cylx(10,mlg2,0,-chainline_position,-dch/2)
		tb_xz(10,-24,-157)
		cylx(10,-8)
		tb_xz(10,24,-182)
		cylx(10,40);
	}
	/*
	chainlg = 
	ceil(chainring_teeth*0.55+ //chainring
	9+ // pinion
	2+ //idler
	10+ // tensioner
	(mlg+mlg2+arlg+arlg2)/12.7); //straight
	echo("chain links",chainlg);
	*/
}

//tube bend AND displacement
module tb_yx (dtube=25,radius=100,ang=90) {
	//echo("bend");
	sang = radius<0?ang:-ang;
	dx=-(1-cos(sang))*-radius;
	dy=sin(sang)*-radius;
	t(radius)
		rotate_extrude(angle=sang, $fn=128, convexity=10)
			translate([-radius,0,0])
				circle(d=dtube);
	t(dx,dy) rotz(sang) children();
}

module tb_xz (dtube=25,radius=100,ang=90) {
	r(90) rotz(90)
		tb_yx(dtube,radius,ang)
			rotz(-90) r(-90) children();
}

//-- Information text -------------
module techo (var1, var2="",var3="", var4="",var5="",var6="", var7="",var8="") {
  if (inf_text) {
    txt = str(var1,var2,var3,var4,var5,var6,var7,var8);
    echo(txt);
  }  
}

//-- Round number to 1/10 --
function r10 (x) = round(x*10)/10;

//Printing multiples lines in a vector
module multiLine (lines, size=1000, large_first = true, always=false){
	pr = 16;
		if(disp_text||always)
			union(){
				for(i=[0:len(lines)-1])
					translate([0 , -i *size*(1.5)*(i?1:1.2), 0 ])  text(lines[i], size*(i?1:(large_first?1.2:1)), $fn=pr);
			}
}

module print_info (size = 30) {
	multiLine(
		["Trike geometry",
//fr::		["Géometrie d'un tricycle",
"https://github.com/PRouzeau/Trike-geometry",
	"(c) 2019 Pierre ROUZEAU",
	"Licence GPL V3"
	]
	, size);
}

module print_spec (size = 30) {
	multiLine([
	str("Project reference: ",proj_ref),
//fr::	str("Référence projet: ",proj_ref),
	str("Front wheel: Rim ",front_wheel_rim, " Tire: ",front_wheel_tire, " mm diam. ",front_wheel_hdia*2," mm"),
//fr::	str("Roue avant: Jante ",front_wheel_rim, " Pneu: ",front_wheel_tire, " mm diam. ",front_wheel_hdia*2," mm"),
	str("Rear wheel: Rim ",rear_wheel_rim, " Tire: ",rear_wheel_tire, " mm diam. ",rear_wheel_hdia*2," mm"),
//fr::	str("Roue arrière: Jante ",rear_wheel_rim, " Pneu: ",rear_wheel_tire, " mm diam. ",rear_wheel_hdia*2," mm"),
str("Front wheels track: ",front_wheel_track," mm - Rear wheels track: ",rear_wheel_track," mm"),
//fr::	str("Voie avant: ",front_wheel_track," mm - Voie arrière: ",rear_wheel_track," mm"),
str("Wheel base: ",wheel_base," mm"),
//fr::	str("Empattement: ",wheel_base," mm"),
str("Headtube angle: ",headtube_angle, "° ,wheel offset (rake): ", axis_offset,"mm  Trail: ",r10(trail),"mm"),
//fr::str("Angle du pivot de direction: ",headtube_angle, "°  ,déport roue: ", axis_offset,"mm  Chasse: ",r10(trail),"mm")
	]
	,size,false);
}

//print_spec (50);

