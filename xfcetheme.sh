#!/bin/bash

xfconf-query -c xfce4-panel -p /panels -n -t int -s 1 -a
xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "WhiteSur-dark"
xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "Materia-dark"
xfconf-query -c xfwm4 -p /general/button_layout -n -t string -s "|HMC"
xfconf-query -c xfwm4 -p /general/theme -n -t string -s "Materia-dark"
xfconf-query -c xfwm4 -p /general/raise_with_any_button -n -t bool -s false
xfconf-query -c xfwm4 -p /general/mousewheel_rollup -n -t bool -s false
xfconf-query -c xfwm4 -p /general/scroll_workspaces -n -t bool -s false
xfconf-query -c xfwm4 -p /general/placement_ratio -n -t int -s 100
xfconf-query -c xfwm4 -p /general/show_popup_shadow -n -t bool -s true
xfconf-query -c xfce4-panel -p /panels/panel-1/size -n -t int -s 32
xfconf-query -c xfce4-panel -p /panels/panel-1/icon-size -n -t int -s 24
xfconf-query -c xfce4-panel -p /plugins/plugin-1/show-button-title -n -t bool -s false
xfconf-query -c xfce4-panel -p /plugins/plugin-1/button-icon -n -t string -s "desktop-environment-xfce"
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -n -t bool -s false
xfconf-query -c xfce4-notifyd -p  /do-slideout -n -t bool -s true
xfconf-query -c xfce4-notifyd -p  /notify-location -n -t int -s 3
xfconf-query -c xfce4-notifyd -p  /expire-timeout -n -t int -s 5
xfconf-query -c xfce4-notifyd -p  /initial-opacity -n -t double -s 1

rm -f xfcetheme.sh