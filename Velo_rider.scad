//Modified from OpenBike rider, which was itself got from http://www.thingiverse.com/thing:3495
// Modifs 2018 by Pierre ROUZEAU AKA PRZ
// License GPL 4.0
//This version: - first issue: December 2018
//pedalling animation tables done by OpenBike are not used and are yet incorrect (movement according $t variable)
//You can adjust the height (without helmet and shoes). There is some provision for shoe thickness
//Inseam/X-seam proportion to overall height is not adjustable, while in the real population the variability is huge and also the proportion are not the same for male and female (female have proportionally longer legs) (This proportion might be added on a future revision), so it is better to adjust the height to get the researched inseam, which will give wrong torso and arms size. You can have up to 100mm (4") of inseam difference for people of same height, which is considerable for recumbent design. Note the model is not precise. 
//The rider is not very accurate on anthropometric viewpoint as his/her articulations are in the middle of the limbs, which is far from the reality and troubles dimensions whith folded limbs, which is a common problem in posable models. Very surprisingly, this is the only posable model I found on OpenSCAD. This model was taken from the openbike site (http://en.openbike.org/wiki/OpenSCAD), with corrections of angles errors sign and foot articulation center. I did modifications to improve the anthropometric proportions. His/her dimensions are now proportional to head size as common practice. It can be taller or smaller with a fixed head size and articulation are repositioned based upon that.
//There is some unchecked attempt to correct the misplaced hip articulation (modified leg length when rotating it)
	//Also, its design is now adimensional and you can use whatever unit you wish, just giving reference head size and whole size in these units.
//This model was itself get from thingiverse model designed as a groom of a wedding cake topper, so no surprise this was not the most accurate human proportions! The initial author may be surprised by what we made from its 3D printed model.
//There was a very detailed and accurate project for human models (based on bones), but unfortunately not finished here: https://github.com/davidson16807/relativity.scad/wiki/Human-Body
//Basing articulations on skeleton is the only way to have accurate dimensions when flexing limbs, but you shall fill in flesh after and that is complex with OpenScad.
//you can find information on anthropometry here: 
//https://design.tutsplus.com/articles/human-anatomy-fundamentals-basic-body-proportions--vector-18254
//in french : http://villemin.gerard.free.fr/Biologie/CorpsPro.htm
//An interesting program to design models (not tested): http://terawell.net/terawell/

/*[Hidden]*/
$fn = 20;
// rider based on groom from http://www.thingiverse.com/thing:3495

rider=true; // used to neutralise library display
/*[Display]*/
stood=false;
//stood=true;
foot_on_ground=false;
rider_check=false;
disp_legs = true;

/*[Sizes]*/
//head reference size, all body proportional to this, 225mm or 8.9 inches, rider design is adimensional
head=225;
//Actual height without shoes and helmet, with head size unmodified, use same units as head
r_height = 1700;

//Foot extend below foot reference plane to take into account shoes. Head reference plane is below ovoid as a real head is not that pointy, so real height is an approximation.
//calculations
//reference size, for internal calculation only
//below red_size is traditional body refernce, size equal to eight time the head
//Note that the ovoid head is taller than this dimensions as a real head is not ovoid
ref_height = 8*head; 
hd=head/2;

//Attempt (rough and experimental) to take into account that the hip articulation is above the model hip center, which position the knee farther than a centered model when upper leg goes horizontal.
//When leg is extended, the correction of hip and knee uncentered articulation may give the foot 40 to 50 mm farther than the model.
//This is better than nothing, but shall be checked

hip_Voffset = hd*0.39; //~40mm

explode = 1; // 1 is normal, bigger "explodes" the parts.

// --------- Modules -------------
function rem8(u,v) = round((u/v-floor(u/v))*8); 

//colors
skin=[0.95,0.75,0.55]; 

//Last term of third array : left foot angle
//Last term of sixth : right foot angle
//animation not used yet
//Positive angle modification rotate limb in counter-clockwise direction
//Left hip angle modifier
legmodl = -12.5;
//Left knee angle modifier
kneemodl = 4;
//Left foot angle modifier
footmodl = -2;
//legmodr = -10;
//kneemodr = 45;
//footmodr = 0;

leg_ground_angle=-20;

//(right) leg position modifications
legmodr=foot_on_ground?leg_ground_angle:-6;
kneemodr=foot_on_ground?50:12;
footmodr=foot_on_ground?-3:-5;

//arm position modification
arm_open = 5;

a_legs = stood?
[[80,69,56,42,42,63,78,32],[96,88,68,30,20,52,74,10],[0,0,0,45,35,20,0,-9], [43,63,78,86,80,69,57,32],[20,52,74,92,96,88,62,10],[45,22,0,10,0,0,20,-9], [-45,23,-45,20,-45,45,-30,45],[-45,45,-20,45,-45,45,-45,45]]
:
[[80,69,56,42,42,63,78,86+legmodl],[96,88,68,30,20,52,74,100+kneemodl],[0,0,0,45,35,20,0,-21+footmodl], [43,63,78,86,80,69,57,32+legmodr],[20,52,74,92,96,88,62,6+kneemodr],[45,22,0,10,0,0,20,15+footmodr], [-45,23,-45,20,-45,45,-30,45],[-45,45,-20,45,-45,45,-45,45]]; // for animation 

ang_seat = stood? 90:60; //20 to 70 degrees clock-wise
leg_a1= -39;
l_angle = stood? -120:leg_a1;
h_angle = stood? 2:-12;
knee_angle = stood? 0:0;
foot_angle = stood? 0:0;

//Arm pinching angle
arm_pinch = 0;
//arm lifting angle
arm_lift = 0;
//forearm lifting angle
farm_lift = 0;
//forearm pinching angle
farm_pinch = 0;

/*stood
ang_seat = 90; //20 to 70 degrees clock-wise
leg_angle = -120;
h_angle = 2;
knee_angle = 0;
foot_angle = 0;
//*/
//h_angle=-25;
//long legs : 1, short legs : 0
l_prop = 0; // [0:0.1:1]
//leg proportionality coeff: 0.45 oct 2019
lpcoef = 0.45;

if (rider) {
	prop = (r_height-head)/(ref_height-head);
	//bot = -990;
	bot=-9.4*hd*prop-0.18*hd-0.4*hd*l_prop;
	//top = 680;
	top = 4.41*hd*prop+2*hd-0.4*hd*l_prop;;
	inseam = 7.2*hd*prop+l_prop*lpcoef*hd;
	if(rider_check)
	echo("rider height check", top-bot); 

	
	rotate([0,90-ang_seat,-90])
	veloRider();
	if (stood) {
	translate ([-2.5*hd,-2.5*hd,bot])
	 cube([5*hd,5*hd,0.05]);
	translate ([-2.5*hd,-2.5*hd,bot+inseam])
	 cube([5*hd,5*hd,0.05]);
	translate ([-2.5*hd,-2.5*hd,top])
	 cube([5*hd,5*hd,0.05]); 
	} 
}

function body_height (prop, leg_prop) = 4.45*hd*prop-0.45*hd*leg_prop;

module veloRider (rh=r_height, rcolor=["red","yellow","darkblue","brown","gray"],  seat_ang=ang_seat, leg_angle=l_angle, left_fold=0, head_angle=h_angle, leg_prop=l_prop) {

//moved to have the reference level at butt
rad_ankle = 1.3*0.83*hd;
rda = stood?-180:rad_ankle;
//echo(rad_ankle=rad_ankle);
	
	//calculate a coefficient to adjust size
echo("Rider height",rh);
prop = (rh-head)/(ref_height-head);
//echo(prop=prop);
	
//top = 680;
//top = 4.41*hd*prop+2*hd;
inseam = 7.2*hd*prop+leg_prop*lpcoef*hd;
//if (rider_check)
	echo("Rider inseam", round(inseam));
//bot=-9.4*hd*prop-0.18*hd;	
//move rider to have the reference point at the butt bottom
	translate([0,0,rda])
		rotate([90-seat_ang,0,90])
			translate([0,0,body_height(prop, leg_prop)/2-hd*0.42])
				vRider(prop, rcolor, seat_ang,leg_angle, left_fold, head_angle, leg_prop);
}

module vRider (prop, rcolor, seat_ang, leg_angle, left_fold, head_angle, leg_prop) {
// Proportions
bodyHeight=body_height(prop, leg_prop);
if(rider_check)
	echo(bodyHeight=bodyHeight);
//armLength = 8; 
hand=[0.6,0.8,1.7]; // orientation
legLength = hd*3.84*prop+leg_prop*lpcoef/2*hd; //Thigh length, equal to lower leg 
armLength = hd*3.2*prop; // 
footLength = hd;

//echo("rider colors", rcolor);

color(rcolor[0]) {
	// torso
	translate([0,0,0.3*hd]) 
		roundedBox([3.33*hd,2.08*hd,bodyHeight+0.83*hd], 0.92*hd, false);
	//rib cage
	*translate([0,0,bodyHeight/3.2]) 
		roundedBox([3.75*hd,2.08*hd,bodyHeight*0.75+0.83*hd], 1.04*hd, false);
	//chest
	translate([0,0,bodyHeight/2]) 
		roundedBox([3.96*hd,2.08*hd,bodyHeight*0.5+0.83*hd], 0.83*hd, false);
}
translate([0,0,bodyHeight/2+0.21*hd]) {
	// arms
	translate([0,-0.08*hd,0.42*hd]){
		mirror([1,0,0]) rotate([-6,0,0]) 
			arm(0.58*hd,1.46*hd,armLength,165+arm_pinch,-15-arm_lift,-12-farm_pinch,25+farm_lift,hand, rcolor[1]); 
		mirror([0,0,0]) rotate([-6,0,0]) 
			arm(0.58*hd,1.46*hd,armLength,165+arm_pinch,-15-arm_lift,-12-farm_pinch,25+farm_lift,hand, rcolor[1]);
	}
	translate([0,-0.1*hd,1.4*hd*prop])
	rotate([seat_ang-90-head_angle,0,0]) {
		// neck
		color(skin) translate([0,0,0.1*hd*prop]) cylinder(r1=0.54*hd,r2=0.58*hd,h=hd*1.8, center=true);
		// head
		color(skin) translate([0,0,0.4*hd*prop+hd+5*(explode-1)]) rotate([-4,-1,0]) scale(hd) scale([1,1,1.33]) sphere($fn=30);
		// helmet
		if(!rider_check)
		color(rcolor[4]) translate([0,-2.08*hd,(0.85-1.4)*hd*prop+15*(explode-1)]) { 
			helmet(); 
		} 
	}
	//LEGS
	if (disp_legs)
		translate([0,-0.08*hd,-bodyHeight+0.21*hd]) { 
			//left
			mirror([1,0,0]) 
			leg(0.8*hd, 0.8*hd, legLength,4,a_legs[0][7-rem8($t*360,90)]+seat_ang+leg_angle+left_fold, a_legs[1][7-rem8($t*360,90)]+left_fold,[a_legs[2][7-rem8($t*360,90)],3,0], rcolor[2],rcolor[3]); 
			//right
			leg(0.8*hd, 0.8*hd, legLength,foot_on_ground?7:2.5,a_legs[3][7-rem8($t*360,90)]+seat_ang+leg_angle, a_legs[4][7-rem8($t*360,90)],[a_legs[5][7-rem8($t*360,90)],3,0], rcolor[2],rcolor[3]);
		} 
}

module helmet () { 
	translate([0,2.08*hd,2.3*hd]){
	hull() {
		difference () {
			sphere(1.25*hd); 
			translate([0,0,-2.3*hd]) 
				rotate([10,0,0])
					cube(4.2*hd,center=true);
		} 
		translate([0,1.5*hd,0.155*hd])
			cube([1.4*hd, 0.1*hd, 0.1*hd], center = true);
	}
	/*  FreeCAD not ok with scale parameter
	 but work with 'hull()'.
		rotate([-95])
			translate([0,-0.25*hd,0])
				linear_extrude(height = 1.6*hd, scale = [0.7,0.2])
					square([2.25*hd, 0.55*hd], center = true);*/
 }
} //helmet

module leg (thickness,hipWidth,lLength,legSpread,kneeLift,kneeBend,footPos, leg_color, shoe_color) { 
	//hip correction attempt
	lgext = sin(kneeLift)*hip_Voffset;
	if (rider_check) {
		echo(kneeLift=kneeLift);
		echo(lgext=lgext);
	}
	llg = lLength + lgext;
	translate([4*(explode-1),0,-10*(explode-1)]){ // upper leg
		translate([hipWidth,0,0])
			rotate([-kneeLift,180-legSpread,-3]) { 
				color(leg_color) {
					sphere(r=thickness*1.25); 
					//cylx(-3,600);
					cylinder(r1=thickness*1.2,r2=thickness*0.75,h=llg);
				}
				// joint
				translate([0,0,llg+10*(explode-1)]) { // lower leg
					color(leg_color)
						sphere(r=thickness*0.75);
					rotate([kneeBend,0,0]) {
						color(leg_color)
							cylinder(r1=thickness*0.75,r2=thickness*0.55,h=lLength);
				// foot
						color(shoe_color)
							translate([0,0,0.01*hd+lLength+10*(explode-1)])
								rotate([footPos[0],footPos[1],footPos[2]]) 
									foot((2*prop-0.55)*hd);
									echo("prop leg",prop);
					}
			}
		}
	}
}// leg

module foot (length= hd*1.04) {
	hull() {
		translate ([0,0,-0.3*hd])
			cylinder(r=hd*0.45,h=0.7*hd);
		translate ([0,length,0.05*hd])
			cylinder(r=hd*0.5,h=0.35*hd);
	}
}

module arm (thickness,shoulderWidth,armLength,armBend,armBendForward,elbowBend,elbowBendForward,hand, arm_color) { 
	translate([10*(explode-1),0,0]) { // upper arm
		translate([shoulderWidth,0,0])
			rotate([armBendForward,armBend,-arm_open]){ 
				color(arm_color){
					sphere(r=thickness*1.3); 
					cylinder(r1=thickness*1.2,r2=thickness*0.8,h=armLength);
				}
				//joint
				translate([0,0,armLength+10*(explode-1)]) { 
					color(arm_color) 
						sphere(r=thickness*0.8);
					rotate([-elbowBendForward,-elbowBend,0]) { 
						color(arm_color)
							cylinder(r1=thickness*0.8,r2=thickness*0.6,h=armLength*0.8);
						// hand
						color(skin) translate([0,0,armLength*0.8+10*(explode-1)]) scale([hand[0],hand[1],hand[2]]) sphere(r=thickness); 
					}
				}
		}
	} 
} // arm
} //veloRider()

module roundedBox (size, radius, sidesonly) { 
	rot=[[0,0,0], [90,0,90], [90,90,0]]; 
	if(sidesonly) { 
		cube(size - [2*radius,0,0], true);
		cube(size - [0,2*radius,0], true);
		for(x = [radius-size[0]/2, -radius+size[0]/2], y = [radius-size[1]/2, -radius+size[1]/2]) {
			translate([x,y,0]) 
				cylinder(r=radius, h=size[2], center=true);
		} 
	} //if
	else { 
		cube([size[0], size[1]-radius*2, size[2]-radius*2], center=true);
		cube([size[0]-radius*2, size[1], size[2]-radius*2], center=true);
		cube([size[0]-radius*2, size[1]-radius*2, size[2]], center=true);
		for (axis = [0:2]) {
			for (x = [radius-size[axis]/2, -radius+size[axis]/2], y = [radius-size[(axis+1)%3]/2, -radius+size[(axis+1)%3]/2]) {
				rotate(rot[axis])
					translate([x,y,0])
						cylinder(h=size[(axis+2)%3]-2*radius, r=radius, center=true); } 
		}
		for (x = [radius-size[0]/2, -radius+size[0]/2], y = [radius-size[1]/2, -radius+size[1]/2], z = [radius-size[2]/2, -radius+size[2]/2]) {
			translate([x,y,z]) sphere(radius); 
		} //for 
	}//else 
}//roundedBox

module seat () {
	translate([0,-6*s,0]) rotate([-90,0,90]) scale(4) 
	linear_extrude_bezier([[[.7,-6,-1], [1,-6.5,-1.5], [2,-6.5,-1.5], [2.3,-6,-1]], [[0,-5,1], [1,-5,1], [2,-5,1], [3,-5,1]], [[0,-4,-.5], [1,-4,0], [2,-4,0], [3,-4,-.5]], [[0,0,0], [1,0.5,0.5], [2,0.5,0.5], [3,0,0]]], steps=10, thickness = 0.2*s);

translate([0,-6*s,0]) rotate([-120,0,90]) scale(4)
	linear_extrude_bezier([[[0.3,2.5,0.5], [1,3.5,0], [2,3.5,0], [2.7,2.5,0.5]], [[0,2,1], [1,2,1], [2,2,1], [3,2,1]], [[0,1,1], [1,1,1], [2,1,1], [3,1,1]], [[0,0,0], [1,0,.5], [2,0,.5], [3,0,0]]], steps=10, thickness = 0.25*s); 
} //seat

/*
module python01() { wheel(w=front_wheel);

translate([-BB2FWA/2*sin(a_rear),0,-BB2FWA/2*cos(a_rear)]) rotate([0,a_front,0]) color(c_frame) roundedBox([1.5*s,0,BB2FWA+s],0.75*s, false);

} //python01
*/