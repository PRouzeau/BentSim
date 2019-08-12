

/*
Géométrie et direction d'un tricycle ou d'un quadricycle
*/
// Copyright 2019 Pierre ROUZEAU,  AKA PRZ
// Program license GPL 4.0
// documentation licence cc BY-SA 4 and GFDL 1.2
// First version: 0.0 - August, 10, 2019
 
/*
  Cette application utilise ma librairie OpenSCAD, jointe, mais vous pouvez trouver des détails sur celle-ci ici:
	https://github.com/PRouzeau/OpenScad-Library

- Le modèle du cycliste vient d'une autre source, voir les commentaires dans son fichier.

Il y a deux types d'affichage possible
- La vue 3D, qui peut être xeportée en stl (après calcul du rendu)
- La projection à plat des axes de direction (suivant un plan passant par les axes), qui peut être exportée comme un fichier DXF (fichier de dessin). Dans cette vue il y a aussi une projection du pivot dans un plan perpendiculaire à l'axe du pivot, ainsi qu'une vue de dessus et de coté.

	Dans cette vue, il peut être préférable de supprimer l'afficache des axes (onglet affichage).
	
	Il n'y a pas simulation complete de la rotation des roues, seule la roue droite peut tourner pour vérifier les encombrements et l'élevation de la roue.

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
/*[Caméra]*/ 
//Utilise la position de la caméra définie ci-dessous - peut être inactivé pour les animations
Dictate_camera_position=false; 
//Dictate_camera_position=$firstpreview; 
// The camera variables shall NOT be included in a module - a module CANNOT export variables
//Vue de dessus
Top_view = false;
//Distance de la caméra
Cimp = Dictate_camera_position||Top_view; 
$vpd=Cimp?Top_view?6000:4000:$vpd; 
//Vecteur de déplacement
$vpt=Cimp?[470,80,580]:$vpt; 
//Vecteur de rotation
$vpr=Cimp?Top_view?[0,0,0]:[70,0,300]:$vpr; 
echo_camera();

/*[Affichage]*/ 
//Affiche les arbres (sinon seulement les axes)
display_shafts = true;
//Affiche le cycliste
display_rider = false;
//Affiche les roues (sinon modèle filaire)
display_wheels = true;
//Affiche la transmission
display_transmission = false;
//Affiche info et avertissements dans la console
inf_text = true;
//Affiche avertissements et données dans la fenêtre de visualisation
disp_text = true;
//Type de vue
view_type = 0; // [0:Vue 3D, 1:Projection, 2: projection latérale de la vue 3D]
//Rotation de la direction (degrés), roue avant droite seulement
steering_rot=0;

/*[Dimensions]*/ 
//Référence projet
proj_ref = "Ref. projet";
//Empattement
wheel_base = 1150;
//Voie avant
front_wheel_track = 700;
//diamètre de jante roue avant
front_wheel_rim = 406; //[305,406,507,559,622]
//Largeur du pneu avant
front_wheel_tire = 47; //[22:125]
//Voie arrière: 0 pour un tricycle
rear_wheel_track = 0;
//diamètre de jante roue arrière
rear_wheel_rim = 559; //[305,406,507,559,622]
//largeur du pneu arrière
rear_wheel_tire = 37; //[22:125]
//Angle de chasse des pivots avant
caster_angle = 15;
//Angle de carrossage roues avant
camber_angle = 5;
//Déport de l'axe roue avant (si l'axe de direction n'est pas dans le même plan que l'axe des roues)
axis_offset= 0;
//Angle de carrossage roues arrières
rear_camber_angle = 5;

//Inclinaison du pivot de direction (dans le plan des pivots - incliné suivant l'angle de chasse)
king_pin_angle = 15;
//Extension de l'arbre de pivot au dessus de l'axe
above_extent = 65;
//Extension de l'arbre de pivot au dessous de l'axe
below_extent = 40;

//Hauteur du plan de tringlerie de direction au dessus de l'axe des roues
arm_position = 40;
//Longueur du levier
arm_length = 60;
//Correction hauteur du levier de direction
arm_height_correction = 3;

/*[Transmission]*/
//Position longitudinale du pédalier
BB_long_pos = -300;
//Hauteur du pédalier
BB_height = 370;
//Longueur des manivelles
crank_arm_length = 152;
//Largeur de l'arbre de pédalier
crankshaft_width = 117;
//Nombre de dents du plateau
chainring_teeth = 38;
//Position latérale de la ligne de chaîne
chainline_position = 50;

/*[Cycliste]*/ 
// Hauteur di siège
seat_height = 310;
//Distance entre le siège et l'axe des roues avant
seat_front_distance = 475;
// Angle des jambes par rapport au corps
a_seat=60;
//Angle du dossier de siège par rapport au sol
seat_angle = 48;

//============================
/*[Couleurs]*/ 
//Couleur cadre
c_frame="orange";
//Couleur pneus
c_tire=[0.4,0.4,0.4]; 
//Couleur acier
c_steel="darkgray";
//Couleur aluminium
c_alu=[0.8,0.8,0.8];
//Couleur pédale
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
techo("Diamètre roue avant: ",front_wheel_hdia*2, "mm, Jante:",front_wheel_rim);
techo("Diamètre roue arrière: ",rear_wheel_hdia*2, "mm, Jante:",rear_wheel_rim);
techo("Empattement: ",wheel_base," mm");
techo("Voie avant: ",front_wheel_track," mm");
techo("Voie arrière: ",rear_wheel_track," mm");
techo("Angle du pivot de direction: ",headtube_angle, " °");
techo("Chasse: ",r10(trail)," mm");
techo("Longueur arbre entre le milieur de la roue et l'axe du pivot: ",r10(shaft_length)," mm");
techo ("Longueur du demi-arbre arrière (au milieu de la roue): ",rear_shaft_lg," mm");

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
} //3D view

module flat_view () {
	projection() {
		//w_track();
		r(0,90-caster_angle)
			t(trail)
				steering(true);
		//pivot
		t(front_wheel_hdia+50,600)
			r(king_pin_angle)
				r(0,-caster_angle)
					t(trail)
						steering(true,false);
		//top view
		t(-1800) {
			steering(false, true, steering_rot);
			rear_shafts(false);
		}
		//side view
		t(-1800,700) r(-90) {
			steering(false,true,steering_rot);
			rear_shafts(false);
			cubey(1800,10,d_line, 600);
			cylz(d_line,front_wheel_hdia, 0,front_wheel_track/2,0, 6);
		}
	}
	t(-1000,-400)
		print_info(30);
	t(-1400,600)
		print_spec(30);
	t(400,100)
		multiLine(["View following a plane going"," through both kingpin axis"],32,false);
	//fr::multiLine(["Vue suivant un plan","passant par les axes de pivot"],32,false);
	t(400,600)
		multiLine(["View perpendicular"," to kingpin axis."],32, false);
	//fr::multiLine(["Vue perpendiculaire"," à l'axe du pivot."],32, false);
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
							//wheel_symb(rear_wheel_hdia*2);
						}
						else {
							cyly(-ds,135, 0,0,0, 6);
							cyly(-d_line,150, 0,0,0, 6);
							//wheel_symb(rear_wheel_hdia*2);
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
	/*check diam
	check()
		diff() {
			cyly(-(manlength*2+40),80);
			cyly(-(manlength*2+35),90);
		}
	*/
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
	//arlg = 385; //top
	//arlg2 = 460; //bottom
	//fda = (folded_wheel||stored_pos)?folding_angle-10:rfa-12;
	//echo(fda=fda);
	//sig = fda<0?-1:1;
	//rad = fda<0?-28:id_rad;
	//modsp = -2.5;
	modsp = 0;
	color (c_steel) {
	r(0,top_ang) // chainring to idler
		cylx(10,mlg,0,-chainline_position,dch/2); 
			//tb_xz(10,rad,sig*(25.8+fda+modsp))
			//idler to sprocket
			//cylx(10,-arlg);
	
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

module tb_xy (dtube=25,radius=100,ang=90) {
	rotate([0,0,90])
		tb_yx(dtube,radius,ang)
			rotate([0,0,-90]) children();
}

module tb_xz (dtube=25,radius=100,ang=90) {
	r(90) rotz(90)
		tb_yx(dtube,radius,ang)
			rotz(-90) r(-90) children();
}

module tb_zy (dtube=25,radius=100,ang=90) {
	r(0,90) rotz(90)
		tb_yx(dtube,radius,ang)
			rotz(-90) r(0,-90) children();
}

module tb_zx (dtube=25,radius=100,ang=90) {
	r(90)
		tb_yx(dtube,radius,ang)
			r(-90) children();
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
	//fr::["Géometrie d'un tricycle",
"https://github.com/PRouzeau/Trike-geometry",
	"App (c) Pierre ROUZEAU",
	"Licence GPL V3"
	]
	, size);
}

module print_spec (size = 30) {
	multiLine([
	str("Project reference: ",proj_ref),
	//fr::str("Référence projet: ",proj_ref),
str("Roue avant: Jante ",front_wheel_rim, " Pneu: ",front_wheel_tire, " mm diam. ",front_wheel_hdia*2," mm"),
str("Roue arrière: Jante ",rear_wheel_rim, " Pneu: ",rear_wheel_tire, " mm diam. ",rear_wheel_hdia*2," mm"),
str("Voie avant: ",front_wheel_track," mm - Voie arrière: ",rear_wheel_track," mm"),
str("Empattement: ",wheel_base," mm"),
str("Angle du pivot de direction: ",headtube_angle, " °"),
str("Déport roue avant: ", axis_offset,"mm  Chasse: ",r10(trail)," mm")
	]
	,size,false);
}

//print_spec (50);

