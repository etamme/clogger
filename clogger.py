#!/usr/bin/python3
import curses
from curses import ascii
from enum import Enum, auto

buffer_x=0
buffer_y=0
buffer_x_offset=0
stats_x=0
stats_y=5
main_buffer = ""
exchange_buffer = ""
sub_buffer = ""
qso_stats={'1min':0,'5min':0,'1hr':0}
keymap={10:"ENTER",
        27:"ESCAPE",
        32:"SPACE",
        258:"ARROW_DOWN",
        259:"ARROW_UP",
        260:"ARROW_LEFT",
        261:"ARROW_RIGHT",
        263:"BACKSP",
        265:"F1",
        266:"F1",
        267:"F2",
        268:"F3",
        269:"F4",
        270:"F5",
        271:"F6",
        272:"F8",
        273:"F9",
        274:"F10",
        275:"F11",
        276:"F12"}

class RunState(Enum):
 IDLE=auto()
 RUN=auto()
 CALL_ENTRY=auto()
 CALL_AGAIN=auto()
 SEND_EXCHANGE=auto()
 EXCHANGE_ENTRY=auto()
 EXCHANGE_AGAIN=auto()
 END_QSO=auto()

class SNPState(Enum):
 IDLE=auto()
 SEND_MYCALL=auto()
 EXCHANGE_ENTRY=auto()
 EXCHANGE_AGAIN=auto()
 SEND_EXCHANGE=auto()
 END_QSO=auto()

def getkey(screen):
  key=""
  c = screen.getch()
  if(c in keymap.keys()):
    key=keymap[c]
  elif(curses.ascii.isalnum(c)):
    key=chr(c)
  elif(curses.ascii.isspace(c)):
    key="KEY_SPACE"
  elif(curses.ascii.isctrl(c)):
    key="CTRL_"+curses.ascii.unctrl(c)
  else: 
    key="uknown-"+chr(c)
#  print("%i",c)
  return (key,c)
 
# Main loop setup in try/finally to properly restore terminal in the event of crash
try:
  # Standard startup
  stdscr = curses.initscr()
  curses.cbreak()
  curses.noecho()
  stdscr.keypad(1)
  curses.start_color()
  curses.init_pair(1, curses.COLOR_RED, curses.COLOR_WHITE)
  curses.init_pair(2, curses.COLOR_WHITE, curses.COLOR_GREEN)


# get input forever
  while 1:
    (key,code) = getkey(stdscr)
    (cur_y,cur_x)=stdscr.getyx()
    stdscr.move(buffer_y,0)
    stdscr.clrtoeol()
    stdscr.move(stats_y,0)
    stdscr.clrtoeol()
    stdscr.move(cur_y,cur_x)

    if(key=="BACKSP"):
      main_buffer=main_buffer[0:-1]
    elif(key=="ARROW_LEFT"):
      if(buffer_x_offset+len(main_buffer) != 0):
        buffer_x_offset-=1
    elif(key=="ARROW_RIGHT"):
      if(buffer_x_offset!=0):
        buffer_x_offset+=1
    else:
      if(buffer_x_offset==0):
        main_buffer=main_buffer+key
      else:
        main_buffer=main_buffer[:buffer_x_offset]+key+main_buffer[buffer_x_offset+1]
    stdscr.addstr(buffer_y,buffer_x,main_buffer)
    stdscr.addstr(stats_y,stats_x,f"buffer_x: {buffer_x}, cur_x: {cur_x}, buffer_x_offset: {buffer_x_offset}, main_buffer: {main_buffer} length: {len(main_buffer)}, keycode: {code}")
    stdscr.addstr(stats_y+1,stats_x,f"next move to {buffer_y}, {len(main_buffer)+buffer_x_offset}")
    stdscr.move(buffer_y,len(main_buffer)+buffer_x_offset)
    stdscr.refresh()


finally:
  # Standard shutdown
  curses.nocbreak()
  stdscr.keypad(0)
  curses.echo()
  curses.endwin()
