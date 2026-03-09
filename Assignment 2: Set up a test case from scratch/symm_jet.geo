SetFactory("OpenCASCADE");

// --- Dimensions ---
H_inlet = 0.0005; 
L_inlet = -0.01; 
Jet = 0.05;
H_main  = 0.1;  
L_main  = 0.5;  

// --- Points ---
Point(1) = {0, 0, 0};                   
Point(2) = {0, H_inlet, 0};             
Point(3) = {L_inlet, H_inlet, 0};       
Point(4) = {L_inlet, H_main, 0};        
Point(5) = {L_inlet + L_main, H_main, 0}; 
Point(6) = {L_inlet + L_main, 0, 0};  
Point(7) = {0 , H_main, 0};  
Point(8) = {L_inlet + L_main, H_inlet, 0};  

// --- Lines ---
Line(1) = {1, 2}; // Inlet
Line(2) = {3, 2}; // Wall 1
Line(3) = {3, 4}; // Wall 2 (Step)
Line(4) = {7, 5}; // Wall 3
Line(5) = {8 ,5}; // Outlet
Line(6) = {1, 6}; // Wall 4 (Bottom)
Line(7) = {2, 7}; // Wall 4 (Bottom)
Line(8) = {4, 7}; // Wall 4 (Bottom)
Line(9) = {6, 8}; // Wall 4 (Bottom)
Line(10) = {2, 8}; // Wall 4 (Bottom)
// --- 4. Surfaces (Corrected to use internal line) ---


//+
Curve Loop(3) = {10, -5, -4, -7};
//+
Surface(2) = {3};
//+
Curve Loop(5) = {3, 8, -7, -2};
//+
Surface(3) = {5};
//+
Curve Loop(7) = {10, -9, -6, 1};
//+
Surface(4) = {7};
// ========== 1. DOMAIN DISCRETIZATION (TRANSFINITE) ==========
// We balance the nodes so the background grid is healthy.
// Vertical: Inlet(1) + Step(3) must equal Outlet(5)

  Transfinite Curve {8} = 20 Using Progression 0.85; 
  Transfinite Curve {2} = 20 Using Progression 0.85; 
Transfinite Curve {3} = 200 Using Progression 1.01;  
 Transfinite Curve {7} = 200 Using Progression 1.01;  
 Transfinite Curve {5} = 200 Using Progression 1.01;  

 Transfinite Curve {4} = 300 Using Progression 1.01;

 Transfinite Curve {1} = 5;
 Transfinite Curve {9} = 5;
 Transfinite Curve {10} = 300 Using Progression 1.01;
 Transfinite Curve {6} = 300 Using Progression 1.01;
  
Transfinite Surface {3};
Transfinite Surface {2};
Transfinite Surface {4};
Recombine Surface "*";

// ========== 2. ADD INFLATION (BOUNDARY LAYER) ==========

Field[1] = BoundaryLayer;

Field[1].CurvesList = {6}; // Apply to all walls

Field[1].hwall_n = 0.0001;           // First layer height

Field[1].ratio = 1.0;               // Growth

Field[1].thickness = 0.0003;          // Total inflation thickness

// Activate the field

//BoundaryLayer Field = 1;



// --- Mesh Settings ---
Mesh.RecombineAll = 1; 
// Mesh.Algorithm = 2; // Frontal-Delaunay handles BL fields best

// --- Physical Groups ---
Physical Curve("inlet") = {1};
Physical Curve("outlet") = {5, 9, 3, 4, 8};
Physical Curve("wall") = {2};
Physical Curve("symmetric") = {6};
Physical Curve("internal") = {7, 10};
Physical Surface("fluid") = {4 ,2, 3};

//+
Coherence;



