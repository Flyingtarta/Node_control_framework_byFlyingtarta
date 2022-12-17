/*
	Description 
		Script that initializas all the nodecontrol framework 

	INPUT:
		0: (number) maxdistance between nodes to be connected 
		1: (number) Minutes | How long before the mission ENDS 
		2: (number) Size of the capturable area

	output:
		none 

*/


params [
	["_max_line", 1000],
	["_duration", 60],
	["_areasize", 250]
];

if (hasInterface) then { [] spawn nsn_fnc_NC_initPlayer};

if !(isServer) exitwith {};
/*
	From here all code is executed on the server only 
*/
node_endtime = servertime + (_duration*60);
publicVariable "node_endtime";

private _nodos_mk = allMapMarkers select {"node" in _x};  //find the markers with the "node" keyword in the name 
if (_nodos_mk isequalto []) exitwith {systemChat "ERROR | There is no nodes "};
private _nodos = [];
/*
	This code uses the marker as reference to create the nodes 
*/
{
	_nodo = _x; 
	_isbase = "base" in markerText _nodo; //if its defined as "base" wont be captureble 
	_nodo_logic = createVehicle ["Land_HelipadEmpty_F",getMarkerPos _nodo ,[],0,"NONE"]; //create an object
	_pos = getpos _nodo_logic;
	_owner = sideUnknown;
	_name = _nodo;
	if ("WEST" in getMarkerColor _x ) then { _owner = west};
	if ("EAST" in  getMarkerColor _x ) then { _owner = east};
	deleteMarker _nodo;

	/*
		this creates the new marker 
	*/
	private _zoneMK = createMarker [_name ,_pos]; 
	_zoneMK setmarkercolor ("color" + str(_owner));
	_zoneMK setmarkerpos (getpos _nodo_logic);
	_zoneMK setMarkerAlpha 1;
	_zoneMK setmarkerSize [_areaSize,_areaSize];
	_zoneMK setmarkershape "ELLIPSE";
	if (_isbase) then {
		_zoneMK setMarkerBrush "FDiagonal";
	}else{
		_zoneMK setMarkerBrush "SolidBorder";
	};

	/*
		This is the capture marker ( for each node there is 2 markers, this will be bigger when its being captured)

	*/

	private _capture_marker = createMarker [_name+"_captureMarker",_pos];
	_capture_marker setmarkercolor "ColorCIV";
	_capture_marker setmarkerpos _pos;
	_capture_marker setMarkerAlpha 1;
	_capture_marker setmarkershape "ELLIPSE";
	_capture_marker setmarkersize [0,0];

	_nodo_logic setvariable ["Data",createHashMapFromArray //all data is saved on the marker object 
		[
			["name", _name],
			["owner", _owner],
			["base", _isbase ],
			["referenceMarker",_zoneMK ],
			["captureMk", _capture_marker],
			["captureProgress", 0]
		]
	];
	_nodos pushBack _nodo_logic;
}forEach _nodos_mk;

//This draw the lines 
_lineas = [];
{
	_nodo = _x;
	_pos = getpos _x;
	_conectados = [];
	{
		if (_x isequalto _nodo) then {continue};
		_posn2 = getpos _x;
		if (_posn2 distance2d _pos > _max_line) then {continue};
		_conectados pushBackunique _x;
		if ([_nodo,_x] in _lineas || [_x,_nodo] in _lineas ) then {continue};
		_lineas pushBackunique [_x,_nodo];
		
	}forEach _nodos; 
	_nodeData = _nodo getVariable "Data";
	_nodeData set ["connected", _conectados];
	_nodo setvariable ["Data", _nodeData, True]; //Share the var 
}forEach _nodos;

nsn_nodos = _nodos;
publicVariable "nsn_nodos";
nsn_lineas = _lineas;
publicVariable "nsn_lineas";

//This init the gameloop 
[_nodos, _areasize] spawn nsn_fnc_nc_gamemode_loop;
