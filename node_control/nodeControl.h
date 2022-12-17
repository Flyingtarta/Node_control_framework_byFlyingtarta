class FLYINGTARTA_NODECONTROL {
    tag = "nsn";
    class nsn_node_control {
        file = "node_control";
        class NC_canCapture           {};
        class NC_diffInArea           {};
        class NC_gamemode_loop        {};
        class NC_init                 {};
        class NC_initPlayer           {};
        class NC_nodeDesconectedCheck {};
    };

    class scoreboard {
        file = "node_control\scoreboard\fncs"
        class scoreboard_nodos_initplayer{};
    };
};