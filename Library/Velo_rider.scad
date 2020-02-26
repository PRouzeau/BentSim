//Deeply modified from OpenBike rider, which was itself got from http://www.thingiverse.com/thing:3495
// Modifs 2018-2020 by Pierre ROUZEAU AKA PRZ
// License GPL V3
//Revised: Dec 2018, Nov 2019, Dec 2019, Feb 2020
//Feb. 2020 Improved torso with proper camber, shoulder blades protrusion and better neck junction, more leg parameters (to view amplitude in a fairing), removed pedalling animation.

//while the 'reference head size is fixed, now head have some proportionality to size,say head size is sizeRatio^0.4
//Limb and body size are sizeRatio^0.6
//This improved proportions on all sizes and small sizes resemble more children than dwarf
//Children are not reduced adults, they have different proportions
//Feet size is proportional to leg length
//Unfortunately, this did increased the calculation time, now around 5 seconds on an old desktop
//You can adjust the height (without helmet and shoes).
//Leg/torso proportion is now adjustable
//More realistic shoe shape
//The rider is not completely accurate on anthropometric viewpoint as his/her articulations are in the middle of the limbs, which is far from the reality and troubles dimensions whith folded limbs, which is a common problem in posable models. Very surprisingly, this is the only posable model I found on OpenSCAD. This model was taken from the openbike site (http://en.openbike.org/wiki/OpenSCAD), with corrections of angles errors sign and foot articulation center. I did extended modifications to improve the anthropometric proportions. His/her dimensions are now proportional to head size as common practice. It can be taller or smaller with a fixed head size and articulation are repositioned based upon that.
//There is some unchecked attempt to correct the misplaced hip articulation (modified leg length when rotating it)
	//Also, its design is now adimensional and you can use whatever unit you wish, just giving reference head size and whole size in these units.
//This model was itself got from thingiverse model designed as a groom of a wedding cake topper, so no surprise this was not the most accurate human proportions! The initial author may be surprised by what we made from its 3D printed model.
//There was a very detailed and accurate project for human models (based on bones), but unfortunately not finished here: https://github.com/davidson16807/relativity.scad/wiki/Human-Body
//Basing articulations on skeleton is the only way to have accurate dimensions when flexing limbs, but you shall fill in flesh after and that is complex with OpenScad.
//you can find information on anthropometry here: 
//https://design.tutsplus.com/articles/human-anatomy-fundamentals-basic-body-proportions--vector-18254
//in french : http://villemin.gerard.free.fr/Biologie/CorpsPro.htm
//An interesting program to design models (not tested): http://terawell.net/terawell/

/*[Hidden]*/
$fn = 24;
// rider based on groom from http://www.thingiverse.com/thing:3495
//rider types
r_none=0;
r_pedal=1;
r_groundleg=2;
r_seated=3;
r_stood=4;
r_noleg=5; 

/*[Display]*/
//Rider type
r_type = 0; //[0:None, 1:Pedalling, 2:Foot on ground, 3:Seated, 4: Stood, 5:No leg] 
rider_check=false;

/*[Sizes]*/
//head reference size, all body proportional to this, 225mm or 8.9 inches, rider design is adimensional
head=225;
//Actual height without shoes and helmet, use same units as head
r_height = 1700;

//Foot extend below foot reference plane to take into account shoes. Head reference plane is below ovoid as a real head is not that pointy, so real height is an approximation.
//calculations
//reference size, for internal calculation only
//below ref_height is traditional body reference, size equal to eight time the head
//Note that the ovoid head is taller than this dimensions as a real head is not ovoid
ref_height = 8*head; 
hd=head/2;

//Attempt (rough and experimental) to take into account that the hip articulation is above the model hip center, which position the knee farther than a centered model when upper leg goes horizontal.
//When leg is extended, the correction of hip and knee uncentered articulation may give the foot 40 to 50 mm farther than the model.
//This is better than nothing, but shall be checked

hip_Voffset = hd*0.39; //~40mm

// --------- Modules -------------
//leg position index from animation time
function lidx() 
 = round(($t*4-floor($t*4))*8);
function pleg(i) = $rider_t==r_stood?stood_a[i]:
a_legs[i][lidx()];

//colors
c_skin=[0.95,0.75,0.55]; 

//Last term of third array : left foot angle
//Last term of sixth : right foot angle
//animation not used yet
//Positive angle modification rotate limb in counter-clockwise direction
//arm position modification
arm_open = 5;

//leg angle when stood
stood_a = [5,12,-7,5,12,-7];

//Array(vector) for animation 
//yet only first parameter is used
a_legs = 
[[73.5,80,69,56,42,42,63,78], //left leg angle
[104,96,88,68,30,20,52,74], //left knee angle
[-23,0,0,0,45,35,20,0], //left foot angle
[32,43,63,78,86,80,69,57], //right leg angle
[6,20,52,74,92,96,88,62], //right knee angle
[15,45,22,0,10,0,0,20]]; //right foot angle

//long legs : 1.2, short legs : 0
l_prop = 0.5; // [0:0.1:1.2]

/*[Hidden] */
//leg proportionality coeff: 0.45 oct 2019
lpcoef = 0.45;
//Head size proportional power (say head = size_coef^head_prop_power
hdpow = 0.4;
//Limb and body size proportional power
szpow = 0.6;


//function prop_rider (rsize) = (rsize-head)/7/head;
function in_seam (rsize,lprop) = 3.6*(rsize-head)/7+lprop*lpcoef*head/2;

if (r_type) {
	prop = (r_height-head)/(ref_height-head);
	$hdprop = ((r_height/hd)/15)^hdpow;
	$hdr = $hdprop*hd;
	top = 5.4*hd*prop+$hdr-lpcoef*hd*l_prop;
	bot = top-r_height;
	inseam = in_seam (r_height,l_prop);
	rotate([0,0,-90])
	veloRider();
	if (r_type==r_stood) { // level planes
	ts (-2.5*hd,-2.5*hd,bot)
	 cube([5*hd,5*hd,0.05]);
	ts (-2.5*hd,-2.5*hd,bot+inseam)
	 cube([5*hd,5*hd,0.05]);
	ts (-2.5*hd,-2.5*hd,top)
	 cube([5*hd,5*hd,0.05]); 
	} 
}

function body_height (prop, leg_prop) = 4.45*hd*prop-0.45*hd*leg_prop;

module veloRider (rh=r_height, rcolor=["red","yellow","darkblue","brown","gray"],  s_ang=70, l_ang=-45, left_fold=0, h_ang=-2, leg_prop=l_prop, vfold=0, lfolda=10, rfolda=10, legspread=3, rt=r_type, lgra = -20, armp =[0,0,0,0]) {
	
$torsocolor = rcolor[0];
$armcolor = rcolor[1];
$legcolor = rcolor[2];
$shoecolor = rcolor[3];
$helmetcolor = rcolor[4];
$vfold = vfold;
$lfolda = lfolda;
$rfolda = rfolda;
$legspread = legspread;
$rider_t = rt;
//real head half height, partly proportional to size
$hdprop = ((r_height/hd)/15)^hdpow;
$hdr = $hdprop*hd;
seat_ang = rt==r_stood?90:s_ang; //3: stood
leg_ang = rt==r_stood?-90:l_ang; //3: stood
head_ang = rt==r_stood?5:h_ang; //3: stood	

//(right) leg position modifications
//hip angle modifier
$legmodr=rt==r_stood?0:rt==r_groundleg?lgra:-6;
//knee angle modifier
$kneemodr=rt==r_stood?0:rt==r_groundleg?50:12;
//foot angle modifier
$footmodr=rt==r_stood?0:rt==r_groundleg?-3:-5;

//arm lifting angle
$arm_lift = armp[0];
//Arm pinching angle
$arm_pinch = armp[1];
//forearm lifting angle
$farm_lift = armp[2];
//forearm pinching angle
$farm_pinch = armp[3];

//moved to have the reference level at butt
rad_ankle = 1.3*0.83*hd;
rda = rt==r_stood?-180:rad_ankle;
//echo(rad_ankle=rad_ankle);
//calculate a coefficient to adjust size
//echo("Rider height",rh);
prop = (rh-head)/(ref_height-head);
//echo(prop=prop);
$sz = hd*prop^szpow;
//echo($sz =$sz);
inseam = in_seam(rh,leg_prop);
riderdxz = 0.8*(hd-$sz); // correction for body size
//echo(riderdxz =riderdxz);
//echo($sz=$sz);

//if (rider_check)
//echo("Rider inseam", round(inseam));
//bot=-9.4*hd*prop-0.18*hd;	
//move rider to have the reference point at the butt bottom
	ts(0,0,rda)
		rotate([90-seat_ang,0,90])
			ts(0,-riderdxz,body_height(prop, leg_prop)/2-hd*0.42-riderdxz)
				vRider(prop, seat_ang,leg_ang, left_fold, head_ang, leg_prop);
}

module vRider (prop, seat_ang, leg_ang, left_fold, head_ang, leg_prop) {
// Proportions
bodyHeight=body_height(prop, leg_prop);
if(rider_check)
	echo(bodyHeight=bodyHeight);
//armLength = 8; 
hand=[0.6,0.8,1.7]; //orientation vector
legLength = hd*3.84*prop+leg_prop*lpcoef/2*hd; //Thigh length, equal to lower leg 
armLength = hd*3.2*prop; // 
footLength = hd; //not real length, only ref 

color($torsocolor) { 
// go to top hip
	ts(0,-0.08*hd,-bodyHeight/2+0.5*hd) {
	//belly
		rshape(3.33*$sz,2*$sz,2*$sz,bodyHeight*0.4, 0.8*$sz,bodyHeight*0.04);
//Lower rib cage
	ts(0,bodyHeight*0.04,bodyHeight*0.4)
		rshape(3.5*$sz,2*$sz,2.2*$sz,bodyHeight*0.45, 0.8*$sz,-bodyHeight*0.04);
//Top rib cage and shoulders
	ts(0,0,bodyHeight*0.85)
		rshape(3.8*$sz,2.2*$sz,1.6*$sz,bodyHeight*0.15+hd*0.08, 0.8*$sz,0);
	//ref axis
		*rotate([0,90])
		cylinder(r1=0.1*hd,r2=0.1*hd,h=hd*8, center=true);
	}
}
ts(0,0,bodyHeight/2+0.21*hd) {
	// arms
	ts(0,-0.08*hd,0.42*hd){
		mirror([1,0,0]) rotate([-6,0,0]) 
			arm(165+$arm_pinch,-15-$arm_lift,-12-$farm_pinch,25+$farm_lift,hand); 
		rotate([-6,0,0]) 
			arm(165+$arm_pinch,-15-$arm_lift,-12-$farm_pinch,25+$farm_lift,hand);
	}
	ts(0,-0.1*$sz,1.4*$sz) {
		rotate([(seat_ang-head_ang-90)*0.5,0,0]) {
			// neck
			color(c_skin)
				ts(0,0,0.1*$sz)
					cylinder(r1=0.54*$hdr,r2=0.58*$hdr,h=$hdr*1.8, center=true);
		}
		rotate([seat_ang-90-head_ang,0,0]) {
			// head
			color(c_skin)
				ts(0,0,0.4*hd*prop+hd) 
					rotate([-4,-1,0]) scale($hdr) scale([1,1,1.33]) sphere($fn=30);
			// helmet
			if(!rider_check)
			color($helmetcolor) 
				ts(0,-2.08*hd,(0.85-1.4)*$hdr)  
					helmet(); 
		}
	}
	//LEGS
	if ($rider_t!=r_noleg)
		ts(0,-0.08*hd,-bodyHeight+0.21*hd) { 
			//left
			mirror([1,0,0]) leg(
			$legspread+1,
			($rider_t==r_seated?42:pleg(0)+left_fold)+seat_ang+leg_ang, 
			($rider_t==r_seated?70:pleg(1))+left_fold,
			[$rider_t==r_seated?10:pleg(2),3,0]
			); 
			//right
			leg(
				$rider_t==r_groundleg?7:$legspread-0.5,
				($rider_t==r_seated?42:pleg(3)+$legmodr)+seat_ang+leg_ang,
				($rider_t==r_seated?70+left_fold:pleg(4)+$kneemodr),
				[$rider_t==r_seated?10:pleg(5)+$footmodr,3,0]
			);
			//2nd leg set 
			//echo($vfold=$vfold);
			if($vfold!=0) {
				$shoecolor="yellow";
				//left
				mirror([1,0,0]) 
					leg($legspread,$lfolda+seat_ang+leg_ang, $vfold,[3,3,0]); 
			//right
				leg($legspread,$rfolda+seat_ang+leg_ang, $vfold-10,[3,3,0]);
			}
		} 
}

module helmet () { 
	// FreeCAD not ok with scale parameter but work with 'hull()'
	ts(0,2.08*hd,2.3*$hdr){
	hull() {
		difference() {
			sphere(1.25*$hdr, $fn=36); 
			ts(0,0,-2.3*$hdr) 
				rotate([10,0,0])
					cube(4.2*hd,center=true);
		} 
		ts(0,1.5*$hdr,0.155*$hdr)
			cube([1.4*$hdr, 0.1*hd, 0.1*hd], center = true);
	}
 }
} //helmet

module leg (legSpread,kneeLift,kneeBend,footPos) {
	thickness= 0.8*$sz;
	hipWidth = 0.8*$sz;
	//hip correction attempt
	lgext = sin(kneeLift)*hip_Voffset;
	if (rider_check) {
		echo(kneeLift=kneeLift);
		echo(lgext=lgext);
	}
	llg = legLength + lgext;
 // upper leg
	ts(hipWidth)
		rotate([-kneeLift,180-legSpread,-3]) { 
			color($legcolor) {
				sphere(r=thickness*1.25); 
				cylinder(r1=thickness*1.2,r2=thickness*0.75,h=llg);
			}
			// joint
			ts(0,0,llg) { // lower leg
				color($legcolor)
					sphere(r=thickness*0.75);
				rotate([kneeBend,0,0]) {
					color($legcolor)
						cylinder(r1=thickness*0.75,r2=thickness*0.55,h=legLength);
			// foot
					color($shoecolor)
						ts(0,0,0.01*hd+legLength)
							rotate([footPos[0],footPos[1],footPos[2]]) 
								foot(legLength*0.38);
								//echo("prop leg",prop);
				}
		}
	}
}// leg

module foot (length= hd*1.48) {
	d=length/1.48;
	hull() {
		ts(0,0,-0.3*d)
			cylinder(r=d*0.45,h=0.7*d);
		ts(0,length,0.05*d)
			cylinder(r=d*0.5,h=0.35*d);
	}
}

module arm (armBend,armBendForward,elbowBend,elbowBendForward,hand) { 
	thickness=0.58*$sz;
	shoulderWidth=1.46*$sz;
	// upper arm
	ts(shoulderWidth)
		rotate([armBendForward,armBend,-arm_open]){ 
			color($armcolor){
				sphere(r=thickness*1.2); 
				cylinder(r1=thickness*1.2,r2=thickness*0.8,h=armLength);
			}
			//joint
			ts(0,0,armLength) { 
				color($armcolor) 
					sphere(r=thickness*0.8);
				rotate([-elbowBendForward,-elbowBend,0]) { 
					color($armcolor)
						cylinder(r1=thickness*0.8,r2=thickness*0.6,h=armLength*0.8);
					// hand
					color(c_skin) 
						ts(0,0,armLength*0.8) 
							scale([hand[0],hand[1],hand[2]]) sphere(r=thickness); 
				}
			}
	}
} // arm

//Torso rounded shape 
module rshape (wd,p,p2,ht,r1,dp,shift=0.25*$sz) {
	/*
	y1 = ((p/2-r1)^2+shift/2^2)^0.5;
	y2 = ((p2/2-r1)^2+shift/2^2)^0.5;
	a1 = atan(shift/2/(p/2-r1));
	a2 = atan(shift/2/(p2/2-r1));*/
	hull() {
		ts(0,p/2-r1,-shift/2)
			dsph();
		ts(0,-p/2+r1,shift/2)
			dsph();
	//rotate([-a1,0,0])  dmy(y1)dsph();
	//ts(0,dp,ht)	rotate([-a2,0,0])  dmy(y2) dsph();
		
		ts(0,dp,ht) {
			ts(0,p2/2-r1,-shift/2)
				dsph();
			ts(0,-p2/2+r1,shift/2)
				dsph();
		}
	}
	module dsph() {
		hull() //reduce calc time 
			dmx(wd/2-r1)
				sphere(r1, $fn=20);
	}
} 

} //veloRider()

//translate module
module ts (x=0,y=0,z=0) {
	translate([x,y,z])
		children();
}
//mirror modules
module dmx(x=0) { // duplicate and mirror
	ts(x) children();
	mirror([1,0,0])
		ts(x) children();  
}

module dmy (y=0) { // duplicate and mirror
	ts(0,y) children();
	mirror([0,1,0])
		ts(0,y) children();  
}
