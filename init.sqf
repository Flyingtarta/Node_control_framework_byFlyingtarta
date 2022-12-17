
//Time of the looptime checks (default: 10 seconds) 
missionnamespace setvariable ["NSN_VAR_NODOS_LOOPTIME", 10]; 
missionnamespace setvariable ["NSN_VAR_NODOS_CAPTURECICLES", 10];  //number of successfull checks to capture ( 10 * 10 seconds = 100 seconds to capture )

[
	1500, //will connect all markers inside this radius 
	60,   // Duration of the mission, IN MINUTES 
	250	  // Size of the capturable zone in the NODE 
] call NSN_fnc_NC_init;
