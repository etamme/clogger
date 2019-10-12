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
        262:"HOME",
        263:"BACKSP",
        265:"F1",
        266:"F2",
        267:"F3",
        268:"F4",
        269:"F5",
        270:"F6",
        271:"F7",
        272:"F8",
        273:"F9",
        274:"F10",
        275:"F11",
        276:"F12",
        330:"DEL",
        331:"INS",
        338:"PGUP",
        339:"PGDN",
        360:"END"
        }

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
      key="CTRL_"+curses.ascii.unctrl(c)[1:]
  else: 
    key=chr(c)
#  print("%i",c)
  return (key,c)
 
def process_key(key,code):
  global buffer_x_offset
  global main_buffer
  if(key=="BACKSP"):
    if(len(main_buffer)>0):
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
      if(buffer_x_offset<-1):
        main_buffer=main_buffer[:buffer_x_offset]+key+main_buffer[buffer_x_offset+1:]
      else:
        main_buffer=main_buffer[:buffer_x_offset]+key

def clear_main_buffer(screen):
    screen.move(buffer_y,0)
    screen.clrtoeol()

# should be called last of all drawing routines b/c it replaces the cursor to the
# buffer_x_offset position
def draw_main_buffer(screen):
    screen.addstr(buffer_y,buffer_x,main_buffer)
    stdscr.move(buffer_y,len(main_buffer)+buffer_x_offset)

def update_main_buffer(screen):
    clear_main_buffer(screen)
    draw_main_buffer(screen)

def clear_stats(screen):
    screen.move(stats_y,0)
    screen.clrtoeol()

def draw_stats(screen):
    (cur_y,cur_x)=screen.getyx()
    screen.addstr(stats_y,stats_x,f"buffer_x: {buffer_x}, cur_x: {cur_x}, buffer_x_offset: {buffer_x_offset}, main_buffer: {main_buffer} length: {len(main_buffer)}, keycode: {code}")

def update_stats(screen):
    clear_stats(screen)
    draw_stats(screen)

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
    clear_main_buffer(stdscr)
    clear_stats(stdscr)
    process_key(key,code)
    update_stats(stdscr)
    update_main_buffer(stdscr)
    stdscr.refresh()
finally:
  # Standard shutdown
  curses.nocbreak()
  stdscr.keypad(0)
  curses.echo()
  curses.endwin()
