/*
Scoreboard for nodes
*/

if !(hasInterface) exitwith {};

addMissionEventHandler ["EachFrame", {
	disableSerialization;
	if !(visibleMap || visibleWatch) exitWith {
		_display = uiNamespace getvariable 'nsn_ui_marcador_nodos';
		if !(isNil {
			_display
		}) then {
			_display closeDisplay 0
		};
	};
	cutRsc ["nsn_marcador_nodos", "PLAIN"];
	_display = uiNamespace getVariable "nsn_ui_marcador_nodos";

	  // _fondo = _display displayCtrl 1000; 
	  // _flagOp =  = _display displayCtrl 1201; 
	  // _flagBlu = _display displayCtrl 1202; 
	  _puntos_op  = _display displayCtrl 1001;// puntos del bando opfor  | rscText  
	  _puntos_blu = _display displayCtrl 1002;// puntos del bando blufor | rscText 
	  _infoText   = _display displayCtrl 1003; // Texto de informacion   | rscText  
	
	_timer = [((node_endtime - servertime)/60)+.01, "HH:MM"] call BIS_fnc_timeToString;
	_texto = (_timer);
	_infoText ctrlSetText _texto;

	/*
		Score
	*/
	_nsn_nodos_marcador = nsn_nodos_marcador;
	
	_puntos_blu ctrlSetText str (_nsn_nodos_marcador select 0);
	_puntos_op  ctrlSetText str (_nsn_nodos_marcador select 1);


}];