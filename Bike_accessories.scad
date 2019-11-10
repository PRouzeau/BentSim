//Bike wheel and fenders modelisation, as extracted from Velassi simulation
// Copyright 2019 Pierre ROUZEAU AKA PRZ
// Program license GPL 4.0
// documentation licence cc BY-SA 3 and GFDL 1.2
// First version: 0.0 - November 2018
// To work, this module requires my OpenSCAD library, attached, but you can find details here:
// https://github.com/PRouzeau/OpenScad-Library

//dcheck = false;

include <Z_library.scad>
/* test 
wheel();
fender(wire_space=135);
//*/

glass_color = [128,128,128,32]/256;
// transparent

function tire_diam (rim=559, tire=40) = rim+2*tire+4;
//-- spoked wheel ---------------------
module wheel (rim=559, tire=40, hubdia=60, hubwidth=60, spa=7.5, spoke_nbr=36, shaft_width = 140, clr_rim= [0.8,0.8,0.8], clr_tire=[0.4,0.4,0.4]) {
	wh_d=rim+2*tire+4; 
	//echo ("wheel diam",wh_d);
	spd = 2.2; // spoke diameter
	spr = hubdia/2+8; // spoke radius
	echo (spoke_nbr = spoke_nbr);
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
} //wheel

//- Fenders / Mudguards ------
//if front_angle = 0, no mudguard
//angle 0 = horizontal
//w_width is width of attach point of wire supports, if 0, there is no support, which is located on rear, at 8 deg from start
module fender (wheel_rim = 559, tire_w = 47, front_angle=8, rear_angle=170, wire_space=110, clr_fender="black") {
	fender_dia = tire_w+26;
	angtot = rear_angle-front_angle;
	echo (angtot=angtot);
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

//== Rans recumbent seat ==========
module rans_seat (s_ang=45, fold=0, width=380, sflag=true, light_color="black"){
	dt = 22; // frame tube diameter
	//cubez (500,500,1,0,0,700); //check height
	cx=-6; cz=112; // rotation centre at hip
	prec = 12;
	module PRZsign() {
		linear_extrude(height=2, center=true)
									import(file="signature_PRZ_cut.dxf");
	}
	
	t(cx,0,cz)
	mirrorx()
	r(0,s_ang) 
	t(cz,0,-cx)
	t(30,0,10) r(0,-79) {
		
	scale ([1,width/380,1])
	black()
		hull() {
			cylz (20,1, 85,0,0, prec);
			cylz (30,1, 85,0,-10, prec);
			dmirrory()
				cylz (20,10, 0,28,0, prec);
		}
	t(-174,0,155) {
		red()
			cyly(-3,500, 0,0,0, prec);
		r(0,-fold) {
			t(-70,0,515) {
				if (light_color) 
				t(-75)
					r(0,78-s_ang) {
						rear_light(light_color);
						dmirrory() 
							silver()
								cubez(3,15,-38, 10,25,20);
					}
			//flag
			if(sflag) t(-20,-190,75)
				r(0,15) {
					//pole
					silver() {
						cyly(-22,10, -9,0,-50, 12);
						cylz(6,1400, -9,0,-50,6);
					}
					//flag
					t(0,0,1350){
						color("OrangeRed") 
							hull() {
								cylz(2,-160, -12,0,0,4);
								cylz(2,2, -250,0,0, 4);
							}
					//Signature (PRZ)
						t(-108,2, -88)
						r(90) color("lime") 
							scale([3.2,3.2,1]) {
								PRZsign();
								t(25,-3,4)
									r(0,180)
										PRZsign();
							}
					}
				}
			}
		}
	}
	gray()
	dmirrory() 
		tb_yx(dt,-75,48, prec)
		cyly(dt,85, 0,0,0, prec)
		r(0,-90)
		tb_yx(dt,75,45, prec)
		cyly(dt,57.6, 0,0,0,prec) {
			r(28,26)
				cylz(15,150, 0,0,0, prec)
				tb_zx(15,250,6, prec);
			tb_yx(dt,75,45, prec)
			cyly(dt,40, 0,0,0, prec)
			r(0,41.8)
			rotz(fold) {
				//back
				cyly(dt,40, 0,0,0, prec) {
					r(0,-48)
					*cylx(dt,wd/2, 0,0,0,4); // check width
					tb_yx(dt,-500,20, prec)
					cyly(dt,30, 0,0,0, prec)
					tb_yx(dt,500,3, prec) {
						//medium transversal bar
						r(0,67.5) 
						t(0,0,-4)
						tb_xz(12,508,22.5, prec);
						tb_yx(dt,500,17, prec)
						cyly(dt,30, 0,0,0, prec)
						tb_yx(dt,-120,30, prec)
						cyly(dt,20, 0,0,0, prec){
							cyly(dt,20, 0,0,0, prec);
							//top transversal bar
							r(0,67.5) 
							t(0,0,-4)
							tb_xz(12,508,22.5, prec);
						};
					}
				}
			}
		}
	}
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
	//on fork
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
	//echo("bend");
	sang = radius<0?ang:-ang;
	dx=-(1-cos(sang))*-radius;
	dy=sin(sang)*-radius;
	t(radius)
		rotate_extrude(angle=sang, $fn=48, convexity=10)
			translate([-radius,0,0])
				circle(d=dtube, $fn=prec);
	t(dx,dy) rotz(sang) children();
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
	r(0,90) 
		tb_yx(dtube,radius,ang, prec)
			r(0,-90) children();
}

module tb_zx (dtube=25,radius=100,ang=90, prec=24) {
	r(90)
		tb_yx(dtube,radius,ang, prec)
			r(-90) children();
}

module tb_zy (dtube=25,radius=100,ang=90, prec=24) {
	r(0,90) rotz(90)
		tb_yx(dtube,radius,ang, prec)
			rotz(-90) r(0,-90) children();
}

//------------------------------
module check () {
	if(dcheck)
		red()
			children();
}
