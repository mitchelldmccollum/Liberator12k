//
// Pipe dimensions
//
PipeInnerDiameter   = 1; // Inner Diameter of pipe, smallest measurement if asymmetrical
PipeOuterDiameter   = 2; // Outer Diameter of pipe, largest measurement if asymmetrical
PipeTaperedDiameter = 3; // Threads are tapered, smallest measurement if asymmetrical
PipeThreadLength    = 4; // Total length of the pipe thread
PipeThreadDepth     = 5; // Depth when fully seated
PipeClearanceSnug   = 6; // Added to the diameter, should not slip
PipeClearanceLoose  = 7; // Added to the diameter, should slide freely
PipeFn              = 8; // Number of sides
PipeWeightPerUnit   = 9;

function PipeClearance(pipe, clearance)     = (clearance != undef) ? lookup(clearance, pipe) : 0;
function PipeOuterDiameter(pipe, clearance) = lookup(PipeOuterDiameter, pipe) + PipeClearance(clearance);
function PipeInnerDiameter(pipe, clearance) = lookup(PipeInnerDiameter, pipe) + PipeClearance(clearance);
function PipeOuterRadius(pipe, clearance)   = PipeOuterDiameter(pipe, clearance)/2;
function PipeInnerRadius(pipe, clearance)   = PipeInnerDiameter(pipe, clearance)/2;
function PipeWall(pipe)                     = PipeOuterRadius(pipe) - PipeInnerRadius(pipe);
function PipeFn(pipe)                       = lookup(PipeFn, pipe);

module Pipe(pipe, length = 1, clearance=undef) {
  cylinder(r=PipeOuterRadius(pipe, clearance=clearance), h=length, $fn=lookup(PipeFn, pipe));
};

//Pipe(PipeOneInch, clearance=PipeClearanceLoose);


// 1/4" Pipe
PipeOneQuarterInch = [
  [PipeInnerDiameter,   0.265],
  [PipeOuterDiameter,   0.415],
  [PipeTaperedDiameter, 0.415], // TODO: Verify
  [PipeThreadLength,    0.5],   // TODO: Verify
  [PipeThreadDepth,     0.25],  // TODO: Verify
  [PipeClearanceSnug,   0.015], // TODO: Verify
  [PipeClearanceLoose,  0.027], // TODO: Verify
  [PipeFn,              20],
  [PipeWeightPerUnit,   0] // TODO
];

// 12GaugeChamber - 12ga Chamber tolerances are much pickier than ERW pipe
12GaugeChamber = [
  [PipeInnerDiameter,   0.78],
  [PipeFn,              30]
];

// 3/4" Pipe
PipeThreeQuartersInch = [
  [PipeInnerDiameter,   0.81],
  [PipeOuterDiameter,   1.07],
  [PipeTaperedDiameter, 1.018],
  [PipeThreadLength,    0.9],
  [PipeThreadDepth,     0.5],
  [PipeClearanceSnug,   0.005],
  [PipeClearanceLoose,  0.027],
  [PipeFn,              30],
  [PipeWeightPerUnit,   40]
];

// 1" Pipe
PipeOneInch = [
  [PipeInnerDiameter,   1.06],
  [PipeOuterDiameter,   1.315],
  [PipeTaperedDiameter, 1.285],
  [PipeThreadLength,    0.982],
  [PipeThreadDepth,     0.5], // TODO: Verify
  [PipeClearanceSnug,   0.02],
  [PipeClearanceLoose,  0.03],
  [PipeFn,              30],
  [PipeWeightPerUnit,   0] // TODO
];


// Fittings: Tee
TeeOuterDiameter = 1; // Diameter of the body, not the rim
TeeWidth         = 2; // Across the top of the tee, side-to-side
TeeHeight        = 3; // From the middle of the bottom rim to the top of the body
TeeInnerDiameter = 4; // Diameter of the threaded hole
TeeRimDiameter   = 5; // Diameter of the tee rim
TeeRimWidth      = 6; // Width of the tee rim
TeeInfillSphere  = 7; // Diameter of the infill sphere, cuts out the casting infill between the tee sections
TeeInfillOffset  = 8; // Offset for the infill sphere from center

TeeThreeQuarterInch = [
  [TeeOuterDiameter, 1.40],
  [TeeWidth,         2.64],
  [TeeHeight,        2.07],
  [TeeInnerDiameter, 0.88],
  [TeeRimDiameter,   1.54],
  [TeeRimWidth,      0.31],
  [TeeInfillSphere,  0.10],
  [TeeInfillOffset,  0.41]
];

function TeeOuterDiameter(tee) = lookup(TeeOuterDiameter, tee);
function TeeOuterRadius(tee)   = lookup(TeeOuterDiameter, tee)/2;
function TeeWidth(tee)         = lookup(TeeWidth, tee);
function TeeHeight(tee)        = lookup(TeeHeight, tee);
function TeeInnerDiameter(tee) = lookup(TeeInnerDiameter, tee);
function TeeInnerRadius(tee)   = lookup(TeeInnerDiameter, tee)/2;
function TeeRimDiameter(tee)   = lookup(TeeRimDiameter, tee);
function TeeRimRadius(tee)     = lookup(TeeRimDiameter, tee)/2;
function TeeRimWidth(tee)      = lookup(TeeRimWidth, tee);
function TeeCenter(tee)        = lookup(TeeHeight, tee) - TeeOuterRadius(tee);

module Tee(tee, $fn=40) {
   union() {

     // Top Body
     rotate([0,-90,0])
     translate([TeeHeight(tee) - (TeeOuterDiameter(tee)/2),0,0])
     cylinder(r=TeeOuterRadius(tee), h=TeeWidth(tee) * 0.99, center=true, $fn=36);

     // Bottom Body
     translate([0,0,TeeCenter(tee) * 0.01])
     cylinder(r=TeeOuterRadius(tee), h=TeeCenter(tee) * 0.98, $fn=36);

     // Bottom Rim
     cylinder(r=TeeRimRadius(tee), h=TeeRimWidth(tee), $fn=36);


    // Rims
    for (i = [1, -1]) {

      // Rim
      translate([i*TeeWidth(tee)/2,0,TeeCenter(tee)])
      rotate([0,i*-90,0]) {
      cylinder(r=TeeRimRadius(tee), h=TeeRimWidth(tee), $fn=36);

      // Casting Infill
      translate([0,0,TeeRimWidth(tee)])
      cylinder(r1=TeeRimRadius(tee),
               r2=TeeOuterRadius(tee),
                h=TeeRimWidth(tee)*1/4,
                $fn=36);
      }
    }

    // Tee Body Casting Infill
    // TODO: Tweak this? Could be better, could be worse.
    intersection() {
      translate([0,0,TeeCenter(tee) + lookup(TeeInfillSphere, tee)])
      sphere(r=TeeRimRadius(tee) + lookup(TeeInfillOffset, tee), $fn=36);

      translate([-TeeRimRadius(tee),-TeeOuterRadius(tee),0])
      cube([TeeRimDiameter(tee),TeeOuterDiameter(tee),TeeCenter(tee)]);
    }
   }
};

//Tee(TeeThreeQuarterInch);

module TeeRim(tee=TeeThreeQuarterInch, height=1, clearance=0) {
  cylinder(r=TeeRimRadius(tee) + clearance, h=height, $fn=36);
}

// Fittings: Bushings
BushingHeight    = 1;
BushingDiameter  = 2;
BushingDepth     = 3; // Bushing screws in about half an inch
BushingCapWidth  = 4;
BushingCapHeight = 5;


// 3/4" Bushing
BushingThreeQuarterInch = [
  [BushingHeight,    0.955],
  [BushingDiameter,  1],
  [BushingDepth,     0.5],
  [BushingCapWidth,  1.225],
  [BushingCapHeight, 0.215]
];

function BushingHeight(bushing) = lookup(BushingHeight, bushing);
function BushingDepth(bushing) = lookup(BushingDepth, bushing);

module Bushing(spec=BushingThreeQuarterInch) {

  od        = lookup(BushingDiameter, spec);
  height    = lookup(BushingHeight, spec);
  capWidth  = lookup(BushingCapWidth, spec);
  capHeight = lookup(BushingCapHeight, spec);

  union() {

    // Body
    translate([0,0,capHeight/2])
    cylinder(r=od/2, h=height - (capHeight/2), $fn=20);

    // Head
    cylinder(r=capWidth/2, h=capHeight, $fn=6);
  }
}