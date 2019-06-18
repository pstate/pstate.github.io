---
interact_link: content/examples/sender-reciever.ipynb
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
# Creating the chart object
sender_reciever_chart = pChart("sender_reciever")

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# Displaying the chart. You are able to 
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
sender_reciever_chart._save()

```
</div>

</div>

