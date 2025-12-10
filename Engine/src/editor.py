#!/usr/bin/env python3
"""
Flappy Bird Level Editor
Just click to place pipes, adjust settings, and save
"""
import tkinter as tk
from tkinter import ttk, messagebox, filedialog, colorchooser
import json
import os

class Editor:
    def __init__(self, root):
        self.root = root
        self.root.title("Flappy Bird Level Editor")
        self.root.geometry("1000x700")

        # level settings
        self.level_name = "My Level"
        self.pipe_width = 60
        self.pipe_gap = 150
        self.gravity = 800.0

        # canvas settings
        self.canvas_width = 800
        self.canvas_height = 600

        # pipes storage
        self.pipes = []
        self.selected_pipe = None

        # power-ups storage: list of dicts with {x,y, type}
        self.powerups = []
        self.selected_powerup_type = None 

        self.bg_r = 135
        self.bg_g = 206
        self.bg_b = 235
        self.setup_ui()

    def setup_ui(self):
        control_frame = tk.Frame(self.root, bg='lightgray', height=150)
        control_frame.pack(fill=tk.X, padx=5, pady=5)
        control_frame.pack_propagate(False)

        row1 = tk.Frame(control_frame, bg='lightgray')
        row1.pack(pady=5)

        tk.Label(row1, text="Level Name:", bg='lightgray').pack(side=tk.LEFT, padx=5)
        self.name_entry = tk.Entry(row1, width=20)
        self.name_entry.insert(0, self.level_name)
        self.name_entry.pack(side=tk.LEFT, padx=5)
        tk.Label(row1, text="Pipe Width:", bg='lightgray').pack(side=tk.LEFT, padx=5)
        self.width_var = tk.IntVar(value=self.pipe_width)
        self.width_spin = tk.Spinbox(row1, from_=30, to=100, width=10,
                                      textvariable=self.width_var,
                                      command=self.update_settings)
        self.width_var.trace('w', lambda *args: self.update_settings())
        self.width_spin.pack(side=tk.LEFT, padx=5)

        tk.Label(row1, text="Gap Height:", bg='lightgray').pack(side=tk.LEFT, padx=5)
        self.gap_var = tk.IntVar(value=self.pipe_gap)
        self.gap_spin = tk.Spinbox(row1, from_=80, to=250, width=10,
                                    textvariable=self.gap_var,
                                    command=self.update_settings)
        self.gap_var.trace('w', lambda *args: self.update_settings())
        self.gap_spin.pack(side=tk.LEFT, padx=5)

        tk.Label(row1, text="Gravity:", bg='lightgray').pack(side=tk.LEFT, padx=5)
        self.gravity_var = tk.DoubleVar(value=self.gravity)
        self.gravity_spin = tk.Spinbox(row1, from_=400, to=1500, increment=50, width=10,
                                       textvariable=self.gravity_var,
                                       command=self.update_settings)
        self.gravity_var.trace('w', lambda *args: self.update_settings())
        self.gravity_spin.pack(side=tk.LEFT, padx=5)

        row2 = tk.Frame(control_frame, bg='lightgray')
        row2.pack(pady=5)
        tk.Button(row2, text="Save Level", command=self.save_level, bg='green', fg='black', width=12).pack(side=tk.LEFT, padx=5)
        tk.Button(row2, text="Load Level", command=self.load_level,
                 bg='blue', fg='black', width=12).pack(side=tk.LEFT, padx=5)
        tk.Button(row2, text="Clear All", command=self.clear_all, bg='red', fg='black', width=12).pack(side=tk.LEFT, padx=5)
        powerup_frame = tk.Frame(control_frame, bg='lightgray')
        powerup_frame.pack(pady=5)

        tk.Label(powerup_frame, text="Power-Ups:", bg='lightgray', font=('Arial', 10, 'bold')).pack(side=tk.LEFT, padx=5)
        tk.Button(powerup_frame, text="Invincibility", command=lambda: self.select_powerup_type('invincibility'), bg='gold', fg='black', width=14).pack(side=tk.LEFT, padx=2)
        tk.Button(powerup_frame, text="Speed Boost", command=lambda: self.select_powerup_type('speed'),
                 bg='cyan', fg='black', width=14).pack(side=tk.LEFT, padx=2)
        tk.Button(powerup_frame, text="Shrink", command=lambda: self.select_powerup_type('shrink'),
                 bg='pink', fg='black', width=14).pack(side=tk.LEFT, padx=2)

        # background color row
        bgcolor_frame = tk.Frame(control_frame, bg='lightgray')
        bgcolor_frame.pack(pady=5)
        tk.Label(bgcolor_frame, text="BG Color:", bg='lightgray', font=('Arial', 10, 'bold')).pack(side=tk.LEFT, padx=5)
        tk.Button(bgcolor_frame, text="Pick Color", command=self.pick_bg_color, bg='orange', fg='black', width=12).pack(side=tk.LEFT, padx=2)

        # canvas with scrollbar
        canvas_frame = tk.Frame(self.root, bg='white')
        canvas_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)

        # horizontal scrollbar
        h_scrollbar = tk.Scrollbar(canvas_frame, orient=tk.HORIZONTAL)
        h_scrollbar.pack(side=tk.BOTTOM, fill=tk.X)
        self.actual_canvas_width = 6000  

        self.canvas = tk.Canvas(canvas_frame, bg='skyblue', width=self.canvas_width,
                               height=self.canvas_height, scrollregion=(0, 0, self.actual_canvas_width, self.canvas_height),
                               xscrollcommand=h_scrollbar.set)
        self.canvas.pack(side=tk.TOP, fill=tk.BOTH, expand=True)

        h_scrollbar.config(command=self.canvas.xview)

        self.canvas.bind('<Button-1>', self.add_pipe)
        self.canvas.bind('<Button-2>', self.select_pipe)  
        self.canvas.bind('<Button-3>', self.remove_pipe)
        self.draw_canvas()

    def select_powerup_type(self, powerup_type):
        self.selected_powerup_type = powerup_type
        print(f"Selected power-up type: {powerup_type}")

    def pick_bg_color(self):
        color = colorchooser.askcolor(color=(self.bg_r, self.bg_g, self.bg_b))
        if color[0]:  
            self.bg_r = int(color[0][0])
            self.bg_g = int(color[0][1])
            self.bg_b = int(color[0][2])
            self.draw_canvas()
            print(f"Selected BG color: RGB({self.bg_r}, {self.bg_g}, {self.bg_b})")

    def update_settings(self):
        try:
            self.pipe_width = self.width_var.get()
            self.pipe_gap = self.gap_var.get()
            self.gravity = self.gravity_var.get()
            if self.selected_pipe is not None and 0 <= self.selected_pipe < len(self.pipes):
                self.pipes[self.selected_pipe]['width'] = self.pipe_width
                self.pipes[self.selected_pipe]['gap_height'] = self.pipe_gap
            self.draw_canvas()
        except:
            pass 
    def add_pipe(self, event):
        x = self.canvas.canvasx(event.x)
        y = event.y

        # if a power-up is selected, place it instead of a pipe
        if self.selected_powerup_type is not None:
            self.powerups.append({
                'x': x, 'y': y, 'type': self.selected_powerup_type
            })
            self.selected_powerup_type = None 
            self.draw_canvas()
            return
        gap_top = y - self.pipe_gap // 2
        if gap_top < 30:
            gap_top = 30
        if gap_top + self.pipe_gap > self.canvas_height - 50:
            gap_top = self.canvas_height - 50 - self.pipe_gap

        # store pipe with its individual properties
        self.pipes.append({
            'x': x, 'gap_top': gap_top,
            'width': self.pipe_width, 'gap_height': self.pipe_gap
        })
        self.draw_canvas()

    def remove_pipe(self, event):
        x = self.canvas.canvasx(event.x)
        y = event.y
        for i, powerup in enumerate(self.powerups):
            if abs(powerup['x'] - x) < 15 and abs(powerup['y'] - y) < 15:
                self.powerups.pop(i)
                self.draw_canvas()
                return

        # find pipe near the click
        to_remove = None
        for i, pipe in enumerate(self.pipes):
            px = pipe['x']
            py = pipe['gap_top']
            pipe_width = pipe['width']
            if abs(px - x) < pipe_width // 2 and abs(py - y) < 100:
                to_remove = i
                break

        if to_remove is not None:
            if self.selected_pipe == to_remove:
                self.selected_pipe = None
            elif self.selected_pipe is not None and self.selected_pipe > to_remove:
                self.selected_pipe -= 1
            self.pipes.pop(to_remove)
            self.draw_canvas()

    def select_pipe(self, event):
        x = self.canvas.canvasx(event.x)
        y = event.y
        for i, pipe in enumerate(self.pipes):
            px = pipe['x']
            py = pipe['gap_top']
            pipe_width = pipe['width']
            pipe_gap = pipe['gap_height']

            if abs(px - x) < pipe_width // 2 and abs(py + pipe_gap // 2 - y) < pipe_gap // 2 + 50:
                self.selected_pipe = i
                self.width_var.set(pipe['width'])
                self.gap_var.set(pipe['gap_height'])
                self.draw_canvas()
                return
        self.selected_pipe = None
        self.draw_canvas()

    def draw_canvas(self):
        self.canvas.delete('all')

        bg_color = f'#{self.bg_r:02x}{self.bg_g:02x}{self.bg_b:02x}'
        self.canvas.config(bg=bg_color)

        # draw ground across full width
        self.canvas.create_rectangle(0, self.canvas_height - 50, self.actual_canvas_width, self.canvas_height,
        fill='brown', outline='black')

        # draw pipes
        for i, pipe in enumerate(self.pipes):
            px = pipe['x']
            gap_top = pipe['gap_top']
            pipe_width = pipe['width']
            pipe_gap = pipe['gap_height']

            is_selected = (i == self.selected_pipe)
            fill_color = 'yellow' if is_selected else 'green'
            outline_color = 'orange' if is_selected else 'darkgreen'
            outline_width = 4 if is_selected else 2

            # top pipe
            self.canvas.create_rectangle(px - pipe_width//2, 0, px + pipe_width//2, gap_top,
            fill=fill_color, outline=outline_color, width=outline_width)

            gap_bottom = gap_top + pipe_gap
            self.canvas.create_rectangle(px - pipe_width//2, gap_bottom,
            px + pipe_width//2, self.canvas_height - 50, fill=fill_color, outline=outline_color, width=outline_width)

            marker_color = 'orange' if is_selected else 'red'
            self.canvas.create_oval(px - 5, gap_top + pipe_gap//2 - 5, px + 5, gap_top + pipe_gap//2 + 5,
            fill=marker_color)

        # draw power-ups
        powerup_colors = {
            'invincibility': 'gold',
            'speed': 'cyan',
            'shrink': 'pink',
        }
        powerup_symbols = {
            'invincibility': '⭐',
            'speed': '⚡',
            'shrink': '🎯',
        }

        for powerup in self.powerups:
            px = powerup['x']
            py = powerup['y']
            ptype = powerup['type']
            color = powerup_colors.get(ptype, 'white')

            # Draw power-up 
            self.canvas.create_oval(px - 15, py - 15, px + 15, py + 15, fill=color, outline='white', width=3)
            # Draw symbol
            self.canvas.create_text(px, py, text=powerup_symbols.get(ptype, '?'), font=('Arial', 16), fill='white')

    def save_level(self):
        self.level_name = self.name_entry.get()
        level_data = {
            "type": "Level",
            "name": self.level_name,
            "width": 800,
            "height": 600,
            "gravity": self.gravity,
            "bgR": self.bg_r,
            "bgG": self.bg_g,
            "bgB": self.bg_b,
            "gameObjects": []
        }
        level_data["gameObjects"].append({
            "type": "GameObject",
            "name": "Ground",
            "active": True,
            "components": [
                {
                    "type": "Transform",
                    "x": 0.0,
                    "y": 550.0,
                    "rotation": 0.0,
                    "scaleX": 1.0,
                    "scaleY": 1.0
                },
                {
                    "type": "Sprite",
                    "width": 800,
                    "height": 50,
                    "r": 139,
                    "g": 69,
                    "b": 19
                },
                {
                    "type": "Collider",
                    "width": 800,
                    "height": 50,
                    "isTrigger": False,
                    "tag": "ground"
                }
            ]
        })

        # add the pipes
        for i, pipe in enumerate(self.pipes):
            px = pipe['x']
            gap_top = pipe['gap_top']
            pipe_width = pipe['width']
            pipe_gap = pipe['gap_height']

            # top pipe
            level_data["gameObjects"].append({
                "type": "GameObject",
                "name": f"Pipe{i}_Top",
                "active": True,
                "components": [
                    {
                        "type": "Transform",
                        "x": float(px - pipe_width//2),
                        "y": 0.0,
                        "rotation": 0.0,
                        "scaleX": 1.0,
                        "scaleY": 1.0
                    },
                    {
                        "type": "Sprite",
                        "width": pipe_width,
                        "height": int(gap_top),
                        "r": 34,
                        "g": 139,
                        "b": 34
                    },
                    {
                        "type": "Collider",
                        "width": pipe_width,
                        "height": int(gap_top),
                        "isTrigger": False,
                        "tag": "pipe"
                    }
                ]
            })

            # bottom pipe
            gap_bottom = gap_top + pipe_gap
            bottom_height = self.canvas_height - 50 - gap_bottom
            level_data["gameObjects"].append({
                "type": "GameObject",
                "name": f"Pipe{i}_Bottom",
                "active": True,
                "components": [
                    {
                        "type": "Transform",
                        "x": float(px - pipe_width//2),
                        "y": float(gap_bottom),
                        "rotation": 0.0,
                        "scaleX": 1.0,
                        "scaleY": 1.0
                    },
                    {
                        "type": "Sprite",
                        "width": pipe_width,
                        "height": int(bottom_height),
                        "r": 34,
                        "g": 139,
                        "b": 34
                    },
                    {
                        "type": "Collider",
                        "width": pipe_width,
                        "height": int(bottom_height),
                        "isTrigger": False,
                        "tag": "pipe"
                    }
                ]
            })

        # add power-ups
        powerup_tag_map = {
            'invincibility': 'powerup_invincibility',
            'speed': 'powerup_speed',
            'shrink': 'powerup_shrink',
        }

        for i, powerup in enumerate(self.powerups):
            tag = powerup_tag_map.get(powerup['type'], 'powerup')
            level_data["gameObjects"].append({
                "type": "GameObject",
                "name": f"PowerUp_{powerup['type']}_{i}",
                "active": True,
                "components": [
                    {
                        "type": "Transform",
                        "x": float(powerup['x']),
                        "y": float(powerup['y']),
                        "rotation": 0.0,
                        "scaleX": 1.0,
                        "scaleY": 1.0
                    },
                    {
                        "type": "Sprite",
                        "width": 20,
                        "height": 20,
                        "r": 255,
                        "g": 255,
                        "b": 0
                    },
                    {
                        "type": "Collider",
                        "width": 20,
                        "height": 20,
                        "isTrigger": True,
                        "tag": tag
                    }
                ]
            })

        # save file
        filename = self.level_name.replace(" ", "_") + ".json"
        filepath = filedialog.asksaveasfilename(
            defaultextension=".json",
            filetypes=[("JSON files", "*.json")],
            initialdir="../levels",
            initialfile=filename
        )

        if filepath:
            with open(filepath, 'w') as f:
                json.dump(level_data, f, indent=2)
            messagebox.showinfo("Success", f"Level saved!\n{os.path.basename(filepath)}")

    def load_level(self):
        filepath = filedialog.askopenfilename(
            filetypes=[("JSON files", "*.json")],
            initialdir="../levels"
        )
        if not filepath:
            return

        try:
            with open(filepath, 'r') as f:
                data = json.load(f)
            self.level_name = data.get("name", "Loaded Level")
            self.name_entry.delete(0, tk.END)
            self.name_entry.insert(0, self.level_name)
            self.gravity = data.get("gravity", 800.0)
            self.gravity_var.set(int(self.gravity))

            # load background color
            self.bg_r = data.get("bgR", 135)
            self.bg_g = data.get("bgG", 206)
            self.bg_b = data.get("bgB", 235)
            self.pipes = []
            pipe_pairs = {}

            for obj in data.get("gameObjects", []):
                name = obj.get("name", "")
                if "Pipe" in name and name != "Ground":
                    x = y = width = height = 0
                    for comp in obj.get("components", []):
                        if comp.get("type") == "Transform":
                            x = comp.get("x", 0)
                            y = comp.get("y", 0)
                        if comp.get("type") == "Sprite":
                            width = comp.get("width", 60)
                            height = comp.get("height", 100)
                    if "_Top" in name:
                        pipe_num = name.replace("Pipe", "").replace("_Top", "")
                        if pipe_num not in pipe_pairs:
                            pipe_pairs[pipe_num] = {}
                        pipe_pairs[pipe_num]["top"] = (x + width//2, height)
                        pipe_pairs[pipe_num]["width"] = width
                    elif "_Bottom" in name:
                        pipe_num = name.replace("Pipe", "").replace("_Bottom", "")
                        if pipe_num not in pipe_pairs:
                            pipe_pairs[pipe_num] = {}
                        pipe_pairs[pipe_num]["bottom_y"] = y

            for pipe_num, pipe_data in pipe_pairs.items():
                if "top" in pipe_data and "bottom_y" in pipe_data:
                    x, top_height = pipe_data["top"]
                    gap_top = top_height
                    gap_bottom = pipe_data["bottom_y"]
                    gap_height = gap_bottom - gap_top
                    pipe_width = pipe_data.get("width", 60)

                    self.pipes.append({
                        'x': x,
                        'gap_top': gap_top,
                        'width': pipe_width,
                        'gap_height': gap_height
                    })

            # load power-ups
            self.powerups = []
            tag_to_type_map = {
                'powerup_invincibility': 'invincibility',
                'powerup_speed': 'speed',
                'powerup_shrink': 'shrink',
            }

            for obj in data.get("gameObjects", []):
                name = obj.get("name", "")
                if "PowerUp" in name:
                    x = y = 0
                    tag = ""
                    for comp in obj.get("components", []):
                        if comp.get("type") == "Transform":
                            x = comp.get("x", 0)
                            y = comp.get("y", 0)
                        if comp.get("type") == "Collider":
                            tag = comp.get("tag", "")
                    powerup_type = tag_to_type_map.get(tag)
                    if powerup_type:
                        self.powerups.append({
                            'x': x, 'y': y, 'type': powerup_type
                        })
            self.draw_canvas()
            messagebox.showinfo("Success", f"Level loaded!\n{len(self.pipes)} pipes, {len(self.powerups)} power-ups")

        except Exception as e:
            messagebox.showerror("Error", f"Failed to load level:\n{str(e)}")

    def clear_all(self):
        if messagebox.askyesno("Clear All", "Remove all pipes and power-ups?"):
            self.pipes = []
            self.powerups = []
            self.draw_canvas()

def main():
    root = tk.Tk()
    app = Editor(root)
    root.mainloop()

if __name__ == "__main__":
    main()
