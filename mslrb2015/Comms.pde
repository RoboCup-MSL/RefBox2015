// New accepted connections
public static void serverEvent(MyServer whichServer, Client whichClient) {
  try {
  if (whichServer.equals(BaseStationServer)) {
    Log.logMessage("New BaseStation @ "+whichClient.ip());
  }
  else if (mslRemote != null && mslRemote.server != null && whichServer != null && whichServer.equals(mslRemote.server)) {
    Log.logMessage("New Remote @ " + whichClient.ip());
  }
  }catch(Exception e){}
}

// Client authentication
public static void clientValidation(MyServer whichServer, Client whichClient) {
  try{
    // BASESTATION CLIENTS AUTH
    if (whichServer.equals(BaseStationServer)) {
      if (!Popup.isEnabled()) {
        if(setteamfromip(whichClient.ip()))
          connectingClient = whichClient; // Accept client!
        else
        {
          // Invalid team
          Log.logMessage("Invalid team " + whichClient.ip());
          whichClient.write(COMM_RESET);
          whichClient.stop();
        }
      } else {
        Log.logMessage("ERR Another team connecting");
        whichClient.write(COMM_RESET);
        whichClient.stop();
      }
    }
    // REMOTE CLIENTS AUTH
    else if (mslRemote != null && mslRemote.server != null && whichServer.equals(mslRemote.server)) {
      
    }
  }catch(Exception e){}
}


public static void send_to_basestation(String c){
  println("Command "+c+" :"+Description.get(c+""));
  BaseStationServer.write(c);
  
//  if(!c.equals("" + COMM_WORLD_STATE))
//  {
    Log.logactions(c);
    mslRemote.setLastCommand(c);      // Update MSL remote module with last command sent to basestations
//  }
}

public static void event_message_v2(ButtonsEnum btn, boolean on)
{
  String cmd = buttonFromEnum(btn).cmd;
  String msg = buttonFromEnum(btn).msg;
  if(!on)
  {
    cmd = buttonFromEnum(btn).cmd_off;
    msg = buttonFromEnum(btn).msg_off;
  }
  
  Team t = null;
  if(btn.isCyan()) t = teamA;
  if(btn.isMagenta()) t = teamB;
  
  if(cmd != null && msg != null)
  {
    send_event_v2(cmd, msg, t);
  }
}

public static void send_event_v2(String cmd, String msg, Team t)
{
  //println("EVENT, " + cmd + " / " + msg);
  String teamName = (t != null) ? t.longName : "";
  send_to_basestation(cmd);
  scoreClients.update_tEvent(cmd, msg, teamName);
  mslRemote.update_tEvent(cmd, msg, t);
}

void event_message(char team, boolean on, int pos) {
  if (on) {  //send to basestations
    if (team=='C' && pos<4){
      send_to_basestation(cCommcmds[pos]);
      scoreClients.update_tEvent("" + cCommcmds[pos], Commcmds[pos], "");
      mslRemote.update_tEvent("" + cCommcmds[pos], Commcmds[pos], null);
    } 
    else if (team=='A' && pos<10){
      send_to_basestation(cCTeamcmds[pos]);//<8
      scoreClients.update_tEvent("" + cCTeamcmds[pos], Teamcmds[pos], teamA.longName);
      mslRemote.update_tEvent("" + cCTeamcmds[pos], Teamcmds[pos], teamA);
    }
    else if (team=='B' && pos<10)
    {
      send_to_basestation(cMTeamcmds[pos]);//<8
      scoreClients.update_tEvent("" + cMTeamcmds[pos], Teamcmds[pos], teamB.longName);
      mslRemote.update_tEvent("" + cMTeamcmds[pos], Teamcmds[pos], teamB);
    }
  }
}

public static void test_send_direct(char team, int pos) {
  if (team=='C') BaseStationServer.write(cCommcmds[pos]);
  if (team=='A') BaseStationServer.write(cCTeamcmds[pos]);
  if (team=='B') BaseStationServer.write(cMTeamcmds[pos]);
}

public static boolean setteamfromip(String s) {
  String clientipstr="127.0.0.*";
  String[] iptokens;
  
  if (!s.equals("0:0:0:0:0:0:0:1")) {
    iptokens=split(s,'.');
    if (iptokens!=null) clientipstr=iptokens[0]+"."+iptokens[1]+"."+iptokens[2]+".*";
  }
  
  //println("Client IP: " + clientipstr);
  
  for (TableRow row : teamstable.rows()) {
    String saddr = row.getString("UnicastAddr");
    if (saddr.equals(clientipstr)) {
      println("Team " + row.getString("Team") + " connected (" + row.getString("shortname8") + "/" + row.getString("longame24") + ")");
      teamselect=row;
      
      boolean noTeamA = teamA.connectedClient == null || !teamA.connectedClient.active();
      boolean noTeamB = teamB.connectedClient == null || !teamB.connectedClient.active();
      
      if(StateMachine.GetCurrentGameState() == GameStateEnum.GS_PREGAME || (noTeamA || noTeamB)) // In pre-game or if lost all connections, ask for the color
      {
        Popup.show(PopupTypeEnum.POPUP_TEAMSELECTION, "Team: "+row.getString("Team")+"\nSelect color or press ESC to cancel","cyan","magenta");
        return true;
      }
      else
      {
        Log.logMessage("ERR No more connections allowed (Attempt from " + s + ")");
        return false;
      }
    }
  }
  Log.logMessage("ERR Unknown team (Attempt from " + s + ")");
  return false;
}

public static void checkBasestationsMessages()
{
  try
  {
    // Get the next available client
    Client thisClient = BaseStationServer.available();
    // If the client is not null, and says something, display what it said
    if (thisClient !=null) {
      
    Team t = null;
    int team = -1; // 0=A, 1=B
      if(teamA != null && teamA.connectedClient == thisClient)
        t=teamA;
      else if(teamB != null && teamB.connectedClient == thisClient)
        t=teamB;
      else{
        if(thisClient != connectingClient)
          println("NON TEAM MESSAGE RECEIVED FROM " + thisClient.ip());
        return;
      }
    String whatClientSaid = new String(thisClient.readBytes());
    if (whatClientSaid != null) 
      while(whatClientSaid.length() !=0){
        //println(whatClientSaid);
        int idx = whatClientSaid.indexOf('\0');
        //println(whatClientSaid.length()+"\t"+ idx);
        if(idx!=-1){
          if(idx!=0)
          {  
            t.wsBuffer+= whatClientSaid.substring(0,idx);
            if(idx < whatClientSaid.length())
              whatClientSaid = whatClientSaid.substring(idx+1);
            else
              whatClientSaid = "";
          }else{
            if(whatClientSaid.length() == 1)
              whatClientSaid = "";
            else
              whatClientSaid = whatClientSaid.substring(1);
          }
          
          // JSON Validation
          boolean ok = true;
          int ageMs = 0;
          String dummyFieldString;
          org.json.JSONArray dummyFieldJsonArray;
          try // Check for malformed JSON
          {
            t.worldstate_json = new org.json.JSONObject(t.wsBuffer);
          } catch(JSONException e) {
            String errorMsg = "ERROR malformed JSON (team=" + t.shortName + ") : " + t.wsBuffer;
            println(errorMsg);
            ok = false;
          }
          
          if(ok)
          {
            try // Check for "type" key
            {
              String type = t.worldstate_json.getString("type");
              
              // type must be "worldstate"
              if(!type.equals("worldstate"))
              {
                String errorMsg = "ERROR key \"type\" is not \"worldstate\" (team=" + t.shortName + ") : " + t.wsBuffer;
                println(errorMsg);
                ok = false;
              }
            } catch(JSONException e) {
              String errorMsg = "ERROR missing key \"type\" (team=" + t.shortName + ") : " + t.wsBuffer;
              println(errorMsg);
              ok = false;
            }
          }
          
          if(ok)
          {
            try // Check for "ageMs" key
            {
              ageMs = t.worldstate_json.getInt("ageMs");
            } catch(JSONException e) {
              String errorMsg = "WS-ERROR missing key \"ageMs\" (team=" + t.shortName + ") : " + t.wsBuffer;
              println(errorMsg);
              ok = false;
            }
          }
          
          if(ok)
          {
            try // Check for "teamName" key
            {
              dummyFieldString = t.worldstate_json.getString("teamName");
            } catch(JSONException e) {
              String errorMsg = "WS-ERROR missing key \"teamName\" (team=" + t.shortName + ") : " + t.wsBuffer;
              println(errorMsg);
              ok = false;
            }
          }
          
          if(ok)
          {
            try // Check for "intention" key
            {
              dummyFieldString = t.worldstate_json.getString("intention");
            } catch(JSONException e) {
              String errorMsg = "WS-ERROR missing key \"intention\" (team=" + t.shortName + ") : " + t.wsBuffer;
              println(errorMsg);
              ok = false;
            }
          }
          
          if(ok)
          {
            try // Check for "robots" key
            {
              dummyFieldJsonArray = t.worldstate_json.getJSONArray("robots");
            } catch(JSONException e) {
              String errorMsg = "WS-ERROR key \"robots\" is missing or is not array (team=" + t.shortName + ") : " + t.wsBuffer;
              println(errorMsg);
              ok = false;
            }
          }
          
          if(ok)
          {
            try // Check for "balls" key
            {
              dummyFieldJsonArray = t.worldstate_json.getJSONArray("balls");
            } catch(JSONException e) {
              String errorMsg = "WS-ERROR key \"balls\" is missing or is not array (team=" + t.shortName + ") : " + t.wsBuffer;
              println(errorMsg);
              ok = false;
            }
          }
          
          if(ok)
          {
            try // Check for "obstacles" key
            {
              dummyFieldJsonArray = t.worldstate_json.getJSONArray("obstacles");
            } catch(JSONException e) {
              String errorMsg = "WS-ERROR key \"obstacles\" is missing or is not array (team=" + t.shortName + ") : " + t.wsBuffer;
              println(errorMsg);
              ok = false;
            }
          }
          
          if(ok)
          {
            t.logWorldstate(t.wsBuffer,ageMs);
          }
          t.wsBuffer="";      
          //println("NEW message");
        }else{
          t.wsBuffer+= whatClientSaid;
          break;
        }
        //println("MESSAGE from " + thisClient.ip() + ": " + whatClientSaid);
        
        // Avoid filling RAM with buffering (for example team is not sending the '\0' character)
        if(t.wsBuffer.length() > 100000) {
          t.wsBuffer = "";
          String errorMsg = "ERROR JSON not terminated with '\\0' (team=" + t.shortName + ")";
          println(errorMsg);
        }
      }
      
      
    }
  }catch(Exception e){
  }
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
  Description.set("z", "Game Over");
  Description.set("Z", "Reset Game");
  Description.set("W", "Welcome");
  Description.set("U", "Test Mode on");
  Description.set("u", "Test Mode off");
  Description.set("1", "1st half");
  Description.set("2", "2nd half");
  Description.set("3", "Overtime 1st half");
  Description.set("4", "Overtime 2nd half");
  Description.set("5", "End of Game Penalties");
  Description.set("L", "Park");
  
  Description.set("K", "CYAN Kickoff");
  Description.set("F", "CYAN Freekick");
  Description.set("G", "CYAN Goalkick");
  Description.set("T", "CYAN Throw In");
  Description.set("C", "CYAN Corner");
  Description.set("P", "CYAN Penalty Kick");
  Description.set("A", "CYAN Goal+");
  Description.set("D", "CYAN Goal-");
  Description.set("O", "CYAN Repair Out");
  Description.set("R", "CYAN Red Card");
  Description.set("Y", "CYAN Yellow Card");
  Description.set("B", "CYAN Double Yellow");

  Description.set("k", "MAGENTA Kickoff");
  Description.set("f", "MAGENTA Freekick");
  Description.set("g", "MAGENTA Goalkick");
  Description.set("t", "MAGENTA Throw In");
  Description.set("c", "MAGENTA Corner");
  Description.set("p", "MAGENTA Penalty Kick");
  Description.set("a", "MAGENTA Goal+");
  Description.set("d", "MAGENTA Goal-");
  Description.set("o", "MAGENTA Repair Out");
  Description.set("r", "MAGENTA Red Card");
  Description.set("y", "MAGENTA Yellow Card");
  Description.set("b", "MAGENTA Double Yellow");
}
