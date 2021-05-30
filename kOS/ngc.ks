//KSP kOS Node Guidance Computer
//Copyright 2021 Haynie IPHC, LLC
//Developed by Haynie Research & Development, LLC
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.#
//You may obtain a copy of the License at
//http://www.apache.org/licenses/LICENSE-2.0
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

//This script is designed to be used with kOS: Kerbal Operating System with the
//Kerbal Space Program. kOS is a programmable autopilot mod.
//Link to kOS: https://ksp-kos.github.io/KOS/

//To use this script save inside Ships/Script which are in the KSP root directory.
//You will need to place one of the kOS devices on your ship, and right click
//to access the terminal.

//Type "switch to 0." and press enter to access the scripts in Ships/Script.
//To run the NGC type "run ngc." and press enter at some point before
//your next maneuver node. This should be ran at some point in time that is
//at least half the duration of the total burn before the node. For example:
//on a maneuver node that is 30 seconds, this should be executed 15 seconds
//before the node is reached. The program will then execute the maneuver
//automatically allowing for more precise burns than manual.

set acc to ship:maxthrust/ship:mass.
set burnTime to nextnode:deltav:mag/acc.
print round(nextnode:eta-(burnTime/2),2) at (11,6).

clearscreen.
print "************* NODE GUIDANCE COMPUTER *************".
print "Craft....: "+ship:shipname.
print "ΔV Rqd...: "+round(nextnode:deltav:mag).
print "ΔV Cur...: "+round(ship:deltav:current).
print "ΔV Rem...: "+round(ship:deltav:current-nextnode:deltav:mag,2).
print "Burn Time: "+round(burnTime)+"s".
print "ETA......: ".
print "**************************************************".

sas off.
rcs on.

if nextnode:eta-(burnTime/2) < 0
  {
    print "Aborting... Next maneuver node is behind craft." at (0,20).
    null.
  }.

when nextnode:eta > (burnTime/2 + 60)*2 then
  {
    rcs off.
    wait 0.5.
    set kuniverse:timewarp:warp to 4.
  }.

when nextnode:eta > (burnTime/2 + 60) then
  {
    rcs off.
    wait 0.5.
    set kuniverse:timewarp:warp to 2.
  }.

when nextnode:eta <= (burnTime/2 + 60) then
  {
    rcs on.
    wait 0.5.
    set kuniverse:timewarp:warp to 0.
  }.

until nextnode:eta <= (burnTime/2 + 60)
  {
    print round(nextnode:eta-(burnTime/2),2) at (11,6).
  }.

lock steering to nextnode:deltav.

until vang(nextnode:deltav, ship:facing:vector) < 0.25
  {
    print round(nextnode:eta-(burnTime/2),2) at (11,6).
  }.

until nextnode:eta <= (burnTime/2).
  {
    print round(nextnode:eta-(burnTime/2),2) at (11,6).
  }.

set thrl to 0.
lock throttle to thrl.
set done to false.
set dv to nextnode:deltav.

until done
  {
    print round(nextnode:eta-(burnTime/2),2) at (11,6).
    set acc to ship:maxthrust/ship:mass.
    set thrl to min(nextnode:deltav:mag/acc, 1).

    if vdot(dv, nextnode:deltav) < 0
      {
        lock throttle to 0.
        break.
      }

    if nextnode:deltav:mag < 0.1
      {
        wait until vdot(dv, nextnode:deltav) < 0.5.
        lock throttle to 0.
        set done to True.
      }
  }.

unlock steering.
unlock throttle.
set ship:control:pilotmainthrottle to 0.
rcs off.
sas on.
