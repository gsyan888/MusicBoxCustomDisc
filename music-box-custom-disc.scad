//================================
//Music Box Disc Generator
//================================
//
//by gsyan ( https://gsyan888.blogspot.com/ )
//
//2021.01.06 start this project
//
//


//* [Global] */ 

//should print disc (false:only print note pins)
enableDiscBase = false;	

//just print calibration tools
calibrationMode = false;

//print a ring at the outermost
print_outter_ring = true;

//
//Disc Size
//
discHeight = 1;
discDiameter = 120;
discCenterHoleDiameter = 15;
discLockHoleDiameter = 4;
discLockHolePosition = 17.5;

//combe(teeth) width
combWidth = 30; 

// 
// pins size
//
pinDiameter = 1.25;
pinHeight = 1.5;

// pin bases size
pinBaseDiameter = 2.4;
pinBaseHeight = 0.4;

//the length of two pins
pinOffsetX = 1.37; //combWidth/tonesTotalNumber;


//the position of first pin 
positionOfTheFirstPin = 25-pinDiameter/4;


//the diameter of the outter ring(to hold all notes)
outter_ring_diameter = (positionOfTheFirstPin+combWidth+2)*2;


/* [Hidden] */ //don't touch below this line unless you need to adjust under the hood

//
//notes and comb teeth number mapping
//
//
//Note Nomenclature
//
//		Note	C	D	E	F	G	A	B
//Octave
//[3]			-1	-2	-3	-4	-5	-6	-7
//[4]			1	2	3	4	5	6	7
//[5]			10	20	30	40	50	60	70
//
//Others		
//				F4#		4.5
//				A4#		6.5
//				C5#		10.5
//				pause	0
//
notesIndexMap = [
 //note number, teeth number
 [0,          0],   //pause
 [-1        , 1],   //C3
 [-2        , 2],   //D3
 [-3        , 3],   //E3
 [-4        , 4],   //F3
 [-5        , 5],   //G3
 [-6        , 6],   //A3
 [-7        , 7],   //B3
 
 [1         , 8],    //C4
 [2         , 9],    //D4
 [3         ,10],    //E4
 [4         ,11],    //F4
 [4.5       ,12],    //#F4
 [5         ,13],    //G4
 [6         ,14],    //A4
 [6.5       ,15],  	 //#A4
 [7         ,16],    //B4
 
 [10        ,17],   //C5
 [10.5      ,18],   //#C5
 [20        ,19],   //D5
 [30        ,20],   //E5
 [40        ,21],   //F5
 [50        ,22],   //G5
 
];


//
//Music score example
//
//It's a small world
//
musicScore = [
	//1st. track
    [
3,4,
5,0, 30,0,
10,0, 20,10,
10,0, 7,0,
7,0, 2, 3,
4,0, 20,0,
7,0, 10, 7,
6,0, 5,0,
5,0, 3, 4,
5,0, 10, 20,
30,0, 20, 10,
6,0, 20, 30,
40,0, 30, 20,
5,0, 6,0,
6,0, 5,0,
3,0,0,0,
3, 0, 0, 0
    ],

	//2nd. track
    [
0,0,
-1, -5, -3, -5,
-1, -5, -3, -5,
-2, -5, -4, -5,
-2, -5, -4, -5,
-2, -5, -4, -5,
-2, -5, -4, -5,
-1, -5, -3, -5,
-1, -5, -1, -2,
-3, -5, -3, -5,
 1, -5, -7, -5,
-4,  1, -6,  1,
-4,  1, -6,  1,
 0, -5, 40, -5,
 0, -5,0,   -5,
-1, -5, -3, -5,
-1,, 0, 0, 0
    ]
];


//total number of tones
tonesTotalNumber = len(notesIndexMap)-1;

//find the tooth number (1-22) of the note
function getToothId(n) = lookup(n, notesIndexMap);

//
//convert notes id to teeth id 
//  and generate pins
//
module generatePins(notes) {
    notesTotal = len(notes);		//total number of notes
    offsetAngle = 360/notesTotal; 	//the angle to roate
    
    for(i=[0 :notesTotal-1]) {
        if(notes[i] != 0) {
            toothId = getToothId(notes[i]);
			
			radius = positionOfTheFirstPin+pinOffsetX*(toothId-1);
				
			a = offsetAngle*i;
			
			x = radius*cos(a);
			y = radius*sin(a);
		   
			translate([x, y, 0])
				rotate([0, 0, a])				
					union() {						
						//base
						if(!enableDiscBase) {
							translate([pinDiameter/2, pinDiameter/2, 0])
							cylinder(d=pinBaseDiameter, h=pinBaseHeight, $fn=12);
						}
						
						//pin
						translate([pinDiameter/2, pinDiameter/2, 0])
						cylinder(d=pinDiameter, h=pinHeight, $fn=36);
					}
		}
	}
}

//
//Generate the disc base
//
module generateDiscBase() {  
    difference() {
		//disc
        translate([0, 0, -discHeight])   cylinder(d=discDiameter, h=discHeight, $fn=100, center=false);
        
        //center hole
        translate([0, 0, -discHeight])  cylinder(d=discCenterHoleDiameter+0.1, h=discHeight, $fn=100, center=false);
        
        //lock hole
        translate([discLockHolePosition, 0, -discHeight])     cylinder(d=discLockHoleDiameter, h=discHeight, $fn=100, center=false);               
    }
}    


//outter ring for center aligment
module generateOutterRing() {
    translate([0, 0, 0.1])
    difference() {
        cylinder(d=outter_ring_diameter, h=0.2, $fn=100, center=true);
        cylinder(d=outter_ring_diameter-(print_outter_ring ? 0.86 : 0.001), h=0.2, $fn=100, center=true);
    }
}

//
module centerRingForCalibration() {    
    height = 2;
    diameter = 20;    
    difference() {
        union() {
            //center
            translate([0, 0, height/2])     cylinder(d=diameter, h=height, $fn=100, center=true);
            
            //bar holder
            translate([0, pinBaseDiameter/-2, 0])  cube([positionOfTheFirstPin-5, pinBaseDiameter, pinHeight]); 
            //pin base bar
            translate([0, pinBaseDiameter/-2, 0])  cube([60-2, pinBaseDiameter, pinBaseHeight]); 
        }                       
        //center hole
        translate([0, 0, height/2])  cylinder(d=15+0.1, h=height, $fn=100, center=true);
        
        //lock hole
        //translate([7.5+8-2, 0, height/2])     cylinder(d=4, h=height, $fn=100, center=true);
    }    
}
module calibrationPinsForCalibration() {
    for(i=[1 :tonesTotalNumber]) {
        toothId = i;          
        radius = positionOfTheFirstPin+pinOffsetX*(toothId-1);           
        a = 0;
        x = radius*cos(a);
        y = radius*sin(a);
        translate([x, y, 0])
            rotate([0, 0, a])
                union() {
                    //base
                    translate([0*pinBaseDiameter/2+pinDiameter/2, pinDiameter/2+0*pinDiameter/4, 0])
                    cylinder(d=pinBaseDiameter, h=pinBaseHeight, $fn=12);
                    
                    //pin
                    translate([pinDiameter/2, pinDiameter/2, 0])
                    cylinder(d=pinDiameter, h=pinHeight, $fn=36);
                }
    }
}
  
//  
//main module
//
module generateMusicBoxDisc() {
	if(calibrationMode) {
		centerRingForCalibration();
		calibrationPinsForCalibration(); 
		
	} else {
		for(i=[0 : len(musicScore)-1]) {
			generatePins(musicScore[i]);
		}
						
		if(enableDiscBase) {
			generateDiscBase();
		} else {
			generateOutterRing();
		}
		
	}	
}

//=========================================
// Start to generate the music box disc
//=========================================
generateMusicBoxDisc();



