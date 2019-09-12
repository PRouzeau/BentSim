//Modified from OpenBike rider, which was itself got from http://www.thingiverse.com/thing:3495
// Modifs 2018 by Pierre ROUZEAU AKA PRZ
// License GPL 4.0
//This version: - first issue: December 2018
//pedalling animation tables done by OpenBike are not used and are yet incorrect (movement according $t variable)
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
foot_on_ground=false;
rider_check=false;

/*[Sizes]*/
//head reference size, all body proportional to this, 225mm or 8.9 inches, rider design is adimensional
head=225;
//Actual size, with head size unmodified, use same units as head
rider_height = 1700;

//Foot extend below foot reference plane to take into account shoes. Head reference plane is below ovoid as a real head is not that pointy, so real height is an approximation.
//calculations
//reference size, for internal calculation only
//below red_size is traditional body refernce, size equal to eight time the head
//Note that the ovoid head is taller than this dimensions as a real head is not ovoid
ref_height = 8*head; 
hd=head/2;
//calculate a coefficient to adjust size
prop = (rider_height-head)/(ref_height-head);
//echo(prop=prop);

// Proportions
bodyHeight = 4.45*hd*prop; 
//armLength = 8; 
hand=[0.6,0.8,1.7]; // orientation
legLength = hd*3.84*prop;
armLength = hd*3.2*prop;
footLength = hd;

//Attempt (rough and experimental) to take into account that the hip articulation is above the model hip center, which position the knee farther than a centered model when upper leg goes horizontal.
//When leg is extended, the correction of hip and knee uncentered articulation may give the foot 40 to 50 mm farther than the model.
//This is better than nothing, but shall be checked

hip_Voffset = hd*0.39; //~40mm

explode = 1; // 1 is normal, bigger "explodes" the parts.

// --------- Modules -------------
function rem8(u,v) = round((u/v-floor(u/v))*8); 

//colors
skin=[0.95,0.75,0.55]; 
c_rider = "gray";

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

//(right) leg position modifications
legmodr=foot_on_ground?-15.5:-6;
kneemodr=foot_on_ground?50:12;
footmodr=foot_on_ground?-3:-5;

//arm position modification
arm_open = 5;


a_legs = stood?
[[80,69,56,42,42,63,78,32],[96,88,68,30,20,52,74,10],[0,0,0,45,35,20,0,-6], [43,63,78,86,80,69,57,32],[20,52,74,92,96,88,62,10],[45,22,0,10,0,0,20,-8], [-45,23,-45,20,-45,45,-30,45],[-45,45,-20,45,-45,45,-45,45]]
:
[[80,69,56,42,42,63,78,86+legmodl],[96,88,68,30,20,52,74,105+kneemodl],[0,0,0,45,35,20,0,-15+footmodl], [43,63,78,86,80,69,57,32+legmodr],[20,52,74,92,96,88,62,19+kneemodr],[45,22,0,10,0,0,20,10+footmodr], [-45,23,-45,20,-45,45,-30,45],[-45,45,-20,45,-45,45,-45,45]]; // for animation 

//ftp = [0,0,0];

//top = 680;
top = 4.41*hd*prop+2*hd;
inseam = 7.2*hd*prop;
if (rider_check)
	echo(inseam=inseam);
//bot = -990;
bot=-9.4*hd*prop-0.18*hd;

if (rider_check)
	echo("rider height check", top-bot); 

a_seat = stood? 90:60; //20 to 70 degrees clock-wise
leg_a1= -39;
leg_angle = stood? -120:leg_a1;
head_angle = stood? 2:-12;
knee_angle = stood? 0:0;
foot_angle = stood? 0:0;

/*stood
a_seat = 90; //20 to 70 degrees clock-wise
leg_angle = -120;
head_angle = 2;
knee_angle = 0;
foot_angle = 0;
//*/

	echo (bodyHeight=bodyHeight);

if (rider) {
	rotate([0,0,-90])
	//rotate([90-a_seat,0,-90])
		mirrory() veloRider();
	if (stood) {
	translate ([-2.5*hd,-2.5*hd,bot])
	 cube([5*hd,5*hd,0.05]);
	translate ([-2.5*hd,-2.5*hd,bot+inseam])
	 cube([5*hd,5*hd,0.05]);
	translate ([-2.5*hd,-2.5*hd,top])
	 cube([5*hd,5*hd,0.05]); 
	} 
}

rad_ankle = 1.3*0.83*hd;
//echo(rad_ankle=rad_ankle);
module veloRider(bang=30) {
	translate([0,0.08*hd,rad_ankle])
		rotate([bang,0,90])
			translate([0,0,bodyHeight/2-hd*0.42])
				vRider();
}

module vRider() {

// torso
translate([0,0,0.3*hd]) 
roundedBox([3.33*hd,2.08*hd,bodyHeight+0.83*hd], 0.92*hd, false);

//rib cage
translate([0,0.04*hd,bodyHeight/3.2]) 
	roundedBox([3.75*hd,2.12*hd,bodyHeight*0.75+0.83*hd], 1.04*hd, false);

//chest
translate([0,0.04*hd,bodyHeight/2]) 
	roundedBox([3.96*hd,2.21*hd,bodyHeight*0.5+0.83*hd], 0.83*hd, false);

translate([0,0,bodyHeight/2+0.21*hd]) {
	// arms
	translate([0,-0.08*hd,0.42*hd]){
		mirror([1,0,0]) rotate([-6,0,0]) 
			arm(0.58*hd,1.46*hd,armLength,165,-15,-12,25,hand); 
		mirror([0,0,0]) rotate([-6,0,0]) 
			arm(0.58*hd,1.46*hd,armLength,165,-15,-12,25,hand);
	}
	translate([0,-0.12*hd,0.08*hd])
	rotate([a_seat-90-head_angle,0,0]) {
		// neck
		color(skin) translate([0,0,1.5*hd*prop]) cylinder(r1=0.54*hd,r2=0.58*hd,h=0.83*hd, center=true);
		// head
		color(skin) translate([0,0,1.8*hd*prop+hd+5*(explode-1)]) rotate([-4,-1,0]) scale(hd) scale([1,1,1.33]) sphere($fn=30);
		// helmet
		color(c_rider) translate([0,-2.08*hd,0.85*hd*prop+15*(explode-1)]) { 
			helmet(); 
		} 
	}

	color(c_rider) translate([0,-0.08*hd,-bodyHeight+0.21*hd]) { // LEGS
		//left
		mirror([1,0,0]) 
		leg(0.8*hd, 0.8*hd, legLength,4,a_legs[0][7-rem8($t*360,90)]+a_seat+leg_angle, a_legs[1][7-rem8($t*360,90)],[a_legs[2][7-rem8($t*360,90)],0,0]); 
		//right
		leg(0.8*hd, 0.8*hd, legLength,foot_on_ground?7:2.5,a_legs[3][7-rem8($t*360,90)]+a_seat+leg_angle, a_legs[4][7-rem8($t*360,90)],[a_legs[5][7-rem8($t*360,90)],0,0]);
	} 
}

module helmet () { 
	translate([0,2.08*hd,2.3*hd]) hull() {
		difference () {
			sphere(1.25*hd); 
			translate([0,0,-2.3*hd]) 
				rotate([10,0,0])
					cube(4.2*hd,center=true);
		} 
		translate([0,1.54*hd,0.17*hd]) cube([1.46*hd,hd*0.3,hd*0.01],center=true);
 }
} //helmet

module leg (thickness,hipWidth,lLength,legSpread,kneeLift,kneeBend,footPos) { 
	//hip correction attempt
	if(rider_check)
		echo (kneeLift=kneeLift);
	lgext = sin(kneeLift)*hip_Voffset;
	if (rider_check)
		echo(lgext=lgext);
	llg = lLength + lgext;
	translate([4*(explode-1),0,-10*(explode-1)]){ // upper leg
		translate([hipWidth,0,0])
			rotate([-kneeLift,180-legSpread,-3]) { 
				sphere(r=thickness*1.25); 
				cylinder(r1=thickness*1.2,r2=thickness*0.75,h=llg);
				// joint
				translate([0,0,llg+10*(explode-1)]) { // lower leg
					sphere(r=thickness*0.75);
					rotate([kneeBend,0,0]) { 
						cylinder(r1=thickness*0.75,r2=thickness*0.55,h=lLength);
				// foot
						translate([0,0,0.01*hd+lLength+10*(explode-1)]) rotate([footPos[0],footPos[1],footPos[2]]) translate([0,0.8*hd*prop,0]) roundedBox([1.04*hd,2.5*hd*prop,0.83*hd],thickness*.55); 
				}
			}
		}
	}
}// leg

module arm (thickness,shoulderWidth,armLength,armBend,armBendForward,elbowBend,elbowBendForward,hand) { translate([10*(explode-1),0,0]) { // upper arm
		translate([shoulderWidth,0,0]) rotate([armBendForward,armBend,-arm_open]){ 
			sphere(r=thickness*1.3); cylinder(r1=thickness*1.2,r2=thickness*0.8,h=armLength);
			//joint
			translate([0,0,armLength+10*(explode-1)]) { sphere(r=thickness*0.8); rotate([-elbowBendForward,-elbowBend,0]) { 
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
	if (sidesonly) { 
		cube(size - [2*radius,0,0], true); cube(size - [0,2*radius,0], true); 
	for (x = [radius-size[0]/2, -radius+size[0]/2], y = [radius-size[1]/2, -radius+size[1]/2]) { translate([x,y,0]) cylinder(r=radius, h=size[2], center=true); } 
	} //if
	else { 
			cube([size[0], size[1]-radius*2, size[2]-radius*2], center=true); cube([size[0]-radius*2, size[1], size[2]-radius*2], center=true); cube([size[0]-radius*2, size[1]-radius*2, size[2]], center=true);

		for (axis = [0:2]) { for (x = [radius-size[axis]/2, -radius+size[axis]/2], y = [radius-size[(axis+1)%3]/2, -radius+size[(axis+1)%3]/2]) { rotate(rot[axis]) translate([x,y,0]) cylinder(h=size[(axis+2)%3]-2*radius, r=radius, center=true); } 
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