---
interact_link: content/examples/examples.ipynb
kernel_name: python3
has_widgets: false
title: 'Examples'
prev_page:
  url: /intro
  title: 'Home'
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



## KeyFob
---



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
key_fob_chart = pChart("key_fob")

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(key_fob_chart)

```
</div>

<div class="output_wrapper" markdown="1">
<div class="output_subarea" markdown="1">
{:.output_data_text}
```

PChartModel::"key_fob". 
Either the front-end extension is missing or the chart must be re-displayed.

```

</div>
</div>
</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# analyze this chart

```
</div>

</div>



## Sender Reciever
---



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# Creating the chart object. If one does not exist with the given name, it will create a new, empty chart.
sender_reciever_chart = pChart("sender_reciever")

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# Displaying the chart. You are able to modify this chart through the UI.
display(sender_reciever_chart)

```
</div>

<div class="output_wrapper" markdown="1">
<div class="output_subarea" markdown="1">
{:.output_data_text}
```

PChartModel::"sender_reciever". 
Either the front-end extension is missing or the chart must be re-displayed.

```

</div>
</div>
</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# analyze the chart

```
</div>

</div>



## GPS Module
---



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
gps_module_chart = pChart("gps_module")

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(gps_module_chart)

```
</div>

<div class="output_wrapper" markdown="1">
<div class="output_subarea" markdown="1">
{:.output_data_text}
```

PChartModel::"gps_module". 
Either the front-end extension is missing or the chart must be re-displayed.

```

</div>
</div>
</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# analyze this chart

```
</div>

</div>



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

<div class="output_wrapper" markdown="1">
<div class="output_subarea" markdown="1">
{:.output_data_text}
```

PChartModel::"safe". 
Either the front-end extension is missing or the chart must be re-displayed.

```

</div>
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

<div class="output_wrapper" markdown="1">
<div class="output_subarea" markdown="1">
{:.output_data_text}
```
HBox(children=(VBox(children=(BoundedIntText(value=0, description='1st Number:', max=60), BoundedIntText(value…
```

</div>
</div>
</div>



## Lightbulb
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

<div class="output_wrapper" markdown="1">
<div class="output_subarea" markdown="1">
{:.output_data_text}
```

PChartModel::"light_switch". 
Either the front-end extension is missing or the chart must be re-displayed.

```

</div>
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
lightbulb = lightbulb_svg(light)
light = False
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

<div class="output_wrapper" markdown="1">
<div class="output_subarea" markdown="1">
{:.output_data_text}
```
HBox(children=(Button(button_style='danger', description='Flip switch', style=ButtonStyle()), Button(descripti…
```

</div>
</div>
</div>



## Create your own examples
---

