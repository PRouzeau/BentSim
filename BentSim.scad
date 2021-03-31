/*en+
BentSim, a recumbent simulator
BentSim allow 3D modelisation of a recumbent bike, trike or quadricycle. It can export geometry blueprint of whole bike/trike and steering. Overall volume or miscellaneous projections can also be exported.
 Rider size and proportion is adjustable.
 Single tube frame (circular or rectangular)
 Optional rear suspension
*/
/*fr+
BentSim, un simulateur de vélo couché
Bentsim permet la simulation 3D d'un vélo couché, bicycle, tricycle ou quadricycle. Il peut notamment exporter une épure du vélo complet et de sa direction. Un volume 3D global ou diverses projections peuvent aussi être exportées.
Taille et proportion du cycliste ajustable.
Cadre monotube (circulaire ou rectangulaire)
Suspension arrière en option.
*/
// Copyright 2019-2021 Pierre ROUZEAU,  AKA PRZ
// Program license GPL V3
// documentation licence cc BY-SA 4.0 and GFDL 1.2
// First version: 0.0 - August, 10, 2019 as Trike geometry only
//Revised October, 4, 2019
//Revised November, 10, 2019 as general Recumbent simulator
//Rev Nov, 14, 2019. Bug correction and rear suspension
//Revised  Feb, 24, 2020. Fairing, new seats, cyclist proportions and many other mods - see detailed text - 
//Revised March,29, 2021. User manual available. Delta trike tilting system, jetrike style. Single sided rear arm possible. Stays end bends adjustable. Indirect front wheel drive possible. Trike ackermann now adjustable and added possibility to adjust right/left steering. Wheel spokes now asymetric with derailleur transmission. Added optional suspension fork. Added examples and updated all others. Grouped Knuckle/Fork data in a new tab. Added experimental articulated 'lefty' fork. Rans seat viewing problem solved. U-bar can now be bended in its center (for under seat use). Can add mid-drive motors -Tongsheng TSDZ2 and Bikee 'the lightest'-. More options in display. Can now have user programmed forks and frame. User help manual. 
/*en+
Application could be downloaded here:
	https://github.com/PRouzeau/BentSim
	Download an installation procedure here:
  http://rouzeau.net/OpenSCADEn/Applications
  Manual is available here:
  http://rouzeau.net/bentsim
  A presentation is done here:
	http://rouzeau.net/OpenSCADEn/BentSim

  This uses my OpenSCAD library, included in download, but you can find details here:
	https://github.com/PRouzeau/OpenScad-Library
-	The rider came from elsewhere but was heavily modified
See comments in the rider file

There is multiple possible displays
- The 3D view, which can be exported as stl file (after rendering)
- The blueprint projection, including steering axis on plane going through king pins, which can be exported as DXF file (CAD file). In this view, you will also find a pivot projection, seen in a plane perpendicular to king pin and top and side views. 
	For this view, you may prefer to cancel shaft display (in display tab on customizer panel)
- Projection along 3 axis of the 3D view, after selection of the chosen elements.
	
	There is no complete steering simulation, yet wheels rotates independently MANUALLY to check clearances and linkage and you can have a look to wheel elevation when turning.

Note that in openscad the rendering may take some time. Projection also need some calculation time.
*/
/*fr+
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
include <Library/Bike_accessories.scad> //also include Z_library.scad
include <Library/Velo_rider.scad>
include <Library/Mid_drives.scad>
//include <User/User_mods.scad>

/*[Hidden]*/ 
rider=false; //unactivate library model
frprec = 24; // facets on frame tube ($fn)
//debug echo
debug=true;

//================================
/*fr:[Affichage]*/ 
/*[Display]*/ 
//fr:Type de vue
//View type
view_type = 0; // [0:3D view, 1:Blueprint projection, 2:Side projection, 3:Top projection, 4:Front projection, 5:Fairing projection]
//fr::view_type = 0; // [0:Vue 3D, 1:Projection de l'épure, 2:Projection latérale, 3:Projection du dessus, 4: Projection de face, 5:Projection carrosserie]
//fr:Affiche les arbres (sinon seulement les axes)
//Display shafts (else only axis)
display_shafts = true;
//fr:Affiche les lignes de géométrie (axes)
//Display geometry lines (axis)
display_lines = true;
//fr:Affiche le sol
//Display ground
display_ground = true;
//fr:Quels sont les cyclistes à afficher ?
//What riders shall be displayed ?
display_rider = 1; //[1:First rider, 2:Second rider, 3:Both riders]
//fr::display_rider = 0; //[0:Aucun, 1:1er cycliste, 2:2eme cycliste, 3:Les deux cyclistes]
//fr:Affiche le(s) cycliste(s)
//Display rider(s)
disp_rider = false;
//fr:Affiche le siège
//Display seat
display_seat = false;
//fr:Affiche le cadre complet (avec la direction)
//Display full frame (including steering)
display_frame = false;
//fr:Affiche le chassis support roue arrière
//Display rear wheel frame support
display_rear_frame = false;
//fr:Affiche la direction
//Display steering
display_steering = true;
//fr:Affiche les roues (sinon modèle filaire)
//Display full wheels (else wire model)
display_wheels = 1; //[0:No wheel, 1:Plain wheels, 2: Wireframe wheels]
//fr::display_wheels = 1; //[0:Pas de roues, 1:Roues normales, 2: Roues symbolisées]
//fr:Affiche la roue arrière relevée (si suspension)
//Display rear wheel up (if suspension)
display_rwheel_up = false;
//fr:Affiche les garde-boues
//Display mudguards
display_fenders = true;
//fr:Affiche la transmission
//Display transmission
display_transmission = false;
//fr:Affiche le moteur (s'il y en a un)
//Display motor (if any) and battery
display_motor = true;
//fr:Affiche info et avertissements dans la console
//Display information and warning in the console
inf_text = true;
//fr:Affiche avertissements et données dans la fenêtre de visualisation
//Display information and warning in the view windows
disp_text = true;
//fr:Affiche des surfaces de vérification
//Display checking surfaces
display_check =false;
//fr:Affiche la roue  droite tournée
//Display right front wheel and handlebar steered
display_steered_wheels = false;
//fr:Rotation de la direction (degrés), roue avant droite seulement
//Steering rotation angle (deg), Right wheel
steering_rot=23.7;
//fr:Angle de rotation de la roue avant gauche (ou 2eme angle)
//Steering rotation angle (deg), Left wheel (or 2nd angle)
steering_rot2=20.1;
//fr:Angle d'inclinaison
//Tilting angle
tilting = 0;
//fr:Affiche la carrosserie
//Display fairing
display_fairing = 0; //[0:None, 1:Full, 2:Half, 3:Shell -for cut-]
//fr::display_fairing = 0; //[0:Aucune, 1:Complète, 2:Demi, 3:Coque -pour coupe-]
//fr:Position de la coupure en x (plan de coupe verticale) sur le carénage
//Fairing x position of vertical cut plane
fairing_cut_x = 1300;
//fr:Position de la coupure en z (plan de coupe horizontale) sur le carénage
//Fairing z position of horizontal cut plane
fairing_cut_z = 1700;
//fr:S'il y a un carénage, affiche le pare-brise
//If fairing, display windscreen
disp_ws = true;

//=================================
/*fr:[Caméra]*/ 
/*[Camera]*/
//fr:Impose la position de la caméra définie ci-dessous - peut être inactivé pour les animations
//Enforce the camera position defined below - could be unactivated for animations
Enforce_camera_position=false; 

// The camera variables shall NOT be included in a module - a module CANNOT export variables

//fr:Vue si la position de la caméra est imposée
//View type if camera position is enforced
cam_view=0; //[0:3D view, 1:Top view, 2: Side view]

//fr:Deplacement x quand la vue de dessus est imposée
//X translation when view imposed
iview_x = -450;

//Impose camera position if rotation vector is default - to detect first startup
Cimp = Enforce_camera_position||$vpr==[55,0,25]; 

//fr:Distance de la caméra
//Camera distance
//$vpd=Cimp?cam_view?8200:7200:$vpd; //with editor and console windows
$vpd=Cimp?cam_view?5500:4500:$vpd; //no window
//fr:Vecteur de déplacement
//Camera translation 
$vpt=Cimp?[iview_x,0,750]:$vpt; 
//fr:Vecteur de rotation
//Camera rotation
$vpr=Cimp?(cam_view>0?(cam_view==1?[0,0,0]:[90,0,0]):[76,0,30]):(view_type>0?[0,0,0]:$vpr); 
//above force top view if we are displaying a projection
echo_camera();

//==============================
/*fr:[Texte Descriptif]*/
/*[Description text]*/
//fr:Numéro de modèle (si défini par l'utilisateur 100->255)
//Model N° (user defined 100->255)
modelnum = 255; //[1:255]
//fr: Votre signature (en 3D sur les vues 3D)
//Your signature (in 3D on 3D views)
txtsign = "(c) Pierre ROUZEAU, Licence cc BY-SA 4.0";
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
//fr::design="test préliminaire";

designtxt = [str("Author: ",author),str("Date, revision: ",design)];
//fr::designtxt = [str("Auteur: ",author),str("Date, révision: ",design)];

/*fr:[Cycliste et siège]*/ 
/*[Rider and seat]*/
//fr:Type de cycliste
//Rider type
rider_type=1; //[1:Pedalling, 2:Leg on ground, 3:Seated, 5:No leg] 
//fr::rider_type=1; //[1:Pédalant, 2:Un pied à terre, 3:Assis, 5:Pas de jambes] 
//fr:Taille du cycliste
//Rider height
rider_height = 1700;
//fr:Hauteur du siège
//Seat height
seat_height = 290;
//fr:Distance entre le siège et l'axe des roues avant
//Seat distance from front wheel axis
seat_front_distance = 440;
//fr:Angle du dossier de siège (/horizontale)
//Seat back angle (/horizontal)
seat_angle = 48;
//fr:Angle des jambes
//Leg angle
leg_angle=62.1;
//fr:Angle de pliage de la jambe droite
//Right leg fold angle
right_leg_fold = -0.8;
//fr:Angle d'ouverture des jambes (1~3)
//Leg spread angle (1~3)
leg_spread = 3;
//fr:Angle de la tête (/verticale)
//Head angle (/vertical)
head_angle = 12;
//fr:Jambes longues: 1.2; jambes courtes: 0
//Long legs: 1.2, short legs: 0
leg_prop = 0.5; // [0:0.1:1.2]

//fr:Angle de soulèvement des bras
//Arm lift angle
arm_lift=8;
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
rider2_height = 1900;
//fr: Décalage en x 2eme cycliste
//2nd rider x offset
rider2_x_offset = 0;
//fr: Angle de glissière de siège du 2ème cycliste
//2nd rider seat slider angle
rider2_seat_slider_angle = 12; //[-5:0.5:50]
//fr: décalage angle jambes 2eme cycliste
//2nd rider leg angle offset
rider2_leg_offset = 1.6;
//fr:2eme cycl. Angle pliage de la jambe droite
//2nd rider: Right leg fold angle
rider2_right_leg_fold = -8.2;
//fr:Sortie bôme pour le 2eme cycliste/Déplacement boitier de pédalier
//2nd rider boom extent/BB displacement
rider2_boom_extent = 120;
//fr:2eme cycliste: Jambes longues:1, jambes courtes:0
//2nd rider: Long legs : 1, short legs : 0
rider2_leg_prop = 0; // [0:0.1:1.2]
//fr:Pliage jambes pour le 2eme cycliste avec manivelles verticales (0 pour supprimer ce 2eme jeu de jambes)
//2nd rider: Leg folding for vertical cranks (0 to remove this 2nd leg set) 
rd2_vfold = 0;
//fr:Angle jambe gauche pour le 2eme cycliste avec manivelles verticales
//2nd rider: Left leg angle for vertical cranks
rd2_lfolda = 70;
//fr:Angle jambe droite pour le 2eme cycliste avec manivelles verticales
//2nd rider: Right leg angle for vertical cranks
rd2_rfolda = 43;

//fr:Type de siège
//Seat type
seat_type = 2; // [0:None,1:Rans mesh seat, 2:ICE mesh seat, 3:Hard shell seat, 9:Saddle]
//fr::seat_type = 1; // [0:Aucun,1:Rans filet, 2:ICE filet, 3:Siège coque, 9:Selle]

/*[Dimensions]*/ 
//fr:Référence projet
//Project reference
proj_ref = "Test project";
//fr::proj_ref = "Ref. projet";
//fr:Empattement
//Wheel base
wheel_base = 1110;
//fr:Voie avant (0 pour une bicyclette)
//Front wheels track (0 for a bike)
front_wheel_track = 750;
//fr:diamètre de jante roue avant
//Front wheel rim diameter
front_wheel_rim = 406; //[203,305,349,355,406,455,507,559,622]
//fr:Largeur du pneu avant
//Front tire width
front_wheel_tire = 47; //[22:125]
//fr:Largeur maximum du pneu avant (affiché avec les surfaces de controle)
//Maximum front tire width (displayed with checking surfaces)
max_fwheel_tire = 55; //[22:125]
//fr:Voie arrière: 0 pour un tricycle 'tadpole' ou une bicyclette
//Rear wheel track: 0 for a tadpole trike or a bike
rwheel_track = 0;
//fr:Diamètre de jante roue arrière
//Rear wheel rim diameter
rear_wheel_rim = 559; //[203,305,349,355,406,455,507,559,622]
//fr:largeur du pneu arrière
//Rear tire width
rear_wheel_tire = 42; //[22:125]
//fr:Largeur maximum du pneu arrière (affiché avec les surfaces de controle)
//Maximum rear tire width (displayed with checking surfaces)
max_rwheel_tire = 42; //[22:125]
//fr:Angle de chasse des pivots avant (10~12° pour les trikes a roues de 406)
//front steering caster angle (10~12° for trikes with 406 wheels)
caster_angle = 11.5;
//fr:Angle de carrossage roues avant
//Front wheel camber angle
camber_angle = 5;
//fr:Déport de l'axe roue avant (si l'axe de direction n'est pas dans le même plan que l'axe des roues) - perpendiculaire a l'axe de rotation
//Front wheel axis offset (rake - if steering axis is not in same plane as wheel shaft) - perpendicular to steering axis
perp_axis_offset = 0;
//fr:Angle de carrossage roues arrières
//Rear wheel camber angle
rear_camber_angle = 5;

//fr:Inclinaison du pivot de direction (dans le plan des pivots - incliné suivant l'angle de chasse) - uniquement pour les roues avant doubles (tricycle ou quad)
//King pin axis angle (in steering axis plane, reclined per caster angle) - only for double front wheel (trike or quad)
king_pin_angle = 15;
/*fr:[Pédalier]*/ 
/*[Bottom Bracket, cranks and drive]*/
//fr:Position longitudinale du pédalier (depuis l'axe de roue avant)
//Longitudinal bottom bracket position (from front wheel axis)
BB_long_pos = -345;
//fr:Hauteur du pédalier
//Bottom bracket height
BB_height = 380;
//fr:Longueur manivelles. Doit être plus court que pour un vélo droit. Recommandé = 0,19*entrejambe (mm).
//Crank arm length - shall be shorter than for an upright bike. Recommended = 0.19*inseam (mm).
crank_arm_length = 152;
//fr:Largeur de l'arbre de pédalier
//Crank shaft width
crankshaft_width = 117;
//fr:Angle des manivelles
//Crank angle (from horizontal)
crank_angle = -21;
//fr:Angle des manivelles verticales ~90
//Crank angle when vertical (from horizontal) ~90
vcrank_angle = 90;
//fr:Angle des pédales
//Pedal angle (from crank)
pedal_angle = 81;
//fr:Angle des pédales pour les manivelles verticales
//Pedal angle for vertical crank (from crank)
vpedal_angle = 120;
//fr:Moteur
//Motor
motor_type = 0; //[0:none, 1:TSDZ2 - Chainring 44 teeth, 2:Bikee]
//fr:Angle du moteur
//Motor angle
mot_ang = 0;
//Bikee motor x
mot_x = 110;
//Bikee motor z
mot_z = 15;
//fr:Angle du bras de roulette du moteur Bikee
//Bikee motor idler arm angle
mot_idler_ang = 20;
//Battery type
batt_type = 0; //[0: Frame batterie height 111, 1:Frame battery height 90, 2:Rack battery, 3:Prismatic battery]
//fr: Position x de la batterie
//Battery x position
batt_x=600;
//fr: Position z de la batterie
//Battery z position
batt_z=400;
//fr: Angle de la batterie
//Battery angle
batt_ang=20; //[-20:0.5:360]

/*fr:[Transmission par chaîne]*/
/*[Chain transmission]*/
//fr:Type de transmission
//Transmission type
trans_type=0; // [0:Rear wheel drive,1:Indirect front wheel drive]
//fr::trans_type=0; // [0:Propulsion,1:Traction indirecte]
//fr:Nombre de dents du plateau
//Chainring teeth number
chainring_teeth = 38;
//fr:Nombre de dents du pignon arriere
//Rear sprocket teeth number
sprocket_teeth = 19;
//fr:Pignon simple ou boite de vitesses
//Single speed or gearbox
single_speed = 0; // [0:Dérailleur, 1:Single speed, 2: Hub gear]
//fr:Position latérale de la ligne de chaîne
//Chainline side position
chainline_position = 50;

//fr:Les poulies de chaine du brin tendu et du brin mou sont sur le même axe
//Driving idler and return idler on same shaft
merged_idler = true;
//fr:Le brin tendu de la chaîne (en haut) est au-dessus de la poulie
//Driving chain (on top) is below the idler
drv_chain_bot = true;
//fr:Angle de la chaine supérieure (plateau vers poulie) - par rapport à l'horizontale
//Top chain angle from chainring (from horizontal)
chain_angle = 30.1;
//fr:Longueur du brin tendu (en haut)- du plateau vers la poulie
//Driving chain length (top) - chainring to idler
chain_length = 550;
//fr:Le brin mou de la chaîne (en bas) est au-dessus de la poulie
//Return chain (bottom) is on top of the idler
rt_chain_top = false;
//fr:Angle brin mou 'en bas) - plateau vers poulie - Utilisé si poulies disjointes
//Return chain (bottom) angle - chainring to idler - Used if separated idlers
chain_ang_bot = 16.2;
//fr:Longueur brin mou (en bas) chaine - plateau vers poulie - Utilisé si poulies disjointes
//Return (bottom) chain length - chainring to idler - Used if separated idlers
chain_length_bot = 540;
//fr:Angle brin tendu (en haut) chaîne (pignon roue vers poulie)
//Driving (top) chain angle (wheel sprocket to idler)
chain_rear_top_angle = -11.9;
//fr:Longueur du brin tendu (haut) de la chaîne (pignon de roue vers poulie)
//Rear chain driving (top) segment length (wheel sprocket to idler)
chain_rear_length = 925;
//fr:Angle du brin mou (bas) (pignon de roue vers poulie)
//Rear return (bottom) chain angle (wheel sprocket to idler)
chain_rear_bot_angle = -9.3;
//fr:Longueur du brin mou (bas) de la chaîne (pignon roue vers poulie)
//Rear chain return segment (bottom) length (wheel sprocket to idler)
chain_rear_bot_length = 925;

//================================
/*fr:[Fusée ou Fourche]*/ 
/*[Steering knuckle or fork]*/
//fr:Longueur de la douille de direction (1 ou 2 roues)
//Frame head tube length (1 or 2 wheels)
head_tube_height = 90;
//fr:Hauteur de la base du roulement du pivot par rapport a l'axe de roue - perpendiculaire. (1 ou 2 roues)
//Fork/pivot perpendicular height - from wheel axis line to bottom bearing seat. (1 or 2 wheels)
frame_pivot_height =15;
//fr:Extension de l'arbre de pivot au dessus de l'axe de roue (2 roues)
//King pin shaft extension above wheel shaft (2 wheels)
above_extent = 120;
//fr:Extension de l'arbre de pivot au dessous de l'axe (2 roues)
//King pin shaft extension below wheel shaft (2 wheels)
below_extent = 40;
//fr:Hauteur du plan de tringlerie de direction au dessus de l'axe des roues - calculé dans le plan passant par les pivot, pas verticalement (2 roues)
//Steering knuckle arm bearing plane height relative to wheel axis - defined in king pin plane, not vertical (2 wheels)
arm_position = -35;
//fr:Longueur du levier de fusée -  dans un plan horizontal. (2 roues)
//Steering knuckle arm length - in horizontal plane (2 wheels)
arm_length = 60;
karm_lg = arm_length;
//fr:Compensation épure d'Ackermann, mm (à cause de l'angle de chasse, la correction d'Ackermann ne fonctionne pas très bien, il faut avancer la pointe du triangle devant l'axe du train arrière)
//Ackermann compensation, mm (due to caster_angle, Ackermann correction does not work well, triangle tip shall be set forward rear axle) 
ackermann_mod = 120;
//fr:Type de fourche (1 roue)
//Fork style (1 wheel)
fork_style = 0; //[0:Rigid, 1:Suspended, 2: Experimental lefty, 3: User defined]
//fr::fork_style = 0; //[0:Rigide, 1:Suspendue, 2: Monobras prototype, 3: Utilisateur]
//fr:Encombrement vertical du roulement inférieur de pivot de direction. (1 roue)
//Steering bottom bearing vertical space (1 wheel)
steer_bbht = 5;
//fr:Longueur du tube pivot de fourche au dessus du siège de roulement (1 roue)
//Steerer tube length atop bearing seat plane (1 wheel)
steerer_tube_length = 120;
//================================
/*fr:[Cadre monotube]*/ 
/*[Tube frame]*/
//fr:Type de cadre - les types personnalisés nécessitent leur propre programme
//Type of frame - customized frame required own program
frame_type = 0; // [0:Tube Frame, 1:Customized frame 1, 2: Customized Frame 2, 3: Customized frame 3]
//fr:Décalage du renfort d'attache de direction (si 0, pas de renfort)
//head tube reinforcement offset (if 0, no reinforcement)
head_reinf_offset = -20;
//fr:Diamètre/largeur du tube principal du cadre
//Main frame tube diameter/width
frame_tube_dia = 50;
//fr:Hauteur du tube principal, 0->tube circulaire
//Main frame tube height  0->cylindrical tube
frame_tube_ht = 0;
//fr:Rayon de cintrage du tube de cadre
//Frame bend radius
frame_bend_radius = 180;
//Épaisseur du tube principal de cadre (pour calcul poids)
//Frame main tube thickness (for weight calc)
frame_tube_thk = 1.5;
//fr:Diamètre/largeur du tube de croix du cadre -si 0 -> même tube que le principal -
//Cross frame tube diameter/width - if 0 -> same tube as main -
cross_tube_dia = 0;
//fr:Longueur du tube en avant du boitier de pédalier
//Tube length in front of Bottom Bracket
frame_front_extent = 0;
//fr:Angle du tube devant le boitier de pédalier
//Angle of tube in front of Bottom Bracket
frame_BB_angle = 3; //[-80:0.5:80]
//fr:Décalage perpendiculaire du cadre par rapport au boitier de pédalier
//Frame offset to BB (perpendicular to frame tube)
frame_BB_offset = 0;
//fr:Longueur tube derrière le pédalier
//Length of tube behind BB
frame_front_length = 310;
//fr:Angle coude après tube derrière le pédalier
//Bend angle after tube behind BB
frame_front_bend_angle =-39; // [-70:0.5:70]
//fr:Longueur tube sous siège 
//Under seat tube length
frame_seat_length = 100;
//fr:Angle coude après tube sous siège 
//Bend angle after seat tube
frame_seat_bend_angle = 41;
//fr:Longueur tube de dossier
//Back seat tube length
frame_back_length = 220;
//fr:Angle coude après tube de dossier
//Bend angle after back tube
frame_back_bend_angle = 58;
//fr:Longueur tube support appui-tête
//Tube behind headrest length
frame_rear_length = 235;
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
//fr:Rotation du tube en croix sur l'axe longitudinal - angle 0 perpendiculaire au pivot
//Trike cross rotation on longitudinal axis - 0 angle perpendicular to kingpin axis.
cross_Y_angle=-15;
//fr:Rotation vers l'arrière du tube de croix d'un trike
//Trike cross rotation to rear
cross_rear_angle=50;
//fr:Distance du coude de la croix par rapport au pivot de direction
//distance of bend on cross beam from kingpin axis
cross_bend_dist=60;
//fr:Longueur du tube de croix après le coude
//Cross arm tube length after bend
cross_lg_adjust = 130;

/*fr:[Support roue arrière]*/
/*[Rear wheel support]*/
//fr:Diamètre des bases
//Chain stay diameter
stay_dia = 16;
//fr:Angle de la base (rel. horizontale)
//Chain stay angle (from horizontal)
chain_stay_angle = -5.1;
//fr:Rotation base sur axe vertical
//Vertical angle of chain stay
chain_stay_v_ang = 2.1;
//fr:Longueur de la base
//Chain stay length
chain_stay_length = 470;
//fr:Angle du coude au raccordement de la base sur le cadre (0: pas de coude)
//Chain stay elbow angle at connexion on the frame (0: no elbow)
chain_stay_elbow = 40;
//fr:Décalage latéral du monobras arrière, 0 laisse le double hauban
//Single stay arm side offset, 0 left dual stay
//fr:Diamètre haubans, si 0 égal au diamètre des bases
//Seat stay diameter, if 0 equal to chain stay diameter
seatstay_dia = 0;
//fr:Angle des haubans (rel. horizontale)
//Seat stay angle (from horizontal)
seat_stay_angle = 16.5;
//fr:Rotation hauban sur axe vertical
//Vertical seat stay angle
seat_stay_v_ang = 5.9;
//fr:Longueur hauban (affiché si longueur > 0)
//Seat stay length (displayed if length>0)
seat_stay_length = 405;
//fr:Angle du coude au raccordement du hauban sur le cadre (0:pas de coude)
//Seat stay elbow angle at connexion on the frame (0: no elbow)
seat_stay_elbow = 40;
//fr:Décalage latéral du bras (crée un monobras - peut être positif ou négatif)
//Rear arm side offset (not 0 make the arm single sided, positive or negative)
rear_arm_offset = 0;
//fr:Position longitudinale de l'axe suspension arrière (0: pas de suspension)
//Longitudinal position of rear suspension axis (0: no suspension)
rsusp_x = 0;
//fr:Hauteur de l'axe de suspension arrière
//Height of rear suspension axis
rsusp_z = 412;
//fr:Mouvement vertical de la suspension arrière
//Rear suspension vertical travel
rsusp_travel = 90;
//fr:Diamètre tube central cadre suspension arrière
//Rear suspension frame central tube diameter
rsusp_dia = 50;
//fr:Longueur tube central cadre suspension arrière (0: pas de tube central)
//Rear suspension frame central tube length (0: no central tube)
rsusp_lg = 240;
//fr:Angle tube central cadre suspension arrière
//Rear suspension frame central tube angle
rsusptan = -14;
//fr:Position amortisseur arrière sur tube central cadre suspension arrière
//Rear suspension shock position on tube
rsusp_shock_pos = 195;
//fr:Angle amortisseur arrière / tube central cadre
//Rear suspension shock angle / rear frame tube
rsusp_shock_an = 88;
//fr:Angle du support de bras de suspension arrière
//Rear arm bracket angle
rsusp_arm_bracket_an = -25;
//fr:Angle du support d'amortisseur arrière (coté cadre)
//Rear shock bracket angle (frame side)
rsusp_shock_bracket_an = 42;
//fr:Longueur amortisseur arrière (non comprimé)
//Rear shock length (uncompressed)
shock_length = 190;
//fr:Compression amortisseur arrière (cycliste en place: 20 à 25% de la course)
//Rear shock sag (static compression when rider on: 20 to 25% of travel)
shock_sag = 12;

/*fr:[Guidon]*/
/*[Handlebar]*/
//fr:Type de guidon
//Handlebar type
handlebar_type = 3; // [0:Trike direct, 1:Cruiser, 2:Hamster, 3:U Bar]
//fr::handlebar_type = 3; //[0:Direction directe (tricyle), 1:Guidon cintré, 2:Hamster, 3:U Bar]
//fr:Le guidon est sur le pivot de direction (sinon sous le siège) - 2 roues
//Handlebar is on kingpin axis (2 else under seat) - 2 wheels
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
hdl_lg = 400;
//fr:'Pliage' latéral des bras du guidon U-bar
//U bar side arm bending angle
hdl_bend = 37.5;
//fr:Guidon U-bar, elargissement au centre
//U-bar central widthening
hdl_width_central_extent=0;
//fr:Angle cintrage central du guidon U-bar
//U-bar central arm bending angle
hdl_central_bend_angle = 0;
//fr:Orientation cintrage central du guidon U-bar / verticale
//U-bar central arm bending orientation/ vertical
hdl_central_bend_orientation = 0;
//fr:Longueur bouts de guidon U-bar
//U-bar bar ends length
hdl_lg2 = 200;
//fr:Position longitudinale d'un guidon sous le siège (x)
//Under seat steering longitudinal  position (x)
USS_x = 270;
//fr:Position en hauteur de l'axe d'un guidon sous siège (z)
//Under seat steering axis height position (z)
USS_z = 270;
//fr:Angle du pivot de direction pour un guidon sous siège
//Under seat steering angle (from vertical)
USS_angle = 10;
//fr:Coefficient d'amplification de direction sous le siège (mouvement de roue/mouvement de guidon)
//Under seat steering amplification coefficient (wheel angle/handlebar angle) 
cf_steer = 1.5;
/*fr:[Carosserie]*/
/*[Fairing]*/
//fr:Affichage des segments de carrosserie, il y a toujours un couple de plus que le nombre de segments.
//Fairing segment display - first segment (nose) is number 0 - there is always one more frame than segment number
bdisp = [1,1,1,1,1];
//fr:Longueur des segments de carrosserie (Le premier est le nez)
//Fairing segment length (first is nose)
blg = [377,310,620,500,750];
//fr:Angle des couples
//Frames angle 
bang = [0,15,-5,10,-36,0];
//fr:Largeur du couple
//Frame width
bwd = [670,670,780,770,650,100];
//fr:Pincement haut du couple
//Frame top width pinching (negative number enlarge frame top)
bpinch = [50,30,70,120,180,0];
//fr:Hauteur du couple (sans extension)
//Frame height (without extension)
bht = [460,440,530,640,930,820];
//fr:Position verticale du centre des couples
//Frames center vertical position
bzpos = [0,-20,15,110,180,260];
//fr:Rayon en bas des couples
//Frame bottom radius
brd = [230,130,100,100,140,47];
//fr:Rayon en haut des couples
//Frame top radius
brdt = [230,190,180,200,140,47];
//fr:Rayon du bombement supérieur (un rayon plus petit agrandit le bombement)
//Frame top bulge radius (lower radius increase bulge)
bwrdt = [0,0,0,0,0,0];
//fr:Rayon des bombements latéraux (un rayon plus petit agrandit les bombements)
//Frame side bulge radius (lower radius increase bulge)
bwrd = [0,500,0,0,1800,1000];
//fr:Largeur de l'extension au dessus
//Frame top bubble width
bblwd = [0,440,450,470,240,0];
//fr:Hauteur supplémentaire de l'extension
//Frame top bubble vertical extent
bblht = [0,80,90,80,230,0];
//fr:Changment au droit de l'extension (-1: pas d'extension haute après, 1: pas d'extension haute avant)
//Frame top bubble discontinuity (-1: no bubble behind, 1: no bubble before)
bblct = [0,0,0,0,1];
//fr:Pliage du couple
//Frame folding angle
bfold = [0,-31,0,0,16,0];
//fr:Position verticale du pli (/ centre)
//Frame fold vertical position (relative/center)
bfoldo = [0,70,0,0,160,0];
//fr:Coefficient d'allongement du nez (2~3)
//Nose length ovoidal coefficient (2~3)
fnosecf = 1.9;
//fr:Le toit est situé sur le segment N° - 0:pas de toit
//roof is located on segment N° - 0:No roof
froofseg = 0;
//fr: Largeur du toit
//roof top width
froofwd = 220;
//fr:Allongement du toit  (1,5~2.5)
//Roof length proportion (to width - 1.5~2.5)
froofcf = 1.5;
//fr:Proportion verticale de l'ellipsoide du toit (0,5~0,75)
//Roof ellipsoidal volume vertical proportion (to width - 0.5~0.75)
froofvcf = 0.6;
//fr: Position longitudinale du toit (/couple) 
//roof top longitudinal position (/frame)
froofx = 300;
//fr: Position en hauteur du toit (au dessus du couple avant) 
//roof top vertical position (atop the front frame)
froofz = 300;
//fr:Position de la carrosserie (réf. entre le segment 1 et 2)
//Fairing x position (ref between first and second segment)
fairing_x = 310;
//fr:Position verticale de la carrosserie
//Fairing z position
fairing_z = 380;
//fr:Correction de profondeur (latérale) du puit de roue avant. positif:plus profond
//Front wheel well depth (sideways) correction. Positive: depeer
dp_well=-20;
//fr:Angle supérieur du pare-brise
//Windscreen top angle
ws_ang = -3;
//fr:Position horizontale du saute-vent
//Wind deflector x position (0: no deflector)
bscreen_x = -480;
//fr:Position verticale du saute-vent
//Wind deflector Z position
bscreen_z = 770;
//nose length radius
noselrd = brd[0]*fnosecf;
//echo(str("Nose length radius: ",noselrd," mm"));
bposx  = [blg[1]+blg[0]-noselrd,blg[1],0,-blg[2],-blg[2]-blg[3],-blg[2]-blg[3]-blg[4]];

// demo with recursive function
function incp(n)=(n==0?0:incp(n-1))-blg[n];
bposx2 = [for(i=[0:4]) incp(i)];
bposx3 = [for(i=[0:5]) (i==0?0:bposx2[i-1])+blg[0]+blg[1]];
//echo(bposx3=bposx3);
//echo(bposx=bposx);

//===================================
/*fr:[Cosmétique et accessoires]*/ 
/*[Cosmetic and accessories]*/
//fr:Drapeau sur le siège
//Flag on seat
flag = true;
//fr:Position du feu avant (affiché uniquement si le feu a une couleur, voir l'onglet couleurs)
//Front light position - light shown only if its color defined - see color tab
flight_pos = 3; //[0:None, 1:Steerer top, 2:Fork, 3: Boom] 
//fr::flight_pos = 3; //[0:Sans, 1:Haut du tube de direction, 2:Fourche, 3: Bôme] 
//fr:Feu arrière
//Rear Light
rlight = true;
//fr:Diamètre du moyeu avant
//Front hub diameter
front_hub_dia = 70;
//fr:Diamètre du moyeu arrière - si 0, c'est le type de transmission qui définit le diamètre
//Rear hub diameter - set to 0 left the transmission type decide.
rear_hub_dia = 0;
//fr:Nombre de rayons de la roue avant
//Number of front wheel spokes
front_spoke_nb = 36;//[0:disc,3,4,5,6,8,20,24,28,32,36,40]
//fr:Roue AV: angle d'ajustement des rayons (pour égaliser l'espace entre les rayons). Si 0, rayonnage radial
//Front spoke angle adjustment (to equalise spoke space). If 0, radial spokes
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
rear_spoke_nb = 36; //[0:disc,3,4,5,6,8,20,24,28,32,36,40]
//fr:Roue AR: angle d'ajustement des rayons (pour égaliser l'espace entre les rayons)
//Rear spoke angle adjustment (to equalise spoke space)
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
c_frame="Orange";
//fr:Couleur fourche
//Fork color
c_fork="Black";
//fr:Couleur jantes, rayons et moyeu
//Rim, spokes and hub color
c_rim="Silver"; 
//fr:Couleur pneus
//Tire color
c_tire="DimGray"; 
//fr:Couleur pédales
//Pedals color
c_pedal = "DarkSlateGrey";
//fr:Couleur des carters de feux
//Front and rear lights casing color
c_light = "Black";
//fr:Couleur acier
//Steel color
c_steel="Darkgray";
//fr:Couleur aluminium
//Aluminium color
c_alu="Silver";
//fr:Couleurs carrosserie [Corps, nez, saute-vent]
//Fairing colors [Fairing, Nose, Wind deflector]
fairing_color = ["silver", "orange", [0.5,0.5,0.5,0.35]];
//fr:Couleur vitrage (RGBa, valeurs de 0 à 1, a est la transparence, une valeur plus grande est plus opaque)
//Screen glass color (RGBa, values 0 to 1, a is transparency, higher value is more opaque)
c_glass=[0.5,0.5,0.5,0.35]; // [0:0.05:1]

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
view_fairing = -1; // < 0 to not force view
view_sidefairing = 5;

//=================================
d_line = $preview?2:0.1;
half_v = display_fairing==2;

usertxt = [txt1,txt2,txt3,"",txt4,txt5,txt6,txt7,txt8];
//echo(usertxt=usertxt);
//== Values ependant from others ===========
//display checking surfaces
dcheck = display_check && view_type==view_3D;
//display geometry lines
dspl= (view_type==view_flat)?true:display_lines;
//Actual king pin angle only if twin wheels
kingpin_ang = front_wheel_track? king_pin_angle:0;

//== calculation =================
function wheel_diam (rim,tire)= rim+2*tire+4;

rider2_z_offset = tan(rider2_seat_slider_angle)*rider2_x_offset;
//echo(rider2_z_offset=rider2_z_offset);
//ground axis offset
axis_offset= perp_axis_offset/cos(caster_angle);

//effective camber angle - 0 when bicycle
camb_ang = front_wheel_track?camber_angle:0;
//effective rear camber angle - 0 when tricycle
rear_camb_a = rwheel_track?rear_camber_angle:0;

fwheel_hdia= wheel_diam(front_wheel_rim,front_wheel_tire)/2;

rwheel_hdia= wheel_diam(rear_wheel_rim,rear_wheel_tire)/2;

ground_length = fwheel_hdia/cos(caster_angle);
trail_base = ground_length*sin(caster_angle);
trail = trail_base-axis_offset;

//head ht when steering angle ==0
hht1 =fwheel_hdia+frame_pivot_height*cos(caster_angle)-perp_axis_offset*sin(caster_angle);
//head ht when steering angle ==0
hht2 = (fwheel_hdia+frame_pivot_height)*cos(caster_angle);

echo (hht1=hht1,hht2=hht2, hht2-hht1, "mm");
echo ("wheel axle drop",fwheel_hdia*(1-cos(caster_angle))); 

steering_length = 
	ground_length/cos(kingpin_ang-camb_ang);
shaft_length = steering_length * sin(kingpin_ang-camb_ang);
king_pin_offset = steering_length*sin(kingpin_ang);

pivot_height = (fwheel_hdia/cos (kingpin_ang-camb_ang))*cos (kingpin_ang);

wheel_shaft_lg = atan(kingpin_ang-camb_ang)*ground_length;


headtube_angle = 90-caster_angle;

//this wheel flop calculation does not take into account king pin angle, so it is wrong for tadpole trikes
//Also, this formula (from Wikipedia) is wrong, see comments in the manual
wheel_flop = cos(headtube_angle)*sin(headtube_angle)*trail;

//length of an half rear shaft for a quad
rear_shaft_lg = rwheel_track?rwheel_track/cos(rear_camber_angle)/2-rwheel_hdia*tan(rear_camber_angle):0;

//== Rear suspension ============
rsusp_zoff = rsusp_z-rwheel_hdia;
rwheel_dist = pow(pow(wheel_base-rsusp_x,2)+pow(rsusp_zoff,2),0.5);
if(rsusp_x)
	techo(str("Rear suspension arm length: ",round(rwheel_dist),"mm"));
//fr::	techo(str("Longueur bras de suspension arrière: ",round(rwheel_dist),"mm"));

rear_arm_angle = asin((rsusp_z-rwheel_hdia)/rwheel_dist);
//becho("rear_arm_angle",rear_arm_angle);

// angle of the rear suspension arm movement
rs_ang = asin((rsusp_travel/rwheel_dist)/cos(rear_arm_angle)); //not exact, 2nd degree error. Travel not possible in certain conditions, so NaN is generated
//echo(rsusp_ang=rsusp_ang);
rsusp_ang= rsusp_x?rs_ang!=rs_ang?0:rs_ang:0;
if(rs_ang!=rs_ang) // test if NaN
	echo("The rear suspension horizontal axis position is unrealistic");
//fr::	echo("La position horizontale de l'axe de la suspension arrière est irréaliste");
// == tilting angle ====
//Wheel vertical travel when tilting
tlt_travel = rwheel_track/2 *tan(tilting);
tlt_rsang = asin((tlt_travel/rwheel_dist)/cos(rear_arm_angle));

//== Geometry data calc ======
//== Ackermann steering calculations ==
arm_y_offset = arm_position*sin(kingpin_ang);
//becho("arm_y_offset",arm_y_offset);
arm_z_plane = arm_position*cos(kingpin_ang);
arm_x_offset = arm_z_plane* sin(caster_angle);
arm_z_offset = arm_z_plane* cos(caster_angle);

whk = wheel_base-ackermann_mod;

x_ackermann = whk-arm_x_offset-axis_offset;
y_ackermann = front_wheel_track/2-king_pin_offset-arm_y_offset;
ackermann_angle = atan(y_ackermann/x_ackermann);
//becho("Ackermann angle",ackermann_angle);
lg_ackermann = x_ackermann/cos(ackermann_angle);

lgep = front_wheel_track/2-shaft_length-arm_y_offset;
lg_steer = lgep-karm_lg*sin(ackermann_angle);

ack_base_dist = whk-arm_position*sin(caster_angle);
tie_dist = ack_base_dist-karm_lg*cos(ackermann_angle);

//cyly(-2,300, -wheel_base+tie_dist,0,pivot_height+arm_z_offset);

lg_tie = tie_dist*tan(ackermann_angle);

karm_dist = (arm_position)/cos(kingpin_ang);

///cos(caster_angle);
	//??? composed angle, not caster angle ? 
arm_r_length= karm_lg*cos(caster_angle)*0.99; //?? composed angle, not caster angle ? 
// Below formulas are quite approximate, not real ?? 
compos_ang = atan(cos(caster_angle)*tan(kingpin_ang));
//echo (compos_ang=compos_ang);
arm_dist_dec = karm_lg*sin(compos_ang);
//echo(arm_dist_dec =arm_dist_dec);

//calculate length - for a SWD or tadpole trike, that depends from BB extent and chainring diameter
cycle_length = round(wheel_base+rwheel_hdia+((BB_long_pos<0)?-BB_long_pos-120:fwheel_hdia));

//Displaying steered wheel (right only)
//Right wheel steering
strot = display_steered_wheels?steering_rot:0;
lgrot = wheel_base/tan(strot);
//left (or 2nd wheel steering)
strot2 = display_steered_wheels?steering_rot2:0;
lgrot2 = wheel_base/tan(strot2);
lgrear = max(lgrot, lgrot2);

//Frame calc
boom = (BB_long_pos<-150) &&frame_BB_offset==0;

//== Console messages ========
techo("Front wheel diameter: ",fwheel_hdia*2, "mm, Tire:",front_wheel_tire,"mm Rim:",front_wheel_rim);
//fr::techo("Diamètre roue avant: ",fwheel_hdia*2,"mm, Pneu:",front_wheel_tire,"mm Jante:",front_wheel_rim);
techo("Rear wheel diameter: ",rwheel_hdia*2,"mm, Tire:",rear_wheel_tire,"mm Rim:",rear_wheel_rim);
//fr::techo("Diamètre roue arrière: ",rwheel_hdia*2,"mm, Pneu:",rear_wheel_tire, "mm Jante:",rear_wheel_rim);
techo("Wheel base: ",wheel_base," mm");
//fr::techo("Empattement: ",wheel_base," mm");
techo("Cycle length: ",cycle_length," mm");
//fr::techo("Longueur vélo: ",cycle_length," mm");
if(front_wheel_track)
techo("Front wheel track: ",front_wheel_track," mm");
//fr::techo("Voie avant: ",front_wheel_track," mm");
if(rwheel_track) 
techo("Rear wheel track: ",rwheel_track," mm");
//fr::techo("Voie arrière: ",rwheel_track," mm");
if(rwheel_track) 
  techo("Rear wheel camber angle: ",rear_camber_angle," mm");
//fr::techo("Angle de carrossage arrière: ",rear_camber_angle," mm");
techo("Headtube angle/Caster angle: ",headtube_angle," / ",caster_angle," °");
//fr::techo("Angle du pivot de direction: ",headtube_angle, " °");
techo("Ground trail: ",r10(trail)," mm ; Mechanical Trail:",r10(cos(caster_angle)*trail), " mm");
//fr::techo("Chasse: ",r10(trail)," Chasse perpendiculaire : ",r10(cos(caster_angle)*trail)," mm");
techo("Wheel flop: ",r10(wheel_flop)," mm");
if(front_wheel_track)
  techo("Steering tie rod length: ",r10(lg_tie*2)," mm");
//fr::techo("Longueur barre de direction: ",r10(lg_tie*2)," mm");
if(shaft_length)
techo("Shaft length from wheel center to king pin axis: ",r10(shaft_length)," mm");
//fr::techo("Longueur arbre entre le milieu de la roue et l'axe du pivot: ",r10(shaft_length)," mm");
if(rear_shaft_lg)
techo("Rear half shaft length (to wheel middle): ",rear_shaft_lg," mm");
//fr::techo("Longueur du demi-arbre arrière (au milieu de la roue): ",rear_shaft_lg," mm");
rins = round(in_seam(rider_height,leg_prop));
techo("Rider height: ",rider_height,"mm; Inseam: ", rins,"mm; Suggest crank: ", round(rins*0.19),"mm");
//fr::techo("Taille cycl. ",rider_height,"mm; Entrejambe",rins, "mm; Pref. manivelle: ", round(rins*0.19),"mm");
if (rider2) {
  rins2 = round(in_seam(rider2_height,leg_prop));
techo("Rider 2 height: ",rider2_height," mm");
//fr::techo("Taille du cycliste: ",rider_height,"mm");
techo("Rider 2 inseam: ", rins2, " mm");
//fr::techo("Hauteur de l'entrejambe",rins2, "mm");
techo("Recommand crank: ", round(rins2*0.19),"mm");  
//fr::techo("Longueur manivelle recommandée",round(rins2*0.19), "mm");  
techo("Rider 2 BB height: ",BB_height+sin (frame_BB_angle)*rider2_boom_extent," mm");
//fr::techo("Taille du cycliste: ",rider_height," mm");
techo("Rider 2 BB dist: ", BB_long_pos-cos(frame_BB_angle)*rider2_boom_extent, " mm");
//fr::		techo("Hauteur de l'entrejambe",round(in_seam(rider_height,leg_prop)), "mm");
}
if(rsusp_x) // there is a rear suspension
	techo("Rear shock travel: ", round(tan(rsusp_ang)*rsusp_shock_pos), " mm");
//fr::	techo("Course amortisseur arrière: ", round(tan(rsusp_ang)*rsusp_shock_pos), " mm");
//
module goBB () {
  t(BB_long_pos,0,BB_height)
    children();
}
//----------------------
module frame_special () {
	dt = 17;
	red()
  goBB()
	dmirrory() {
	r(6,-3,0.8)
	cylx(dt,350, 0,22,6)
	tb_xz(dt,-100,-40)
	cylx(dt,370)
	tb_xz(dt,100,-72)
	cylx(dt,370)
	tb_xz(dt,-100,-35)
	cylx(dt,370)
	;
	r(7,5,1.8)
	cylx(dt,345, 0,22,-8)
	tb_xz(dt,-100,-40)
	cylx(dt,420)
	tb_xz(dt,100,-74)
	cylx(dt,810)
	;	
	}
}
//mirrorx() frame_special();

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
		//signature and user text
		print_text(200, -70);
		t(1200,-70)
			rotz(180)
				print_info(30);
	}
}
else if (view_type==view_top){//top view
	projection() 
		rotz(180)
			3Dview();
	if (disp_text) {
	//signature and user text
		print_text(200, -600);
		//info
		t(1200,600)
			rotz(180)
				print_info(30);
	}
}
else if (view_type==view_front) { //front view
	projection() 
		r(-90,90) 
			3Dview();
	if (disp_text) {
	//signature and user text
		print_text(200, -600);
		//info
		t(1200,600)
			rotz(180)
				print_info(30);
	}
}
else if (view_type==view_sidefairing)
	fairing_proj();
else if (view_type==view_fairing)
	full_fairing(display_fairing);
else { // 0 - 3D view
	//hull() r(0,-80) scale(0.1)	fairing();
	rotz(180) 3Dview(); 
	print_text();
}
//== 3D view =======================
module 3Dview () {
	//ground
	if (view_type!=view_top)
	 if(display_ground)
		gray() { 
			cubex(wheel_base+1100,1440,d_line,-700);
			if (dspl) // dimensions marks
				duplx(500,3)
					cubez (1,222,6);
		}
	//
	if(dspl) {
		arrow();
		w_track();
	}
  r(tilting) {
    all_wheels(true,false, !half_v);
    disp_transmission();
    steering(false,true,strot,strot2);
    if (disp_text&&view_type<0)
    t(1200,600) // print 3D ground info only in 3D view
      rotz(180)
        linear_extrude(1)
          print_info(30);
    if (display_frame) {
      if(frame_type==1)
        custom_frame1();
      else if(frame_type==2)
        custom_frame2();
      else if(frame_type==3)
        custom_frame3();
      else  {
        tube_frame();
        if(display_rear_frame)
          rear_frame(); 
      }  
      if(display_motor&&motor_type)
        battery(batt_type,batt_x,batt_z,batt_ang,true);
      if(!front_wheel_track && display_steering)
        fork(fork_style,-strot, frame_pivot_height,fwheel_hdia, caster_angle, perp_axis_offset, trans_type==0?100:135, steerer_tube_length,steer_bbht,head_tube_height,c_fork);
      
   //   fork (style=0, stro=0, flg=fwheel_hdia+55, hdia=325,  casta=18, pao=47, OLD=100, stl = 180, clrf = "black") 
      
      if(!OSS_handlebar && display_steering)
        t(USS_x,0,USS_z)
          r(0,USS_angle,180) {
            rotz(-strot/cf_steer)
              handlebar(handlebar_type, stem_length,stem_height,stem_ang,hdl_ang,hdl_lg,hdl_bend, hdl_width_central_extent,
hdl_central_bend_angle,hdl_central_bend_orientation,hdl_lg2, dcheck, d_line);
            glinez(400);
          }
      //front light
      pos_flight();
    }
    if(dcheck) red() {
      //rear suspension - check plane
      if(rsusp_x)
        cubez(100,200,d_line, wheel_base,0,rwheel_hdia+rsusp_travel);
      //reference seat height (nor real due to slope
      cubez(500,500,d_line, wheel_base-450,0,seat_height);
      goBB()
        cubez(80,400,d_line);
    }  
    //---------------------
    disp_rider();
    //Print full fairing  (after other stuff to have transparency)
    rotz(180)
      full_fairing(display_fairing);
  }
}

//== Flat view =================
module flat_view () {
	module p_arrow (ry=0,rz=0, tx = "", rev=false) {
		r(0,ry,rz) {
			cubex(-100,5,5);
			dmirrorz() 
				r(0,15)
					cubex(-27,5,4);
			t(-75,0,12)
				r(90) mirrorx(rev)
					linear_extrude(1)
						mytxt(tx, 32);
		}
	}
	projection() {
		// Steering blueprint
    // View B (front view)
		r(0,90-caster_angle)
			t(trail) {
				steering(true,true,strot,strot2,true);
				all_wheels(false, false); //front wheels only
				// Arrow
				r(kingpin_ang)
					t(0,front_wheel_track/2, 420) 
						p_arrow(90,90, "A");
			}
		// View A - Pivot view
		t(fwheel_hdia+50,600)
			r(kingpin_ang)
				r(0,-caster_angle)
					t(trail) {
						steering(true,false,strot,strot2,true);
						all_wheels(false, false, false); //front wheels only
					}
		// Top view
		t(-500) rotz(180) {
			//tie rod and knuckle steering arm
			steering(false,true,strot,strot2,true);
			//Wheels and rear shafts
			all_wheels(top_symb=true);
		}
		// Side view
		t(-500,850) r(-90, 180) {
			steering(false,true,strot,strot2,true);
			//Wheels and rear shafts;
			all_wheels();
			cubey(1800,10,d_line, 600);
			t(0,front_wheel_track/2)
				glinez(fwheel_hdia,false);
			// Arrows
			tslz (fwheel_hdia)
				r(0, caster_angle) {
					t(-70) p_arrow(0,0,"B", true);
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
		multiLine(["View B"],32,false, true);
//fr::	multiLine(["Vue B"],32,false, true);
	t(400,600)
		multiLine(["View A"],32, false, true);
//fr::	multiLine(["Vue A"],32, false, true);
	//Signature and user text
	print_text(-1950, -600);
}

module BB (clr=c_frame) {
	color(clr)
		diff() {
			cyly(-42,68,0,0,0, 24);
			cyly(-36,111,0,0,0, 12);
		}
  if(display_motor) mirrorx() mirrory() {  
    if(motor_type==1) 
      r(0,-mot_ang) 
        TSDZ2();
    else if(motor_type==2)
      bikee_lt(mot_x,0,mot_z,mot_ang, -mot_idler_ang);
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
		goBB() {
			pedals(crank_arm_length,crank_angle,pedal_angle,chain_length, chain_angle,clb, cab, true, true);
			//vertical crank - no wheel chain redraw
			if(rd2_vfold!=0)
				pedals(crank_arm_length,vcrank_angle,vpedal_angle,0, chain_angle, 100, cab, false, false);
			
			//2nd crank set if display 2nd rider
      //don't redraw wheel chain
			if(display_rider>1 && rider2_boom_extent!=0)
				r(0,frame_BB_angle)
					t(-rider2_boom_extent) {
						if(boom)
							silver()
                fr_beam(rider2_boom_extent, 0, 0, frame_tube_dia-5, frame_tube_ht?frame_tube_ht-5:0);
						r(0,-frame_BB_angle) {
              BB("silver");
							pedals(crank_arm_length,crank_angle,pedal_angle,0, chain_angle, 100, cab, false, true);
						//vertical crank
						if(rd2_vfold!=0)
							pedals(crank_arm_length,vcrank_angle,vpedal_angle,0, chain_angle, 100, cab, false, false);
            }
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
	t(seat_front_distance,0,seat_height) {
		if(display_rider!=2) {
      if (disp_rider)
        mirrory() 
          veloRider(rider_height, c_rider, seat_angle, leg_angle-90, right_leg_fold, -head_angle, leg_prop, legspread=leg_spread, rt=rider_type, lgra=leg_ground_angle, armp = [arm_lift,arm_pinch,farm_lift,farm_pinch]);
      //seat
      if(display_seat) 
        disp_seat();
    }
    fold2 = rider_type==1?rd2_vfold:0;
    //display second rider
    if (display_rider>1) {
      t(rider2_x_offset,0,rider2_z_offset) {
        if(disp_rider)      
					mirrory()
						veloRider(rider2_height, c_rider2, seat_angle, leg_angle-90+rider2_leg_offset, rider2_right_leg_fold, -head_angle, rider2_leg_prop,fold2,rd2_rfolda,rd2_lfolda,leg_spread, rider_type,leg_ground_angle,[arm_lift,arm_pinch,farm_lift,farm_pinch]);
        if(display_seat)
          disp_seat();
			}
		}
		//cubez(250,350,1);//check height
  }  
}

module disp_seat () {
	b_seat(seat_type,seat_angle,0,flag?1000:0,rlight?c_light:"");
}

// Line wheel symbol
module wheel_wireframe (wh_d=0, top_symb=true, shaftlg=0) {
	diff() {
		cyly(-16,d_line, 0,0,0, 12);
		cyly(-12,10, 0,0,0, 12);
	}
	glinez(disp=true);
	glinex(disp=true);
	gliney(disp=true); //wheel axis
	if(shaftlg!=0) {
		//echo(shaftlg=shaftlg);
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
module all_wheels (rearw=true, top_symb = false, mirr=true) {
	//front wheels
	steer(-strot,front_wheel_track?0:-strot2) 
		fwheel(top_symb);
	if(front_wheel_track && mirr)
		mirrory()
      steer(strot2)
        fwheel(top_symb);
		//front wheel shafts (both)
		front_wheel_shaft(display_shafts);
	//rear wheel(s)
  rsusp_al = tilting?tlt_rsang:0; //rsusp_ang;
  rsusp_ar = tilting?-tlt_rsang:0;
	if(rearw) {
      //rear shaft prolonge line for Ackermann check
    if (display_steered_wheels&&top_symb)
      t(wheel_base)
        gliney(lgrear-300,false,800,true);
    rwheel(rsusp_ar);
    if(display_rwheel_up&&rsusp_x)
      rwheel(rsusp_ar+rsusp_ang);
    if (rwheel_track) { //rear dual wheels
      mirrory() {
        rwheel(rsusp_al);
        if(display_rwheel_up&&rsusp_x)
          rwheel(rsusp_al+rsusp_ang);
      }  
    }  
  }  
  module rwheel (rsusp_a) {
    wsdia = rwheel_track?25:-25;
    wslg = rwheel_track?-rwheel_track/2:100;

    t(0,rwheel_track/2)
      r(rear_camb_a) {
        rwheel_move(rsusp_a) {
          rear_wheel();
          if(rsusp_x) //lines for rear suspension
            r(0,rear_arm_angle)
              glinex(-rwheel_dist,false,0){
              glinez();
              gliney();
            }
        }
        //Rear arm articulation shaft
        roff = rear_arm_offset
            -tan(chain_stay_v_ang)*(wheel_base-rsusp_x)*0.9;
        
        if(display_shafts&&rsusp_x) {
          color(c_steel) 
            cyly(wsdia,wslg, rsusp_x,0,rsusp_z, 16);
        if(rear_arm_offset) 
           color(c_frame) {
            cyly(-32,stay_dia+30, rsusp_x,roff,rsusp_z, 16);
            cyly(40,-rwheel_track/2-roff+18+stay_dia/2, rsusp_x,roff-18-stay_dia/2,rsusp_z, 16);
          }
        }  
      }
  }      

	module fwheel (top_symb=true) {
		fwt = front_wheel_track;
		t(0,fwt/2)
			r(camb_ang)
				tslz(fwheel_hdia)
					if(display_wheels==1&&view_type!=view_flat) {
						wheel(front_wheel_rim,dcheck?max_fwheel_tire:front_wheel_tire,front_hub_dia,shaft_width=fwt?66:trans_type==0?130:160,  spa=front_spoke_adj,spoke_nbr=front_spoke_nb, hub_offset=trans_type?single_speed==2?-2:-8:0, clr_rim=c_rim,clr_tire=c_tire);
						if(display_frame&& display_fenders)
							mirrorx()
								fender(front_wheel_rim,dcheck?max_fwheel_tire:front_wheel_tire,fw_mud_front,fw_mud_rear,fwt?0:115);
            if(!fwt&&trans_type&&display_transmission)
              silver()
              r(0,90)
                wheel_chain();
					}
					else if(display_wheels==2||view_type==view_flat)
						wheel_wireframe(fwheel_hdia*2,top_symb);
	}
	//following double partly what is in steering() module  - for axis
	module front_wheel_shaft (shaft=false) {
		// Wheel shaft
		steer(-strot)
			fwshaft(true);
		if(mirr) // context parameter
      mirrory()
        steer(strot2)
          fwshaft(false);
		module fwshaft (right=true) {
			d = shaft?15:d_line;
			clrx = shaft?c_steel:"orange";
			//wheel axisline
			if(shaft||dspl)
				color(clrx)
					t(0,front_wheel_track/2)
						r(camb_ang){
							cyly(d,-shaft_length,0,0,fwheel_hdia, 16);
              tslz(fwheel_hdia) {
                gliney(200);
              if(display_steered_wheels&&top_symb)
                gliney(right?lgrot+800:-lgrot2-800,false);
              }
            }  
		}
	}
} //all_wheels

module rear_wheel () { // from axis position
  h_offset = rwheel_track?0:(trans_type==0?(single_speed==2?-2:-8):0);
	if (display_wheels==1&&view_type!=view_flat) {
		wheel(rear_wheel_rim,dcheck?max_rwheel_tire:rear_wheel_tire, hubdia=rear_hub_dia?rear_hub_dia:(single_speed==2?80:28),shaft_width = rear_arm_offset?70:170, spa=rear_spoke_adj, spoke_nbr=rear_spoke_nb, hub_offset=h_offset, clr_rim=c_rim,clr_tire=c_tire);
		if(display_frame&& display_fenders)
			mirrorx()
				fender(rear_wheel_rim,dcheck?max_rwheel_tire:rear_wheel_tire,rw_mud_front,rw_mud_rear,rwheel_track?0:145);
		//long shaft if two wheel
    if(rwheel_track) {
      color(c_steel)
				cyly(rsusp_x?-14:18,
          rsusp_x?80:-rear_shaft_lg, 
          0,rsusp_x?rear_arm_offset:0,0, 16);
      color(c_frame)
				cyly(rsusp_x?-18:-24,60, 
          0,rear_arm_offset-3,0, 16);
    }
    else // single sided shaft if single sided arm
      if(rear_arm_offset)
        color(c_steel)
          cyly(14,rear_arm_offset+sign(rear_arm_offset)*36,0,0,0, 16); 
	}
	else if(display_wheels==2||view_type==view_flat)
		wheel_wireframe(rwheel_hdia*2,true,rwheel_track?rear_shaft_lg:0);
}

//move wheel/rear frame according suspension angle 
module rwheel_move (ang) {
	t(rsusp_x, 0, rsusp_z) 
		r(0,-ang+rear_arm_angle) 
			t(rwheel_dist)
				r(0,-rear_arm_angle) //rotate for fender and stays alignment
					children(); 
}

//-- display 3D steering -----------
//next module only used in projection
module steering (flat = false, mirr=true, rot=0, rot2=0, proj=false) {
  //  echo ("3D steering angles ",rot, rot2); ?.?
	if (mirr)
		mirrory()
      steer(rot2)
        hsteering(flat, -rot2, proj, mirr);
	if (front_wheel_track)
		steer(-rot)
			hsteering(flat, rot, proj, mirr);
}

//steer origin is 0,0
module steer (stro, stro2=0) {
	t(axis_offset,front_wheel_track/2-king_pin_offset, pivot_height)
		r(0,caster_angle)
			r(kingpin_ang)  {
				stx(stro) children();
				if (stro2) 
					stx(stro2) children();
			}
	module stx(str1) {
		rotz(str1)
			r(-kingpin_ang)
				r(0,-caster_angle)
					t(-axis_offset,-front_wheel_track/2+king_pin_offset, -pivot_height)
						children();
	}
}

module hsteering (flat = false, srot=0, proj=false, top_symb=false) {
	//2nd cross length = 
	td = cross_tube_dia?cross_tube_dia:frame_tube_dia;
	//Ackermann angle as viewed in the plan perpendicular to steering axis
	c_acker = atan(tan(ackermann_angle)/cos(caster_angle));
  c_acker2 = asin(sin(ackermann_angle)*cos(caster_angle));
	//echo ("Ackermann angle, angle calculated in other plane",ackermann_angle,c_acker);
	
	t(axis_offset,front_wheel_track/2-king_pin_offset, pivot_height) {
		//king pin
		r(0,caster_angle)
			r(kingpin_ang) {
				//steering axis
				glinez (fwheel_hdia*2+300, false,-steering_length);
        //cylz(25,1,0,0,karm_dist);
        /*rotz(-c_acker2)
          tslz(karm_dist) {
              r(0,-compos_ang)
                glinex(karm_lg, false);
            tslz(arm_dist_dec)
            glinex(arm_r_length, false)
            glinez(12);
          } */ 
				//-- frame cross structure and steering ---
        if(!proj && display_frame)
        rotz(srot) {
					color(c_frame) {
						//head tube
						tslz(frame_pivot_height+steer_bbht-sin(caster_angle)*axis_offset) {
							duplz(head_tube_height)
								glinex(80);
							cylz(42,head_tube_height, 0,0,0, 24);
						}
						if (front_wheel_track)
							tslz(frame_pivot_height+40)
							r(cross_Y_angle)
							rotz(cross_rear_angle-90)
							r(0)
							fr_beam(cross_bend_dist)
							if(cross_lg_adjust){
								//next not ok, calculate a composite angle and rotation
								fr_bend(kingpin_ang+cross_Y_angle)r(-90)
								fr_bend(-cross_rear_angle)
								fr_beam(cross_lg_adjust);
							}
					}
					dx=tire_diam(front_wheel_rim,max_fwheel_tire)+30;
					rtx = (BB_long_pos<0)?0:180;
					if(dcheck)
						tslz(-sin(caster_angle)*axis_offset)
						rotz(-55+rtx){
							rotate_extrude(angle=110, $fn=64)
							t(sign(BB_long_pos)* perp_axis_offset)
							rotz(-45)
								intersection() {
									circle(d=dx);
									rotz(14)
									t(-dx*0.9) square(dx+10, center=true);
								}
						}
					if(OSS_handlebar && display_steering)
						tslz(stem_height+frame_pivot_height+steerer_tube_length-sin(caster_angle)*axis_offset)
							rotz(-srot)
								handlebar(handlebar_type, stem_length,stem_height,stem_ang,hdl_ang,hdl_lg,hdl_bend, hdl_width_central_extent,
hdl_central_bend_angle,hdl_central_bend_orientation,hdl_lg2, dcheck, d_line);
				}
				//shaft
				if(display_shafts&&front_wheel_track&&display_steering)
					silver()
						cylz(20,above_extent+below_extent, 0,0,-below_extent);
							
			} //king pin
	t(arm_x_offset,-arm_y_offset,arm_z_offset)
		{
		//Ackermann lines
		color(c_steel)
			if(front_wheel_track) {
				if (!flat && !srot)  {
          //Ackermann triangle base line
          gliney(-lgep+1, false);
        //Ackermann triangle lines
          rotz(-ackermann_angle) 
            glinex(lg_ackermann, false);
        }
				//bar link between front wheels
				if(display_steering)
        t(karm_lg*cos(ackermann_angle),-lgep+lg_steer) {
					r(srot/6.8,0,srot*1.034) {
						gliney(-lg_tie, false);
						if(display_shafts) color(c_steel)
							cyly(16,-lg_tie+18, 0,-18,0,12)
            cyly(-30,0.5, 0);
					}
					//Steering arm (bracket)
					r(kingpin_ang) 
            r(0,caster_angle) 
              rotz(-c_acker){
                glinex(-arm_r_length,false);
                if($preview)
                  duplx(-arm_r_length) 
                    glinez(12);
						if(display_shafts) color(c_steel)
							diff() { //bracket
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
module pedals (manlength=155, cr_ang=-35, ped_ang=90, top_lg=900, top_ang=13,bot_lg=900,bot_ang=5, wheel_chain=true, front_chain=true) {
	cr2 = crankshaft_width/2;
	//chainring diam
	dch = chainring_teeth*12.7/PI;
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
		color(c_pedal)
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
  //.............................
	r(0,cr_ang) {
		crank_arm(cr2,0);
	mirrory()
		r(0,180)
			crank_arm(cr2,7);
	}
  //............................
//all front chainline display
	if (front_chain) {
		//chainring
		t(0,chainline_position)
			color(c_steel) diff() {
				cyly(-dch,5);
				//:::: Chainring holes ::::
				droty (60, nb=5)
					hull() {
						cyly(-18,66,0,0,30);
						dmirrorx()
							cyly(-24,66, chainring_teeth-30,0,dch/2-28);
					}
			}
    //.............................  
    if(dcheck)
		red()
		r(0,-20)
		tslz (-90)
		duplz(80,2) 
		dmirrory() 
			diff() {
				cyly(-2*crank_arm_length,100, 0,150,0,32);
				cyly(-2*crank_arm_length+6,222, 0,150,0, 32);
			}
	
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
    if(motor_type==2) { // Bikee. Chain on motor sprocket 
      t(-mot_x,0,mot_z)    
        r(0,top_ang+atan((mot_z+23-dch/2)/(top_lg+mot_x+200))) {
          cylx(10,top_lg+mot_x+40, 0,chainline_position,23, 6);
        t(0,chainline_position,23)
          tb_xz(10,-23,160, 6);
        }  
      r(0,-90)
        t(0,chainline_position,dch/2)
          tb_xz(10,-dch/2,90, 6);
    }  
    else
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
	//rear chain. We are located at BB, so back to 0 first
	color(c_steel)
	if(wheel_chain && !trans_type)
		t(-BB_long_pos,0,-BB_height)
			t(wheel_base,rwheel_track/2)
			r(rear_camb_a)
				t(0,-rear_shaft_lg,rwheel_hdia) 
      wheel_chain();
	} //chainline
}

//Wheel chain and dérailleur
module wheel_chain () {
 	//wheel sprocket diam
	dsp = sprocket_teeth*12.7/PI;
  t(0, chainline_position) {
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
  if(single_speed) 
    tb_xz(10,dsp/2,60+chain_rear_bot_angle, 6)
    cylx(10,-chain_rear_bot_length,0,0,0, 6);
  else //dérailleur
    cylx(10,-60, 0,0,0, 6)
    tb_xz(10,-24,71.5, 6)
    cylx(10,-28,0,0,0, 6)
    // if above have 6 facets, cause non-manifold error ????
    tb_xz(10,24,166-25+chain_rear_bot_angle, 6)
    cylx(10,-chain_rear_bot_length,0,0,0, 6);
    //wheels
    if(!single_speed) {
      cyly(-45,3, -60,0,-23, 24);
      cyly(-45,3, -114,0,-37, 24);
    }
  }
  }
}


//-- Section straights and bends --------
module fr_bend (ang, dt=frame_tube_dia, ht=frame_tube_ht, br=frame_bend_radius) {
	sgn=sign(ang);
	if(frame_tube_ht||!frame_bend_radius) 
		rrcty(-ang,ht,dspl)
			children();
	else
		tb_xz(dt,sgn*br,-abs(ang))
			children();
}

module fr_beam (length=100, a_start=0, a_end=0, dt=frame_tube_dia, ht=frame_tube_ht, br=frame_bend_radius) {
	l_start = sign(a_start);
	l_end = sign(a_end);
		if(l_start!=0)
			glinez(l_start*(br+80),false,-l_start*50);
		if(l_end!=0)
			t(length) 
				glinez(l_end*(br+80),false,-l_end*50);
		if(ht)
			beamx(ht, dt, length, a_end)
				children();
		else
			cylx(dt,length, 0,0,0, 24)
				children();
}

//---------------------------------
module tube_frame (clrf=c_frame){
	dt = frame_tube_dia;
	br = frame_bend_radius;
	boom_out = boom&&frame_BB_offset==0?50:0;
	prec= 24; //$fn for main tube
	stprec = 16; //$fn
	//-- Main frame sequence ------
  a1 = frame_front_bend_angle;
  a2 = frame_seat_bend_angle;
  a3 = frame_back_bend_angle;
  s1 = sign(a1);
  s2 = sign(a2);
  s3 = sign(a3);
  //-------------------
	goBB() {
    BB(boom?"Silver":c_frame);
	 //geometry lines
		glinez();
		glinex(); 
		//boom with bottom bracket and derailleur support
		if(boom) {
			silver() {
				r(0,frame_BB_angle)
          fr_beam(boom_out+1+frame_front_extent, 0, 0, frame_tube_dia-5, frame_tube_ht?frame_tube_ht-5:0);
				r(0,18+chain_angle)
					cylz(28,120,0,0,0, 16);
			}
		}
		else if(front_wheel_track) { //Tadpole trike
			black() {
				r(0,frame_BB_angle)
					tslz(frame_BB_offset){
						if(frame_tube_ht)
							cubex(80,frame_tube_dia+8,frame_tube_ht+8, -40);
						else
							cylx(-frame_tube_dia-8,80);
					}
			}
		}
		// saddle->upright bike
		if(seat_type==9)
			silver()
			r(0,frame_BB_angle-frame_front_bend_angle)
				cylx(dt-3,frame_seat_length+130, 0,0,0, prec); 
	//--Frame itself -----------
	color(clrf) {
		r(0,frame_BB_angle)
		tslz(frame_BB_offset){
			// BB bracket
			if (frame_BB_offset!=0 && front_wheel_track==0)
				hull(){
					cubez(30,dt-2,1);
					cubez(30,64,1,0,0,-frame_BB_offset);
				}
			//steer bracket
			if(!boom && head_reinf_offset!=0&&front_wheel_track==0)
				t(-frame_front_extent)
					hull() {
						cylx(dt-2,1, 90);
						r(0,-frame_BB_angle+caster_angle)
							cylz(-38,head_tube_height-25, 0,0,head_reinf_offset);
					}
			
	t(-frame_front_extent+boom_out)
			//frame
			fr_beam(frame_front_length+frame_front_extent-boom_out, 0, a1)
			fr_bend(frame_front_bend_angle){
				//reinforcment tube
				t(rft_pos)
					r(0,rft_angle)
						cylx(rft_dia, -rft_length);
				//continuation of frame sequence
				fr_beam(frame_seat_length,a1,a2)
				fr_bend(frame_seat_bend_angle)
				fr_beam(frame_back_length,a2,a3)
				fr_bend(frame_back_bend_angle)
				fr_beam(frame_rear_length,a3,0);
			}
		}
   
    
	}
 }
  //-- dimensions calc --------
  tube_lg = (frame_tube_ht?0:a1+a2+a3)/180*PI*br+
      frame_front_extent-boom_out+
      frame_front_length+
      frame_seat_length+
      frame_back_length+
      frame_rear_length;  
  techo(str("Main frame tube length (without boom): ",round(tube_lg)," mm"));
  th = frame_tube_thk;
  tsec = frame_tube_ht?frame_tube_ht*dt-(frame_tube_ht-2*th)*(dt-2*th):PI/4*(pow(dt,2)-pow(dt-2*th,2));
  twgh = tube_lg*tsec/10000*78;
  techo(str("Main frame tube weight (steel - without boom): ",round(twgh)," g"));
 
} //module tube_frame

//------------------------------------
module rear_frame (clrf=c_frame) {
	rear_wheel_support(0, clrf);
 if((dcheck||display_rwheel_up) && rsusp_x)
	 rear_wheel_support(rsusp_ang, clrf);
}

//-- rear wheel support -------
module rear_wheel_support (suspang=0, clrf=c_frame) {
	stprec = 16; //$fn
  // dropout slot angle (from vertical)
  drop_angle = 65;
 //dropouts offset
	rco = rear_arm_offset?rear_arm_offset:135/2;
  ss_dia = seatstay_dia?seatstay_dia:stay_dia;
  color(clrf) {
    rws(suspang-tlt_rsang);
    if(rwheel_track)
      mirrory() 
        rws(suspang+tlt_rsang);
  }  
  //rear stays
  module rws (sang) {
		t(0,rwheel_track/2)
		r(rear_camb_a)
    dmirrory(!rear_arm_offset,0,false)
		t(0,rco) // stays are designed from shaft end
		rwheel_move(sang) {
		//chain stays
      if(chain_stay_length)
			t(0,rear_arm_offset?0:stay_dia/2-6,rear_arm_offset?0:stay_dia/2+10)
				r(0,chain_stay_angle)
					cylx(stay_dia,-53, 17,0,0, stprec)
					tb_xy(stay_dia,-5*stay_dia,chain_stay_v_ang, stprec)
					cylx(stay_dia,-chain_stay_length+130, 0,0,0, stprec)
            if(chain_stay_elbow)
              tb_xy(stay_dia,-5*stay_dia,chain_stay_elbow, stprec)
                cylx(stay_dia,-20,
                  0,0,0, stprec);
			//dropouts
        if (!rear_arm_offset)
				diff() {
					hull() {
            r(0,chain_stay_angle)
              cubey(50,6,-1, -1,0,20);
						cyly(35,6, 0,0,0, 16);
            //trailer attach
						cyly(28,6, 25,0,0, 16);
            //fender attach
            cyly(16,6, 25,0,14, 16);
            r(0,drop_angle)
              cyly(28,6, 0,0,-12, 16);
					}
					//::::::::::::::
					r(0,drop_angle)
						hull() 
							duplz(-60)
								cyly(-10,99, 0,0,0, 16);
          //trailer attach hole
					cyly(-8,99, 25,0,0, 16);
          //fender attach hole
          cyly(-5,33, 25,0,14, 16);
				}
			//seat stays - only if they have a length > 0
			if(seat_stay_length)
        t(0,ss_dia/2-6,rear_arm_offset?0:stay_dia/2+15)
          r(0,seat_stay_angle, seat_stay_v_ang)
            cylx(ss_dia,-seat_stay_length+70, 12,0,0, 16)
            if(seat_stay_elbow)
              tb_xy(ss_dia,-5*ss_dia,seat_stay_elbow)
                cylx(ss_dia,-20);
	}
}
	//rear suspension frame (minus stays)
	arm_arti_wd = 75;
	shock_comp = tan(suspang)*rsusp_shock_pos;
  //If suspension and main tube
	if(rsusp_x) 
    dmirrory(rwheel_track,rwheel_track/2) { 
		t(rsusp_x,-rear_arm_offset,rsusp_z) r(0,-suspang-rsusptan) {
      if (rsusp_lg)
			color(clrf) {
				hull() {
					cyly(-36,arm_arti_wd);
					cylx(rsusp_dia,1, 30);
				}
				cylx(rsusp_dia,rsusp_lg-29, 25);
				//Main frame arm articulation bracket
				if(suspang==0 && !rwheel_track) //no frame bracket for wheel up
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
      if (rsusp_shock_pos)
			t(rsusp_shock_pos,rear_arm_offset,rsusp_dia/2+14) {
				//Shock bracket on arm
				color(clrf)
        if (rsusp_lg)
					dmirrory()
						hull(){
							cyly(22,4, 0,12);
							cubey(55,4,1, 0,12,-rsusp_dia/2-8);
						}
				r(0,rsusp_shock_an+180+suspang) {
					shock(shock_length,50,shock_sag+shock_comp);
				//shock articulation frame bracket
				color(clrf)
				if(suspang==0) // no frame bracket for wheel up
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
	if (flight_pos==1) {
		steer(-strot,-strot2)
		mirrorx()
    to_steer_b (head_tube_height+12)
			front_light(caster_angle, 1, c_light);
	}
	//fork 
	else if(flight_pos==2) {
		steer(-strot, -strot2)
		mirrorx()
    to_steer_b (-steer_bbht)
      t(16)
			front_light(caster_angle, 2, c_light);
	}
	// boom
	else if(flight_pos==3) {
    goBB()
      mirrorx()
        front_light(0, 3, c_light);
	}
}

//== Information ===================
//-- Information text -------------
module techo (var1, var2="",var3="", var4="",var5="",var6="", var7="",var8="") {
  if (inf_text) {
    txt = str(var1,var2,var3,var4,var5,var6,var7,var8);
    echo(txt);
  }  
}

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
	rtype = front_wheel_track?(rwheel_track?"quad":"trike"):"bicycle";
//fr:: 	rtype = front_wheel_track?(rwheel_track?"quadricycle":"tricycle"):"bicyclette";
	multiLine(
		[str("Recumbent ",rtype," geometry"),
//fr::		[str("Géometrie d'un vélo couché ",rtype),
"https://github.com/PRouzeau/BentSim",
"http://rouzeau.net/OpenSCADEn/BentSim",	
	"(c) 2019 Pierre ROUZEAU",
	"Licence GPL V3"
	]
	, size);
}

module print_text (xpos=200, ypos = -65) {
	//-- Signature ---------
	if(disp_text) {
		if (view_type <=0) {// 3D view
			black() {
				t(-400,-700)
					r(45)
						linear_extrude(5) {
							mytxt(txtsign, 25);
							t(-900)
								multiLine(usertxt,30,false);
						}
			}
		}
		// top or side view
		else 
			t(xpos,ypos) {
				mytxt(txtsign, 26);
				t(0,-60)
					multiLine(usertxt,30,false);
			}
	}
}

module print_spec (size = 30) {
	multiLine([
	str("Project reference: ",proj_ref),
//fr::	str("Référence projet: ",proj_ref),
	str("Front wheel: Rim ",front_wheel_rim, " Tire: ",front_wheel_tire, " mm External diam: ",fwheel_hdia*2," mm"),
//fr::	str("Roue avant: Jante ",front_wheel_rim, " Pneu: ",front_wheel_tire, " mm Diam. extérieur: ",fwheel_hdia*2," mm"),
	str("Rear wheel: Rim ",rear_wheel_rim, " Tire: ",rear_wheel_tire, " mm External diam: ",rwheel_hdia*2," mm"),
//fr::	str("Roue arrière: Jante ",rear_wheel_rim, " Pneu: ",rear_wheel_tire, " mm Diam. extérieur: ",rwheel_hdia*2," mm"),
str("Wheel base: ",wheel_base," mm Front wheels track: ",front_wheel_track," mm - Rear wheels track: ",rwheel_track," mm"),
//fr::str("Empattement: ",wheel_base," mm Voie avant: ",front_wheel_track," mm - Voie arrière: ",rwheel_track," mm"),
str("Caster angle/Headtube angle:",caster_angle, "/",headtube_angle, "° ,perpendicular wheel offset(rake): ", perp_axis_offset,"mm"),
//fr::str("Angle de chasse/Angle de direction: ",caster_angle,"/",headtube_angle, "°  ,déport roue: ", perp_axis_offset,"mm"),
str("Trail: ",r10(trail),"mm - Wheel flop: ",r10(wheel_flop),"mm"),
//fr::str("Chasse: ",r10(trail),"mm - Wheel flop: ",r10(wheel_flop),"mm"),
str("Front camber angle: ",camber_angle, "° King pin angle: ", kingpin_ang,"° Rear camber angle: ",rwheel_track?rear_camber_angle:"-","°"),
//fr::str("Angle de carrossage avant: ",camber_angle, "° Angle du pivot: ", kingpin_ang,"° Angle de carrossage arrière: ",rwheel_track?rear_camber_angle:"-","°"),
str("Seat bottom height: ",seat_height,"mm - Bottom bracket height: ",BB_height,"mm")
//fr::str("Hauteur assise siège: ",seat_height,"mm - Hauteur pédalier: ",BB_height,"mm")
	]
	,size,false);
}

module print_spec2 (size = 30) {
	multiLine([
		str("Rider height: ",rider_height, "mm"),
//fr::		str("Taille du cycliste: ",rider_height, "mm"),
		str("Seat back angle (from horizontal): ",seat_angle, "°"),
//fr::		str("Inclinaison du dossier (par rapport à l'horizontale: ",seat_angle, "°"),
		str("Rider inseam: ", in_seam(rider_height,leg_prop), "mm"),
//fr::		str("Hauteur de l'entrejambe",in_seam(rider_height,leg_prop), "mm"),
		str("Shock travel: ", round(tan(rsusp_ang)*rsusp_shock_pos), "mm")
//fr::		str("Course amortisseur arrière: ", round(tan(rsusp_ang)*rsusp_shock_pos), " mm")
	]
	,size,false);
}

//== FAIRING Module =================
//t(0,600,300) fairing_frame(2,true);

module fairing_frame (nfr=1, fold=true, thkx=0, bub=true) {
	foldang = fold?bfold[nfr]:0;
	diff() {
		brf(nfr,thkx,bub);
		if(foldang)
			cubez(10,1999,1999, 0,0,bfoldo[nfr]);
	}
	if (foldang) 
		tslz(bfoldo[nfr]) 
			r(0,foldang) diff() {
				tslz(-bfoldo[nfr])
					brf(nfr,thkx,bub);
				cubez(10,1999,-1999);
			}
}

module brf (nfr=1, thkx=0, bub=true) {
	thk = thkx>0?thkx:0;
	t = thkx==-1?-0.01:0.01; // thk==-0.01, end face of external volume
	prec=$preview?(half_v?36:48):64;
	precb=$preview?(half_v?96:128):192;
	$tk = t;
	//'bulb' radius
	rdb = 120-thk;
	//middle bubble offset
	mzoa = 100;
	//main radius
	rd = brd[nfr]-thk;
	//side bulge radius
	wrd = bwrd[nfr]?bwrd[nfr]-thk:0;
	//top bulge radius
	wrdt = bwrdt[nfr]?bwrdt[nfr]-thk:0;
	//top radius
	rdt = wrd?rd:brdt[nfr]-thk;
	//width
	wd = max(bwd[nfr],2*rd)-2*thk;
	//top width
	wdt = max(bwd[nfr]-bpinch[nfr],2*rdt)-2*thk;
	//main height
	ht = bht[nfr]-2*thk;
	//top bubble width
	bubwd= max(bblwd[nfr],2*rdb)-2*thk;
	bubht= bblht[nfr]-thk;
	dw = (wdt-wd)/2;
	dh = ht-2*rd;
	//side angle (for equal radiuses)
	sang = atan(dw/dh);
	tbdist = sqrt(pow(dw,2)+pow(dh,2));
	wang = asin((tbdist/2)/(wrd-rd));
	wdist = cos(wang)*(wrd-rd);
	//top bulge angle normal
	ttang1 = asin((wdt/2-rdt)/(wrdt-rdt));
	//top bulge angle top bubble
	ttang2 = asin((bubwd/2-rdb)/(wrdt-rdb));
	
	istopbub = bubwd>0&&bubht>0&&bub;
	ttang= istopbub?ttang2:ttang1;
	mintoprad = istopbub?bubwd/2:wdt/2;
	tbulgeht = istopbub? 
		ht/2+bubht-rdb-(wrdt-rdb)*cos(ttang2):
		ht/2-rdt-(wrdt-rdt)*cos(ttang1);
	
	// echo (str("istopbub=",istopbub,"  ttang=",ttang,"  wrdt=",wrdt,"tbulgeht=",tbulgeht));
	
	//Side bulge radius side extension
	module dwrd() {
		if(wang==wang)//wang is a number
			t(0,wd/2-rd,-ht/2+rd) {
				r(-sang) {
					t(0,-wdist,tbdist/2)
						diff() {
							cyl2(wrd*2,0,0,precb);
							//::::::::::::::
							r(wang)
								cubez(10,2.5*wrd,1.5*wrd);
							r(-wang)
								cubez(10,2.5*wrd,-1.5*wrd);
							cubey(10,-wrd,2*ht,0,wrd-rd);
						}
					}
				}
			else if(wrd)
				echo(str("for frame ",nfr," side bulge radius ",wrd," is not compatible with other radiuses"));
			//fr::			echo(str("pour le couple ",nfr," Le rayon ",wrd," du ventre latéral n'est pas compatible avec les autres rayons"));
	}
	
	module cyl2 (d=10,h=0,w=0, pr=prec){
		cylx(d,$tk, 0,w,h, pr);
	}

	hull() {
		//top bulge
		if(wrdt>0&&(ttang==ttang))
			tslz(tbulgeht) 
				diff() {
					cyl2(wrdt*2,0,0,precb);
					//:::::::::::::
					r(-ttang)
						cubey (10,999,1999);
					r(ttang)
						cubey (10,-999,1999);
				}
		if(!(ttang==ttang)&&wrdt>0)
			echo(str("for frame ",nfr," top bulge radius ",wrdt," is not compatible with other dimensions, minimum radius is: ",mintoprad));
			//fr::			echo(str("pour le couple ",nfr," Le rayon ",wrdt," du ventre supérieur n'est pas compatible avec les autres dimensions, le rayon minimum est: ",mintoprad));
		dmirrory(){
			//top bubble
			if(istopbub)
				cyl2(rdb*2, 
					,ht/2+bubht-rdb, bubwd/2-rdb);
			//top
			cyl2(rdt*2,ht/2-rdt, wdt/2-rdt);
			//side bulge
			dwrd();
			// bottom
			cyl2(rd*2,-ht/2+rd,wd/2-rd);
		}
	}
}

//-----------------------------
module fairing_seg (nseg, thk=0) 
{
	prec = half_v?48:64;
	foldf = bfold[nseg];
	foldr = bfold[nseg+1];
	foldfo = bfoldo[nseg];
	foldro = bfoldo[nseg+1];
	fa = bang[nseg];
	ra = bang[nseg+1];
	fzo = bzpos[nseg+1]-bzpos[nseg];
	lgs = blg[nseg]-(nseg?0:noselrd);
	lg = -lgs+(thk?2:0);
	thke = thk>0?thk:-0.01; //-1 indicate end face of external volume
	bubblef = bblct[nseg]==-1?false:true;
	bubbler = bblct[nseg+1]==1?false:true;
	//next only for nose
	wd = bwd[0]-2*thk;
	ht = bht[0]-2*thk;
	rd = brd[0]-thk;

	diff() {
		hull(){
			r(0,fa) 
				if(nseg>0)
					fairing_frame(nseg, true, thk,bubblef);
				else //0 is nose
					dmirrory() { 
					t(0,wd/2-rd,ht/2-rd)
						r(0,-fa)
							scale([fnosecf,1,1])
								sphere(rd, $fn=prec);
					t(0,wd/2-rd,-ht/2+rd)
						r(0,-fa)
							scale([fnosecf,1,1])
								sphere(rd, $fn=prec);
				}
			//next 0.1 move is to overlap volumes to avoid non-manifold results
			t(lg-0.1,0,fzo) 
				r(0,ra)
					fairing_frame(nseg+1,true,thke,bubbler);
			if(froofseg&&froofseg==nseg)
				t(-froofx,0,bht[nseg]/2+froofz)
					scale([froofcf,1,froofvcf])
						sphere(froofwd/2, $fn=128);

		} //hull 
		//::::::::::::::::
		// cut front fold
		if (nseg>0)
		r(0,fa){
			tslz(foldfo) {
				cubex(999,999,900, 0,0,-450);
				r(0,foldf)
				cubex(999,999,900, 0,0,450); 
			}
		}
		// cut rear fold
		t(lg-0.1,0,fzo)	r(0,ra){
			tslz(foldro) {
				cubex(-999,999,900, 0,0,-450);
				r(0,foldr)
				cubex(-999,999,900, 0,0,450); 
			}
		}
	}
}
//--------------------------------
module all_frames (nb=5) {
	xpos =[0,0, 
		bwd[1]/2+bwd[2]/2+200,
		bwd[1]/2+bwd[2]+bwd[3]/2+400,
		bwd[1]/2+bwd[2]+bwd[3]+bwd[4]/2+600,
		bwd[1]/2+bwd[2]+bwd[3]+bwd[4]+bwd[5]/2+800,
		bwd[1]/2+bwd[2]+bwd[3]+bwd[4]+bwd[5]+bwd[6]/2+1000
	];

	module sec(sec=1,bub=true) {
		diff() {
				r(0,90) 
					hull()
						fairing_frame(sec, false, 0, bub);
				cubez (50,4,10, 25,0,-5);
				cubez (4,50,10, 0,-25,-5);
			// level zero line
				t(-bzpos[sec],0,-5) {
					cubez (3,300,10);
					cubez (40,3,10);
					cubez (40,3,10,0,150);
					cubez (40,3,10,0,-150);
				}
				tslz(-5)
				linear_extrude(10) {
					t(15,-15)
						rotz(-90)
							mytxt(str(sec),30);
					t(10,10)
						rotz(-90)
							mytxt(str(bang[sec]),25,halign="right");
				}
				// folding line
				if (bfold[sec]) {
					t(bfoldo[sec])
						cubez (4,1555,10, 0,0,-5); 
				}
		}
	}

  for(i=[1:nb]) {
		t(-xpos[i],1000+bzpos[i]) {
			rotz(90)
				sec(i);
			if(bblct[i])
				t(0,-bht[i]-150)
					rotz(90)
						sec(i, false);
		}
	}
}
//-------------------------------
module fairing_proj () {
	projection() {
		all_frames();
		t(0,-1000) {
			r(-90)
				diff() {
					full_fairing();
					//:::::::::
					t(fairing_x,0,fairing_z)
						for (fr=[1:6])
							if(bposx[fr]!=undef && bzpos[fr]!=undef && bang[fr]!=undef)
							t(bposx[fr],0,bzpos[fr])
								r(0,bang[fr])
									tslz(bfoldo[fr]) {
										cubez (4,1555,-999);
										r(0,bfold[fr])
											cubez (4,1555,999);
									}
						//fairing elevation
						cubez (3500,1555,4, -500,0,fairing_z-2);
					}
			//ground
			cubez (3500,4,20, -500);
		}
	}
}

//--------------------------------
module fairing (vtype, clr) {
	fwdi = wheel_diam(front_wheel_rim,max_fwheel_tire)+50;
	rwdi = wheel_diam(rear_wheel_rim,max_rwheel_tire)+50;
	rs = froofseg;
	dzr = (bzpos[rs+1]-brd[rs+1])-(bzpos[rs]-brd[rs]);
	aroof = atan(dzr/blg[rs]);
	
	//make windscreen cut
	module ws_cut () {
		diff(){
			tslz(bht[rs]/2-brd[rs]/2)
				r(0,aroof)
					cubez(2999,1888,1999, -444);
			//:::::::::::::
			t(-froofx,0,froofz+bht[rs]/2)
				r(0,ws_ang)
					cubez(4999,1999,1999);
		}
	}
	//display one segment
	module fairing_s (seg=1, thk=0) {
		if(bdisp[seg]) 
			t(bposx[seg]+fairing_x,0,fairing_z+bzpos[seg])
				diff() {
					fairing_seg(seg,thk);
					//:::::::::::::
					if (rs&&rs==seg&&$preview&&disp_ws)  // there is a roof so we cut top part
						ws_cut();
				}
	} //fairing_s
	
	//windscreen
	if(rs&& bdisp[rs]&&$preview&&disp_ws) 
		color(c_glass)
		t(bposx[rs]+fairing_x,0,fairing_z+bzpos[rs]-($preview?0.6:0)) // height offset for color
			diff(){
				fairing_seg(rs);
				//:::::::::::::
				//bottom cut located at half of top circle (not top bubble)
				tslz(bht[rs]/2-brd[rs]/2)
					r(0,aroof)
						cubez(2999,1888,-1999, -444);
				//top cut at roof level, angled -3°
				t(-froofx,0,froofz+bht[rs]/2)
					r(0,ws_ang)
						cubez(4999,1999,1999, -555);
			}
	//Nose
	if(bdisp[0])
		color(clr[1]) render() diff() {
			fairing_s(0); //nose
			//::::::::::::
			if (vtype>1) //shell
				t(-3) 
					fairing_s(0,4);
			if(vtype==2) //half cut
				cubey(6666,999,4444, 0,0,1555);
		}
	//Main fairing
	color(clr[0])
		diff(){
			for(seg=[1:6]) 
				fairing_s(seg);
			//:::::::::::::
			wheel_well(fwdi,front_wheel_track/2-150-dp_well,60,rwdi);
			if(vtype==2)
				cubey(6666,999,4444, 0,0,1555);
			if(vtype>1) //shell
				diff(){
					t(-3)
						for(seg=[1:6]) 
							fairing_s(seg,4);
					//:::::::::::
					wheel_well(fwdi+5,front_wheel_track/2-155-dp_well,60, rwdi+5);
				}
		}
}

//======================================
module full_fairing (vtype=1) {
	//cyly(-100,800, -190,0,700); // width check
	if(vtype>0) diff() { //3D view (full or shell)
		u() {
			fairing(vtype,fairing_color);
			// wind deflector
			if(bscreen_x!=0) 
				color(fairing_color[2])
				t(bscreen_x,0,bscreen_z)
					r(0,-50)
						diff(){
							cylz(320,280, 0,0,0, 64);
							//::::::::
							// top face cut
							r(0,15)
								cubez(444,444,200, 0,0,230);
							// bottom cut
							r(0,60)
								cubez(555,444,-333, 0,0,120);
						}
		} //:: cut fairing frame :::::::::::::
		cubex(2999,1999,2999, fairing_cut_x,0,1333);
		cubez(4999,1999,1999, 333,0,fairing_cut_z);
	}
	else if(vtype==-1)
		fairing_proj();
}

module wheel_well (fdia=570, pos = 290, fvt= 60, rdia = 560, rvt=100, rang = 0) {
	// front well
	dmirrory() {
		t(0,pos,fwheel_hdia)
		diff(){
			hull()
				duplz(70+fvt)
					cyly(fdia,300,
						0,-60,-70, 64);
			//internal 'V' shape
			r(camber_angle,-13)
				t(20,60){
					rotz(-29)
						cubex(333,120,777,
							0,-60);
					rotz(36)
						cubex(-333,120,777,
							0,-60);
				}
			// enlarge in front of wheels
			cubey(444,-80,666, 222,-60+25);
		}
	}
	//-- rear wheel well ------
	t(-wheel_base, 0,rwheel_hdia) {
		r(0,rang)
			hull() 
				duplz(100+rvt){
					cyly(-rdia,120,
						0,0,-100, 48);
					cyly(-150,180,
						0,0,-100, 48);
				}
	}
}

/*/ Length eval
duplx (-1000, 3) cubex (5, 100,30, 1000);
cylx (100, -2520, 965,0,300);
cyly (-100, 400, -150,0,150);
//*/

//== LIBRARY =======================
//-- Geometry lines ----------------
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

//-- Cyl/Rectangular tube handling --
//--Beam extrusion & displacement --
module beamx (height=10, width=10, length=10, ang=0) {
	sa = sign(ang);
	if(length!=0)
		if(height) // so, rectangular beam
			t(length/2) {
				diff(){
					cube([abs(length),width,height], center=true);
					//bias cut on rectangular beam
					if(ang!=0) {
						t(length/2,0,-sa*height/2)
							r(0,-ang/2) 
								t(0,-width/2-5,sa<0?-3*height+2:-2)
									cube([200,width+10,3*height], center=false);
							
					}
				}
				t(length/2)
					children();
			}
		else
			cylx(width,length) children();
}

//Rotation of rectangular tube on y
//ht shall be negative if former segment negative (to merge tubes)
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
//width shall be negative if former segment negative (to merge tubes)
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

module mytxt (txt, size, hal="left", prec=16) {
		text(txt, size,$fn=prec, halign=hal,font="Segoe UI");
}

//go to steering bottom bearing TOP
module to_steer_b (voff=0) {
  tslz(fwheel_hdia)
    r(0,-caster_angle)
			t(-perp_axis_offset,0,frame_pivot_height+steer_bbht+voff)
      children();
}

module custom_frame1 () {
  //
  fra = 14.5;
  frext = 35;
  lgfr = 950;
  front_ht = 140;
  front_wd = 61.6;
  rear_ht = 108;
  rear_wd = 124;
  seat_stay_an = 30;
  chain_stay_an = -8.7;
  chain_stay_z = -46;
  border = 0; //set value as 12 to see internal shape
  bottom_ang = atan((rear_ht-front_ht)/lgfr);
  
  mirrorx()
  to_steer_b() r(0,fra) 
    diff() {
      u() {
        cyly(-1,222); // fork bottom bearing base
      dmirrory() {
        rotz(2){
          *cubez(lgfr,front_wd,front_ht,
            -lgfr/2+frext,0,-20);
          //Seat stay
          blue()
          t(-1225,-front_wd/2,front_ht-50)
            r(0,-seat_stay_an)
            r(90,-90,90)  
              profile_angle (20,20,2,389);
          //Chain stay
          orange()
          t(-1250,-front_wd/2,front_ht+chain_stay_z)
            r(0,-chain_stay_an)
              r(90,90,-90)  
              profile_angle (20,20,3,-520);
          //seat support
          yellow()
          t(-898,-front_wd/2+2,front_ht+162)
            r(-0.5)
            r(0,46,0)
              r(90,90,-90)  
              profile_angle (20,20,2,-422);
        }  
      } 
      //main beam
      red() hull() {
        cubez(5, front_wd, front_ht,frext,0,-25);
        t(-lgfr+frext-3)
          cubez(5, rear_wd, rear_ht,0,0,-25+front_ht-rear_ht);
      }  
      
    }  
    //:::::::::::::
   //bottom cut 
   r(0,-bottom_ang)
      t(0,0,-20)
        cubez (lgfr+200,300,-300, -lgfr/2,0,-3.8+border); 
   //rear bottom cut 
   r(0,-chain_stay_an)
      t(-lgfr+200)
        cubez (500,300,-300, 0,0,-117);
    //front bottom cut
    r(0,-fra) {
      cubez (500,300,-300,
        0,0,-11.5+border);
      cubex (200,300,300,
        frext,0,-11.5+border);
    }  
  }  
  
}
//== The end =====================
//cylz (80,80, -200);