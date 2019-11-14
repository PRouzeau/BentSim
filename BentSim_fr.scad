

/*
BentSim, un simulateur de vélo couché
Bentsim permet la simulation 3D d'un vélo couché, bicycle, tricycle ou quadricycle. Il peut notamment exporter une épure du vélo complet et de sa direction. Un volume 3D global ou diverses projections peuvent aussi être exportées.
Taille et proportion du cycliste ajustable.
Cadre monotube (circulaire ou rectangulaire)
Suspension arrière en option.
*/
// Copyright 2019 Pierre ROUZEAU,  AKA PRZ
// Program license GPL V3
// documentation licence cc BY-SA 4.0 and GFDL 1.2
// First version: 0.0 - August, 10, 2019 as Trike geometry only
//Revised October, 4, 2019
//Revised November, 10, 2019 as general Recumbent simulator
//Rev Nov, 14, 2019. Bug correction and rear suspension
/*
	L'Application peut être téléchargée ici:
	https://github.com/PRouzeau/BentSim
	La procédure de téléchargement et d'installation est ici:
	http://rouzeau.net/OpenSCAD/Applications
  Des explications d'utilisation peuvent être trouvées ici:
	http://rouzeau.net/OpenSCAD/BentSim

  Cette application utilise ma librairie OpenSCAD, comprise dans le téléchargement, mais vous pouvez trouver des détails sur celle-ci ici:
	https://github.com/PRouzeau/OpenScad-Library

- Le modèle du cycliste vient d'une autre source et a été beaucoup modifié, voir les commentaires dans son fichier.

Il y a plusieurs types d'affichages possible
- La vue 3D, qui peut être exportée en stl (après calcul du rendu)
- La projection à plat des axes de direction (suivant un plan passant par les axes), qui peut être exportée comme un fichier DXF (fichier de dessin). Dans cette vue il y a aussi une projection du pivot dans un plan perpendiculaire à l'axe du pivot, ainsi qu'une vue de dessus et de coté.

	Dans cette vue, il peut être préférable de supprimer l'affichage des axes (onglet affichage dans le panneau de personnalisation).
	
- Des projections de la vue 3D suivant x, y ou z, après sélection des éléments souhaités.
	
	Il n'y a pas de simulation complète de la rotation des roues, seule la roue droite peut tourner pour vérifier les encombrements et l'élevation de la roue.

Il faut noter que le calcul de rendu est assez long avec OpenScad.
	La projection prend aussi un petit moment à calculer.
*/

//*******************************
include <Bike_accessories.scad> //also include Z_library.scad
include <Velo_rider.scad>

/*[Hidden]*/ 
rider=false; //unactivate library model
frprec = 24; // facets on frame tube ($fn)

//================================
/*[Affichage]*/ 
//Type de vue
view_type = 0; // [0:Vue 3D, 1:Projection de l'épure, 2:Projection latérale, 3:Projection du dessus, 4: Projection de face]
//Affiche les arbres (sinon seulement les axes)
display_shafts = true;
//Affiche les lignes de géométrie (axes)
display_lines = true;
//Affiche le cycliste
display_rider = false;
//Pied gauche a terre
foot_on_ground = false;
//Affiche le cadre
display_frame = false;
//Affiche les roues (sinon modèle filaire)
display_wheels = true;
//Affiche la roue arrière relevée (si suspension)
display_rwheel_up = false;
//Affiche les garde-boues
display_fenders = true;
//Affiche la transmission
display_transmission = false;
//Affiche info et avertissements dans la console
inf_text = true;
//Affiche avertissements et données dans la fenêtre de visualisation
disp_text = true;
//Rotation de la direction (degrés), roue avant droite seulement
//Affiche des surfaces de vérification
display_check =false;
//Angle de rotation de la roue avant
steering_rot=0;

//=================================
/*[Caméra]*/ 
//Impose la position de la caméra définie ci-dessous - peut être inactivé pour les animations
Enforce_camera_position=false; 

// The camera variables shall NOT be included in a module - a module CANNOT export variables

//Vue si la position de la caméra est imposée
iview_type=0; //[0:3D view, 1:Top view, 2: Side view]

//Deplacement x quand la vue de dessus est imposée
iview_x = -450;

//Impose camera position if rotation vector is default - to detect first startup
Cimp = Enforce_camera_position||$vpr==[55,0,25]; 

//Distance de la caméra
//$vpd=Cimp?iview_type?8200:7200:$vpd; //with editor and console windows
$vpd=Cimp?iview_type?5500:4500:$vpd; //no window
//Vecteur de déplacement
$vpt=Cimp?[iview_x,0,750]:$vpt; 
//Vecteur de rotation
$vpr=Cimp?(iview_type?(iview_type==1?[0,0,0]:[90,0,0]):[76,0,30]):(view_type?[0,0,0]:$vpr); 
//above force top view if we are displaying a projection
echo_camera();


//==============================
/*[Texte Descriptif]*/
// coordonnée x du texte
text_xpos = -820;
//Descriptif vélo
txt1 = "Tricycle 'Tadpole'";
//Texte descriptif
txt2 = "avec direction indirecte";
//_
txt3 = "";
//_
txt4 = "";
//_
txt5 = "";
//_
txt6 = "";

//Concepteur
author="_";
//Date et révision
design="preliminary test";

designtxt = [str("Author: ",author),str("Date, revision: ",design)];

/*[Cycliste]*/ 
// Taille du cycliste
rider_height = 1700;
// Hauteur du siège
seat_height = 290;
//Distance entre le siège et l'axe des roues avant
seat_front_distance = 440;
//Angle du dossier de siège par rapport au sol
seat_angle = 48;
// Angle des jambes
leg_angle=62.1;
//Angle pliage de la jambe droite
right_leg_fold = -1.1;
//Angle de la tête
head_angle = -12;
//Jambes lobgues:1, jambes courtes:0
leg_prop = 0.5; // [0:0.1:1]

//Angle de soulèvement des bras
arm_lift=10;
//Angle de pincement des bras
arm_pinch=0;
//Angle de soulèvement des avant-bras
farm_lift=0;
//Angle de pincement des avant-bras
farm_pinch=0;
// Angle de la jambe quand pied a terre
leg_ground_angle=-25;
// Il y a un deuxième cycliste
rider2= false;
// Taille du 2eme cycliste
rider2_height = 1900;
// Décalage en x 2eme cycliste
rider2_x_offset = 0;
// Angle de glissière de siège du 2ème cycliste
rider2_seat_slider_angle = 12;
// décalage angle jambes 2eme cycliste
rider2_leg_offset = 1.6;
//2eme cycl. Angle pliage de la jambe droite
rider2_right_leg_fold = -8.2;
//Sortie bôme pour le 2eme cycliste
rider2_boom_extent = 120;
//2eme cycliste: Jambes longues:1, jambes courtes:0
rider2_leg_prop = 0; // [0:0.1:1]

/*[Dimensions]*/ 
//Référence projet
proj_ref = "Ref. projet";
//Empattement
wheel_base = 1110;
//Voie avant (0 pour une bicyclette)
front_wheel_track = 750;
//diamètre de jante roue avant
front_wheel_rim = 406; //[305,349,355,406,455,507,559,622]
//Largeur du pneu avant
front_wheel_tire = 47; //[22:125]
//Largeur maximum du pneu avant (affiché avec les surfaces de controle)
max_fwheel_tire = 55; //[22:125]
//Voie arrière: 0 pour un tricycle 'tadpole' ou une bicyclette
rear_wheel_track = 0;
//Diamètre de jante roue arrière
rear_wheel_rim = 559; //[305,349,355,406,455,507,559,622]
//largeur du pneu arrière
rear_wheel_tire = 42; //[22:125]
//Largeur maximum du pneu arrière (affiché avec les surfaces de controle)
max_rwheel_tire = 42; //[22:125]
//Angle de chasse des pivots avant
caster_angle = 15;
//Angle de carrossage roues avant
camber_angle = 5;
//Déport de l'axe roue avant (si l'axe de direction n'est pas dans le même plan que l'axe des roues)
perp_axis_offset = 0;
//Angle de carrossage roues arrières
rear_camber_angle = 5;

//Inclinaison du pivot de direction (dans le plan des pivots - incliné suivant l'angle de chasse)
king_pin_angle = 15;
//Extension de l'arbre de pivot au dessus de l'axe
above_extent = 120;
//Extension de l'arbre de pivot au dessous de l'axe
below_extent = 40;

//Hauteur du plan de tringlerie de direction au dessus de l'axe des roues
arm_position = -35;
//Longueur du levier
arm_length = 60;
//Correction hauteur du levier de direction
arm_height_correction = 3;

/*[Transmission]*/
//Position longitudinale du pédalier
BB_long_pos = -355;
//Hauteur du pédalier
BB_height = 380;
//Longueur des manivelles
crank_arm_length = 152;
//Largeur de l'arbre de pédalier
crankshaft_width = 117;
//Nombre de dents du plateau
chainring_teeth = 38;
//Position latérale de la ligne de chaîne
chainline_position = 50;
//Angle des manivelles
crank_angle = -23;
//Angle des pédales
pedal_angle = 75;
//Les poulies de chaine du brin tendu et du brin mou sont sur le même axe
merged_idler = true;
//Le brin tendu de la chaîne (en haut) est au-dessus de la poulie
drv_chain_bot = true;
//Angle de la chaine supérieure (plateau vers poulie) - par rapport à l'horizontale
chain_angle = 30.1;
//Longueur du brin tendu (en haut)- du plateau vers la poulie
chain_length = 550;
//Le brin mou de la chaîne (en bas) est au-dessus de la poulie
rt_chain_top = false;
//Angle brin mou 'en bas) - plateau vers poulie - Utilisé si poulies disjointes
chain_ang_bot = 16.2;
//Longueur brin mou (en bas) chaine - plateau vers poulie - Utilisé si poulies disjointes
chain_length_bot = 540;
//Angle brin tendu (en haut) chaîne (pignon roue vers poulie)
chain_rear_top_angle = -11.9;
//Longueur du brin tendu (haut) de la chaîne (pignon de roue vers poulie)
chain_rear_length = 925;
//Angle du brin mou (bas) (pignon de roue vers poulie)
chain_rear_bot_angle = -9.3;
//Longueur du brin mou (bas) de la chaîne (pignon roue vers poulie)
chain_rear_bot_length = 925;

//================================
/*[Cadre monotube]*/ 
//Hauteur de la base du roulement du pivot par rapport a l'axe de roue (perpendiculaire)
frame_pivot_height =15;
//Hauteur de la douille de direction
head_tube_height = 90;
//Décalage du renfort d'attache de direction (si 0, pas de renfort)
head_reinf_offset = -20;
//Longueur du tube pivot de fouche
steerer_tube_length = 120;
//Diamètre/largeur du tube principal du cadre
frame_tube_dia = 50;
//Hauteur du tube principal, 0->tube circulaire
frame_tube_ht = 0;
//Rayon de cintrage du tube de cadre
frame_bend_radius = 180;
//Longueur du tube en avant du boitier de pédalier
frame_front_extent = 0;
//Angle du tube devant le boitier de pédalier
frame_BB_angle = 3.1;
//Décalage perpendiculaire du cadre par rapport au boitier de pédalier
frame_BB_offset = 0;
//Longueur tube derrière le pédalier
frame_front_length = 310;
//Angle coude après tube derrière le pédalier
frame_front_bend_angle =-39.1;
//Longueur tube sous siège 
frame_seat_length = 100;
//Angle coude après tube sous siège 
frame_seat_bend_angle = 41;
//Longueur tube de dossier
frame_back_length = 170;
//Angle coude après tube de dossier
frame_back_bend_angle = 50;
//Longueur tube support appui-tête
frame_rear_length = 300;
//Diamètre du tube renfort de cadre
rft_dia = 28;
//Longueur du tube renfort de cadre
rft_length = 0;
//Position du tube renfort (sur le tube de siège)
rft_pos = 140;
//Angle du tube renfort de cadre
rft_angle =68.1; 
//Rotation du tube en croix sur l'axe des roues (horizontal)
cross_X_angle=1.2;
//Rotation vers l'arrière du tube de croix d'un trike
cross_rear_angle=40.1;
//Distance du coude de la croix par rapport au pivot de direction
cross_bend_dist=120;
//Longueur du tube de croix après le coude
cross_lg_adjust = 120;

//Type de siège
seat_type = 1; // [0:Aucun,1:Filet, 9:Selle]

/*[Support roue arrière]*/
//Diamètre des bases et haubans
stay_dia = 16;
//Angle des haubans (rel. horizontale)
seat_stay_angle = 17.1;
//Rotation hauban sur axe vertical
seat_stay_v_ang = 5.9;
//Longueur hauban (affiché si longueur > 0)
seat_stay_length = 425;
//Angle de la base (rel. horizontale)
chain_stay_angle = -5.1;
//Rotation base sur axe vertical
chain_stay_v_ang = 2.1;
//Longueur de la base
chain_stay_length = 530;
//Position longitudinale de l'axe suspension arrière (0: pas de suspension)
rsusp_x = 0;
//Hauteur de l'axe de suspension arrière
rsusp_z = 412;
//Mouvement vertical de la suspension arrière
rsusp_travel = 90;
//Diamètre tube central cadre suspension arrière
rsusp_dia = 50;
//Longueur tube central cadre suspension arrière
rsusp_lg = 240;
//Angle tube central cadre suspension arrière
rsusp_an = -14;
//Position amortisseur arrière sur tube central cadre suspension arrière
rsusp_shock_pos = 195;
//Angle amortisseur arrière / tube central cadre
rsusp_shock_an = 88;
//Angle du support de bras de suspension arrière
rsusp_arm_bracket_an = -25;
//Angle du support d'amortisseur arrière (coté cadre)
rsusp_shock_bracket_an = 42;
//Longueur amortisseur arrière (non comprimé)
shock_length = 190;
//Compression amortisseur arrière (cycliste en place: 20 à 25% de la course)
shock_sag = 12;

/*[Direction]*/
//Type de guidon
handlebar_type = 3; //[0:Direction directe (tricyle), 1:Guidon cintré, 2:Hamster, 3:U Bar]
//Le guidon est sur le pivot de direction (sinon sous le siège)
OSS_handlebar=false;
//Hauteur du tube de potence
stem_height = 60;
//Longueur de la potence
stem_length = 40;
//Angle de la potence
stem_ang = 0;
//Angle du guidon
hdl_ang = -110;
//Hauteur du guidon (taille)
hdl_lg = 420;
//Position longitudinale d'un guidon sous le siège (x)
USS_x = 250;
//Position en hauteur de l'axe d'un guidon sous siège (z)
USS_z = 275;
//Angle du pivot de direction pour un guidon sous siège
USS_angle = 10;

//============================
/*[Cosmétique et accessoires]*/ 
//Drapeau sur le siège
flag = true;
//Position du feu avant (affiché uniquement si le feu a une couleur, voir l'onglet couleurs)
flight_pos = 3; //[0:Sans, 1:Haut du tube de direction, 2:Fourche, 3: Bôme] 
//Diamètre du moyeu avant
front_hub_dia = 70;
//Nombre de rayons de la roue avant
front_spoke_nb = 36;//[28,32,36]
//Roue AV: angle d'ajustement des rayons (pour égaliser l'espace entre les rayons). Si 0, rayonnage radial
front_spoke_adj = 3.5; //
//Garde-boue avant:Angle de départ (0: pas de garde-boue)
fw_mud_front = 0;
//Garde-boue avant: Angle d'arrivée
fw_mud_rear = 195;
//------------------------------------
//Nombre de rayons de la roue arrière
rear_spoke_nb = 36; //[28,32,36]
//Roue AR: angle d'ajustement des rayons (pour égaliser l'espace entre les rayons)
rear_spoke_adj = 10.1; //
//Garde-boue arrière: Angle de départ (0:pas de garde-boue)
rw_mud_front = -15;
//Garde-boue arrière: Angle d'arrivéee
rw_mud_rear = 175;

//============================
/*[Couleurs - utiliser les noms html]*/ 
//Couleurs du cycliste (buste, bras, jambes, chaussures, casque)
c_rider = ["red","yellow","darkblue","SaddleBrown", "Gray"];
//Couleurs du 2ème cycliste (buste, bras, jambes, chaussures, casque)
c_rider2 = ["green","orange","gray","dimgray","Yellow"];
//Couleur cadre
c_frame="orange";
//Couleur fourche
c_fork="black";
//Couleur pneus
c_tire=[0.4,0.4,0.4]; 
//Couleur acier
c_steel="darkgray";
//Couleur aluminium
c_alu=[0.8,0.8,0.8];
//Couleur pédale
c_pedal = [0.3,0.3,0.3];
//Couleur des feux, sans couleur il n'y a pas de feux
c_light = "black";

/*[Hidden]*/ 
//_
txt7 = "";
//_
txt8 = "";

view_3D = 0;
view_flat = 1;
view_side = 2;
view_top = 3;
view_front = 4;

//=================================
d_line = $preview?2:0.2;

usertxt = [txt1,txt2,txt3,"",txt4,txt5,txt6,txt7,txt8];
//echo(usertxt=usertxt);
//display checking surfaces
dcheck = display_check && view_type==view_3D;
//display geometry lines
dspl= (view_type==view_flat)?true:display_lines;

//-- calculation -------------
function wheel_diam (rim,tire)= rim+2*tire+4;

rider2_z_offset = tan(rider2_seat_slider_angle)*rider2_x_offset;
//echo(rider2_z_offset=rider2_z_offset);
//ground axis offset
axis_offset= perp_axis_offset/cos(caster_angle);

//effective camber angle - 0 when bicycle
camb_ang = front_wheel_track?camber_angle:0;
//effective rear camber angle - 0 when tricycle
rear_camb_a = rear_wheel_track?rear_camber_angle:0;

fwheel_hdia= wheel_diam(front_wheel_rim,front_wheel_tire)/2;

rwheel_hdia= wheel_diam(rear_wheel_rim,rear_wheel_tire)/2;

ground_length = fwheel_hdia/cos(caster_angle);
trail_base = ground_length*sin(caster_angle);
trail = trail_base-axis_offset;

steering_length = 
	ground_length/cos(king_pin_angle-camb_ang);
shaft_length = steering_length * sin(king_pin_angle-camb_ang);
king_pin_offset = steering_length*sin(king_pin_angle);

pivot_height = (fwheel_hdia/cos (king_pin_angle-camb_ang))*cos (king_pin_angle);

wheel_shaft_lg = atan(king_pin_angle-camb_ang)*ground_length;

arm_y_offset = arm_position*sin(king_pin_angle);
//becho("arm_y_offset",arm_y_offset);
arm_z_plane = arm_position*cos(king_pin_angle);
arm_x_offset = arm_z_plane* sin(caster_angle);
arm_z_offset = arm_z_plane* cos(caster_angle);

headtube_angle = 90-caster_angle;

//this wheel flop calculation does not take into account king pin angle, so it is wrong
wheel_flop = cos(headtube_angle)*sin(headtube_angle)*trail;

//length of an half rear shaft for a quad
rear_shaft_lg = rear_wheel_track?rear_wheel_track/cos(rear_camber_angle)/2-rwheel_hdia*tan(rear_camber_angle):0;

//== Rear suspension ============
rsusp_zoff = rsusp_z-rwheel_hdia;
rwheel_dist = pow(pow(wheel_base-rsusp_x,2)+pow(rsusp_zoff,2),0.5);
if(rsusp_x)
	techo(str("Longueur bras de suspension arrière: ",round(rwheel_dist),"mm"));

rear_arm_angle = asin((rsusp_z-rwheel_hdia)/rwheel_dist);
//becho("rear_arm_angle",rear_arm_angle);

// angle of the rear suspension arm
rs_ang = asin((rsusp_travel/rwheel_dist)/cos(rear_arm_angle)); //not exact, 2nd degree error. Travel not possible in certain conditions, so NaN is generated
//echo(rsusp_ang=rsusp_ang);
rsusp_ang= rs_ang!=rs_ang?0:rs_ang;
if(rs_ang!=rs_ang) // test if NaN
	echo("La position horizontale de l'axe de la suspension arrière est irréaliste");

//== Geometry data calc ======
x_ackermann = wheel_base-arm_x_offset-axis_offset;
y_ackermann = front_wheel_track/2-king_pin_offset-arm_y_offset;
ackermann_angle = atan(y_ackermann/x_ackermann);
//becho("Ackermann angle",ackermann_angle);
lg_ackermann = x_ackermann/cos(ackermann_angle);

lgep = front_wheel_track/2-shaft_length-arm_y_offset;
lg_steer = lgep-arm_length*sin(ackermann_angle);

arm_z_dec = 
	arm_length*sin(caster_angle);
	//+arm_height_correction; //?? composed angle, not caster angle ? 
arm_r_length= arm_length*cos(caster_angle)*0.99; //?? composed angle, not caster angle ? 

//calculate length - for a SWD or tadpole trike, that depends from BB extent and chainring diameter
cycle_length = round(wheel_base+rwheel_hdia+((BB_long_pos<0)?-BB_long_pos-120:fwheel_hdia));

//== Console messages ========
techo("Diamètre roue avant: ",fwheel_hdia*2,"mm, Pneu:",front_wheel_tire,"mm Jante:",front_wheel_rim);
techo("Diamètre roue arrière: ",rwheel_hdia*2,"mm, Pneu:",rear_wheel_tire, "mm Jante:",rear_wheel_rim);
techo("Empattement: ",wheel_base," mm");
techo("Longueur vélo: ",cycle_length," mm");
if(front_wheel_track)
techo("Voie avant: ",front_wheel_track," mm");
if(rear_wheel_track)
techo("Voie arrière: ",rear_wheel_track," mm");
techo("Angle du pivot de direction: ",headtube_angle, " °");
techo("Chasse: ",r10(trail)," mm");
techo("Wheel flop: ",r10(wheel_flop)," mm");
if(shaft_length)
techo("Longueur arbre entre le milieur de la roue et l'axe du pivot: ",r10(shaft_length)," mm");
if(rear_shaft_lg)
techo("Longueur du demi-arbre arrière (au milieu de la roue): ",rear_shaft_lg," mm");
techo("Taille du cycliste: ",rider_height," mm");
		techo("Hauteur de l'entrejambe",round(in_seam(rider_height,leg_prop)), "mm");
if (rider2) {
techo("Taille du cycliste: ",rider_height," mm");
		techo("Hauteur de l'entrejambe",round(in_seam(rider_height,leg_prop)), "mm");
}
techo("Course amortisseur arrière: ", round(tan(rsusp_ang)*rsusp_shock_pos), " mm");

//== Program ====================
if (view_type==view_flat)
	flat_view();
else if (view_type==view_side) { //side view
	projection() 
		r(90,0,180) 
			3Dview();
	//print spec
	if (disp_text)   {
		t(-1000,-70)
			print_spec(30);
		t(-1000,-500)
			print_spec2(30);
	}
}
else if (view_type==view_top) //top view
	projection() 
		rotz(180) 
			3Dview();
else if (view_type==view_front) //front view
	projection() 
		r(0,90) 
			3Dview();
else { // 0 - 3D view
	rotz(180) 3Dview(); 
	print_text();
}
//== 3D view =================
module 3Dview () {
	//ground
	if (view_type!=view_top)
		gray() { 
			cubex(wheel_base+1100,1200,d_line,-700);
			if (dspl) // dimensions marks
				duplx(500,3)
					cubez (1,222,6);
		}
	//
	w_track();
	if(dspl) arrow();
	all_wheels();
	//rear_shafts(display_shafts);
	disp_rider();
	disp_transmission();
	steering (false,true,steering_rot);
	
	t(1200,400) // print ground info
		rotz(180)
			print_info(30);
	if (display_frame) {
		tube_frame();
		if (!front_wheel_track)
			fork(-steering_rot, frame_pivot_height, c_fork);
		cf_steer = 0.55; // shall be a parameter ??
		if(!OSS_handlebar)
			t(USS_x,0,USS_z)
				r(0,USS_angle,180) {
					rotz(-steering_rot*cf_steer)
						handlebar();
					glinez(400);
				}
		//front light
		pos_flight();
	}
	//rear suspension - check plane
	if(rsusp_x && dcheck)
		cubez (100,200,d_line, wheel_base,0,rwheel_hdia+rsusp_travel);
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
					linear_extrude(1)
						text(tx, 32, $fn=16);
		}
	}
	projection() {
		// Steering blueprint
		r(0,90-caster_angle)
			t(trail) {
				steering(true, true, 0, true);
				all_wheels(false, false); //front wheels only
				// Arrow
				r(king_pin_angle)
					t(0,front_wheel_track/2, 420) 
						p_arrow(90,90, "A");
			}
		// Pivot
		t(fwheel_hdia+50,600)
			r(king_pin_angle)
				r(0,-caster_angle)
					t(trail) {
						steering(true,false, -steering_rot, true);
						all_wheels(false, false, false); //front wheels only
					}
		// Top view
		t(-500) rotz(180) {
			//steering bars and bracket
			steering(false, true, -steering_rot, true);
			//Wheels and rear shafts
			all_wheels();
		}
		// Side view
		t(-500,850) r(-90, 180) {
			steering(false,true,-steering_rot, true);
			//Wheels and rear shafts;
			all_wheels();
			cubey(1800,10,d_line, 600);
			t(0,front_wheel_track/2)
				glinez(fwheel_hdia,false);
			// Arrows
			tslz (fwheel_hdia)
				r(0, caster_angle) {
					t(-70) p_arrow(0,0,"B");
					tslz (200)
						p_arrow(90,0,"A");
				}
		}
	}
//-- TEXT --------------------
	t(-1950,-250)
		print_info(30);
	t(-1950,780)
		print_spec(30);
	t(400,100)
	multiLine(["Vue B"],32,false, true);
	t(400,600)
	multiLine(["Vue A"],32, false, true);
}

module BB () {
	diff() {
		cyly(-42,68,0,0,0, 24);
		cyly(-36,111,0,0,0, 12);
	}
}

//--display transmission --------
module disp_transmission () {
//chainring and idler diameter
	dch = chainring_teeth*12.7/PI;
	idler_teeth = 15;
	dpl = idler_teeth*12.7/PI;
	//chain angles to idler
	plang = atan ((dch/2+dpl/2)/chain_length);
	plang2 = atan ((dch/2-dpl/2)/chain_length);
	//chain bottom angle
	cab = merged_idler?(rt_chain_top?chain_angle-2*plang:chain_angle-plang-plang2):chain_ang_bot;
	//Chain bottom length
	clb = merged_idler?chain_length:chain_length_bot;
	
	if(display_transmission) {
		t(BB_long_pos,0,BB_height) {
			pedals(crank_arm_length,crank_angle,pedal_angle,chain_length, chain_angle,clb, cab);
			if(rider2 && rider2_boom_extent!=0)
				r(0,frame_BB_angle)
					t(-rider2_boom_extent) {
						silver()
							BB();
						silver()
							cylx(45,rider2_boom_extent);
						r(0,-frame_BB_angle)
							pedals(crank_arm_length,crank_angle,pedal_angle,0, chain_angle, 100, cab, true);
					}
		}
	}
}

//-- display wheel track --------
module w_track () {
	blue()
		dmirrory() 
			cubez(120,1,5, -60,front_wheel_track/2);
}
//-- display rider --------------
module disp_rider (){
	cx = -6; cz = 112;
	if(display_rider)
		t(seat_front_distance,0,seat_height){
			mirrory() 
				veloRider(rider_height, c_rider, seat_angle, leg_angle-90, right_leg_fold, head_angle, leg_prop);
			//seat
			disp_seat();
			if (rider2) {
				t(rider2_x_offset,0,rider2_z_offset) {
					mirrory()
						veloRider(rider2_height, c_rider2, seat_angle, leg_angle-90+rider2_leg_offset, rider2_right_leg_fold, head_angle, rider2_leg_prop);
					disp_seat();
				}
			}
			//cubez(250,350,1); // check height
		}
}

module disp_seat () {
	if(seat_type==1)
		rans_seat(seat_angle, sflag=flag, light_color=c_light);
	else if (seat_type==9)
		mirrorx()
			saddle(light_color=c_light);
}

// Line wheel symbol
module wheel_symb (wh_d=0, top_symb=true, shaftlg=0) {
	diff() {
		cyly(-16,d_line, 0,0,0, 12);
		cyly(-12,10, 0,0,0, 12);
	}
	glinez(disp=true);
	glinex(disp=true);
	gliney(disp=true);
	if(shaftlg!=0) {
		echo (shaftlg=shaftlg);
		gliney(-shaftlg, false, 0, true);
	}
	if(wh_d) {
		diff() {
			cyly(-wh_d,d_line, 0,0,0, 32);
			cyly(-wh_d+2*d_line,10, 0,0,0, 32);
		}
		if(top_symb) //wheel ends on top view
			dmirrorx()
				t(wh_d/2)
					glinex(disp=true);
				//cubex(-d_line,30,3, wh_d/2,0 ,0); 
	}
}

//-- display all wheels -------
module all_wheels (rearw=true, top_symb = true, mirr=true) {
	//front wheels
	steer(-steering_rot) 
		fwheel(top_symb);
	if(front_wheel_track && mirr)
		mirrory()
			fwheel(top_symb);
		//front wheel shafts
		front_wheel_shaft(display_shafts);
	//rear wheel(s)
	if(rearw)
	dmirrory(rear_wheel_track) 
		t(0,rear_wheel_track/2)
			r(rear_camb_a) {
				rwheel_disp(0);
				if(rsusp_x) { //rear_suspension
					if(dcheck||view_type==view_flat|| display_rwheel_up)
						rwheel_disp(rsusp_ang);
					if(display_shafts)
						color(c_steel) //???
							cyly(-25,100, rsusp_x,0,rsusp_z);
				}
			}
				//t(wheel_base,0,rwheel_hdia)
				//	rear_wheel();
	//spa angle parameter to adjust spoke spacing, should be user accessible ??
	module fwheel (top_symb=true) {
		fwt = front_wheel_track;
		t(0,fwt/2)
			r(camb_ang)
				tslz(fwheel_hdia)
					if(display_wheels&&view_type!=view_flat) {
						wheel(front_wheel_rim,dcheck?max_fwheel_tire:front_wheel_tire,front_hub_dia,shaft_width=fwt?66:130,  spa=front_spoke_adj,spoke_nbr=front_spoke_nb);
						if(display_frame&& display_fenders)
							mirrorx()
								fender(front_wheel_rim,dcheck?max_fwheel_tire:front_wheel_tire,fw_mud_front,fw_mud_rear,fwt?0:115);
					}
					else 
						wheel_symb(fwheel_hdia*2,top_symb);
	}
	//following double partly what is in steering() module  - for axis
	module front_wheel_shaft (shaft=false) {
		// Wheel shaft
		steer(steering_rot)
			fwshaft();
		if(mirr)
			mirrory()
				fwshaft();
		module fwshaft () {
			d = shaft?15:d_line;
			clrx = shaft?c_steel:"orange";
			//line
			color(clrx)
				t(0,front_wheel_track/2)
					r(camb_ang)
						cyly(d,-shaft_length,0,0,fwheel_hdia, 16);
		}
	}
} //all_wheels

module rear_wheel () { // from axis position
	shaft_dia = 18;
	if (display_wheels&&view_type!=view_flat) {
		wheel(rear_wheel_rim,dcheck?max_rwheel_tire:rear_wheel_tire,28, shaft_width = 85, , spa=rear_spoke_adj, spoke_nbr=rear_spoke_nb);
		if(display_frame&& display_fenders)
			mirrorx()
				fender(rear_wheel_rim,dcheck?max_rwheel_tire:rear_wheel_tire,rw_mud_front,rw_mud_rear,rear_wheel_track?0:135);
		//shafts
		color (c_steel)
			if(rear_wheel_track)
				cyly(shaft_dia,-rear_shaft_lg, 0,0,0, 16);
			else
				cyly(-shaft_dia,135+45, 0,0,0, 6);
	}
	else 
		wheel_symb(rwheel_hdia*2,true,rear_wheel_track?rear_shaft_lg:0);
}

//move wheel/rear frame according suspension angle 
module rwheel_move (ang = rsusp_ang) {
	t(rsusp_x, 0, rsusp_z) 
		r(0,-ang+rear_arm_angle) 
			t(rwheel_dist)
				r(0,-rear_arm_angle) //rotate for fender and stays alignment
					children(); 
}

//display wheel according suspension angle
module rwheel_disp (ang = rsusp_ang) {
	rwheel_move (ang) {
		rear_wheel();
		if (rsusp_x)
			r(0,rear_arm_angle)
			glinex(-rwheel_dist,false,0,true){
				glinez();
				gliney();
			}
	}
};

module rear_shafts (shaft=true) {
	ds = shaft?18:d_line;
	dmirrory(rear_wheel_track) 
		t(0,rear_wheel_track/2)
			r(rear_wheel_track?rear_camb_a:0) {
				*rwheel_disp(0);
				if (rsusp_x)
					*rwheel_disp(rsusp_ang);
			}
	//-------------------
	module wheel_s () {
		gray()
			if(rear_wheel_track) {
				cyly(ds, -rear_shaft_lg);
				wheel_symb(rwheel_hdia*2);
			}
			else {
				cyly(-ds,135+45, 0,0,0, 6);
				gliney();
				wheel_symb(rwheel_hdia*2);
			}
	}
}

//-- display 3D steering -----------
module steering (flat = false, mirr=true, rot=0, proj=false) {
	if (mirr)
		mirrory()
			hsteering(flat, 0, proj);
	if (front_wheel_track)
		steer(rot)
			hsteering(flat, rot, proj);
}

//steer origin is 0,0
module steer (stro) {
	t(axis_offset,front_wheel_track/2-king_pin_offset, pivot_height)
		r(0,caster_angle)
			r(king_pin_angle) 
			 rotz(stro)
				r(-king_pin_angle)
					r(0,-caster_angle)
						t(-axis_offset,-front_wheel_track/2+king_pin_offset, -pivot_height)
							children();
}

module hsteering (flat = false, srot=0, proj=false) {
	//2nd cross length = 
	td = frame_tube_dia;
	//Ackerman angle as viewed in the plan perpendicular to steering axis
	c_acker = atan(tan(ackermann_angle)/cos(caster_angle));
	//echo ("Ackermann angle, angle calculated in other plane",ackermann_angle,c_acker);
	
	t(axis_offset,front_wheel_track/2-king_pin_offset, pivot_height) {
		//king pin
		r(0,caster_angle)
			r(king_pin_angle) {
				//axis
				glinez (fwheel_hdia*2+400, false,-steering_length);
				//-- frame cross structure ---
				if (!proj && display_frame) rotz (-srot) {
					color(c_frame) {
						//head tube
						tslz(frame_pivot_height-sin(caster_angle)*axis_offset) {
							duplz(head_tube_height)
								glinex(80);
							cylz(42,head_tube_height, 0,0,0, 24);
						}
						if (front_wheel_track)
							tslz(frame_pivot_height+40)
							r(-king_pin_angle)
							r(0,cross_X_angle)
							rotz(cross_rear_angle)
							cyly(td,-cross_bend_dist, 0,0,0, 24)
							tb_yx(td,-150,-cross_rear_angle, 24)
							cyly(td,-cross_lg_adjust, 0,0,0, 24)
						;
					}
					dx=tire_diam(front_wheel_rim,max_fwheel_tire)+30;
					rtx = (BB_long_pos<0)?0:180;
					if (dcheck&&front_wheel_track==0)
						tslz(-sin(caster_angle)*axis_offset)
						rotz(-45+rtx){
							rotate_extrude(angle=90, $fn=64)
							t(sign(BB_long_pos)* perp_axis_offset)
							rotz(-45)
								intersection() {
									circle(d=dx);
									rotz(14)
									t(-dx*0.9) square(dx+10, center=true);
								}
						}
					if(OSS_handlebar)
						tslz(stem_height+frame_pivot_height+steerer_tube_length-sin(caster_angle)*axis_offset)
							rotz(-srot)
								handlebar();
				}
				//shaft
				if(display_shafts)
					silver()
						difference() {
							cylz(20,above_extent+below_extent, 0,0,-below_extent);
							cylz(-8,400, 0,0,0, 6);
						}
			} //king pin
	t(arm_x_offset,-arm_y_offset,arm_z_offset)
		{
		//Ackermann lines
		color(c_steel)
			if(front_wheel_track) {
				if (!flat)  {
					// line joining steering axis
					rotz(-srot)
						gliney(-lgep+1, false);
					//Ackerman lines
					rotz(-ackermann_angle-srot) 
						glinex(lg_ackermann, false);
				}
				//bar link between front wheels
				t(arm_length*cos(ackermann_angle),-lgep+lg_steer) {
					rotz(-srot) {
						gliney(-lg_steer, false);
						if(display_shafts) color(c_steel)
							cyly(16,-lg_steer+18, 0,-18,0,12);
					}
					//Steering arm (bracket)
					r(king_pin_angle) 
					r(0,caster_angle) 
					rotz(-c_acker) {
						glinex(-arm_r_length,false);
						duplx(-arm_r_length) 
							glinez(12);
						if(display_shafts) color(c_steel)
							diff() {
								hull()
									duplx(-arm_r_length)
									cylz(-25,6);
								//::::::::::::
								duplx(-arm_r_length) 
									cylz(-8,66,0,0,0, 6);
							} //diff
					}
				}
			}
		}
	}
} //Steering

//-- Ground arrow --------------
module arrow () {
	orange() {
		cubex(-200,30,1,-200,0,1);
		hull() {
			cubex(-2,80,1,-400,0,1);
			cubex(-50,1,1,-400,0,1);
		}
	}
}

//== LIBRARY ===================
module pedals (manlength=155, cr_ang=-35, ped_ang=90, top_lg=900, top_ang=13,bot_lg=900,bot_ang=5, extent=false) {
	cr2 = crankshaft_width/2;
	//chainring diam
	dch = chainring_teeth*12.7/PI;
	//wheel sprocket diam
	sprocket_teeth = 19;
	dsp = sprocket_teeth*12.7/PI;
	idler_teeth = 15;
	dpl = idler_teeth*12.7/PI;
	//bottom bracket
	color (c_steel){
		//inside bottom bracket
		cyly(-32.5,68);
		//cup sides
		dmirrory()
			cyly(41,2,0,34);
	}
	module crank_arm (cr2, mod_ped=0) {
		color (c_alu) {
			//shaft
			cyly(20,cr2);
			//crank arm
			cyly(30,14, 0,cr2-15);
			hull() {
				cyly(30,16, 0,cr2-1);
				cyly(22,12, manlength/2,cr2+10);
			}
			//as often on cranks , the end extends slightly after pedam thread hole (to check clearance)
			hull() {
				cyly(22,12, manlength/2,cr2+10);
				cyly(22,12, manlength+8,cr2+10);
			}
		}
		//pedals
		color (c_pedal)
			t(manlength,cr2+22) {
				cyly(16,105);
				r(0,ped_ang+mod_ped) 
					hull() {
						cyly(18,95, 0,9);
						dmirrorx() 
							cyly(18,70, 45,9+12);
					}
			}
	} //crank_arm()
	r(0,cr_ang) {
		crank_arm(cr2,0);
	mirrory()
		r(0,180)
			crank_arm(cr2,6);
		//chainring
		t(0,chainline_position)
		color(c_steel) diff() {
			cyly(-dch,5);
			//::::::::::
			droty (60, nb=5)
				hull() {
					cyly(-18,66,0,0,30);
					dmirrorx()
						cyly(-24,66, chainring_teeth-30,0,dch/2-28);
				}
		}
	}
	/*/idler
	if (top_lg)
		black() //Idler
			r(0,top_ang) 
				cyly(-68,20, top_lg,chainline_position,dch/2+dpl/2); */
	
	
	//driving chain idler
	if(top_lg) 
		r(0,top_ang)  
			t(top_lg,chainline_position,dch/2+(drv_chain_bot?1:-1)*dpl/2) {
				black()
					cyly(-68,20);
				color(c_steel)
					cyly(10,-90, 0,15,0, 16); 
			}
	//color(c_steel) {
	//$fn=6;
	color(c_steel)
		r(0,top_ang) {
			//around chainring
			t(0,chainline_position,dch/2)
				tb_xz(10,-dch/2,200, 6);
			//chainring top to idler
			cylx(10,top_lg, 0,chainline_position,dch/2, 6);
		}
  //chainring bottom to idler
	r(0,bot_ang) {
		color(c_steel) 
			cylx(10,bot_lg, 
				0,chainline_position,-dch/2, 6);
		//separated idler if chain length are not identical - top_lg==0 indicates 2nd pedal set for 2nd rider, no idler
		if (top_lg!=bot_lg && top_lg) {
			t(bot_lg,chainline_position,-dch/2+(rt_chain_top?-1:1)*dpl/2) { 
				black() //Idler
					cyly(-68,20);
				color (c_steel)
					cyly(10,-90, 0,15);
			}
		}
	}
	//rear chain
	color(c_steel)
	if(!extent)
		t(-BB_long_pos,0,-BB_height)
			t(wheel_base,rear_wheel_track/2)
			r(rear_camb_a)
			t(0,chainline_position-rear_shaft_lg,rwheel_hdia) {
				cyly(-dsp,3, 0,0,0, 24);
				
				//top chain from sprocket
				r(0,chain_rear_top_angle)
					cylx(10,-chain_rear_length, 0,0,dsp/2, 6);
				//bottom chain from sprocket
				$fn=6;
				// beware, playing with the facet number may render the chain volume non manifold ????
				r(0,-60)
					t(0,0,-dsp/2) {
						tb_xz(10,dsp/2,-190+50, 6);
						cylx(10,-60, 0,0,0, 6)
						tb_xz(10,-24,71.5, 6)
						cylx(10,-28,0,0,0, 24)
						// if above have 6 facets, cause non-manifold error ????
						tb_xz(10,24,166-25+chain_rear_bot_angle, 6)
						cylx(10,-chain_rear_bot_length,0,0,0, 6);
						//wheels
						cyly(-45,3, -60,0,-23, 24);
						cyly(-45,3, -114,0,-37, 24);
					}
				//cylx(10,-chain_rear_bot_length, 0,0,-dsp/2);
			}
//	}
}

module fork (stro=0, flg=fwheel_hdia+55, clrf = "black") {
	rad = 100;
	pao = perp_axis_offset;
	sgn = sign(pao);
	fang = acos((rad-abs(perp_axis_offset))/rad);
	//echo(fang=fang);
	lgstr = flg-88-rad*sin(fang);
	hhang = atan(8/lgstr);
	//echo (hhang=hhang);
	fwhd = fwheel_hdia;
	color(clrf)
	t(axis_offset,0,fwhd) 
		r(0,caster_angle)
			rotz(stro)
				dmirrory()
				t(-pao,54, -pao*tan(caster_angle)){
					diff(){
						mirrorx(pao<0)
							r(hhang)
								r(0,fang-90) 
									tb_xz(24,rad,-fang)
										cylx(24,lgstr)
											tb_xy(24,-rad,-60);
						//::::::::
						cyly(-24,66);
					}
					cyly(-32,8);
				}
	t(0,0,fwhd)
		r(0,caster_angle) {
			color(clrf)
				cylz(36,-40, pao,0,flg);
			gray()
				cylz(28.6,steerer_tube_length, pao,0,flg);
		}
}

module tube_frame (clrf=c_frame){
	dt = frame_tube_dia;
	br = frame_bend_radius;
	boom = (BB_long_pos<-150) && frame_BB_offset==0;
	boom_out = boom?50:0;
	prec= 24; //$fn for main tube
	stprec = 16; //$fn

	module fr_cyl (length=100, l_start=0, l_end=0) {
		if(l_start!=0)
			glinez(l_start*(br+80),false,-l_start*50);
		if(l_end!=0)
			t(length) 
				glinez(l_end*(br+80),false,-l_end*50);
		cylx(frame_tube_dia,length, 0,0,0, prec)
			children();
	}
	*t(0,0,-200)
		fr_cyl(100, 0, 1)
			tb_xz(dt,180,-abs(frame_front_bend_angle)) 
			fr_cyl(300, 1, 0);
	
	
 t(BB_long_pos,0,BB_height) {
	 //geometry lines
	glinez();
	glinex(); 
	//boom with bottom bracket and derailleur support
		if(boom)
			silver() {
				BB();
				// see for rectangular tube ???
				r(0,frame_BB_angle)
					cylx(dt-6,boom_out+1+frame_front_extent, -frame_front_extent,0,0, prec);
				r(0,18+chain_angle)
					cylz(28,120,0,0,0, 16);
			}
		// saddle->upright bike
		if(seat_type==9)
			silver()
			r(0,frame_BB_angle-frame_front_bend_angle)
				cylx(dt-3,frame_seat_length+120, 0,0,0, prec); 
	//--Frame itself -----------
	color(clrf) {
		//bottom bracket
		if (!boom) BB();
		r(0,frame_BB_angle)
		tslz(frame_BB_offset){
			// BB bracket
			if (frame_BB_offset!=0)
				hull(){
					cubez(30,dt-2,1);
					cubez(30,64,1,0,0,-frame_BB_offset);
				}
			//steer bracket
			if(!boom && head_reinf_offset!=0)
				t(-frame_front_extent)
					hull() {
						cylx(dt-2,1, 90);
						r(0,-frame_BB_angle+caster_angle)
							cylz(-38,head_tube_height-25, 0,0,head_reinf_offset);
					}
			//-- Main frame sequence ------
			s1 = sign(frame_front_bend_angle);
			s2 = sign(frame_seat_bend_angle);
			s3 = sign(frame_back_bend_angle);
	t(-frame_front_extent+boom_out)
			if (frame_tube_ht)
				//-- rectangular tube --
				rctx(frame_tube_ht,frame_tube_dia,frame_front_length+frame_front_extent-boom_out) 
				rrcty(-frame_front_bend_angle,frame_tube_ht,dspl) {
					//reinforcment tube
					t(rft_pos)
						r(0,rft_angle)
							cylx(rft_dia, -rft_length);
					rctx(frame_tube_ht,frame_tube_dia,frame_seat_length)
					rrcty(-frame_seat_bend_angle,frame_tube_ht,dspl)
					rctx(frame_tube_ht,frame_tube_dia,frame_back_length)
					rrcty(-frame_back_bend_angle,frame_tube_ht,dspl)
					rctx(frame_tube_ht,frame_tube_dia,frame_rear_length)
				;
				}
				else
					//-- circular tube ----
					fr_cyl(frame_front_length+frame_front_extent-boom_out, 0, s1)
					tb_xz(dt,s1*br,-abs(frame_front_bend_angle)) {
					//reinforcment tube
						t(rft_pos)
							r(0,rft_angle)
								cylx(rft_dia, -rft_length);
						//continuation of frame sequence
						fr_cyl(frame_seat_length,s1,s2)
						tb_xz(dt,s2*br,-abs(frame_seat_bend_angle)) 
						fr_cyl(frame_back_length,s2,s3)
						tb_xz(dt,s3*br,-abs(frame_back_bend_angle)) 
						fr_cyl(frame_rear_length,s3,0);
					}
		}
	}
 }
 rear_wheel_support(0, clrf);
 if((dcheck||display_rwheel_up) && rsusp_x)
	 rear_wheel_support(rsusp_ang, clrf);
} 

//-- rear wheel support -------
module rear_wheel_support (susp_ang=0, clrf=c_frame) {
	stprec = 16; //$fn
 //dropouts offset
	rco = rear_camb_a?-50:135/2;
 color(clrf)
	dmirrory() 
		t(0,rear_wheel_track/2)
		r(rear_camb_a)
		t(0,rco) // stays are designed from shaft end
		rwheel_move(susp_ang) {
		//t(wheel_base,0,rwheel_hdia) {
		//chain stays
			t(0,stay_dia/2-6,stay_dia/2+12)
				r(0,chain_stay_angle, chain_stay_v_ang)
					cylx(stay_dia,-chain_stay_length+60, 30,0,0, stprec)
						tb_xy (stay_dia,-5*stay_dia,40, stprec)
							cylx(stay_dia,-20, 0,0,0, stprec);
			//dropouts
				diff() {
					hull() {
						tslz(22)
						r(0,chain_stay_angle)
							cubey (50,6,-1);
						cyly(35,6, 0,0,0, 16);
						cyly(28,6, 25,0,0, 16);
					}
					//::::::::::::::
					r(0,15)
						hull() 
							duplz(-50)
								cyly(-10,99, 0,0,0, 16);
					cyly(-8,99, 25,0,0, 16);
				}
			//seat stays - only if they have a length
			if(seat_stay_length)
			t(15,stay_dia/2-6,stay_dia/2+20)
				r(0,seat_stay_angle, seat_stay_v_ang)
					cylx(stay_dia,-seat_stay_length+60, 15)
						tb_xy(stay_dia,-5*stay_dia,40)
							cylx(stay_dia,-20);
	}
	//rear suspension frame (minus stays)
	arm_arti_wd = 75;
	shock_comp = tan(susp_ang)*rsusp_shock_pos;
	if (rsusp_x) {
		t(rsusp_x,0,rsusp_z) r(0,-susp_ang-rsusp_an) {
			color(clrf) {
				hull() {
					cyly(-36,arm_arti_wd);
					cylx(rsusp_dia,1, 30);
				}
				cylx(rsusp_dia,rsusp_lg-29, 25);
				//Main frame arm articulation bracket
				if(susp_ang==0) //no frame bracket for wheel up
				r(0,rsusp_arm_bracket_an)
					dmirrory() {
						hull(){
							cyly(50,5, 0,arm_arti_wd/2+2);
							cubey(75,5,3, 0,arm_arti_wd/2+2,22);
						}
						hull(){
							cubey(75,5,3, 0,arm_arti_wd/2+2,22);
							cubey(110,6,1, 0,15,55);
						}
					}
			}
			t(rsusp_shock_pos,0,rsusp_dia/2+14) {
				//Shock bracket on arm
				color(clrf)
					dmirrory()
						hull(){
							cyly(22,4, 0,12);
							cubey(55,4,1, 0,12,-rsusp_dia/2-8);
						}
				r(0,rsusp_shock_an+180+susp_ang) {
					rear_shock(shock_length,50,shock_sag+shock_comp);
				//shock articulation frame bracket
				color(clrf)
				if(susp_ang==0) // no frame bracket for wheel up
				t(shock_length-shock_sag)
					r(0,rsusp_shock_bracket_an)
						dmirrory()
							hull(){
								cyly(22,4, 0,12);
								cubey(55,4,1, 0,12,40);
							}
				}
			}
		}
	}
}

module pos_flight () {
	//steerer top
	if (c_light)
	if (flight_pos==1) {
		steer(-steering_rot)
		mirrorx()
		tslz(fwheel_hdia)
		r(0,-caster_angle)
			t(-perp_axis_offset,0,frame_pivot_height+steerer_tube_length-12)
				front_light(caster_angle, 1, c_light);
	}
	//fork 
	else if(flight_pos==2) {
		steer(-steering_rot)
		mirrorx()
		tslz(fwheel_hdia)
		r(0,-caster_angle)
			t(-perp_axis_offset+16,0,frame_pivot_height)
				front_light(caster_angle, 2, c_light);
	}
	// boom
	else if(flight_pos==3) {
		mirrorx()
		t(-BB_long_pos,0,BB_height)
			front_light(0, 3, c_light);
	}
}

module handlebar () {
	sgo = sign(stem_length);
	//stem_ang = OSS_handlebar?20:0;
	sto = sign(stem_height)*27; // stem shaft axis offset
	//depending its length 'cruiser' handlebar go from chopper type to near flat mountain bike bar through town type.
		crui_a = hdl_lg>150?90:20+(hdl_lg-50)*0.70;
	if (dcheck)
		red()
			cubez (d_line,666,555);
	silver() {
		//stem pivot shaft
		cylz(25,-stem_height-sto, 0,0,sto);
		cylz(-36,40);
		r(0,-stem_ang) {
			//stem
			cylx(32,sgo*(abs(stem_length)+40),-sgo*20);
			//handlebar
			t(stem_length)
				r(0,hdl_ang+stem_ang)
					dmirrory() 
						if(handlebar_type==0){ //trike direct
							cylz(22,10)
							cylz(30,120);
						}
						else if(handlebar_type==1){ //cruiser
							cyly(22,40)
							tb_yz(22,-70,crui_a)
							r(0,-20)
							cyly(22,abs(hdl_lg-140))
							tb_yz(22,70,crui_a)
							cyly(22,10)
							cyly(32,120);
						}
						else if(handlebar_type==2) { // Hamster
							cylz(22,hdl_lg)
							tb_yx(22,80,18)
							cyly(22,40)
							cyly(30,120);
						}
						else if(handlebar_type==3) { //U Bar
						// if handlebar length = 420, this is a metabike Ubar
							cyly(22,177)
							tb_yx(22,50,80)
							cyly(22,hdl_lg-270)
							r(0,90)
							tb_yx(22,50,37.5)
							cyly(22,30)
							cyly(30,120)
							cyly(22,50);
						}
				}
			}
}

//== Rear shock ===============
module rear_shock (dist = 190, travel=50, sag=10) {
	gray() {
		duplx(dist-sag) {
			diff() {
				u(){
					cyly(-23,14);
					cyly(-18,24);
				}//::::::::::
				cyly(-8,99);
			}
			cyly(-8,55);
		}
		cylx(15,dist-sag-16, 8);
		cylx(28,dist-sag-30, 15);
		cylx(48,20, 20);
		cylx(47,dist*0.5, 18);
	}
}

//== Information ====================
//-- Information text -------------
module techo (var1, var2="",var3="", var4="",var5="",var6="", var7="",var8="") {
  if (inf_text) {
    txt = str(var1,var2,var3,var4,var5,var6,var7,var8);
    echo(txt);
  }  
}

//debug echo
debug=true;

module decho (text, var) {
	if(debug)
		echo(text,var);
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
 	rtype = front_wheel_track?(rear_wheel_track?"quadricycle":"tricycle"):"bicyclette";
	multiLine(
		[str("Géometrie d'un vélo couché ",rtype),
"https://github.com/PRouzeau/BentSim",
"http://rouzeau.net/OpenSCADEn/BentSim",	
	"(c) 2019 Pierre ROUZEAU",
	"Licence GPL V3"
	]
	, size);
}

module print_text () {
	if(disp_text) black()
		t(text_xpos,0,65)
			r(90) 
				multiLine(usertxt,30,false);
}

module print_spec (size = 30) {
	multiLine([
	str("Référence projet: ",proj_ref),
	str("Roue avant: Jante ",front_wheel_rim, " Pneu: ",front_wheel_tire, " mm diam. ",fwheel_hdia*2," mm"),
	str("Roue arrière: Jante ",rear_wheel_rim, " Pneu: ",rear_wheel_tire, " mm diam. ",rwheel_hdia*2," mm"),
	str("Voie avant: ",front_wheel_track," mm - Voie arrière: ",rear_wheel_track," mm"),
	str("Empattement: ",wheel_base," mm"),
str("Angle du pivot de direction: ",headtube_angle, "°  ,déport roue: ", perp_axis_offset,"mm"),
str("Chasse: ",r10(trail),"mm - Wheel flop: ",r10(wheel_flop),"mm"),
str("Hauteur assise siège: ",seat_height,"mm - Hauteur pédalier: ",BB_height,"mm")
	]
	,size,false);
}

module print_spec2 (size = 30) {
	multiLine([
		str("Taille du cycliste: ",rider_height, "mm"),
		str("Inclinaison du dossier (par rapport à l'horizontale: ",seat_angle, "°"),
		str("Hauteur de l'entrejambe",in_seam(rider_height,leg_prop), "mm"),
		str("Course amortisseur arrière: ", round(tan(rsusp_ang)*rsusp_shock_pos), " mm")
	]
	,size,false);
}

//== LIBRARY ========================

//-- Geometry lines -----------------
module glinex (length=50, ctr=true, off=0, disp=dspl) {
	if(disp)
		cylx(d_line*(ctr?-1:1), length, off,0,0, 4)
			children();
}

module gliney (length=50, ctr=true, off=0, disp = dspl) {
	if(disp)
		cyly(d_line*(ctr?-1:1), length, 0,off,0, 4);
}

module glinez (length=50, ctr=true, off=0, disp=dspl) {
	if(disp)
		cylz(d_line*(ctr?-1:1), length, 0,0,off, 4);
}

//-- Rectangle extrusion & rotation --
module rctx (height=10, width=10, length=10, x=0, y=0, z=0) {
	t(x+length/2,y,z) {
		cube([abs(length),width,height], center=true);
		t(length/2)
			children();
	}
}

//Rotation of rectangular tube on y
//ht shall be negative if former segment negative (to merge tubes
module rrcty(ang=0, height=10, line=false, thk_line=d_line) {
	t(0,0,sign(ang)*height/2) {
		//cyly(-2,100);
		if(line)
			r(0,ang/2)
				cylz(-thk_line,200, 0,0,-sign(ang)*height/2, 4);
		r(0,ang)
			t(0,0,-sign(ang)*height/2)
				children();
	}
}

//Rotation of rectangular tube on z
//width shall be negative if former segment negative (to merge tubes
module rrctz(ang=0, width=10, line=false, thk_line=d_line) {
	if(line)
	t(0,sign(ang)*width/2) {
		if(line) {
			rotz(ang/2)
				cyly(-thk_line,200, 0,-sign(ang)*width/2/cos(ang/2),0, 4)
				cylz(-thk_line,150, 0,0,0, 4);
		}
		rotz(ang)
			t(0,-sign(ang)*width/2)
				children();
	}
}
