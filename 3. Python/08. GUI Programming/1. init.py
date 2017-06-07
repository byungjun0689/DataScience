from tkinter import *
from PIL import Image, ImageTk

class Window(Frame):


    def __init__(self, master=None):
        Frame.__init__(self, master)
        self.master = master
        self.init_window()

    #Creation of init_window
    def init_window(self):

        # changing the title of our master widget
        self.master.title("GUI")

        # allowing the widget to take the full space of the root window
        self.pack(fill=BOTH, expand=1)

        menu = Menu(self.master)
        self.master.config(menu=menu)

        file = Menu(menu)
        file.add_command(label='Exit', command=self.client_exit)
        file.add_command(label='Exit2', command=self.client_exit)

        menu.add_cascade(label='File', menu=file)

        edit = Menu(menu)

        edit.add_command(label='Undo')
        menu.add_cascade(label='Edit', menu=edit)

        # creating a button instance
        #quitButton = Button(self, text="Quit", command=self.clien)

        # placing the button on my window
        #quitButton.place(x=0, y=0)

    def client_exit(self):
    	exit()

if __name__ == '__main__':
	root = Tk()

	#size of the window
	root.geometry("400x300")

	app = Window(root)
	root.mainloop()