# rlib + rcore

# Usage
Lua library used as the foundation of scripts developed by Richard for the steam game Garry's Mod.
You must install this library on your gmod server before any modules can be installed and function properly.

# Installation
- Download the latest copy of rlib and extract the zip to a local folder on your computer
- Create a new folder within your gmod server's file structure in the **addons** folder.
  - recommended path **garrysmod/addons/rlib/**
  - do **not** use **spaces** or **special characters** when naming your folder.
- Upload the extracted zip contents to your newly created server folder
- Reboot your server after files transferred.
- To confirm that rlib is installed:
  - Read your server console and check for any mention of rlib loading
  - Type **rlib.status** in your console and check for output.
  
# About
rlib contains a wide variety of commonly used functions that are required for Richard's scripts to work properly. It acts as a foundation for the scripts (modules), and also a debugging utility which helps monitor the server for actions, issues, and anything that the server owner should be made aware of.

All scripts are treated as **modules**, and can be installed in one of two locations:
- In the provided modules folder located in **garrysmod/addons/rlib/lua/modules** OR;
- As a seperate folder in the base addons directory (with proper file structure being used)

##### Note
If your script included a PDF guide, follow the installation instructions provided in that. The allowed choices of installation above include an additional method if you are developing a script using rlib.

# Help
Along with this quick guide; your script should also include a pdf with detailed information on how to install both rlib and your script. Review both carefully.

# Documentation
For detailed information related to rlib, rcore, and any particular feature or function, please view the documentation.
