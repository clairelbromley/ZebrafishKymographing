# ClaireDataAnalysis
Scripts and tools for automated image processing for Claire PhD project

v 1.0
Doug Kelly
https://www.linkedin.com/in/doug-kelly-794a8736
2016-03-11


Getting started:

Processing:
  - in kymographBase.m, configure userParameters to taste. Comments indicate default values and provide explanation
  - run kymographBase(root), where root is a directory containing raw data arranged in folders in <ddmmyy>_E<embryo #>
  - (alternatively, run kymographUpDownWrapper(root) to generate kymographs both "above" and "below" the cut axis)
  
Viewing: 
  - run viewerMain
  - Load data (File -> Load data..., Ctrl + O) - select a base folder in which data is arranged in subfolders named <ddmmyy>, Embryo <#> <x>wards
  - Load metadata (File -> Load metadata..., Ctrl + D)
  - Browse data, pulling up particular kymographs by clicking (close to) points on the speed vs position plots
  - Middle and rightmost view panels have context menus with useful bits
  - Kymographs can be selected (i.e. quality controlled) by Include? toggle in context menu on rightmost panel
  - Metadata, fitted data and stats for included kymographs using the data export wizard (File -> Data export wizard...)
  
