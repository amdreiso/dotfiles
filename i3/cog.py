
import subprocess
import customtkinter as ctk
from enum import Enum
from pynput import keyboard
import threading


class Section(Enum):
    AUDIO = 1
    APPLICATIONS = 2

FONT = "FiraCode Nerd Font"
FONT_SIZE = 24

app = ctk.CTk()
ctk.set_default_color_theme("dark-blue")
ctk.set_appearance_mode("dark")

w_margin = 2
w_width = 800
w_height = 600
wx = app.winfo_screenwidth() - w_width - (w_margin * 2)

w_size = str(w_width) + "x" + str(w_height) + "+" + str(wx) + "+" + str(w_margin)

app.geometry(w_size)
app.title("COG")

app.resizable(False, False)


# Main Application
sections = []
sectionIndex = None
CURRENT_SECTION = None

sections.append((Section.AUDIO, "Audio"))

subsections = {}
optionIndex = 0

def updateAudio():
    volume = subprocess.run(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"], text=True, capture_output=True)
    t_output = "1 . Output " + volume.stdout
    l_output = ctk.CTkLabel(master=app, text=t_output, font=(FONT, FONT_SIZE))
    l_output.pack()

    volume = subprocess.run(["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"], text=True, capture_output=True)
    t_input = "2 . Input " + volume.stdout
    l_input = ctk.CTkLabel(master=app, text=t_input, font=(FONT, FONT_SIZE))
    l_input.pack()

subsections[Section.AUDIO] = updateAudio

def update():
    global sectionIndex, CURRENT_SECTION 

    for widget in app.winfo_children():
        widget.destroy()

    if sectionIndex == None:
        CURRENT_SECTION = None

        for i in range(len(sections)):
            s = str(i+1) + " . " + sections[i][1]
            l = ctk.CTkLabel(master=app, text=s, font=(FONT, FONT_SIZE))
            l.pack()
    else:
        id = sections[sectionIndex][0]
        CURRENT_SECTION = id
        subsections[id]()

def sectionSwitch(index):
    global sectionIndex, optionIndex

    if sectionIndex != None: 
        if index == 0: 
            sectionIndex = None
            optionIndex = 0
            update()
        else:
            sectionIndex = index - 1
    else:
        if index != 0 and index != sectionIndex: 
            sectionIndex = index - 1
            update()
        else:
            app.destroy()

    print(sectionIndex)

def optionSetValue(val):
    if CURRENT_SECTION == Section.AUDIO:
        if optionIndex == 0:
            percentage = "1%-" if val < 0 else "1%+"
            subprocess.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", percentage])
            update()
        elif optionIndex == 1:
            percentage = "1%-" if val < 0 else "1%+"
            subprocess.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", percentage])
            update()


def keyboard_check(key):
    global optionIndex
    val = None
    if key.char.isdigit():
        val = int(key.char)
        if CURRENT_SECTION == None or val == 0: sectionSwitch(val) 
        else: optionIndex = val - 1
        print(optionIndex, sectionIndex)

    if key.char == "j":
        optionSetValue(-1)
    elif key.char == "k":
        optionSetValue(1)

def keyboard_thread():
    def on_press(key):
        try:
            keyboard_check(key)
        except AttributeError:
            print(key)

    with keyboard.Listener(on_press=on_press) as listener:
        listener.join()


update()

threading.Thread(target=keyboard_thread, daemon=True).start()
app.mainloop()


#subprocess.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"])
#subprocess.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"])






