#!/usr/bin/python3
import curses
from curses import ascii
from enum import Enum, auto

buffer_x=0
buffer_y=1
main_buffer = ""
exchange_buffer = ""
sub_buffer = ""
qso_stats={'1min':0,'5min':0,'1hr':0}


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
    c = stdscr.getkey()
    if curses.ascii.isctrl(ord(c)):
      unctrl=curses.ascii.unctrl(c)
      stdscr.addstr(0,0,"CTRL+"+c, curses.color_pair(1))
   
    if(len(c)==1 and curses.ascii.isalnum(c)):
      main_buffer=main_buffer+c
      buffer_x+=1
      stdscr.addch(buffer_y,buffer_x,c, curses.color_pair(1))
      stdscr.refresh()
    elif( len(c) > 1):
      if curses.ascii.isctrl(ord(c)):
        unctrl=curses.ascii.unctrl(c)
        stdscr.addstr(0,0,"CTRL+"+c, curses.color_pair(1))
      if c == "KEY_DOWN":
        y, x = stdscr.getyx()
        maxy, maxx = stdscr.getmaxyx()
        stdscr.move((y+1) % maxy, x)

    elif(c == ' '):
        c="KEY_SPACE"
    elif c == '\n':
        c="KEY_ENTER"
    elif c == '\t':
        c="KEY_TAB"

finally:
  # Standard shutdown
  curses.nocbreak()
  stdscr.keypad(0)
  curses.echo()
  curses.endwin()
