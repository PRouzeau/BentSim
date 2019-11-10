//BentSim
/*en+
Recumbent simulator, can export geometry blueprint of whole bike/trike and steering
 Rider size and proportion adjustable.
 Single tube frame (circular or rectangular)
*/
/*fr+
Simulateur de vélo couché bicycle ou tricycle. Peut notamment exporter une épure du vélo complet et de sa direction.
Taille et proportion du cycliste ajustable.
Cadre monotube (circulaire ou rectangulaire)
*/
// Copyright 2019 Pierre ROUZEAU,  AKA PRZ
// Program license GPL V3
// documentation licence cc BY-SA 4.0 and GFDL 1.2
// First version: 0.0 - August, 10, 2019 as Trike geometry only
// revised October, 4, 2019
// revised November, 4, 2019 as general Recumbent simulator
//https://github.com/PRouzeau/BentSim
//http://rouzeau.net/Print3D/OpenSCAD
 
/*en+
  This uses my OpenSCAD library, attached, but you can find details here:
 https://github.com/PRouzeau/OpenScad-Library
-- The rider came from elsewhere --
See comments in the rider file

There is three possible displays
- The 3D view, which can be exported as stl file (after rendering)
- The blueprint projection, including steering axis on plane going through king pins, which can be exported as DXF file (CAD file). In this view, you will also find a pivot projection, seen in a plane perpendicular to king pin and top and side views. 
	For this view, you may prefer to cancel shaft display (in display tab on customizer panel)
- A side projection of the 3D view
	
	There is no complete steering simulation, yet only right wheel rotate to check clearances and you can have a look to wheel elevation when turning.

Note that in openscad the rendering may take some time. Projection also need some calculation time.
*/
/*fr+
  Cette application utilise ma librairie OpenSCAD, jointe, mais vous pouvez trouver des détails sur celle-ci ici:
	https://github.com/PRouzeau/OpenScad-Library

- Le modèle du cycliste vient d'une autre source, voir les commentaires dans son fichier.

Il y a trois types d'affichage possible
- La vue 3D, qui peut être exportée en stl (après calcul du rendu)
- La projection à plat des axes de direction (suivant un plan passant par les axes), qui peut être exportée comme un fichier DXF (fichier de dessin). Dans cette vue il y a aussi une projection du pivot dans un plan perpendiculaire à l'axe du pivot, ainsi qu'une vue de dessus et de coté.

	Dans cette vue, il peut être préférable de supprimer l'affichage des axes (onglet affichage dans le panneau de personnalisation).
	
- Une projection latérale de la vue 3D
	
	Il n'y a pas de simulation complète de la rotation des roues, seule la roue droite peut tourner pour vérifier les encombrements et l'élevation de la roue.

Il faut noter que le calcul de rendu est assez long avec OpenScad.
	La projection prend aussi un petit moment à calculer.
*/

//*******************************
include <Bike_accessories.scad> //also include Z_library.scad
include <Velo_rider.scad>

/*[Hidden]*/ 
//mini_hole=false;
rider=false; //unactivate library model
frprec = 24; // facets on frame tube ($fn)

//================================
/*fr:[Affichage]*/ 
/*[Display]*/ 
//fr:Type de vue
//View type
view_type = 0; // [0:3D view, 1:Blueprint projection, 2:Side projection, 3:Top projection, 4:Front projection]
//fr::view_type = 0; // [0:Vue 3D, 1:Projection de l'épure, 2:Projection latérale, 3:Projection du dessus, 4: Projection de face]
//fr:Affiche les arbres (sinon seulement les axes)
//Display shafts (else only axis)
display_shafts = true;
//fr:Affiche les lignes de géométrie (axes)
//Display geometry lines (axis)
display_lines = true;
//fr:Affiche le cycliste
//Display rider
display_rider = false;
//fr:Pied gauche a terre
//Rider left foot on ground
foot_on_ground = false;
//fr:Affiche le cadre
//display frame
display_frame = false;
//fr:Affiche les roues (sinon modèle filaire)
//Display full wheels (else wire model)
display_wheels = true;
//fr:Affiche les garde-boues
//Display mudguards
display_fenders = true;
//fr:Affiche la transmission
//Display transmission
display_transmission = false;
//fr:Affiche info et avertissements dans la console
//Display information and warning in the console
inf_text = true;
//fr:Affiche avertissements et données dans la fenêtre de visualisation
//Display information and warning in the view windows
disp_text = true;
//fr:Rotation de la direction (degrés), roue avant droite seulement
//Steering rot angle (deg), front right wheel only
//fr:Affiche des surfaces de vérification
//Display checking surfaces
display_check =false;
//fr:Angle de rotation de la roue avant
//Front wheel steering angle
steering_rot=0;

//=================================
/*fr:[Caméra]*/ 
/*[Camera]*/
//fr:Impose la position de la caméra définie ci-dessous - peut être inactivé pour les animations
//Enforce the camera position defined below - could be unactivated for animations
Enforce_camera_position=false; 

// The camera variables shall NOT be included in a module - a module CANNOT export variables

//fr:Vue si la position de la caméra est imposée
//View type if camera position is enforced
iview_type=0; //[0:3D view, 1:Top view, 2: Side view]

//fr:Deplacement x quand la vue de dessus est imposée
//X translation when view imposed
iview_x = -450;

//Impose camera position if rotation vector is default - to detect first startup
Cimp = Enforce_camera_position||$vpr==[55,0,25]; 

//fr:Distance de la caméra
//Camera distance
$vpd=Cimp?iview_type?8200:7200:$vpd; 
$vpd=Cimp?iview_type?5500:4500:$vpd; 
//fr:Vecteur de déplacement
//Camera translation 
$vpt=Cimp?[iview_x,0,750]:$vpt; 
//fr:Vecteur de rotation
//Camera rotation
$vpr=Cimp?(iview_type?(iview_type==1?[0,0,0]:[90,0,0]):[76,0,30]):(view_type?[0,0,0]:$vpr); 
//above force top view if we are displaying a projection
echo_camera();


//==============================
/*fr:[Texte Descriptif]*/
/*[Description text]*/
//fr: coordonnée x du texte
//text x coordinate position
text_xpos = -820;
//fr:Descriptif vélo
//Bike description
txt1 = "Recumbent 'tadpole' Trike";
//fr::txt1 = "Tricycle 'Tadpole'";
//fr:Texte descriptif
//Description text
txt2 = "with Indirect Steering";
//fr::txt2 = "avec direction indirecte";
//_
txt3 = "";
//_
txt4 = "";
//_
txt5 = "";
//_
txt6 = "";

//fr:Concepteur
//Design author
author="_";
//fr:Date et révision
//Date and revision
design="preliminary test";

designtxt = [str("Author: ",author),str("Date, revision: ",design)];

/*fr:[Cycliste]*/ 
/*[Rider]*/
//fr: Taille du cycliste
//Rider height
rider_height = 1700;
//fr: Hauteur du siège
//Seat height
seat_height = 290;
//fr:Distance entre le siège et l'axe des roues avant
//Seat distance from front wheel axis
seat_front_distance = 440;
//fr:Angle du dossier de siège par rapport au sol
//Seat back angle from ground plane
seat_angle = 48;
//fr: Angle des jambes
//Leg angle
leg_angle=62.1;
//fr:Angle pliage de la jambe droite
//Right leg fold angle
right_leg_fold = -1.1;
//fr:Angle de la tête
//Head angle (to body)
head_angle = -12;
//fr:Jambes lobgues:1, jambes courtes:0
//Long legs : 1, short legs : 0
leg_prop = 0.5; // [0:0.1:1]

//fr:Angle de soulèvement des bras
//Arm lift angle
arm_lift=10;
//fr:Angle de pincement des bras
//Arm pinch angle
arm_pinch=0;
//fr:Angle de soulèvement des avant-bras
//Forearm lifting angle
farm_lift=0;
//fr:Angle de pincement des avant-bras
//Forearm pinching angle
farm_pinch=0;
//fr: Angle de la jambe quand pied a terre
//Leg angle when foot is on ground
leg_ground_angle=-25;
//fr: Il y a un deuxième cycliste
//There is a second rider
rider2= false;
//fr: Taille du 2eme cycliste
//2nd rider height
rider2_height = 1900; // [1200:10:2200]
//fr: Décalage en x 2eme cycliste
//2nd rider x offset
rider2_x_offset = 0;
//fr: Angle de glissière de siège du 2ème cycliste
//2nd rider seat slider angle
rider2_seat_slider_angle = 12;
//fr: décalage angle jambes 2eme cycliste
//2nd rider leg angle offset
rider2_leg_offset = 1.6;
//fr:2eme cycl. Angle pliage de la jambe droite
//2nd rider: Right leg fold angle
rider2_right_leg_fold = -8.2;
//fr:Sortie bôme pour le 2eme cycliste
//2nd rider boom extent
rider2_boom_extent = 120;
//fr:2eme cycliste: Jambes longues:1, jambes courtes:0
//2nd rider: Long legs : 1, short legs : 0
rider2_leg_prop = 0; // [0:0.1:1]

/*[Dimensions]*/ 
//fr:Référence projet
//Project reference
proj_ref = "Test project";
//fr::proj_ref = "Ref. projet";
//fr:Empattement
//Wheel base
wheel_base = 1110;
//fr:Voie avant
//Front wheels track
front_wheel_track = 750;
//fr:diamètre de jante roue avant
//Front wheel rim diameter
front_wheel_rim = 406; //[305,349,355,406,455,507,559,622]
//fr:Largeur du pneu avant
//Front tire width
front_wheel_tire = 47; //[22:125]
//fr:Largeur maximum du pneu avant (affiché avec les surfaces de controle)
//Maximum front tire width (displayed with checking surfaces)
max_fwheel_tire = 55; //[22:125]
//fr:Voie arrière: 0 pour un tricycle
//Rear wheel track: 0 for a trike
rear_wheel_track = 0;
//fr:Diamètre de jante roue arrière
//Rear wheel rim diameter
rear_wheel_rim = 559; //[305,349,355,406,455,507,559,622]
//fr:largeur du pneu arrière
//Rear tire width
rear_wheel_tire = 42; //[22:125]
//fr:Largeur maximum du pneu arrière (affiché avec les surfaces de controle)
//Maximum rear tire width (displayed with checking surfaces)
max_rwheel_tire = 42; //[22:125]
//fr:Angle de chasse des pivots avant
//front steering caster angle
caster_angle = 15;
//fr:Angle de carrossage roues avant
//Front wheel camber angle
camber_angle = 5;
//fr:Déport de l'axe roue avant (si l'axe de direction n'est pas dans le même plan que l'axe des roues)
//Front wheel axis offset (rake - if steering axis is not in same plane as wheel shaft)
perp_axis_offset = 0;
//fr:Angle de carrossage roues arrières
//Rear wheel camber angle
rear_camber_angle = 5;

//fr:Inclinaison du pivot de direction (dans le plan des pivots - incliné suivant l'angle de chasse)
//King pin axis angle (in steering axis plane, reclined per caster angle)
king_pin_angle = 15;
//fr:Extension de l'arbre de pivot au dessus de l'axe
//King pint shaft extenstion above wheel shaft
above_extent = 120;
//fr:Extension de l'arbre de pivot au dessous de l'axe
//King pin shaft extension below wheel shaft
below_extent = 40;

//fr:Hauteur du plan de tringlerie de direction au dessus de l'axe des roues
//Arm steering plane above wheel axis height
arm_position = -35;
//fr:Longueur du levier
//Arm (lever) length
arm_length = 60;
//fr:Correction hauteur du levier de direction
//Arm (lever) height correction
arm_height_correction = 3;

/*[Transmission]*/
//fr:Position longitudinale du pédalier
//Longitudinal bottom bracket position
BB_long_pos = -355;
//fr:Hauteur du pédalier
//Bottom bracket height
BB_height = 380;
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
//fr:Angle des manivelles
//Crank angle (from horizontal)
crank_angle = -23;
//fr:Angle des pédales
//Pedal angle (from crank)
pedal_angle = 75;
//fr:Les poulies de chaine du brin tendu et du brin mou sont sur le même axe
//Driving idler and return idler on same shaft
merged_idler = true;
//fr:Le brin mou de la chaîne est au-dessus de la poulie
//Driving chain is below the idler
drv_chain_bot = true;
//fr:Angle de la chaine supérieure depuis le plateau (/ horizontale)
//Top chain angle from chainring (from horizontal)
chain_angle = 30.1;
//fr:Longueur de la chaine supérieure depuis le plateau
//Top chain length (from chainring)
chain_length = 550;
//fr:Le brin mou de la chaîne est au-dessus de la poulie
//Return chain is on top of the idler
rt_chain_top = false;
//fr:Angle chaîne sous le plateau - utilisé si poulies disjointes
//Bottom chain angle (from chainring) - used if separated idlers
chain_ang_bot = 16.2;
//fr:Longueur chaine en dessous du plateau - utilisé si poulies disjointes
//Bottom chain length (chainring to idler) - used if separated idlers
chain_length_bot = 540;
//fr:Angle de la chaîne arrière supérieure
//Rear top chain angle (from wheel sprocket)
chain_rear_top_angle = -11.9;
//fr:Angle de la chaîne arrière inférieure
//Rear bottom chain angle (from wheel sprocket)
chain_rear_bot_angle = -9.3;
//fr:Longueur du brin tendu de la chaîne arrière
//Rear chain driving segment length
chain_rear_length = 925;
//fr:Longueur du brin mou de la chaîne arrière
//Rear chain return segment length
chain_rear_bot_length = 925;


//================================
/*fr:[Cadre monotube]*/ 
/*[Tube frame]*/
//fr:Hauteur de la base du roulement du pivot par rapport a l'axe de roue (perpendiculaire)
//Fork/pivot perpendicular height (from bottom bearing seat to wheel axis)
frame_pivot_height =15;
//fr:Hauteur de la douille de direction
//Head tube height
head_tube_height = 90;
//fr:Décalage du renfort d'attache de direction (si 0, pas de renfort)
//head tube reinforcement offset (if 0, no reinforcement)
head_reinf_offset = -20;
//fr:Longueur du tube pivot de fouche
//Steerer tube length (atop bearing base plane)
steerer_tube_length = 120;
//fr:Diamètre/largeur du tube principal du cadre
//Main frame tube diameter/width
frame_tube_dia = 50;
//fr:Hauteur du tube principal, 0->tube circulaire
//Main frame tube height  0->cylindrical tube
frame_tube_ht = 0;
//fr:Rayon de cintrage du tube de cadre
//Frame bend radius
frame_bend_radius = 180;
//fr:Longueur du tube en avant du boitier de pédalier
//Tube length in front of Bottom Bracket
frame_front_extent = 0;
//fr:Angle du tube devant le boitier de pédalier
//Angle of tube in front of Bottom Bracket
frame_BB_angle = 3.1;
//fr:Décalage perpendiculaire du cadre par rapport au boitier de pédalier
//Frame offset to BB (perpendicular to frame tube)
frame_BB_offset = 0;
//fr:Longueur tube derrière le pédalier
//Length of tube behind BB
frame_front_length = 310;
//fr:Angle coude après tube derrière le pédalier
//Bend angle after tube behind BB
frame_front_bend_angle =-39.1;
//fr:Longueur tube sous siège 
//Under seat tube length
frame_seat_length = 100;
//fr:Angle coude après tube sous siège 
//Bend angle after seat tube
frame_seat_bend_angle = 41;
//fr:Longueur tube de dossier
//Back seat tube length
frame_back_length = 170;
//fr:Angle coude après tube de dossier
//Bend angle after back tube
frame_back_bend_angle = 50;
//fr:Longueur tube appui-tête
//Head tube length
frame_rear_length = 300;
//fr:Diamètre du tube renfort de cadre
//Frame reinforcment tube diameter
rft_dia = 28;
//fr:Longueur du tube renfort de cadre
//Frame reinforcment tube length
rft_length = 0;
//fr:Position du tube renfort (sur le tube de siège)
//Frame reinforcment tube position (on seat beam segment)
rft_pos = 140;
//fr:Angle du tube renfort de cadre
//Frame reinforcment tube angle (from seat beam segment axis)
rft_angle =68.1; 
//fr:Rotation du tube en croix sur l'axe des roues (horizontal)
//trike cross rotation on wheel axis (horizontal)
cross_X_angle=1.2;
//fr:Rotation vers l'arrière du tube de croix d'un trike
//Trike cross rotation to rear
cross_rear_angle=40.1;
//fr:Distance du coude de la croix par rapport au pivot de direction
//distance of bend on cross beam from kingpin axis
cross_bend_dist=120;
//fr:Longueur du tube de croix après le coude
//Cross arm tube length after bend
cross_lg_adjust = 120;
//fr:Angle des haubans (rel. horizontale)
//Seat stay angle (from horizontal)
seat_stay_angle = 17.1;
//fr:Rotation hauban sur axe vertical
//Vertical seat stay angle
seat_stay_v_ang = 5.9;
//fr:Longueur hauban
//Seat stay length
seat_stay_length = 425;
//fr:Angle de la base (rel. horizontale)
//Chain stay angle (from horizontal)
chain_stay_angle = -5.1;
//fr:Rotation base sur axe vertical
//Vertical angle of chain stay
chain_stay_v_ang = 2.1;
//fr:Longueur de la base
//Chain stay length
chain_stay_length = 530;
//fr:Type de siège
//Seat type
seat_type = 1; // [0:None,1:Mesh seat, 9:Saddle]
//fr::seat_type = 1; // [0:Aucun,1:Filet, 9:Selle]

/*fr:[Direction]*/
/*[Steering]*/
//fr:Type de guidon
//Handlebar type
handlebar_type = 3; // [0:Trike direct, 1:Cruiser, 2:Hamster, 3:U Bar]
//fr::handlebar_type = 3; //[0:Direction directe (tricyle), 1:Guidon cintré, 2:Hamster, 3:U Bar]
//fr:Le guidon est sur le pivot de direction (sinon sous le siège)
//Handlebar is on kingpin axis (else under seat)
OSS_handlebar=false;
//fr:Hauteur du tube de potence
//Stem height
stem_height = 60;
//fr:Longueur de la potence
//Stem length
stem_length = 40;
//fr:Angle de la potence
//Stem angle
stem_ang = 0;
//fr:Angle du guidon
//handlebar angle
hdl_ang = -110;
//fr:Hauteur du guidon (taille)
//handlebar height (size)
hdl_lg = 420;
//fr:Position longitudinale d'un guidon sous le siège (x)
//Under seat steering longitudinal  position (x)
USS_x = 250;
//fr:Position en hauteur de l'axe d'un guidon sous siège (z)
//Under seat steering axis height position (z)
USS_z = 275;
//fr:Angle du pivot de direction pour un guidon sous siège
//Under seat steering angle (from vertical)
USS_angle = 10;

//============================
/*fr:[Cosmétique et accessoires]*/ 
/*[Cosmetic and accessories]*/
//fr:Drapeau sur le siège
//Flag on seat
flag = true;
//fr:Position du feu avant (affiché uniquement si le feu a une couleur, voir l'onglet couleurs)
//Front light position - light shown only if its color defined - see color tab
flight_pos = 3; //[0:None, 1:Steerer top, 2:Fork, 3: Boom] 
//fr::flight_pos = 3; //[0:Sans, 1:Haut du tube de direction, 2:Fourche, 3: Bôme] 
//fr:Diamètre du moyeu avant
//Front hub diameter
front_hub_dia = 70;
//fr:Nombre de rayons de la roue avant
//Number of front wheel spokes
front_spoke_nb = 36;//[28,32,36]
//fr:Roue AV: angle d'ajustement des rayons (pour égaliser l'espace entre les rayons). Si 0, rayonnage radial
//Front spoke angle adjument (to equalise spoke space). If 0, radial spokes
front_spoke_adj = 3.5; //
//fr:Garde-boue avant:Angle de départ (0: pas de garde-boue)
//Front wheel mudguard: start angle (0: no mudguard)
fw_mud_front = 0;
//fr:Garde-boue avant: Angle d'arrivée
//Front wheel mudguard: rear angle
fw_mud_rear = 195;
//------------------------------------
//fr:Nombre de rayons de la roue arrière
//Number of rear wheel spokes
rear_spoke_nb = 36; //[28,32,36]
//fr:Roue AR: angle d'ajustement des rayons (pour égaliser l'espace entre les rayons)
//Rear spoke angle adjument (to equalise spoke space)
rear_spoke_adj = 10.1; //
//fr:Garde-boue arrière: Angle de départ (0:pas de garde-boue)
//Rear wheel mudguard: start angle (0: no mudguard)
rw_mud_front = -15;
//fr:Garde-boue arrière: Angle d'arrivéee
//Rear wheel mudguard: rear angle
rw_mud_rear = 175;

//============================
/*fr:[Couleurs - utiliser les noms html]*/ 
/*[Colors - use html color names]*/
//fr:Couleurs du cycliste (buste, bras, jambes, chaussures, casque)
//Rider colors (torso, arms, legs, shoes, helmet)
c_rider = ["red","yellow","darkblue","SaddleBrown", "Gray"];
//fr:Couleurs du 2ème cycliste (buste, bras, jambes, chaussures, casque)
//2nd Rider colors (torso, arms, legs, shoes, helmet)
c_rider2 = ["green","orange","gray","dimgray","Yellow"];
//fr:Couleur cadre
//Frame color
c_frame="orange";
//fr:Couleur fourche
//Fork color
c_fork="black";
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
//fr:Couleur des feux, sans couleur il n'y a pas de feux
//front and rear lights color, no color remove lights
c_light = "black";

/*[Hidden]*/ 
//_
txt7 = "";
//_
txt8 = "";

//=================================
d_line = $preview?3:0.2;

usertxt = [txt1,txt2,txt3,"",txt4,txt5,txt6,txt7,txt8];
//echo(usertxt=usertxt);
//display checking surfaces
dcheck = display_check && view_type==0;
//display geometry lines
dspl= (view_type==1)?true:display_lines;

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

front_wheel_hdia= wheel_diam(front_wheel_rim,front_wheel_tire)/2;

rear_wheel_hdia= wheel_diam(rear_wheel_rim,rear_wheel_tire)/2;

ground_length = front_wheel_hdia/cos(caster_angle);
trail_base = ground_length*sin(caster_angle);
trail = trail_base-axis_offset;

steering_length = 
	ground_length/cos(king_pin_angle-camb_ang);
shaft_length = steering_length * sin(king_pin_angle-camb_ang);
king_pin_offset = steering_length*sin(king_pin_angle);

pivot_height = (front_wheel_hdia/cos (king_pin_angle-camb_ang))*cos (king_pin_angle);

wheel_shaft_lg = atan(king_pin_angle-camb_ang)*ground_length;

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
	arm_length*sin(caster_angle);
	//+arm_height_correction; //?? composed angle, not caster angle ? 
arm_r_length= arm_length*cos(caster_angle)*0.99; //?? composed angle, not caster angle ? 

//calculate length - for a SWD or tadpole trike, that depends from BB extent and chainring diameter
cycle_length = round(wheel_base+rear_wheel_hdia+((BB_long_pos<0)?-BB_long_pos-120:front_wheel_hdia));

//== Console messages ========
techo("Front wheel diameter: ",front_wheel_hdia*2, "mm, Rim:",front_wheel_rim);
//fr::techo("Diamètre roue avant: ",front_wheel_hdia*2, "mm, Jante:",front_wheel_rim);
techo("Rear wheel diameter: ",rear_wheel_hdia*2,"mm, Rim:",rear_wheel_rim);
//fr::techo("Diamètre roue arrière: ",rear_wheel_hdia*2, "mm, Jante:",rear_wheel_rim);
techo("Wheel base: ",wheel_base," mm");
//fr::techo("Empattement: ",wheel_base," mm");
techo("Cycle length: ",cycle_length," mm");
//fr::techo("Longueur vélo: ",cycle_length," mm");
techo("Front wheel track: ",front_wheel_track," mm");
//fr::techo("Voie avant: ",front_wheel_track," mm");
techo("Rear wheel track: ",rear_wheel_track," mm");
//fr::techo("Voie arrière: ",rear_wheel_track," mm");
techo("Headtube angle: ",headtube_angle, " °");
//fr::techo("Angle du pivot de direction: ",headtube_angle, " °");
techo("Trail: ",r10(trail)," mm");
//fr::techo("Chasse: ",r10(trail)," mm");
techo("Wheel flop: ",r10(wheel_flop)," mm");
techo("Shaft length from wheel center to king pin axis: ",r10(shaft_length)," mm");
//fr::techo("Longueur arbre entre le milieur de la roue et l'axe du pivot: ",r10(shaft_length)," mm");
techo ("Rear half shaft length (to wheel middle): ",rear_shaft_lg," mm");
//fr::techo ("Longueur du demi-arbre arrière (au milieu de la roue): ",rear_shaft_lg," mm");

//== Program ====================
if (view_type==1)
	flat_view();
else if (view_type==2) //side view
	projection() 
		r(90,0,180) 
			3Dview();
else if (view_type==3) //top view
	projection() 
		rotz(180) 
			3Dview();
else if (view_type==4) //front view
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
	if (view_type!=3)
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
	rear_shafts(display_shafts);
	disp_rider();
	disp_transmission();
	steering(false,true,steering_rot);
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
				steering(true, true, 0, true);
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
						steering(true,false, -steering_rot, true);
		// Top view
		t(-500) rotz(180) {
			steering(false, true, -steering_rot, true);
			rear_shafts(false);
		}
		// Side view
		t(-500,850) r(-90, 180) {
			steering(false,true,-steering_rot, true);
			rear_shafts(false);
			cubey(1800,10,d_line, 600);
			t(0,front_wheel_track/2)
				glinez(front_wheel_hdia,false);
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
	t(-1950,-250)
		print_info(30);
	t(-1950,780)
		print_spec(30);
	t(400,100)
		multiLine(["View B"],32,false);
//fr::	multiLine(["Vue B"],32,false);
	t(400,600)
		multiLine(["View A"],32, false);
//fr::	multiLine(["Vue A"],32, false);
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
	
	if (display_transmission) {
		t(BB_long_pos,0,BB_height) {
			pedals(crank_arm_length,crank_angle,pedal_angle,chain_length, chain_angle,clb, cab);
			if (rider2 && rider2_boom_extent!=0)
				r(0,frame_BB_angle)
					t(-rider2_boom_extent) {
						silver()
							BB();
						silver()
							cylx (45,rider2_boom_extent);
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
			if(seat_type==1)
				rans_seat(seat_angle, sflag=flag, light_color=c_light);
			else if (seat_type==9)
				mirrorx()
					saddle(light_color=c_light);
			if (rider2) {
				t(rider2_x_offset,0,rider2_z_offset) {
					mirrory()
						veloRider(rider2_height, c_rider2, seat_angle, leg_angle-90+rider2_leg_offset, rider2_right_leg_fold, head_angle, rider2_leg_prop);
					if(seat_type==1)
						rans_seat(seat_angle, sflag=false);
				}
			}
			//cubez(250,350,1); // check height
		}
}

// Line wheel symbol
module wheel_symb (wh_d=0, top_symb=true) {
	//if(view_type) {//view_type==0->3D
		diff() {
			cyly(-16,d_line, 0,0,0, 12);
			cyly(-12,10, 0,0,0, 12);
		}
		glinez();
		glinex();
		if(wh_d) {
			diff() {
				cyly(-wh_d,d_line, 0,0,0, 32);
				cyly(-wh_d+2*d_line,10, 0,0,0, 32);
			}
			if(top_symb)
				dmirrorx()
					cubex(-d_line,30,3, wh_d/2,0 ,0); 
		}
	//}
}

//-- display all wheels -------
module all_wheels () {
	//front wheels
	steer(-steering_rot) 
		fwheel();
	if(front_wheel_track)
		mirrory()
			fwheel();
		//front wheel shafts
		front_wheel_shaft(display_shafts);
	//rear wheel(s)
	dmirrory(rear_wheel_track) 
		t(wheel_base,rear_wheel_track/2)
			r(rear_camb_a)
				tslz(rear_wheel_hdia)
					if (display_wheels) {
						wheel(rear_wheel_rim,dcheck?max_rwheel_tire:rear_wheel_tire,28, shaft_width = 85, , spa=rear_spoke_adj, spoke_nbr=rear_spoke_nb);
						if(display_frame&& display_fenders)
							mirrorx()
								fender(rear_wheel_rim,dcheck?max_rwheel_tire:rear_wheel_tire,rw_mud_front,rw_mud_rear,135);
					}
					else 
						wheel_symb(rear_wheel_hdia*2,true);
	
	//spa angle parameter to adjust spoke spacing, should be user accessible ??
	module fwheel () {
		fwt = front_wheel_track;
		t(0,fwt/2)
			r(camb_ang)
				t(0,0,front_wheel_hdia)
					if(display_wheels) {
						wheel(front_wheel_rim,dcheck?max_fwheel_tire:front_wheel_tire,front_hub_dia,shaft_width=fwt?66:130,  spa=front_spoke_adj,spoke_nbr=front_spoke_nb);
						if(display_frame&& display_fenders)
							mirrorx()
								fender(front_wheel_rim,dcheck?max_fwheel_tire:front_wheel_tire,fw_mud_front,fw_mud_rear,115);
					}
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
					r(camb_ang)
						cyly(d,-shaft_length,0,0,front_wheel_hdia, 16);
		}
	}
} //all_wheels

module rear_shafts (shaft=true) {
	ds = shaft?18:d_line;
	dmirrory(rear_wheel_track) 
		t(wheel_base,rear_wheel_track/2)
			r(rear_camb_a)
				tslz(rear_wheel_hdia)
					gray()
						if(rear_wheel_track) {
							cyly(ds, -rear_shaft_lg);
							wheel_symb(rear_wheel_hdia*2);
						}
						else {
							cyly(-ds,135+45, 0,0,0, 6);
							gliney();
							wheel_symb(rear_wheel_hdia*2);
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
	//echo ("ackerman angle, angle calculated in other plane",ackermann_angle,c_acker);
	
	t(axis_offset,front_wheel_track/2-king_pin_offset, pivot_height) {
			//front wheel shaft axis
			r(camb_ang) {
				t(-axis_offset)
					gliney(shaft_length, false); //???
				t(-axis_offset,shaft_length) {
					if(view_type)
						wheel_symb(front_wheel_hdia*2, !flat);
				}
			}
			//king pin
			r(0,caster_angle)
				r(king_pin_angle) {
					//axis
					glinez (front_wheel_hdia*2+400, false,-steering_length);
					//-- frame cross structure ---
					if (!proj && display_frame) {
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
								rotz(steering_rot)
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
			orange()
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
							glinex (-arm_r_length,false);
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
			cyly (20,cr2);
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
				cyly (16,105);
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
			t(0,chainline_position-rear_shaft_lg,rear_wheel_hdia) {
				cyly(-dsp,3, 0,0,0, 24);
				
				//top chain from sprocket
				r(0,chain_rear_top_angle)
					cylx (10,-chain_rear_length, 0,0,dsp/2, 6);
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

module fork (stro=0, flg=front_wheel_hdia+55, clrf = "black") {
	rad = 100;
	pao = perp_axis_offset;
	sgn = sign(pao);
	fang = acos((rad-abs(perp_axis_offset))/rad);
	//echo(fang=fang);
	lgstr = flg-88-rad*sin(fang);
	hhang = atan(8/lgstr);
	//echo (hhang=hhang);
	fwhd = front_wheel_hdia;
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
						cyly (-24,66);
					}
					cyly (-32,8);
				}
	t(0,0,fwhd)
		r(0,caster_angle) {
			color(clrf)
				cylz (36,-40, pao,0,flg);
			gray()
				cylz (28.6,steerer_tube_length, pao,0,flg);
		}
}

module tube_frame (clrf=c_frame){
	dt = frame_tube_dia;
	br = frame_bend_radius;
	boom = (BB_long_pos<-150) && frame_BB_offset==0;
	boom_out = boom?50:0;
	prec= 24; //$fn for main tube
	stprec = 16; //$fn
	//stay diameter
	std = 16;
	
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
							cylz (-38,head_tube_height-25, 0,0,head_reinf_offset);
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
							cylx (rft_dia, -rft_length);
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
								cylx (rft_dia, -rft_length);
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
	//-- rear wheel support -------
 //dropouts offset
	rco = rear_camb_a?-50:135/2;
 color(clrf)
	dmirrory() 
		t(0,rear_wheel_track/2)
		r(rear_camb_a)
		t(wheel_base,rco,rear_wheel_hdia) {
		//chain stays
		t(0,2,20)
			r(0,chain_stay_angle, chain_stay_v_ang)
				cylx(std,-chain_stay_length+60, 30,0,0, stprec)
					tb_xy (std,-5*std,40, stprec)
						cylx(std,-20, 0,0,0, stprec);
		//dropouts
			diff() {
				hull() {
					tslz (22)
					r(0,chain_stay_angle)
						cubey (50,6,-1);
					cyly (35,6, 0,0,0, 16);
					cyly (28,6, 25,0,0, 16);
				}
				//::::::::::::::
				r(0,15)
					hull() 
						duplz(-50)
							cyly (-10,99, 0,0,0, 16);
				cyly (-8,99, 25,0,0, 16);
			}
		//seat stays
		t(15,2,28)
			r(0,seat_stay_angle, seat_stay_v_ang)
				cylx(std,-seat_stay_length+60, 15)
					tb_xy (std,-5*std,40)
						cylx(std,-20);
	}
} 

module pos_flight () {
	//steerer top
	if (c_light)
	if (flight_pos==1) {
		steer(-steering_rot)
		mirrorx()
		tslz(front_wheel_hdia)
		r(0,-caster_angle)
			t(-perp_axis_offset,0,frame_pivot_height+steerer_tube_length-12)
				front_light(caster_angle, 1, c_light);
	}
	//fork 
	else if (flight_pos==2) {
		steer(steering_rot)
		mirrorx()
		tslz(front_wheel_hdia)
		r(0,-caster_angle)
			t(-perp_axis_offset+16,0,frame_pivot_height)
				front_light(caster_angle, 2, c_light);
	}
	// boom
	else if (flight_pos==3) {
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
			cubez (1,666,555);
	silver() {
		//stem pivot shaft
		cylz(25,-stem_height-sto, 0,0,sto);
		cylz (-36,40);
		r(0,-stem_ang) {
			//stem
			cylx (32,sgo*(abs(stem_length)+40),-sgo*20);
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
	rtype = front_wheel_track?(rear_wheel_track?"quad":"trike"):"bicycle";
//fr:: 	rtype = front_wheel_track?(rear_wheel_track?"quadricycle":"tricycle"):"bicyclette";
	multiLine(
		[str("Recumbent ",rtype," geometry"),
//fr::		[str("Géometrie d'un vélo couché ",rtype),
"https://github.com/PRouzeau/Trike-geometry",
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
str("Headtube angle: ",headtube_angle, "° ,perpendicular wheel offset(rake): ", perp_axis_offset,"mm"),
//fr::str("Angle du pivot de direction: ",headtube_angle, "°  ,déport roue: ", perp_axis_offset,"mm"),
str("Trail: ",r10(trail),"mm - Wheel flop: ",r10(wheel_flop),"mm"),
//fr::str("Chasse: ",r10(trail),"mm - Wheel flop: ",r10(wheel_flop),"mm"),
str("Seat bottom height: ",seat_height,"mm - Bottom bracket height: ",BB_height,"mm")
//fr::str("Hauteur assise siège: ",seat_height,"mm - Hauteur pédalier: ",BB_height,"mm")
	]
	,size,false);
}


//== Geometry lines =================
module glinex (length=150, ctr=true, off=0) {
	if(dspl)
		cylx(d_line*(ctr?-1:1), length, off,0,0, 4);
}

module gliney (length=150, ctr=true, off=0) {
	if(dspl)
		cyly(d_line*(ctr?-1:1), length, 0,off,0, 4);
}

module glinez (length=150, ctr=true, off=0) {
	if(dspl)
		cylz(d_line*(ctr?-1:1), length, 0,0,off, 4);
}

//== Rectangle extrusion & rotation ==
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
		//cyly (-2,100);
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
