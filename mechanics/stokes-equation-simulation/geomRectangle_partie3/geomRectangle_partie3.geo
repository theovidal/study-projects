Mesh.MshFileVersion = 2.2;
// definition du pas du maillage
h = 0.0125;
// definition des points (en 3D, raison pour laquelle il y a un 0 en z)
Point(1) = {0, 0, 0, h};
Point(2) = {3, 0, 0, h};
Point(3) = {3, 2, 0, h};
Point(4) = {0, 2, 0, h};
// definition des segments qui relient les points
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};
// definition des contours fermes
Line Loop(1) = {1,2,3,4};
// definition des surfaces a partir contours fermes
Plane Surface(1) = {1};
// definition des elements physiques : pour ces elements, nous pourrons recuperer
//									   les references 
Physical Point(1) = {1,2,3,4};
Physical Line(1) = {4};
Physical Line(2) = {1,3};
Physical Line(3) = {2};
Physical Surface(1) = {1};
