//Seats, lights, Bike wheel and fenders modelisation are extracted from Velassi simulation (Velassi not published)
// Copyright 2018-2020 Pierre ROUZEAU AKA PRZ
// Program license GPL 4.0
// documentation licence cc BY-SA 3 and GFDL 1.2
// First version: 0.0 - November 2018
//Feb 2020: Add ICE mesh seat, Hardshell seat, corrected Rans seat frame width
//Dec 2020: Corrected hardshell viewing artifacts 
// To work, this module requires my OpenSCAD library, attached, but you can find details here:
// https://github.com/PRouzeau/OpenScad-Library

//dcheck = false;

include <Z_library.scad>

//== Test of the accessories ============
//Testing seat
test_seat = 0; //[0:no seat view, 1:Rans mesh, 2:ICE mesh, 3: Hardshell, 9:Saddle]
//Seat angle
  seat_a = 50; // [15:85]
//Flag attached to seat
  seat_f=true;
//Rear light attached to seat
  seat_l=true;
  
//Testing wheel
test_wheel = 0; //[0:no wheel, 1:Symetrical wheel, 2:Wheel hub offset, 3:Radial spokes, 4:Disc wheel, 5:Wheel with fender]
spoke_test = 32; // [0,3,4,5,6,8,20,24,28,32,36,42]

//Testing fork
test_fork = 0; //[0:No fork, 1:Rigid fork, 2:Suspended fork, 3:Experimental Lefty, 4:User fork]
//test viewing handlebar

//Testing handlebar
test_hdl = 0; // [0:none, 1:Trike direct, 2:Cruiser 400mm long, 6:Cruiser flat 80 mm, 3:Hamster, 4:U Bar, 5:Underseat U bar with center bend]

if (test_seat)
  b_seat(test_seat,seat_a,0,seat_f?1000:0, seat_l?"black":"");

if (test_wheel==1)
  wheel(spoke_nbr=spoke_test);
else if (test_wheel==2)
  wheel(hub_offset=10, hubdia=28, spa=10);
else if (test_wheel==3)
  wheel(hub_offset=0, hubdia=28, spa=0, spoke_nbr=28, tire=25);
else if (test_wheel==4)
    wheel(spoke_nbr=0);
else if (test_wheel==5) {
  wheel(hub_offset=0, hubdia=60, spa=10.6, spoke_nbr=32);
  fender(wire_space=110, rear_angle=195, front_angle=75);
}
  
//test viewing wheel
if(test_fork) {
 caster_angle=12;
 perp_axis_offset=40;
 fwheel_hdia=320;
 steerer_tube_length=200; 
  
  fork(test_fork-1,0,400,fwheel_hdia,caster_angle,perp_axis_offset,100,steerer_tube_length,clrf="#404040");
}  
//Test handlebar
hdla = test_hdl==5?-110:test_hdl==4?40:test_hdl==1?10:50;
hdl_typ = test_hdl==6?1:test_hdl==5?3:test_hdl-1;
if(test_hdl)
  handlebar(hdl_typ, stem_length=test_hdl==1?90:test_hdl==4?-80:40,stem_ang=test_hdl==4?-15:15, hdl_ang=hdla, hdl_lg=test_hdl==6?80:400, hdl_centbend=test_hdl==5?30:0,hdl_centor=test_hdl==5?60:0);

//Transparent color
glass_color = [128,128,128,32]/256;


flag_img = "Library/flag_image.dxf";
flag_scale = 3.2;

function tire_diam (rim=559, tire=40) = rim+2*tire+4;
//-- spoked wheel ---------------------
//add parameter to simulate single and double spoke crossing for small wheels
module wheel (rim=559, tire=40, hubdia=60, hubwidth=60, spa=7.5, spoke_nbr=36, shaft_width = 140, clr_rim= [0.8,0.8,0.8], clr_tire=[0.4,0.4,0.4], hub_offset=0) {
	wh_d=rim+2*tire+4; 
	//becho("wheel diam",wh_d);
	spd = 2.2; // spoke diameter
  //spokes faces
  spf = 6;
	spr = hubdia/2+5; // spoke radius
	//becho("spoke_nbr", spoke_nbr);
	rpt_spoke = spoke_nbr/4;
	spoke_ang = 360/rpt_spoke;
  radial = (spa==0) || (spoke_nbr<20);
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
		cyly(-hubdia,hubwidth, 0,hub_offset);
    t(0,hub_offset)
  //flanges
    if(spoke_nbr>=20)  
      dmirrory()
        cyly(hubdia+20,3, 0,hubwidth/2-3);
	//spokes
		lgspoke = rim/2-(spa?10:hubdia/2+15);
		spangle = atan((hubwidth/2+2+hub_offset)/lgspoke);
		spangle2 = atan((hubwidth/2-5+hub_offset)/lgspoke);
    spangle3= atan((hubwidth/2+2-hub_offset)/lgspoke);
		spangle4 = atan((hubwidth/2-5-hub_offset)/lgspoke);
    t(0,hub_offset)
      if(!radial)
        droty(spoke_ang,rpt_spoke-1){
         // first side 
          r(0,-spa) rotz(-spangle)
            cylx(spd, lgspoke, 0,hubwidth/2+1,spr,spf);
          r(0,spa+30) rotz(-spangle2)
            cylx(spd, lgspoke, 0,hubwidth/2-5,-spr,spf);
          // other side
          r(0,360/spoke_nbr) {
            r(0,-spa) rotz(spangle3)
              cylx(spd, lgspoke, 0,-hubwidth/2-1,spr,spf);
            r(0,spa+30) rotz(spangle4)
              cylx(spd, lgspoke, 0,-hubwidth/2+5,-spr,spf);
          }
        }
      else //radial spokes
        if(spoke_nbr>=20)
          droty(spoke_ang*0.5,rpt_spoke*2-1){
            t(0,hubwidth/2+1,spr)
              rot(spangle)
                cylz(spd, lgspoke, 0,0,0, spf);
            r(0,360/spoke_nbr)
              t(0,-hubwidth/2-1,spr)
                rot(-spangle)
                  cylz(spd, lgspoke, 0,0,0, spf);
        }
        else
          droty(spoke_ang*0.25,spoke_nbr-1)
            hull() {
              cylz(45,0.01);
              scale([1,0.3,1])
                cylz(60*pow(0.9,spoke_nbr),0.01, 0,0,lgspoke+spr);
            }
	}
	else 
		// no spoke gives plain wheel
		hull() {
			cyly(-hubdia-35,hubwidth+12, 0,hub_offset,0, 48);
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
		supy = wire_space/2;
		ags = -atan((supy-tire_w/2-3)/(wheel_dia/2-20));
		if(wire_space) 
			silver() 
				r(0,-rear_angle+20)
					dmirrory()
						t(15,supy,-4)
							rotz(ags)
								cylx(4,wheel_dia/2-16, 0,0,0, 6);
	}
}

module seat_light (x=-70,z=515,s_ang, light_color, vert_ext = 80) {
  if(light_color)
  mirrorx()
	t(x,0,z+42) {
		if(light_color) 
		t(-75)
			r(0,79-s_ang) t(-10,0,vert_ext){
				rear_light(light_color);
				dmirrory() 
					silver()
						cubez(3,15,-20-vert_ext, 10,25,20);
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
      mirrorx()
			seat_light(-60,455,s_ang,light_color, 60);
			//flag
			if(sflag) t(-110,-175,540) 
				r(0,50-s_ang) flag();
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
		cyly(-22,10, 0,0,0, 12);
		cylz(6,lg, 0,0,0, 6);
	}
	//flag
	t(12,0,lg){
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
				t(0,0,4)
					imp_img(imgfile);
			}
	}
}

//== ICE recumbent mesh seat ======
//ICE frame designed from photo, so accuracy may be limited
module ICE_seat (seat_angle=45,width=380, sflag=true, light_color="black") {
	prec= 12;
	dt = 25.4;
	wd = width-dt;
	module cxl(d,l) {
		cylx (d,l,0,0,0,prec)
			children();
	}
	module transv(dx=0) {
		t(dx)
		//render()
			r(45)
				cyly(dt-1,-60, 0,0,0, prec)
					tb_yz(dt,-50,-45, prec)
						//t(0,0.1) // stop CGAL error
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
			seat_light(-370,375,seat_angle+26,light_color, 60);
			//-- seat -------------------
			color("gray")
			mirrorx() 
				//render()
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
		if(sflag) t(410,-wd/2,525)
			r(0,-25+seat_angle,0) rotz(180) flag();
		} //r, t
	} // -t
}

module hardshell_seat (seat_angle=45,wd=300, sflag=true, light_color="black", thk = 16) {
	$wd = wd;
	$prec=64;
	reinf_dist = 80;
	
	module shape (wd=$wd,mirr=true) {
    u() {
      hull() {
        dmirrory(mirr)
          t(0,wd/2-thk/2)
            circle (d=thk, $fn=12);
        if(!mirr)
          square([thk,thk],center=true);
      }
      dmirrory(mirr)
        hull() {
          t(25,reinf_dist)
            circle (d=25, $fn=12);
          t(5,reinf_dist)
            square ([25,25],center=true);
        }
    }  
	}
	
	module rshp (radius=100,ang=90, wd=$wd,mirr=true) {
		sang = radius<0?ang:-ang;
		dx = (1-cos(sang))*radius;
		dy = sin(sang)*-radius;
		t(radius)
			rotate_extrude(angle=sang, $fn=$prec, convexity=4)
				translate([-radius,0,0])
					shape(wd,mirr);
		t(dx,dy-0.1) 
      rotz(sang) 
        mirrorz()children();
	}
	
	module srt (a=-25,wd=$wd) {
		diff() {
      tslz(-sign(a)*wd/2)
        r(a)
          tslz(sign(a)*wd/2)
            children();
			//::::::::::::
			cubey(99,-199,999);
			cubez(99,399,sign(a)*399, 0,99);
		}
	}
	//Convexity 4 required to eliminate viewing artifacts
	module tshp (lg,wd=$wd,mirr=true) {
		r(-90) 
      linear_extrude(height=lg,center=false, convexity=4)
        shape(wd,mirr);
		t(0,lg-0.1)
			children();
	}
//------------------	
	cx=-6; cz=112; // rotation centre at hip
//---------------------------

 t(cx,0,cz) {
	//red() cyly(-5,600);

  r(0,-seat_angle+60)
  t(-cx,0,-cz)
  t(-130,0,-10) {
    //-- rear light ---------------
    seat_light(-415,540,seat_angle+19,light_color, 25);
    //-- flag ----
    if(sflag) 
      mirrorx()
        t(-492,-97,590) 
          r(0,-seat_angle+32) flag();  
    // shell
    gray()
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
        //headrest cut
        dmirrorz()  
          t(-200,680,100)
            rotz(60)
              r(-21)
                cubez(199,399,399);
      //Base nose cut 
        dmirrorz() 
          t(40,60,90)
            rotz(-30)
              r(40)
              cubez(88,255,99, 0);
      }
	}
 }
}

module b_seat (type=2,s_ang=55,fold=0, sflag=1000, light_color="black", wd=380){
	if(type==1) //rans mesh
		rans_seat(s_ang, fold, wd, sflag, light_color); 
	else if(type==2) //ICE mesh
		ICE_seat(s_ang, wd, sflag, light_color); 
	else if(type==3) //Hard shell
		hardshell_seat(s_ang, 300, sflag,light_color); 
	else if (type==9) //saddle
    tslz(15)
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
	if(light_color)
		t(-100,0,-60) {
			rear_light(light_color);
			black()
				dmirrory() {
					cubez(2.5,15,25, 9,25,10);
					cubex(20,15,2.5, 9,25,34);
				}
		}
}

//== SHOCK  with eyes ==============
//Dist = length eye to eye without compression, travel = compression travel, sag = compression at nominal load {~20% of travel)
module shock (dist = 190, travel=50, sag=10) {
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

//== FORK ===========================
//Fork parameters:style= fork type, stro = steering rotation angle, flg = perpendicular distance between bearing bottom and wheel axis, casta = caster_angle, pao = perpendicular axis offset, fwhd = wheel hald diameter, stl= steerer tube length, stb = steering bottom bearing height space, htb = header tube height, clrf= fork color

module fork (style=0, stro=0, flg=380, fwhd=325,  casta=18, pao=47, OLD=100, stl = 180, stb=5, htb=115, clrf = "black") {
  steerdia = 28.6;
	rad = 125; //dropout bend radius
  toprad = 100; //top bend radius
	//pao = perp_axis_offset;
	sgn = sign(pao);
	fang = acos((rad-abs(pao))/rad);
	//fwhd = fwheel_hdia;
  //move to wheel center and tilt of caster_angle value 
	t(0,0,fwhd) 
		r(0,casta)
			t(pao) rotz(stro) t(-pao){
        if (style==3) //User programmed fork 
          user_fork1(); 
        else if (style==2) //Experimental lefty
          xlefty();
        else if (style==1) //suspended fork 
          stsusp();
        else
          st();
        //steerer tube
        gray()
          cylz(steerdia,stl, pao,0,flg);
      }  
  //rigid fork - bent dropout style
  module st () {
    lgstr = flg-88-rad*sin(fang);
    hhang = atan((8+OLD/2-50)/lgstr);
    color(clrf)
    mirrorx(pao<0)
      dmirrory() {
        t(0,OLD/2+4,0)
          diff() {
            r(hhang)
              r(0,fang-90) 
                tb_xz(24,rad,-fang)
                  cylx(24,lgstr)
                    tb_xy(24,-toprad,-60);
            //:::::::::::::
            cyly(-24,66);
          } 
        cyly(-32,8, 0,OLD/2+4);  
      }     
    color(clrf)
      cylz(steerdia+5,-40, pao,0,flg);
  }
  //suspended fork
  module stsusp () {
    tubsp = 106;
    tubdia = 28;
    postube = pao-sign(pao)*20;
    dmirrory() {
      color(clrf) {
        cylz(tubdia+15,250, postube,tubsp/2,5);
        hull() {
          cylz(steerdia+15,-40, pao,0,flg);
          cylz(tubdia+12,-40, postube,tubsp/2,flg-20);
        }
        hull() {
          cyly(-32,8, 0,OLD/2+4);  
          cylz (12,50, postube,tubsp/2,5); 
        }  
      }  
      silver()
        cylz(tubdia,flg-60, postube,tubsp/2,20);
    }
  }
  // Experimental 'lefty' fork
  module xlefty (sideoff=-60, shock_ang=-38) {
    //stb = steer_bbht==undef?5:steer_bbht;
    //htb = head_tube_height==undef?stl-50:head_tube_height;
    harm_ang = 15; // articulated arm angle from horizontal
    hang = -casta+harm_ang;
    bang=32;  
    armlg = -220; // axis to axis arm length
    sa = sign(armlg);
    vrad = 200;
    vdia=50;
    // first length segment calc
    xar = armlg*cos(hang);
    xb=(1-cos(bang))*vrad*sa;
    stlg = (xar-xb-pao)/sin(bang);
    //top segment
    yar = armlg*sin(hang);
    yb = sin(bang)*vrad;
    vlgb = flg+yar-yb-sa*stlg*cos(bang);
    vlg = vlgb+2*stb+htb+20;
    //Attach to pivot
    module side_plate () {
      hull() {
        cylz(vdia+12,-8, pao);
        cylz(40,-8, pao,-sideoff);
      }
    }
    
    //Bottom tube segment
    silver() 
      cylz(28.6,-10, pao,0,flg-8);
    // fork
    t(0, sideoff) {
      color(clrf) {
        cyly(-18,60);  
        r(0,hang) {
          //arm
          cylx(50,armlg+sa*40,-sa*20)
          cyly(-18,60,-sa*20);
          //support tube
          t(armlg) {
            diff() {  
              r(0,-sa*bang-hang-90)
                cylx(vdia,sa*stlg-30,30)
                tb_xz(vdia,-sa*vrad,-bang)
                cylx(vdia,vlg)
              ;
             //::::::::::::::: 
              r(0,sa*15)
                cylx(-80,166);
            }
            //arm axis fork
            mirrorx (sa<0)
            hull() {
              cyly(-30,80);
              r(0,15)
              diff() {
                cylx(-80,87, -35);
                //::::::::::::
                cubez(222,111,-111, 0,0,10);
                r(0,40)
                  cubez(222,111,-111, 0,0,-20);
                cylx(-70,222);
              }  
            }
          }
        } 
      } 
      //shafts
      gray() { 
        cyly(-14,70);  
        r(0,hang)
        cyly(-14,90, armlg);
      }  
      // Attach plates 
      color(clrf) {
        tslz(flg)
          side_plate();
        tslz(flg+2*stb+htb)
          mirrorz()
            side_plate();
      }
      //shock
      r(0,hang)
        t(armlg*0.6,0,40) {
          r(0,-90+sa*harm_ang+sa*shock_ang) {
            shock(190,50,15);
            color(clrf)
            mirrorz(sa<0)
              dmirrory() 
                t(190-15)
                  hull() {
                    cyly(28,5, 0,12);
                    cubey(60,5,1, 16,12,-45);
                  }
          }  
        color(clrf)
          dmirrory() 
            hull() {
              cyly(28,5, 0,12);
              cubey(60,5,1, 0,12,-30);
            }
      }  
    } // sideoff
  } //xlefty
} //fork

//== Handlebar ======================
module handlebar (hdl_type=0, stem_length=40,stem_height=40,stem_ang=15,hdl_ang=60,hdl_lg=400,hdl_bend=37.5, hdl_width_central_extent=0,
hdl_centbend=0,hdl_centor=0,hdl_lg2=200, dcheck=false, d_line=1) {
	//sgo = sign(stem_length);
  sgo = stem_length>0?1:-1;
	//stem_ang = OSS_handlebar?20:0;
	sto = sign(stem_height)*27; // stem shaft axis offset
	//depending its length 'cruiser' handlebar go from chopper type to near flat mountain bike bar through town type.
		crui_a = hdl_lg>150?90:20+(hdl_lg-50)*0.70;
	if (dcheck)
		red()
			cubez(d_line,666,555);
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
						if(hdl_type==0){ //trike direct
							cylz(22,10)
							cylz(30,120);
						}
						else if(hdl_type==1){ //cruiser
							cyly(22,40)
							tb_yz(22,-70,crui_a)
							r(0,-20)
							cyly(22,abs(hdl_lg-140))
							tb_yz(22,70,crui_a)
							cyly(22,10)
							cyly(32,120);
						}
						else if(hdl_type==2) { // Hamster
							cylz(22,hdl_lg)
							tb_yx(22,80,18)
							cyly(22,40)
							cyly(30,120);
						}
						else if(hdl_type==3) { //U Bar
						// if handlebar length = 420, this is a metabike Ubar
              centpart = hdl_width_central_extent>0||hdl_centbend; // if true, central bent part
              cyly(25,30)
              cyly(25,hdl_width_central_extent/2)
              r(0,hdl_centor)
							tb_yx(25,50,hdl_centbend/2)
              r(0,-hdl_centor)
              cyly(25,centpart?120:0)
              cyly(22,centpart?27:147)
							tb_yx(22,50,80)
							cyly(22,hdl_lg-270)
							r(0,90)
							tb_yx(22,50,hdl_bend)
							cyly(22,(hdl_lg2-120)/2)
							cyly(30,120)
							cyly(22,(hdl_lg2-120)/2);
						}
				}
			}
}

//== Lighting ======================
module rear_light (clr="black", z=15) {
	//light
  tslz(z) {
    color(clr)
    hull() dmirrory() {
      cylx(45,-10, 0,30);
      cylx(30,8, 0,30);
    }
    red()
      hull() dmirrory() 
        cylx(44,10, -20,30);
    color(glass_color)
      hull() dmirrory()
        cylx(44,2, -22,30);
  } 
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