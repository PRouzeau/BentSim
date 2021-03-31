//*******************************
include <Z_library.scad>
//Mid Drive bike motors
mpart = 0; // [0:None, 1:TSDZ2, 2: Bikee Lightest, 3: Both, 4:Frame battery]
Bikee_x = 0;
Bikee_z = 0;
Bikee_ang = 0;
Bikee_idler= -10;

//Battery
mpart2=0; // [0:None, 1:frame battery, 2:frame ht 90, 3:rack , 4:Prismatic]

if (mpart2)
  t(0,0,400)
    battery (mpart2-1);

if(mpart==1 || mpart==3)
	TSDZ2();
else if(mpart==2 || mpart==3)
	bikee_lt();
else if (mpart==4)
	frame_batt();

$fn=36;
	//cyly(-52,68, 0,0,0, 64); // Check BB
//reference is BB shaft axis. Positioned for 68 BB. shall be moved sideway by 2.5mm for BB of 73mm width

//-- Mid drive motor TSDZ2 ------------
module TSDZ2 (yoffset=0, clr="gray") {
	t(0,-yoffset-7) {
		color(clr) {
			cyly(-33.5,100, 0,0,0, 24);
			cyly(-80,105, 28,14.5,-60, 32);
			cyly(130,16, 0,-43,0, 36);
			hull() {
				cyly(-50,100, 21,12,-52, 24);
				duplz(-30)
					cyly(-50,100, -21,12,-52, 24);
				diff() {
					cyly(-215,100, -5,12,0, 64);
					//:::::::::::::
					cubez(222,333,222,0,0,-52);
					r(0,-75)
						cubez(222,333,222);
					r(0,60)
						cubez(222,333,222);
				}
			}
			//Anchor
			diff() {
				hull() {
					cyly(-16,30, -60,5,-32, 16);
					cyly(-20,30, -30,5,-37, 16);
				}
				cyly(-7,99, -60,0,-32, 12);
			}
		}
		silver() {
			cyly (-176,2.2, 0,-50.2+7);
			cyly (-18,150, 0,-5);
		}
	}
}

//Italian company 'Bikee' designed a mid-drive they called modestly "The lightest". It is positioned in front of the chainring. This is an interesting design as it doesn't need a special frame and its installation is cleaner than others second mount mid-drives. Though they did not invent the system well proved before by the 'powerplay' motor sold by Canadian 'Rocky mountain' company and designed by 'Propulsion Powercycle company'. Uuuh, seems that some mid-drive sellers have difficulties to create discriminating names, just to make web search the most difficult possible ?
//Could be found here: 
module bikee_lt (x=Bikee_x, y=0, z=Bikee_z, ang=Bikee_ang, idler_ang=Bikee_idler) {
  //cyly (-3,300);
	t(x,y,z) r(0,-ang-29) 
  t(-63)r(0,18) { // move to sprocket axis
		gray() {
			// motor ??
			hull() {
				cyly(72,-35);
				cyly(65,-40);
			}	
			hull() {
				cyly(88,70, 44,-25);
				cyly(72,55, 0,-25);
			}
			//sprocket bearing holder
			r(0,-18) 
				t(63,-35)
					r(0,18) {
						hull()
							duplx(-60)
								cyly(33,25);
						cyly(32,25, 0,-5);
					}
			// bearing holders
			hull() {
				cyly(25,52, 44);
				cyly(25,52, 0);
			}
			//attachs
			dmirrorz()
				diff() {
					hull() {
						r(0,34)
							cyly(11,-20, -41,10);
						cyly(40,-20, 0,10,16);
					} //::::::::::
					r(0,34)
						cyly(-5.2,111, -41,10,0, 12);
				}
			diff() {
				hull() {
					r(0,9.7)
						cyly(11,-20, 93,10);
					cyly(40,-20, 60,10,-5);
				} //::::::::::
				r(0,9.7)
					cyly(-5.2,111,  93,10,0, 12);
			}
		}
		//Sprocket
		silver() {
			r(0,-18) 
				t(63) {
					cyly(15,-75, 0,20);
					cyly(-50,2, 0,-50);
					r(0,idler_ang)
						t(-48,-50) {
							cyly(-35,2);
							cyly(-20,12);
						}
				}
		}
	}
}

module battery (type,x=0,z=0,ang=0,ht=111, rev=true, clr="#606060") {
  color(clr)
    t(x,0,z)
      r(0,ang)
        mirrorx(rev)
  if(!type)
    frame_batt(111); 
  else if(type==1)
    frame_batt(90);
  else if(type==2)
    rack_batt(lg=440);
  else if(type==3)
    prism_batt(lg=370);
} 
//Frame batterie, Hailong style
module frame_batt (ht=111) {
	lg = 368;
  hull() {
    dmirrory() {
      duplx(lg-70-16) {
        cylz(16,1, 16,30);
        cylz(32,4, 16,30, 12);
        cyly(40,-5, 20,30,ht-20);
        cyly(16,-1, 16,45,ht-20);
      }	
      cylz(16,50, lg-16,22);
      cylz(32,50, lg-16,22,12);
    }
  }
}
//Rack type battery
module rack_batt (lg=440, ht=75, wd = 150) {
  hull() 
    duplx(lg-ht) 
      cyly(-ht,wd, ht/2, 0, ht/2);
}
//Prismatic battery
module prism_batt (lg=370, ht=85, wd=61) {
  cubex(lg,wd,ht, 0,0,ht/2); 
}
