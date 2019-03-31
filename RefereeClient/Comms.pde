
public static void serverEvent(Server whichServer, Client whichClient) {
/*  if (whichServer.equals(BaseStationServer)) {
    println(getAbsoluteTime()+": New BaseStationClient @ "+whichClient.ip());
    if (!Popup.isEnabled()) {
      if(setteamfromip(whichClient.ip()))
        connectingClient = whichClient; 
      else
      {
        // Invalid team
        whichClient.write(COMM_RESET);
        BaseStationServer.disconnect(whichClient);
      }
    } else {
      whichClient.write(COMM_RESET);
      BaseStationServer.disconnect(whichClient);
      Log.logMessage("ERR Another team connecting");
    }
  }
  if (whichServer.equals(scoreClients.scoreServer))
    println(getAbsoluteTime()+": New ScoreClient @ " + whichClient.ip());
  if (whichServer.equals(mslRemote.server))
    println(getAbsoluteTime()+": New RemoteControl @ " + whichClient.ip());
    */
}

// -------------------------
// Referee Box Protocol 2015

// default commands
public static final char COMM_STOP = 'S';
public static final char COMM_START = 's';
public static final char COMM_WELCOME = 'W';  //NEW 2015CAMBADA: welcome message
public static final char COMM_RESET = 'Z';  //NEW 2015CAMBADA: Reset Game
public static final char COMM_TESTMODE_ON = 'U';  //NEW 2015CAMBADA: TestMode On
public static final char COMM_TESTMODE_OFF = 'u';  //NEW 2015CAMBADA: TestMode Off

// penalty Commands 
public static final char COMM_YELLOW_CARD_MAGENTA = 'y';  //NEW 2015CAMBADA: @remote
public static final char COMM_YELLOW_CARD_CYAN = 'Y';//NEW 2015CAMBADA: @remote
public static final char COMM_RED_CARD_MAGENTA = 'r';//NEW 2015CAMBADA: @remote
public static final char COMM_RED_CARD_CYAN = 'R';//NEW 2015CAMBADA: @remote
public static final char COMM_DOUBLE_YELLOW_MAGENTA = 'b'; //NEW 2015CAMBADA: exits field
public static final char COMM_DOUBLE_YELLOW_CYAN = 'B'; //NEW 2015CAMBADA:
//public static final char COMM_DOUBLE_YELLOW_IN_MAGENTA = 'j'; //NEW 2015CAMBADA: 
//public static final char COMM_DOUBLE_YELLOW_IN_CYAN = 'J'; //NEW 2015CAMBADA: 


// game flow commands
public static final char COMM_FIRST_HALF = '1';
public static final char COMM_SECOND_HALF = '2';
public static final char COMM_FIRST_HALF_OVERTIME = '3';  //NEW 2015CAMBADA: 
public static final char COMM_SECOND_HALF_OVERTIME = '4';  //NEW 2015CAMBADA: 
public static final char COMM_END_OF_GAME_PENALTIES = '5';
public static final char COMM_HALF_TIME = 'h';
public static final char COMM_END_GAME = 'e';    //ends 2nd part, may go into overtime
public static final char COMM_GAMEOVER = 'z';  //NEW 2015CAMBADA: Game Over
public static final char COMM_PARKING = 'L';

// goal status
public static final char COMM_GOAL_MAGENTA = 'a';
public static final char COMM_GOAL_CYAN = 'A';
public static final char COMM_SUBGOAL_MAGENTA = 'd';
public static final char COMM_SUBGOAL_CYAN = 'D';

// game flow commands
public static final char COMM_KICKOFF_MAGENTA = 'k';
public static final char COMM_KICKOFF_CYAN = 'K';
public static final char COMM_FREEKICK_MAGENTA = 'f';
public static final char COMM_FREEKICK_CYAN = 'F';
public static final char COMM_GOALKICK_MAGENTA = 'g';
public static final char COMM_GOALKICK_CYAN = 'G';
public static final char COMM_THROWIN_MAGENTA = 't';
public static final char COMM_THROWIN_CYAN = 'T';
public static final char COMM_CORNER_MAGENTA = 'c';
public static final char COMM_CORNER_CYAN = 'C';
public static final char COMM_PENALTY_MAGENTA = 'p';
public static final char COMM_PENALTY_CYAN = 'P';
public static final char COMM_DROPPED_BALL = 'N';

// repair Commands
public static final char COMM_REPAIR_OUT_MAGENTA = 'o';  //exits field
public static final char COMM_REPAIR_OUT_CYAN = 'O';
//public static final char COMM_REPAIR_IN_MAGENTA = 'i';
//public static final char COMM_REPAIR_IN_CYAN = 'I';

//  public static final char COMM_CANCEL = 'x'; //not used
//  public static final String COMM_RECONNECT_STRING = "Reconnect"; //not used

//free: fFHlmMnqQvVxX
//------------------------------------------------------

public static StringDict Description;
void comms_initDescriptionDictionary() {
  Description = new StringDict();
  Description.set("S", "STOP");
  Description.set("s", "START");
  Description.set("N", "Drop Ball");
  Description.set("h", "Halftime");
  Description.set("e", "End Game");
  Description.set("z", "Game Over");  //NEW 2015CAMBADA
  Description.set("Z", "Reset");  //NEW 2015CAMBADA
  Description.set("W", "Welcome");  //NEW 2015CAMBADA
  Description.set("U", "Test Mode on");  //NEW 2015CAMBADA  ?
  Description.set("u", "Test Mode off");  //NEW 2015CAMBADA  ?
  Description.set("1", "1st half");
  Description.set("2", "2nd half");
  Description.set("3", "Overtime 1st half");  //NEW 2015CAMBADA
  Description.set("4", "Overtime 2nd half");  //NEW 2015CAMBADA
  Description.set("5", "End of Game Penalties");
  Description.set("L", "Park");
  
  Description.set("K", "Kick Off CYAN");
  Description.set("F", "Free Kick CYAN");
  Description.set("G", "Goal Kick CYAN");
  Description.set("T", "Throw In CYAN");
  Description.set("C", "Corner CYAN");
  Description.set("P", "Penalty CYAN");
  Description.set("A", "Goal+ CYAN");
  Description.set("D", "Goal- CYAN");  
  Description.set("O", "Repair Out CYAN");
//  Description.set("I", "Repair In");
  Description.set("R", "Red Card CYAN");  //NEW 2015CAMBADA
  Description.set("Y", "Yellow Card CYAN");  //NEW 2015CAMBADA
//  Description.set("J", "CYAN Double Yellow in");  //NEW 2015CAMBADA
  Description.set("B","Double Yellow CYAN");  //NEW 2015CAMBADA

  Description.set("k", "Kick Off MAGENTA");
  Description.set("f", "Free Kick MAGENTA");
  Description.set("g", "Goal Kick MAGENTA");
  Description.set("t", "Throw In MAGENTA");
  Description.set("c", "Corner MAGENTA");
  Description.set("p", "Penalty MAGENTA");
  Description.set("a", "Goal+ MAGENTA");
  Description.set("d", "Goal- MAGENTA");
  Description.set("o", "Repair Out MAGENTA");
//  Description.set("i", "MAGENTA Repair In");
  Description.set("r", "Red Card MAGENTA");  //NEW 2015CAMBADA
  Description.set("y", "Yellow Card MAGENTA");  //NEW 2015CAMBADA
//  Description.set("j", "MAGENTA Double Yellow in");  //NEW 2015CAMBADA
  Description.set("b","Double Yellow MAGENTA");  //NEW 2015CAMBADA
}
