/*
Description:
  
  This file handles all the gamemode itself
  
  input: Node array ( object )
  
*/


params [ "_nodes", ["_areasize", 250]];



private _fnc_modificar_capture_area = {
  params ["_capture_marker","_capture_progress","_TargetCaptura","_areaSize"];
  
  if (_capture_progress >= 0 && _capture_progress <= _TargetCaptura) then {
    _newsize = linearconversion [0,_TargetCaptura,_capture_progress,0,_areaSize];
    _capture_marker setmarkersize [_newsize,_newsize];
  };
};

private _fnc_scoreboard_update = {
  _nodos_opfor = 0;
  _nodos_blufor = 0;
  _nsn_nodos_marcador = nsn_nodos_marcador;
  {
    _nodo = _x;
    _nododata = _nodo getVariable "Data";
    _owner = _nododata get "owner";
    
    if (_owner isEqualTo opfor) then { 
      _nodos_opfor = _nodos_opfor + 1;
    };
    
    if (_owner isequalto blufor ) then {
    _nodos_blufor = _nodos_blufor + 1;
    };
  }foreach nsn_nodos;
  

  if ( _nodos_blufor isEqualTo _nodos_opfor) exitwith {};

  if (_nodos_blufor > _nodos_opfor) then {
    _diff  = _nodos_blufor - _nodos_opfor;
    _nsn_nodos_marcador set [0, (_nsn_nodos_marcador select 0)+ _diff];
  }else{
    _diff = _nodos_opfor - _nodos_blufor;
    _nsn_nodos_marcador set [1, (_nsn_nodos_marcador select 1) + _diff];	
  };
  nsn_nodos_marcador = _nsn_nodos_marcador;
  publicVariable "nsn_nodos_marcador";
};

private _capturable_nodes = _nodes select { //excludes bases to the check 
  !( (_x getvariable "Data") get "base")
};
nsn_nodos_marcador = [0,0];
publicVariable "nsn_nodos_marcador";
private _sleep = missionnamespace getvariable ["NSN_VAR_NODOS_LOOPTIME", 10];
private _TargetCaptura = missionnamespace getvariable ["NSN_VAR_NODOS_CAPTURECICLES", 10];
private _missionEndTime = node_endtime; 

while {servertime < _missionEndTime } do {
	sleep _sleep;

	{
		_node = _x;
    //Get node data 
    _nodeData = _node getvariable "Data";
    _node_mk = _nodeData get "referenceMarker"; 
    _node_owner = _nodeData get "owner";
    _node_captureMK = _nodeData get "captureMk";
    _node_captureProgress = _nodeData get "captureProgress";
    //Si no hay enemigos presentes y el progreso de captura es 0, seguimos de largo 
    
    _notOwnerInArea = ({_x inarea _node_mk && side _x isnotequalto _node_owner} count allunits);
    if (_notOwnerInArea isEqualTo 0 && _node_captureProgress isEqualTo 0) then {continue};

    //Si hay Enemigos presentes en el area verificamos captura 
    _diff = [_node, 0 , _node_mk ] call nsn_fnc_nc_diffinarea;
    
    _diff_ratio = _diff select 0;
    _diff_side = _diff select 1;
    //Si el ratio es mayor a 1.5 y el bando dominante no es el owner sumamos 1 punto de captura 
    if (_diff_ratio > 1.5 && _diff_side isnotequalto _node_owner && [_node, _diff_side] call nsn_fnc_nc_canCapture) then {
      _node_captureProgress = _node_captureProgress + 1;
    }else{
      if (_node_captureProgress > 0) then {
        _node_captureProgress = _node_captureProgress - 1;
      }; 
    };
    //Actualizamos captura
    
    if (_node_captureProgress isequalto _TargetCaptura) then {
      _newOwner = _diff_side; 
      
      //
      //Zona capturada - //here you can add functions that work as EH if needed when a node is captured 
      //
      //Change the color 
      _node_mk setMarkerColor ("color" + str _newOwner);
      _node_captureProgress = 0;
      //Node information is updated and shared 
      _nodeData set ["owner", _newOwner];
      _nodeData set ["captureProgress",0];
      _node setvariable ["Data", _nodeData, True];
      //if a node is disconected will be set to uncaptured 
      [_capturable_nodes] call nsn_fnc_NC_nodeDesconectedCheck;
    }else{
      _nodeData set ["captureProgress",_node_captureProgress];
      _node setvariable ["Data", _nodeData]; //Capture value is only updated in the server until it ends 
    }; 
    [_node_captureMK,_node_captureProgress,_TargetCaptura,_areaSize] call _fnc_modificar_capture_area  // this updates the capture marker 
	}foreach _capturable_nodes; 

  call _fnc_scoreboard_update;
}; 
/*
  MISSION END
    WHO WIN?
*/

nsn_nodos_marcador params ["_puntosblufor", "_puntosopfor"];
if ( _puntosblufor > _puntosopfor ) exitwith {
  //blufor win 
  
  ["end1",false, 2] remoteExec ["BIS_fnc_endMission", opfor ]; 
  ["end1",true,  2] remoteExec ["BIS_fnc_endMission", blufor]; 
  ["end1",false, 2] call BIS_fnc_endMission; //end server
};

if ( _puntosblufor < _puntosopfor ) exitwith {
  // ofopr win
  ["end1",true , 2] remoteExec ["BIS_fnc_endMission", opfor ]; 
  ["end1",false, 2] remoteExec ["BIS_fnc_endMission", blufor];
  ["end1",false, 2] call BIS_fnc_endMission; //end server
  
};

if ( _puntosblufor isequalto  _puntosopfor) then {
  //tie
  ["end1",true, 2] remoteExec ["BIS_fnc_endMission",0];
};

