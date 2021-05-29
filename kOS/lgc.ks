//KSP kOS Launch Guidance Computer
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
//To run the LGC type "run lgc(80000)." and press enter; where 80000 is the
//desired orbital altitude. You can set this to any number your ship is
//capable of, as long as it is >= 75000.

declare parameter orbitAlt.
set minSpeed to 100.
set maxPitch to 90.
set minPitch to 0.
set stepSpeed to 75.
set step to 5.
set solid to 25.
set row to 9.

set massTons to round(ship:wetmass,2).
if massTons > 500
  {
    set minSpeed to 125.
    set stepSpeed to 100.
  }

clearscreen.
print "************ LAUNCH GUIDANCE COMPUTER ************".
print "Craft....: "+ship:shipname.
print "Type.....: "+ship:type.
print "Mass.....: "+round(ship:mass,2)+"t". print "(ΔV: "+round(ship:deltav:current,2)+"m/s)" at (25,3).
print "Status...: "+ship:status.
print "Target AP: "+orbitAlt.
print "T-.......: 00:00:00".
print "**************************************************".
print "Msg:" at (0,8).

if orbitAlt < 75000
  {
    print "Aborting... Target AP should be >= 75,000." at (0,20).
    null.
  }

from {local countdown is 5.} until countdown = 0 step {set countdown to countdown - 1.}
  do
    {
      print countdown at (18,6).
      wait 1.
    }.

print "0" at (18,6).
print "LIFTOFF            " at (11,4).
print ship:shipname+" liftoff!" at (5,8).
print "Apoapsis.: "+round(ship:apoapsis,0)+" " at (0,row+1).
print "Periapsis: "+round(ship:periapsis,0)+" " at (0,row+2).
wait 0.25.

set varSrbEmpty to 1.
list engines in englist.
for eng in englist
  {
    if eng:allowshutdown = false
      {
        for res in eng:resources
          {
            if res:amount < solid
              {
                set varSrbEmpty to varSrbEmpty + res:amount.
              }.
          }.
      }.
  }.

sas off.
rcs off.

lock steering to up + R(0,0,180).
lock throttle to 1.

print "IN FLIGHT            " at (11,4).

when maxthrust = 0 then
  {
    stage.
    preserve.
  }

when stage:liquidfuel = 0 then
  {
    print "Jettisoning boosters                   " at (5,8).
    stage.
  }.

when stage:solidfuel < varSrbEmpty and altitude > 25000 then
  {
    print "Jettisoning boosters                   " at (5,8).
    stage.
  }.

until ship:apoapsis > orbitAlt
  {
    print "Mass.....: "+round(ship:mass,2)+"t" at (0,3). print "(ΔV: "+round(ship:deltav:current,2)+"m/s)" at (25,3).
    if ship:apoapsis < 45000 and ship:velocity:surface:mag >= 1500
      {
        lock throttle to 0.5.
      }
    else if ship:apoapsis < 60000 and ship:velocity:surface:mag >= 2000
      {
        lock throttle to 0.75.
      }
    else if throttle < 1
      {
        lock throttle to 1.
      }.

    set speed to ship:velocity:surface:mag.

    if speed < minSpeed
      {
        lock steering to up + R(0,maxPitch-90,180).
        print "Setting pitch to 90 degrees             " at (5,8).
      }
    else
      {
        set speedIncr to (speed - minSpeed) / stepSpeed.
        set pitch to round(maxPitch - (speedIncr * step),1).

        if pitch < minPitch set pitch to minPitch.

        print "Adjusting pitch to "+round(pitch,0)+" degrees" at (5,8).
        print "Apoapsis.: "+round(ship:apoapsis,0)+" " at (0,row+1).
        print "Periapsis: "+round(ship:periapsis,0)+" " at (0,row+2).

        lock steering to up + R(0,pitch-90,180).
      }.
  }.

lock throttle to 0.
set burnFlag to false.

print "Activating RCS                      " at (5,8).
rcs on.

until ship:periapsis > orbitAlt
  {
    print "Mass.....: "+round(ship:mass,2)+"t" at (0,3). print "(ΔV: "+round(ship:deltav:current,2)+"m/s)" at (25,3).
    lock steering to up + R(0,-90,180).
      if burnFlag
        {
          print "Performing orbit burn             " at (5,8).
          print "Apoapsis.: "+round(ship:apoapsis,0)+"    " at (0,row+1).
          print "Periapsis: "+round(ship:periapsis,0)+"    " at (0,row+2).
          print "ETA......: "+round(eta:apoapsis,0)+"    " at (0,row+3).
        }
      else if eta:apoapsis < 1
        {
          print "                                 " at (5,8).
          print "Apoapsis.: "+round(ship:apoapsis,0)+"    " at (0,row+1).
          print "Periapsis: "+round(ship:periapsis,0)+"    " at (0,row+2).
          print "ETA......: 0                " at (0,row+3).

          lock throttle to 1.
          set ecc to orbit:eccentricity.

          until ecc < orbit:eccentricity
            {
              print "Mass.....: "+round(ship:mass,2)+"t" at (0,3). print "(ΔV: "+round(ship:deltav:current,2)+"m/s)" at (25,3).
              set ecc to orbit:eccentricity.
              set power to 1.
              if orbit:eccentricity < .1
                {
                  set power to max(.02, orbit:eccentricity*10).
                }

              set radius to altitude+orbit:body:radius.
              set gForce to constant:G*mass*orbit:body:mass/radius^2.
              set cForce to mass*ship:velocity:orbit:mag^2/radius.
              set totalForce to gForce - cForce.

              set thrust to power*maxThrust.

              if thrust^2-totalForce^2 < 0
                {
                  print "Aborting... not enough thrust available." at (5,8).
                  break.
                }

              set angle to arctan(totalForce/sqrt(thrust^2-totalForce^2)).

              lock throttle to power.
              lock steering to up + R(0,angle-90,180).
              wait 0.1.
            }
        }
      else
        {
          print "Waiting for Apoapsis            " at (5,8).
          print "Apoapsis.: "+round(ship:apoapsis,0)+"    " at (0,row+1).
          print "Periapsis: "+round(ship:periapsis,0)+"    " at (0,row+2).
          print "ETA......: "+round(eta:apoapsis,0)+"    " at (0,row+3).
        }.
  }.

lock throttle to 0.
set burnFlag to false.

print "Mass.....: "+round(ship:mass,2)+"t" at (0,3). print "(ΔV: "+round(ship:deltav:current,2)+"m/s)" at (25,3).
print "ORBIT            " at (11,4).
print "Stable orbit                       " at (5,8).
print "                         " at (0,row+1).
print "Program Complete         " at (0,row+2).
print "                         " at (0,row+3).
set ship:control:pilotmainthrottle to 0.
rcs off.
sas on.
