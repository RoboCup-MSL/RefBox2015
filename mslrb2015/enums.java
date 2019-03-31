enum ButtonsEnum
{
  BTN_START(0),
  BTN_STOP(1),
  BTN_DROPBALL(2),
  BTN_PARK(3),
  BTN_ENDPART(4),
  BTN_RESET(5),
  
  BTN_C_KICKOFF(6),
  BTN_C_FREEKICK(7),
  BTN_C_GOALKICK(8),
  BTN_C_THROWIN(9),
  BTN_C_CORNER(10),
  BTN_C_PENALTY(11),
  
  BTN_C_GOAL(12),
  BTN_C_REPAIR(13),
  BTN_C_RED(14),
  BTN_C_YELLOW(15),
  
  BTN_M_KICKOFF(16),
  BTN_M_FREEKICK(17),
  BTN_M_GOALKICK(18),
  BTN_M_THROWIN(19),
  BTN_M_CORNER(20),
  BTN_M_PENALTY(21),
  
  BTN_M_GOAL(22),
  BTN_M_REPAIR(23),
  BTN_M_RED(24),
  BTN_M_YELLOW(25),
  
  BTN_ILLEGAL(99);
  
  private final int value;
  private ButtonsEnum(int value) {
      this.value = value;
  }

  public int getValue() {
      return value;
  }
  
  public boolean isSetPiece()
  {
    return (value >= BTN_C_KICKOFF.value && value <= BTN_C_PENALTY.value) || (value >= BTN_M_KICKOFF.value && value <= BTN_M_PENALTY.value) || value == BTN_DROPBALL.value;
  }
  
  public boolean isCommon()
  {
    return value >= BTN_START.value && value <= BTN_RESET.value;
  }
  
  public boolean isCyan()
  {
    return value >= BTN_C_KICKOFF.value && value <= BTN_C_YELLOW.value;
  }
  
  public boolean isMagenta()
  {
    return value >= BTN_M_KICKOFF.value && value <= BTN_M_YELLOW.value;
  }
  
  public boolean isStop()
  {
    return value == BTN_STOP.value;
  }
  
  public boolean isStart()
  {
    return value == BTN_START.value;
  }
  
  public boolean isGoal()
  {
    return value == BTN_C_GOAL.value || value == BTN_M_GOAL.value;
  }
  
  public boolean isRepair()
  {
    return value == BTN_C_REPAIR.value || value == BTN_M_REPAIR.value;
  }
  
  public boolean isEndPart()
  {
    return value == BTN_ENDPART.value;
  }
  
  public boolean isReset()
  {
    return value == BTN_RESET.value;
  }
  
  public boolean isYellow()
  {
    return value == BTN_C_YELLOW.value || value == BTN_M_YELLOW.value;
  }
  
  public boolean isRed()
  {
    return value == BTN_C_RED.value || value == BTN_M_RED.value;
  }
  
  public static final ButtonsEnum[] items = ButtonsEnum.values();
};

enum GameStateEnum
{
  GS_PREGAME(0),            // Period from start until first Kickoff Start 
  
  GS_GAMESTOP_H1(1),        // Game stopped during first half
  GS_GAMEON_H1(2),          // Game on during first half
  
  GS_HALFTIME(3),            // First half time
  
  GS_GAMESTOP_H2(4),        // Game stopped during second half
  GS_GAMEON_H2(5),          // Game on during second half
  
  GS_OVERTIME(6),            // Game end (ready for overtime)
  
  GS_GAMESTOP_H3(7),        // Game stopped during first half of overtime
  GS_GAMEON_H3(8),          // Game on during first half of overtime
  
  GS_HALFTIME_OVERTIME(9),  // First half time of oertime
  
  GS_GAMESTOP_H4(10),        // Game stopped during second half of overtime
  GS_GAMEON_H4(11),          // Game on during second half of overtime
  
  GS_PENALTIES(12),          // Penalties period on mbc????
  GS_PENALTIES_ON(13),       // Penalties period on mbc????
  GS_ENDGAME(14),            // Game over
  
  GS_ILLEGAL(99);
  
  private final int value;
  private GameStateEnum(int value) {
      this.value = value;
  }

  public int getValue() {
      return value;
  }
  
  public boolean isRunning() {
    return value == GS_GAMEON_H1.value || value == GS_GAMEON_H2.value || value == GS_GAMEON_H3.value || value == GS_GAMEON_H4.value;
  }
  
  public boolean isStopped() {
    return value == GS_GAMESTOP_H1.value || value == GS_GAMESTOP_H2.value || value == GS_GAMESTOP_H3.value || value == GS_GAMESTOP_H4.value;
  }
 
  public static GameStateEnum newInstance(GameStateEnum symbol) {
    return GameStateEnum.values()[symbol.ordinal()];
  }
  
  private static String[] GameStatusNames = 
  { 
    "Pre-Game", 
    "1st Half - STOP",
    "1st Half", 
    "Halftime",
    "2nd Half - STOP",
    "2nd Half",
    "Pre-Overtime",
    "Overtime - 1st Half - STOP",
    "Overtime - 1st Half", 
    "Overtime - Halftime",
    "Overtime - 2nd Half - STOP",
    "Overtime - 2nd Half",
    "Penalties/STOP",
    "Penalties",
    "End Game" };
  
  public String getName() {
    if(value < GameStatusNames.length)
    {
      return GameStatusNames[value];
    }else{
      return "--";
    }
  }
};


enum PopupTypeEnum
{
  POPUP_RESET(0),
  POPUP_TEAMSELECTION(1),
  POPUP_ENDPART(2),
  
  POPUP_ILLEGAL(99);
  
  private final int value;
  private PopupTypeEnum(int value) {
      this.value = value;
  }

  public int getValue() {
      return value;
  }
};
