# rlib + rcore

# Usage
Lua library used as the foundation of scripts developed by Richard for the steam game Garry's Mod.
You must install this library on your gmod server before any modules can be installed and function properly.

# Installation
- Download the latest copy of rlib and extract the zip to a local folder on your computer
- Create a new folder within your gmod server's file structure in the **addons** folder.
  - recommended path **addons/rlib/**
- Upload the extracted zip contents to your newly created server folder
- Reboot your server after files transferred.
- To confirm that rlib is installed:
  - Read your server console and check for any mention of rlib loading
  - Type **rlib.status** in your console and check for output.
  
# About
rlib contains a wide variety of commonly used functions that are required for Richard's scripts to work properly. It acts as a foundation for the scripts (modules), and also a debugging utility which helps monitor the server for actions, issues, and anything that the server owner should be made aware of.

All scripts are treated as **modules**, and can be installed in one of two locations:
- In the provided modules folder located in **addons/rlib/lua/modules** OR;
- As a seperate folder in the base addons directory (with proper file structure being used)

### Modules
All modules require a **manifest** file which gives rlib info on the module itself, and a **config** file which is where settings will be stored. This manifest file not only includes basic information such as name, description, etc., but it can also provide a list of materials to be used, netlib strings, timer ids, data folder structure setup, and more.

A properly structured module is as follows:
  #### if installed as an integrated module in **addons/rlib/lua/modules**:
  - addons
    - rlib
      - lua
        - modules
          - module_foldername
            - sh_[modulename]_manifest.lua
            - sh_[modulename]_config.lua
            - sv_[modulename].lua
            - sh_[modulename].lua
            - cl_[modulename].lua
            
  #### if installed as an stand-alone module in **addons/module_name**:
  - addons
    - module_foldername
      - resource
      - materials
      - lua
        - modules
          - module_foldername
            - sh_[modulename]_manifest.lua
            - sh_[modulename]_config.lua
            - sv_[modulename].lua
            - sh_[modulename].lua
            - cl_[modulename].lua
            
At the very minimum; a module requires two files to be present:
  - sh_[modulename]_manifest.lua
  - sh_[modulename]_config.lua

If either file is missing, the module will be _skipped_ and marked as _disabled_.

** For more in-depth information related to setting up modules, view the documentation for rlib **
