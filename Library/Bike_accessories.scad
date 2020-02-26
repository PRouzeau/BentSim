//Bike wheel and fenders modelisation, as extracted from Velassi simulation
// Copyright 2018-2020 Pierre ROUZEAU AKA PRZ
// Program license GPL 4.0
// documentation licence cc BY-SA 3 and GFDL 1.2
// First version: 0.0 - November 2018
//Feb 2020: Add ICE mesh seat, Hardshell seat, corrected Rans seat frame width
// To work, this module requires my OpenSCAD library, attached, but you can find details here:
// https://github.com/PRouzeau/OpenScad-Library

//dcheck = false;

include <Z_library.scad>
/* test 
wheel();
fender(wire_space=135);
//*/
//test viewing seat
seat_test = 0; //[0:no seat view, 1:Rans mesh, 2:ICE mesh, 3: Hardshell]

if (seat_test==1)
	rans_seat();
else if (seat_test==2)
	ICE_seat();
else if (seat_test==3)
	hardshell_seat();

glass_color = [128,128,128,32]/256;
// transparent

flag_img = "Library/signature_PRZ_cut.dxf";
flag_scale = 3.2;

function tire_diam (rim=559, tire=40) = rim+2*tire+4;
//-- spoked wheel ---------------------
module wheel (rim=559, tire=40, hubdia=60, hubwidth=60, spa=7.5, spoke_nbr=36, shaft_width = 140, clr_rim= [0.8,0.8,0.8], clr_tire=[0.4,0.4,0.4]) {
	wh_d=rim+2*tire+4; 
	//becho("wheel diam",wh_d);
	spd = 2.2; // spoke diameter
	spr = hubdia/2+8; // spoke radius
	//becho("spoke_nbr", spoke_nbr);
	rpt_spoke = spoke_nbr/4;
	spoke_ang = 360/rpt_spoke;
	check()
		diff() {
			cyly(-(rim-65),78, 0,0,0,48);
			cyly(-(rim-66),122,0,0,0,48);
		}
	//tire
	color(clr_tire) 
		r(90)
			rotate_extrude(convexity = 10, $fn=48) 
				t(wh_d/2-tire/2, 0, 0) 
					circle(r = tire/2, $fn=24); 
	//rim 
	color(clr_rim) {
	//rim
		diff(){
			cyly(-(wh_d-tire*2+10),0.6*tire,0,0,0, 48); 
			cyly(-(wh_d-tire*2-25),60, 0,0,0, 48); 
		}
	// shaft
		cyly(-9,shaft_width);
	if(spoke_nbr) {
	//hub
		cyly(-hubdia,hubwidth);
		dmirrory()
			cyly(hubdia+25,3, 0,hubwidth/2-3);
	//spokes
		lgspoke = rim/2-(spa?10:hubdia/2+15);
		spangle = atan((hubwidth/2+2)/lgspoke);
		spangle2 = atan((hubwidth/2-5)/lgspoke);
		if (spa)
			droty(spoke_ang,rpt_spoke-1){
				r(0,-spa) rotz(-spangle)
					cylx(spd, lgspoke, 0,hubwidth/2+1,spr,8);
				r(0,spa+30) rotz(-spangle2)
					cylx(spd, lgspoke, 0,hubwidth/2-5,-spr,8);
				// other side
				r(0,360/spoke_nbr) {
					r(0,-spa) rotz(spangle)
						cylx(spd, lgspoke, 0,-hubwidth/2-1,spr);
					r(0,spa+30) rotz(spangle2)
						cylx(spd, lgspoke, 0,-hubwidth/2+5,-spr);
				}
			}
		else //radial spokes
			droty(spoke_ang*0.5,rpt_spoke*2-1){
				t(0,hubwidth/2+1,spr)
					rot(spangle)
						cylz(spd, lgspoke, 0,0,0, 8);
				r(0,360/spoke_nbr)
					t(0,-hubwidth/2-1,spr)
						rot(-spangle)
							cylz(spd, lgspoke, 0,0,0, 8);
		}
	}
	else 
		// no spoke gives plain wheel
		hull() {
			cyly(-hubdia-35,hubwidth+12, 0,0,0, 48);
			cyly(-rim-30,35, 0,0,0, 48);
		}
	}
} //wheel

//- Fenders / Mudguards ------
//if front_angle = 0, no mudguard
//angle 0 = horizontal
//w_width is width of attach point of wire supports, if 0, there is no support, which is located on rear, at 8 deg from start
module fender (wheel_rim = 559, tire_w = 47, front_angle=8, rear_angle=170, wire_space=110, clr_fender="black") {
	fender_dia = tire_w+26;
	angtot = rear_angle-front_angle;
	//becho("fender angtot",angtot);
	wheel_dia = tire_diam (wheel_rim, tire_w);
	if(front_angle!=0) {
		color(clr_fender)
			r(90, -front_angle)
				rotate_extrude(angle=angtot, convexity = 10, $fn=48)
					diff() {
						t(wheel_rim/2+tire_w/2, 0, 0)
							circle(r=fender_dia/2, $fn=48);
						//::::::::::
						t(wheel_rim/2+tire_w/2, 0, 0) 
					circle(r=(fender_dia/2-1), $fn=16); 
						square ([wheel_rim+tire_w,100], center=true);
						//side cut, width 10mm more than tire
						dmirrory() 
							t(0,tire_w/2+5)
								square ([wheel_rim+tire_w+100,100]);
					}
	// wire supports
		supy = wire_space/2+5;
		ags = atan((supy-25)/(wheel_dia/2-20));
		if(wire_space) 
			silver() 
				r(0,-rear_angle+20)
					dmirrory()
						t(15,supy,15)
							rotz(-ags)
								cylx(4,wheel_dia/2-13, 0,0,0, 6);
	}
}

module seat_light (x=-70,z=515,s_ang, light_color) {
	t(x,0,z) {
		if (light_color) 
		t(-75)
			r(0,79-s_ang) {
				rear_light(light_color);
				dmirrory() 
					silver()
						cubez(3,15,-38, 10,25,20);
			}
	}
}

/*/-- seat tests
b_seat(1);
b_seat(2);
b_seat(3);
*projection()	r(90) b_seat(2,55,0,false,"");
cyly (-50,380,350,0,400); // width test
//*/

//== Rans recumbent mesh seat ======
module rans_seat (s_ang=45, fold=0, width=400, sflag=true, light_color="black"){
	//Width at base, top of seat have less width than the base (~ 30mm)
	prec = 12;
	dt = 22; // frame tube diameter
	//cubez (500,500,1,0,0,700); 
	//check height
	cx=-6; cz=112; // rotation centre at hip
//---------------------------
 t(cx,0,cz) {
	//cyly(-5,600);
	//nominal width of 380 will give bottom width of 400 
	mirrorx()
	r(0,s_ang) 
	t(cz,0,-cx)
	t(30,0,10) r(0,-79) {
		
	scale ([1,width/400,1]) {
	black()
		hull() {
			cylz (20,1, 85,0,0, prec);
			cylz (30,1, 85,0,-10, prec);
			dmirrory()
				cylz (20,10, 0,28,0, prec);
		}
	t(-174,0,155) {
		red()
			cyly(-3,420, 0,0,0, prec);
		r(0,-fold) {
			seat_light(-60,518,s_ang,light_color);
			//flag
			if(sflag) t(-90,-175,590) 
				r(0,15) flag();
			// width check
			//cyly(-20,372,-106,0,535, 6);
			//cyly(-20,400,10,0,-40, 4);
		}
	}
	gray()
	dmirrory() 
		tb_yx(dt,-75,48, prec)
		cyly(dt,84, 0,0,0, prec)
		r(0,-90)
		tb_yx(dt,75,45, prec)
		cyly(dt,57.6, 0,0,0,prec) {
			r(28,26)
				cylz(15,150, 0,0,0, prec)
				tb_zx(15,250,6, prec);
			tb_yx(dt,75,45, prec)
			cyly(dt,40, 0,0,0, prec)
			r(0,41.8)
			rotz(fold) r(1.5){
				//back
				cyly(dt,40, 0,0,0, prec) {
					tb_yx(dt,-500,20, prec)
					cyly(dt,30, 0,0,0, prec)
					tb_yx(dt,500,3, prec) {
						//medium transversal bar
						r(-5,69.5) 
						t(0,0,-4)
						tb_xz(12,500,21.6, prec);
						tb_yx(dt,500,17, prec)
						cyly(dt,30, 0,0,0, prec)
						tb_yx(dt,-120,30, prec)
						cyly(dt,20, 0,0,0, prec){
							cyly(dt,20, 0,0,0, prec);
							//top transversal bar
							r(-5,70) 
							t(0,0,-4)
							tb_xz(12,500,20.9, prec);
						};
					}
				}
			}
		}
	}
 }
 }
}

module flag (lg=1000, imgfile=flag_img, imgscale=flag_scale, fclr = ["orangered","lime"]) {

	module imp_img(imgfile) {
		linear_extrude(height=2, center=true)
		import(file=imgfile);
	}
	//pole
	silver() {
		cyly(-22,10, -9,0,-50, 12);
		cylz(6,lg, -9,0,-50,6);
	}
	//flag
	t(0,0,lg-50){
		color(fclr[0]) 
			hull() {
				cylz(2,-160, -12,0,0,4);
				cylz(2,2, -250,0,0, 4);
			}
	//Image set on flag
		t(-108,2, -88)
		r(90) color(fclr) 
			scale([imgscale,imgscale,1]) {
				imp_img(imgfile);
				t(25,-3,4)
					r(0,180)
						imp_img(imgfile);
			}
	}
}

//== ICE recumbent mesh seat ======
//ICE frame designed from photo, so accuracy may be limited
module ICE_seat(seat_angle=60,width=380, sflag=true, light_color="black") {
	prec= 12;
	dt = 25.4;
	wd = width-dt;
	module cxl(d,l) {
		cylx (d,l,0,0,0,prec)
			children();
	}
	module transv(dx=0) {
		t(dx)
		render()
			r(45)
				cyly(dt,-60, 0,0,0, prec)
					tb_yz(dt,-50,-45, prec)
						t(0,0.01) // stop CGAL error
						cyly(dt,-wd/2+50, 0,0,0, prec) 
							children();
	} 
	cx=-6; //cx, cz rotation center coord
	cz=112;
	t(cx,0,cz) {
		//red()cyly(-5,600);
		r(0,-seat_angle+52.8,0)
			t(-cx,0,-cz) {
			//-- rear light ---------------
			mirrorx() seat_light(-383,440,seat_angle+26,light_color);
			//-- seat -------------------
			color("gray")
			mirrorx() render()
			dmirrory() 
				t(185,wd/2,10)
				r(0,24)
				tb_xz(dt,-200,40, prec)
				cxl(dt,-50){
					transv(15);
					//back bend
					tb_xz(dt,100,78, prec)
					cxl(dt,-100){
						transv(65);
						tb_xz(dt,-200,14, prec)
						cxl(dt,-190){
							transv(60);
							tb_xz(dt,200,20, prec)
							cxl(dt,-150)
							transv(80);
						}
					}
				}
			//flag
		if(sflag) t(422,-wd/2,577)
			r(0,21,0) rotz(180) flag();
		} //r, t
	} // -t
}

module hardshell_seat (seat_angle=60,wd=300, sflag=true, light_color="black", thk = 16) {
	$wd = wd;
	$prec=64;
	reinf_dist = 80;
	
	module shape (wd=$wd,mirr=true) {
		hull() {
			dmirrory(mirr)
				t(0,wd/2-thk/2)
					circle (d=thk, $fn=24);
			if(!mirr)
				square([thk,thk],center=true);
		}
		dmirrory(mirr)
			hull() {
				t(25,reinf_dist)
					circle (d=25, $fn=24);
				t(5,reinf_dist)
					square ([25,25],center=true, $fn=24);
			}
	}
	
	module rshp (radius=100,ang=90, wd=$wd,mirr=true) {
		sang = radius<0?ang:-ang;
		dx=-(1-cos(sang))*-radius;
		dy=sin(sang)*-radius;
		t(radius)
			rotate_extrude(angle=sang, $fn=$prec, convexity=4)
				translate([-radius,0,0])
					shape(wd,mirr);
		t(dx,dy) rotz(sang) mirrorz()children();
	}
	
	module srt(a=-25,wd=$wd) {
		diff() {
		tslz(-sign(a)*wd/2)
			r(a)
				tslz(sign(a)*wd/2)
					children();
			//::::::::::::
			cubey (99,-199,999);
			cubez (99,399,sign(a)*399, 0,99);
		}
	}
	
	module tshp (lg,wd=$wd,mirr=true) {
		r(-90) linear_extrude (height=lg,center=false)
			shape(wd,mirr);
		t(0,lg)
			children();
	}
//------------------	
	cx=-6; cz=112; // rotation centre at hip
//---------------------------
	t(cx,0,cz) {
	//red() cyly(-5,600);
	gray()
	r(0,-seat_angle+60)
	t(-cx,0,-cz)
	t(-130,0,-10)
	r(90,90)
		rotz(32+5) diff() {
			rshp(100,40)
			tshp(55)
			rshp(-150,70)
			tshp(100)
			rshp(200,14)
			tshp(100)
			rshp(-400,42)
			;
			//:::::::::::
			dmirrorz() {
				//headrest cut
				t(-200,680,100)
					rotz(60)
						r(-21)
							cubez(199,399,399);
				//Base nose cut - create viewing artifacts
				t(50,50,90)
					rotz(-30)
						r(30)
							cubez(199,399,399, 50);
			}
		}
	}
}

module b_seat (type=2,s_ang=55,fold=0, sflag=true, light_color="black", wd=380){
	if(type==1) //rans mesh
		rans_seat(s_ang, fold, wd, sflag, light_color); 
	else if(type==2) //ICE mesh
		ICE_seat(s_ang, wd, sflag, light_color); 
	else if(type==3) //Hard shell
		hardshell_seat(s_ang, 300); 
	else if (type==9) //saddle
		mirrorx()
			saddle("saddlebrown", light_color);
}
//-- Saddle ------------------------

module saddle(seat_color="saddlebrown", light_color="black") {
	color(seat_color)
		hull() {
			dmirrory() 
				t(-80,60)
					sphere (r=25, $fn=24);
			t(115,0,3)
				sphere (r=20, $fn=24);	
		}
	if (light_color)
		t(-100,0,-60) {
			rear_light(light_color);
			black()
				dmirrory() {
					cubez(2.5,15,25, 9,25,10);
					cubex(20,15,2.5, 9,25,34);
				}
		}
}

//== Lighting ======================
module rear_light (clr="black") {
	//light
			color(clr)
			hull() dmirrory() {
				cylx(45,-10,0,30,15);
				cylx(30,8,0,30,15);
			}
			red()
				hull() dmirrory() 
					cylx(44,10, -20,30,15);
			color(glass_color)
				hull() dmirrory()
					cylx(44,2, -22,30,15);
}

//front_light (-20, false);

module front_light (st_ang=0, steer_bracket=0, clr = "black"){
	//support (normal type on fork)
	if(steer_bracket==1) {
		t(25)
			r(0,st_ang) 
				flight();
		//steering bracket
		silver() {
			hull(){
				cylz(34,2.5, 0,0,-1);
				cyly(-2.5,26, 25);
			}
			t(25)
				r(0,st_ang)
					hull() {
						cyly(-2.5,26);
						cylx (-12,2.5, 0,0, 10);
					}
		}
	}
	//on top of fork
	else if(steer_bracket==2) {
		tslz (-10-20)
		flight(st_ang);
	}
	//above boom
	else if(steer_bracket==3) {
		silver() { 
			cubez(3,20,60, 22);
			dmirrory()
			cubez(10,3,60, 22-5,8.5);
		}
		t(22,0,42) flight();
	}
	else // simple light
		flight();
	//-- light with own bracket --------
	module flight(an=0) {
		//light bracket
		silver() 
			hull() {
				cyly(-14,10, 20,0,35);
				cylx(-12,2.5, 3,0, 10);
			}
		//light
		t(33,0,40) r(0,an) {
			color(clr)
				hull() {
					cylx(50,20,0,0,15);
					cylx(30,-20,0,0,15);
				}
			silver()
				cylx(48,1, 20,0,15);
			color (glass_color)
				cylx(48,2, 22,0,15);
		}
	}
}

//=== Miscellaneous utilities ===
//tube bend AND displacement
module tb_yx (dtube=25,radius=100,ang=90, prec=24) {
	sang = radius<0?ang:-ang;
	dx=-(1-cos(sang))*-radius;
	dy=sin(sang)*-radius;
	t(radius)
		rotate_extrude(angle=sang, $fn=64, convexity=10)
			t(-radius)
				circle(d=dtube, $fn=prec);
	t(dx,dy) 
		rotz(sang)
			children();
}

module tb_xy (dtube=25,radius=100,ang=90, prec=24) {
	rotate([0,0,90])
		tb_yx(dtube,radius,ang, prec)
			rotate([0,0,-90]) children();
}

module tb_xz (dtube=25,radius=100,ang=90, prec=24) {
	r(90) rotz(90)
		tb_yx(dtube,radius,ang, prec)
			r(-90,0,-90) children();
}

module tb_yz (dtube=25,radius=100,ang=90, prec=24) {
	rotate([0,90,0]) 
		tb_yx(dtube,radius,ang, prec)
			rotate([0,-90,0]) 
				children();
}

module tb_zx (dtube=25,radius=100,ang=90, prec=24) {
	r(90)
		tb_yx(dtube,radius,ang, prec)
			rotate([-90,0,0]) children();
}

module tb_zy (dtube=25,radius=100,ang=90, prec=24) {
	r(0,90) rotz(90)
		tb_yx(dtube,radius,ang, prec)
			rotate ([0,0,-90]) 
				rotate([0,-90,0]) 
					children();
}

//------------------------------
module check () {
	if(dcheck)
		red()
			children();
}
