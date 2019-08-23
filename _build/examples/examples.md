---
interact_link: content/examples/examples.ipynb
kernel_name: python3
has_widgets: false
title: 'Examples'
prev_page:
  url: /tutorial/tutorial
  title: 'Tutorial'
next_page:
  url: /documentation/pstate-core/core
  title: 'pState Documentation'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---


# pState Examples
---



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
from pstate import *
from IPython.display import display

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
pChart("water_monitoring").chart

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("water_monitoring"))

```
</div>

</div>



## State Invariants



PRISM uses properties for analysis of its models. In pState, we use state invariants, which are simpler to read and write, and serve the same purpose. Below are some of these properties translated into state invariants.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# display(pChart(""))

```
</div>

</div>



## Luxury Car Seat



Some cars contain luxury features, one of which is power seats. Power seats have a panel of controls that allow you to adjust your seating position automatically. The seats are controlled by motors, and the one in the example below has 5 motors. These are:
1. Rear Height Motor (RH)
   * Can move up, down 
2. Longitudinal Adjustment Motor (LA)
   * Can move forward, backward
3. Front Height Motor (FH)
   * Can move up, down
4. Backrest Motor (B)
   * Can move forward, backward
5. Head Restraint Motor (HR)
   * Can move up, down

Each motor has 2 corresponding buttons (one for each direction). There are also 3 additional buttons, M, M1, M2, which control the memory functionality. If you hold M and press and release M1 or M2, the current position of the seat will be saved into their respective memory slots and can be loaded at a later time. To load the seat settings you press and M1 or M2 to load the seat position from memory. <br>

There are two groups of motors, Group 1 (LA, RH) and Group 2 (FH, B, HR). Only one motor per group can be active at any given time. Within each group, there are motors which take priority over another, meaning if they are both being pressed, the one with the higher priority will be active. In Group 1, LA has priority over RH. In Group 2, FH has priority over B, B has priority over HR.<br>
Each motor is also equipped with a Hall effect sensor which allow them to keep track of their position. The motors are controlled by *ticks*. <br>
The number of ticks required for movement from one stop to the other is:
* RH: 250 ticks
* LA: 600 ticks
* FH: 250 ticks
* B: 1100 ticks
* HR: 130 ticks





<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("car_seat"))

```
</div>

</div>



## Landing Gear
The landing gear of planes are usually very simple, however they are safety critical systems. In the example below, the landing gear of a typical airplane is modelled, along with the landing gear level in the cockpit. One important aspect is the state invariant of GearSystem, which says that if the landing gear is extending or retracting, the doors for the gear should not be opening, closing or closed. 



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("landing_gear"))

```
</div>

</div>



## Production Cell
The example below is of a production cell which consists of 5 interacting machines: 
1. Feed Belt
2. Table
3. 2-Armed Robot
4. Press
5. Deposit Belt

The production cell presses metal plates which arrive on the feed belt, and delivers them to the deposit belt.
The process is as follows:
1. The feed belt delivers the plate to the table
2. The table elevates and rotates so the robot can grip it with arm 1
3. The robot grips the plate with arm 1, rotates CCW and feeds the press
4. The press forms the plate
5. The robot rotates CW and arm 2 grips the pressed plate
6. The robot rotates CCW and drops the plate on the deposit belt
7. The deposit belt delivers the plate to the end

The machine processes several plates at a time.

### Feed Belt

The feed belt transports plates from one side to the other. It can detect when a plate arrives at the end and when it falls onto the table. The belt can be switched on and off. It is on when waiting for a plate, and off when a plate is at the end but cannot be delivered. <br>
The belt is initially running and empty. 



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("feed_belt"))

```
</div>

</div>



### Table
The table lifts and rotates in order to position the plate for the robot to pick it up. It consists of two motors, one for elevating and one for rotating. The table can sense when it is at its upper/lower end and left/right end. <br>
Initially, the table is in the lower-left position.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("table"))

```
</div>

</div>



### Robot
The robot consists of 2 orthogonal arms, which can extend and retract, and a rotating base. 
There are 3 relevant positions for the base: 
* Position 1: aligns arm 1 with the table
* Position 2: aligns arm 2 with the press
* Position 3: aligns arm 1 with the press and arm 2 with the delivery belt

The arms have 3 sensor positions inner, middle, and outer. Each arm also has an electromagnetic gripper which can be turned on and off. The arms have to be in these positions during the process:
* In position 1, arm 1 has to extend to its middle position 
  * This lets arm 1 grab the plate from the table
* In position 2, arm 2 has to extend to its outer position
  * This lets arm 2 pick up the plate from the press
* In position 3, arm 1 has to extend to its outer position and arm 2 has to extend to its middle position
  * This is lets arm 1 load the plate into the press and lets arm 2 drop the plate on the delivery belt
* When the base is rotating, the arms of the robot must be fully retracted and in the inner position.

The initial position of the robot base is in position 3, arm 1 retracted to its inner position, arm 2 extended to its middle position, and both grippers are off.

#### Robot Base



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("robot_base"))

```
</div>

</div>



#### Robot Arms



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("robot_arms"))

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("robot"))

```
</div>

</div>



### Press
The press consists of a platform which moves up and down, forming the plate against a mould. It closes by moving the platform up, and closes by moving it down. <br>
Arm 1 and arm 2 are at different heights, so the press has to be at different positions for loading and unloading. There is a lower, middle, and upper position. It is unloaded by arm 2 in the lower position, and loaded by arm 1 in the middle position. <br>
For safety, the following conditions are met:
* When the robot is in position 3, arm 1 only extends if the platform is in the middle position.
* When the robot is in position 2, arm 2 only extends if the platform is in the lower position. 
* The platform only moves when after the robot loading/unloading retracts its arm to the inner position.

The initial position of the press is in its lower position, and is empty. 



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("press"))

```
</div>

</div>



### Deposit Belt
The deposit belt transports plates from one end to the other. The belt senses when a plate arrives at the end and when it's been removed. The belt can be switched on or off. It is off when waiting for a plate to be placed or when a plate reaches the end. It is on when a plate is placed on it and there is no plate on the end. A new plate can only be placed on the belt if there is no additional plate on, or at the end of, the belt.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("deposit_belt"))

```
</div>

</div>



## KeyFob
---



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("key_fob"))

```
</div>

</div>



## Sender Reciever
---



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("sender_reciever"))

```
</div>

</div>



## GPS Module
---



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("gps_module"))

```
</div>

</div>



---
# Examples using Widgets
---



## Safe
---



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
import ipywidgets as widgets

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
safe_chart = pChart("safe")

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(safe_chart)

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
number1 = widgets.BoundedIntText(value=0, min=0, max=60, step=1, description='1st Number:', disabled=False)
number2 = widgets.BoundedIntText(value=0, min=0, max=60, step=1, description='2nd Number:', disabled=True)
number3 = widgets.BoundedIntText(value=0, min=0, max=60, step=1, description='3rd Number:', disabled=True)

reset_button = widgets.Button(description='Reset', button_style='danger')
reset = False

def reset_clicked(button):
    global reset
    reset = True
    reset_state(button)

def reset_state(button):
    global number1, number2, number3, reset
    reset_clicked()
    number1.value = 0
    number2.value = 0
    number3.value = 0
    number1.disabled = False
    number2.disabled = True
    number3.disabled = True
    reset = False
    
def cracking(val1, val2, val3):
    global number1, number2, number3
    
    result1 = val1 == 0b100001
    if result1:
        print("Click")
        number1.disabled = True
        number2.disabled = False
    else:
        print("The safe is locked.")

    result2 = result1 and val2 == 0b101100
    if result2:
        print("Clack")
        number2.disabled = True
        number3.disabled = False
    
    result3 = result2 and val3 == 0b110111
    if result3:
        print("You've cracked the safe!")
        number3.disabled = True


out = widgets.interactive_output(cracking, {'val1': number1, 'val2': number2, 'val3': number3})
reset_button.on_click(reset_state)

left_VBox = widgets.VBox([number1, number2, number3])
right_VBox = widgets.VBox([reset_button, out])
display(widgets.HBox([left_VBox, right_VBox]))

```
</div>

</div>



## Light switch
---



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
light_switch_chart = pChart("light_switch")

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(light_switch_chart)

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# Lightbulb SVG
# Obtained from: https://www.svgrepo.com/svg/17720/lightbulb-on
def lightbulb_svg(light):
    return widgets.HTML('''
    <svg version="1.1"
        xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" 
        width="300px" height="300px" viewBox="0 0 468.759 468.759">
        <g fill="{0}">
            <path d="M234.38,0c-72.257,0-131.039,59.728-131.039,133.146c0,29.205,16.976,55.49,31.951,78.672
            c8.831,13.66,17.165,26.563,19.036,36.209c5.261,27.225,8.275,91.806,8.299,92.456c0.212,4.516,3.921,8.068,8.449,8.068h126.611
            c2.329,0,4.552-0.952,6.147-2.642c1.596-1.697,2.424-3.967,2.293-6.283c-1.572-28.307-0.484-78.489,9.127-92.699
            c1.666-2.459,3.582-5.178,5.65-8.156c16.656-23.759,44.514-63.541,44.514-105.632C365.406,59.734,306.636,0,234.38,0z
             M307.062,229.092c-2.146,3.047-4.091,5.85-5.805,8.367c-13.252,19.588-13.074,72.359-12.389,94.193H179.114
            c-0.993-18.535-3.794-64.025-8.195-86.822c-2.494-12.874-11.266-26.451-21.42-42.183c-13.716-21.226-29.247-45.273-29.247-69.496
            c0-64.096,51.199-116.235,114.122-116.235c62.924,0,114.123,52.139,114.123,116.235
            C348.502,169.911,322.554,206.956,307.062,229.092z M168.864,361.118h131.033v65.521c0,12.318-7.979,22.662-19.026,26.445
            c-2.052,8.973-10.025,15.675-19.612,15.675h-53.765c-9.587,0-17.566-6.702-19.612-15.675
            c-11.038-3.783-19.024-14.127-19.024-26.445v-65.521H168.864z M215.985,41.304c0.919,3.212 0.931,6.567-4.152,7.48
            c-59.32,17.002-59.92,80.741-59.92,83.442c0,3.34-2.692,6.059-6.041,6.064h-0.012c-3.333,0-6.041-2.687-6.053-6.023
            c0-0.75,0.473-75.566,68.698-95.116C211.694,36.232,215.066,38.083,215.985,41.304z M319.119,163.687
            c-1.194,1.327-2.843,1.998-4.492,1.998c-1.442,0-2.902-0.515-4.055-1.555c-2.482-2.24-2.684-6.064-0.438-8.553
            c19.15-21.258,3.168-47.242,3.003-47.502c-1.785-2.831-0.935-6.567,1.892-8.346c2.825-1.785,6.561-0.932,8.346,1.894
            C330.728,113.3,339.311,141.294,319.119,163.687"/>
        </g></svg>'''.format('#FFFF00' if light else '#000000'))

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
light = False
lightbulb = lightbulb_svg(light)
switch_button = widgets.Button(
    description='Flip switch',
    button_style='success' if light else 'danger'
)
info_button = widgets.Button(
    description = 'Light is on' if light else 'Light is off',
    button_style = '',
    disabled = True
)


def light_switch(b):
    global light, lightbulb
    light = False if light else True
    switch_button.button_style = 'success' if light else 'danger'
    info_button.description = 'Light is on' if light else 'Light is off'
    lightbulb.value = lightbulb_svg(light).value
    
switch_button.on_click(light_switch)
widget = widgets.HBox([switch_button, info_button, lightbulb])
display(widget)

```
</div>

</div>



## Speedometer
---



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def update_svg(rotation):
    return widgets.HTML('''<?xml version='1.0' encoding='iso-8859-1'?>
    <!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'>
    <svg version="1.1" 
        xmlns="http://www.w3.org/2000/svg" viewBox="0 0 238 115" 
        width='460' height='238'
        xmlns:xlink="http://www.w3.org/1999/xlink" enable-background="new 0 0 400 400">
        <g>
            <circle r="100" cx="50%" cy="100%" stroke="#FF0000" stroke-width="15" stroke-dasharray="314.159, 628.318" fill="none" transform="rotate (-180 115 115)" />
            <rect width="100" height="4" transform="translate(111, 113) rotate({0}, 0, 2)"/>
        </g>
    </svg>'''.format(rotation))

def update_speed(speed):
    global speedometer_html
    speedometer_html.value = update_svg(-180 + speed['new']).value
gas_pedal = widgets.IntSlider(orientation="vertical", min=0, max=180)
speedometer_html = update_svg(-180)

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
speedometer = widgets.HBox([gas_pedal, speedometer_html])
gas_pedal.observe(update_speed, names=['value'])
display(speedometer)

```
</div>

</div>



## Create your own examples
---

