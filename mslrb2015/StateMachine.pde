static class StateMachine
{
  private static boolean needUpdate = false; 
  private static boolean btnOn = false;
  private static ButtonsEnum btnCurrent = ButtonsEnum.BTN_ILLEGAL;
  private static ButtonsEnum btnPrev = ButtonsEnum.BTN_ILLEGAL;
  public static GameStateEnum gsCurrent = GameStateEnum.GS_PREGAME;
  private static GameStateEnum gsPrev = GameStateEnum.GS_ILLEGAL;
  
  public static boolean setpiece = false;
  public static boolean setpiece_cyan = false;
  public static ButtonsEnum setpiece_button = null;
  
  public static boolean firstKickoffCyan = true;
  private static boolean startedEndOfGamePenalties = false;
  
  public static void Update(ButtonsEnum click_btn, boolean on)
  {
    //println("Updating clicked button: " + click_btn.getValue());
    btnCurrent = click_btn;
    btnOn = on;
    needUpdate = true;
    
    StateMachineRefresh();
  }
  
  //
  // Basic state machine main refresh
  //
  private static void StateMachineRefresh()
  {
    GameStateEnum nextGS = GameStateEnum.newInstance(gsCurrent);
    GameStateEnum saveGS = GameStateEnum.newInstance(gsCurrent);
    
    // Check popup response when popup is ON
    if(Popup.hasNewResponse())
    {
      switch(Popup.getType())
      {
        case POPUP_RESET:
        {
          if(Popup.getResponse().equals("yes"))
          {
            send_event_v2(cCommcmds[CMDID_COMMON_RESET], Commcmds[CMDID_COMMON_RESET], null);
            reset();
          }
          break;
        }
        
        case POPUP_ENDPART:
        {
          if(Popup.getResponse().equals("yes"))
          {
            gsCurrent = SwitchGamePart();
            gsPrev = saveGS;
            resetStartTime(false);
            
            if (bCommoncmds[CMDID_COMMON_HALFTIME].Label.equals("End Game"))
              send_event_v2(cCommcmds[CMDID_COMMON_ENDGAME], Commcmds[CMDID_COMMON_ENDGAME], null);
            else
              send_event_v2(cCommcmds[CMDID_COMMON_HALFTIME], Commcmds[CMDID_COMMON_HALFTIME], null);
          }
          break;
        }
        
        case POPUP_TEAMSELECTION:
        {
          Team t = null;
          if(Popup.getResponse().equals("cyan"))
          {
            //println("cyan - " + teamselect.getString("shortname8"));
            Log.logMessage("Connection from " + connectingClient.ip() + " accepted - Cyan");
            t = teamA;
          }else{
            //println("magenta - " + teamselect.getString("shortname8"));
            Log.logMessage("Connection from " + connectingClient.ip() + " accepted - Magenta");
            t = teamB;
          }
          
          if(t != null)
            t.teamConnected(teamselect);
          
          break;
        }
      }
      
      needUpdate = false;
      Popup.close();
      return;
    }
    
    if(needUpdate)
    {
      //println("Updating state machine: btn " + btnCurrent.getValue());
      // Goal buttons
      int add = (btnOn ? +1 : -1);
      if(btnCurrent.isGoal())
      {
        if(btnCurrent.isCyan()) teamA.Score+=add;
        else teamB.Score+=add;
      }
      else if(btnCurrent.isReset())
      {
        Popup.show(PopupTypeEnum.POPUP_RESET, MSG_RESET, "yes", "no");
        needUpdate = false;
        return;
      }
      else if(btnCurrent.isEndPart())
      {
        Popup.show(PopupTypeEnum.POPUP_ENDPART, MSG_HALFTIME, "yes", "no");
        needUpdate = false;
        return;
      }
      else if(btnCurrent.isRepair())
      {
        if(btnCurrent.isCyan())
          teamA.newRepair=btnOn;
        else
          teamB.newRepair=btnOn;
      }
      else if(btnCurrent.isRed())
      {
        if(btnCurrent.isCyan())
          teamA.newRedCard=btnOn;
        else
          teamB.newRedCard=btnOn;
      }
      else if(btnCurrent.isYellow())
      {
        Team t = teamA;
        if(!btnCurrent.isCyan())
          t = teamB;
        
        if (t.YellowCardCount==1)
          t.newDoubleYellow = btnOn;
        else
          t.newYellowCard = btnOn;
      }
      
      /* Update game state */
      switch(gsCurrent)
      {
        // PRE-GAME and Half Times
        case GS_PREGAME:
        case GS_HALFTIME:
        case GS_OVERTIME:
        case GS_HALFTIME_OVERTIME:
          if(btnCurrent == ButtonsEnum.BTN_START)
          {
            resetStartTime(true);
            nextGS = SwitchRunningStopped();
            switch(nextGS)
            {
              case GS_GAMEON_H1: send_to_basestation(COMM_FIRST_HALF + ""); break;
              case GS_GAMEON_H2: send_to_basestation(COMM_SECOND_HALF + ""); break;
              case GS_GAMEON_H3: send_to_basestation(COMM_FIRST_HALF_OVERTIME + ""); break;
              case GS_GAMEON_H4: send_to_basestation(COMM_SECOND_HALF_OVERTIME + ""); break;
            }
          }
          else if(btnCurrent == ButtonsEnum.BTN_STOP)
          {
            if(setpiece)
              ResetSetpiece();
          }
          else if(btnCurrent == ButtonsEnum.BTN_C_KICKOFF)
          {
            // Save first kickoff
            if(gsCurrent == GameStateEnum.GS_PREGAME)
              firstKickoffCyan = true;
            SetSetpiece(true, btnCurrent);
          }else if(btnCurrent == ButtonsEnum.BTN_M_KICKOFF){
            if(gsCurrent == GameStateEnum.GS_PREGAME)
              firstKickoffCyan = false;
            SetSetpiece(false, btnCurrent);
          }
          
          break;
          
        case GS_GAMESTOP_H1:
        case GS_GAMESTOP_H2:
        case GS_GAMESTOP_H3:
        case GS_GAMESTOP_H4:
          if(btnCurrent.isSetPiece())
            SetSetpiece(btnCurrent.isCyan(), btnCurrent);
          else if(btnCurrent.isStart())
            nextGS = SwitchRunningStopped();
          else if(btnCurrent.isStop())
            ResetSetpiece();
          else if(btnCurrent.isEndPart())
            nextGS = SwitchGamePart();
          

          break;
        
        case GS_GAMEON_H1:
        case GS_GAMEON_H2:
        case GS_GAMEON_H3:
        case GS_GAMEON_H4:
          if(setpiece)
            ResetSetpiece();
            
          if(btnCurrent == ButtonsEnum.BTN_STOP)
          {
            nextGS = SwitchRunningStopped();
          }
            
          break;
          
        case GS_PENALTIES:
          if(!startedEndOfGamePenalties){
            send_to_basestation(COMM_END_OF_GAME_PENALTIES + "");
            startedEndOfGamePenalties = true;
          }
          if(btnCurrent.isSetPiece())                        // Kick Off either, Penalty either, DropBall
            SetSetpiece(btnCurrent.isCyan(), btnCurrent);
          else if(btnCurrent.isStop())
            ResetSetpiece();
          else if(btnCurrent.isEndPart())
            nextGS = SwitchGamePart();
          else if(btnCurrent.isStart())
            nextGS = SwitchRunningStopped();
          break;
        
        case GS_PENALTIES_ON:
          if(setpiece)
            ResetSetpiece();
          if(btnCurrent.isStop())
            nextGS = SwitchRunningStopped();
          break;
          
        case GS_ENDGAME:
          if(btnCurrent.isEndPart()){
            println("RESETING");
            reset();
          }
          break;
      }
      
      if(nextGS != null)
      {
        // Update split time
        if(nextGS.isRunning())
          resumeSplitTimer();
        else
          stopSplitTimer();
        
        gsCurrent = nextGS;
        gsPrev = saveGS;
        
        //println("gs: " + gsPrev.getValue() + " -> " + nextGS.getValue());
        
        if(gsCurrent.getValue() != gsPrev.getValue())
        {
          teamA.checkflags();
          teamB.checkflags();
        }
      }
      
      btnPrev = btnCurrent;
      
      
      
      needUpdate = false;
    }
  }
  
  private static GameStateEnum SwitchGamePart()
  {
    switch(gsCurrent)
    {
      case GS_GAMESTOP_H1: return GameStateEnum.GS_HALFTIME;
      case GS_GAMESTOP_H2: return GameStateEnum.GS_OVERTIME;
      case GS_GAMESTOP_H3: return GameStateEnum.GS_HALFTIME_OVERTIME;
      case GS_GAMESTOP_H4: return GameStateEnum.GS_PENALTIES;
      case GS_PENALTIES: return GameStateEnum.GS_ENDGAME;
    }
    
    return null;
  }
  
  private static GameStateEnum SwitchRunningStopped()
  {
    switch(gsCurrent)
    {
      case GS_GAMEON_H1: return GameStateEnum.GS_GAMESTOP_H1;
      case GS_GAMEON_H2: return GameStateEnum.GS_GAMESTOP_H2;
      case GS_GAMEON_H3: return GameStateEnum.GS_GAMESTOP_H3;
      case GS_GAMEON_H4: return GameStateEnum.GS_GAMESTOP_H4;
      
      case GS_PREGAME:
      case GS_GAMESTOP_H1:
        return GameStateEnum.GS_GAMEON_H1;
      case GS_HALFTIME:
      case GS_GAMESTOP_H2:
        return GameStateEnum.GS_GAMEON_H2;
      case GS_OVERTIME:
      case GS_GAMESTOP_H3:
        return GameStateEnum.GS_GAMEON_H3;
      case GS_HALFTIME_OVERTIME:
      case GS_GAMESTOP_H4:
        return GameStateEnum.GS_GAMEON_H4;
        
      case GS_PENALTIES: return GameStateEnum.GS_PENALTIES_ON;
      case GS_PENALTIES_ON: return GameStateEnum.GS_PENALTIES;
    }
    
    return null;
  }
  
  private static void ResetSetpiece()
  {
    setpiece = false;
  }
  
  private static void SetSetpiece(boolean cyan, ButtonsEnum btn)
  {
      setpiece = true;
      setpiece_cyan = cyan;
      setpiece_button = btn;
  }
  
  public static GameStateEnum GetCurrentGameState()
  {
    return gsCurrent;
  }
  
  public static String GetCurrentGameStateString()
  {
    if(gsCurrent != null)
      return gsCurrent.getName();
    else
      return "";
  }
  
  public static void reset()
  {
    try {
      send_to_basestation("" + COMM_RESET);
      
      needUpdate = false; 
      startedEndOfGamePenalties = false;
      btnCurrent = ButtonsEnum.BTN_ILLEGAL;
      btnPrev = ButtonsEnum.BTN_ILLEGAL;
      gsCurrent = GameStateEnum.GS_PREGAME;
      gsPrev = GameStateEnum.GS_ILLEGAL;
      
      previousNameTeamA = teamA.shortName; //<>//
      previousNameTeamB = teamB.shortName; //<>//
      
      teamA.reset();
      teamB.reset();        
      teamA.resetname();
      teamB.resetname();        
      resetStartTime(true);
      
      Exporter exporter = new Exporter(Log.getTimedName());
      exporter.zipAllFiles();
      
      Log.createLog();
      
      BaseStationServer.stop();
      BaseStationServer = new MyServer(mainApplet, Config.basestationServerPort);
    } catch(Exception e) {}
  }
  
  public static boolean isHalf()
  {
    return is1stHalf() || is2ndHalf() || is3rdHalf() || is4thHalf();
  }

  public static boolean isPreGame()
  {
    return gsCurrent == GameStateEnum.GS_PREGAME;
  }
  
  public static boolean is1stHalf()
  {
    return gsCurrent == GameStateEnum.GS_GAMESTOP_H1 || gsCurrent == GameStateEnum.GS_GAMEON_H1;
  }
  
  public static boolean is2ndHalf()
  {
    return gsCurrent == GameStateEnum.GS_GAMESTOP_H2 || gsCurrent == GameStateEnum.GS_GAMEON_H2;
  }
  
  public static boolean is3rdHalf()
  {
    return gsCurrent == GameStateEnum.GS_GAMESTOP_H3 || gsCurrent == GameStateEnum.GS_GAMEON_H3;
  }
  
  public static boolean is4thHalf()
  {
    return gsCurrent == GameStateEnum.GS_GAMESTOP_H4 || gsCurrent == GameStateEnum.GS_GAMEON_H4;
  }

  public static boolean isInterval() {
    return gsCurrent == GameStateEnum.GS_HALFTIME || gsCurrent == GameStateEnum.GS_OVERTIME || gsCurrent == GameStateEnum.GS_HALFTIME_OVERTIME || gsCurrent == GameStateEnum.GS_GAMESTOP_H4 || gsCurrent == GameStateEnum.GS_PENALTIES;
  }

}

void StateMachineCheck() {
  StateMachine.StateMachineRefresh();
}
