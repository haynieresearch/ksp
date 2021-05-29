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

declare parameter orbit.
set minSpeed to 100.
set maxPitch to 90.
set minPitch to 45.
set step to 5.

set massTons to round(ship:wetmass,2).
if massTons <= 100
  {
    set stepSpeed to 70.
    set sizeTxt to "Ultralight".
  }
else if massTons > 100 and massTons <= 250
  {
    set stepSpeed to 60.
    set sizeTxt to "Light".
  }
else if massTons > 250 and massTons <= 500
  {
    set stepSpeed to 60.
    set sizeTxt to "Medium".
  }
else if massTons > 500 and massTons <= 1000
  {
    set stepSpeed to 60.
    set sizeTxt to "Large".
  }
else if massTons > 1500
  {
    set stepSpeed to 60.
    set sizeTxt to "Heavy".
  }

set solid to 25.
set row to 9.

set warpFlag1 to 0.
set warpFlag2 to 0.

clearscreen.
print "************ LAUNCH GUIDANCE COMPUTER ************".
print "Craft....: "+ship:shipname.
print "Type.....: "+sizeTxt+" "+ship:type.
print "Mass.....: "+massTons+"t".
print "Status...: "+ship:status.
print "Target AP: "+orbit.
print "T-.......: 00:00:00".
print "**************************************************".

from {local countdown is 5.} until countdown = 0 step {set countdown to countdown - 1.}
  do
    {
      print countdown at (18,6).
      wait 1.
    }.

print "0" at (18,6).
print "LIFTOFF            " at (11,4).
print "Msg:" at (0,8).
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

when ship:apoapsis >= orbit and altitude >= 55000 and eta:apoapsis > 30 and warpFlag1 = 1 then
  {
    rcs off.
    wait 0.5.
    set kuniverse:timewarp:warp to 4.
  }.

when eta:apoapsis <= 30 and warpFlag1 = 1 then
  {
    set kuniverse:timewarp:warp to 0.
    rcs on.
  }.

when ship:apoapsis > orbit+(orbit*0.025) and eta:periapsis > 60 and warpFlag2 = 1 then
  {
    rcs off.
    wait 0.5.
    set kuniverse:timewarp:warp to 4.
  }.

when eta:periapsis <= 60 and warpFlag2 = 1 then
  {
    set kuniverse:timewarp:warp to 0.
    rcs on.
  }.

when maxthrust = 0 then
  {
    print "Jettisoning boosters                   " at (5,8).
    stage.
  }

when stage:liquidfuel = 0 then
  {
    print "Jettisoning boosters                   " at (5,8).
    stage.
  }.

when stage:solidfuel < varSrbEmpty then
  {
    print "Jettisoning boosters                   " at (5,8).
    stage.
  }.

sas off.
rcs off.
lock throttle to 1.

lock steering to up + R(0,0,180).
print "IN FLIGHT            " at (11,4).

until ship:apoapsis > orbit
  {
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
        set varSpeedInc to (speed - minSpeed) / stepSpeed.
        set varPitch to round(maxPitch - (varSpeedInc * step),1).

        if varPitch < minPitch set varPitch to minPitch.

        print "Adjusting pitch to "+round(varPitch,0)+" degrees" at (5,8).
        print "Apoapsis.: "+round(ship:apoapsis,0)+" " at (0,row+1).
        print "Periapsis: "+round(ship:periapsis,0)+" " at (0,row+2).

        lock steering to up + R(0,varPitch-90,180).
      }.
  }.

lock throttle to 0.
set warpFlag1 to 1.
set burnFlag to false.

print "Activating RCS                      " at (5,8).
rcs on.

until ship:periapsis > orbit
  {
    lock steering to prograde.
      if burnFlag
        {
          print "Performing orbit burn             " at (5,8).
          print "Apoapsis.: "+round(ship:apoapsis,0)+"    " at (0,row+1).
          print "Periapsis: "+round(ship:periapsis,0)+"    " at (0,row+2).
          print "ETA......: "+round(eta:apoapsis,0)+"    " at (0,row+3).
        }
      else if eta:apoapsis < 30
        {
          print "                                 " at (5,8).
          print "Apoapsis.: "+round(ship:apoapsis,0)+"    " at (0,row+1).
          print "Periapsis: "+round(ship:periapsis,0)+"    " at (0,row+2).
          print "ETA......: "+round(eta:apoapsis,0)+"    " at (0,row+3).
          lock throttle to 1.
        }
      else
        {
          print "                                 " at (5,8).
          print "Apoapsis.: "+round(ship:apoapsis,0)+"    " at (0,row+1).
          print "Periapsis: "+round(ship:periapsis,0)+"    " at (0,row+2).
          print "ETA......: "+round(eta:apoapsis,0)+"    " at (0,row+3).
        }.
  }.

lock throttle to 0.
set burnFlag to false.
set warpFlag1 to 0.
set warpFlag2 to 1.

print "Waiting for correction burn      " at (5,8).

until ship:apoapsis <= orbit+(orbit*0.025)
  {
    lock steering to retrograde.
      if burnFlag
        {
          print "Performing correction burn             " at (5,8).
          print "Apoapsis.: "+round(ship:apoapsis,0)+" " at (0,row+1).
          print "Periapsis: "+round(ship:periapsis,0)+" " at (0,row+2).
          print "ETA......: "+round(eta:periapsis,0)+" " at (0,row+3).
        }
      else if eta:periapsis < 30
        {
          print "                                 " at (5,8).
          print "Apoapsis.: "+round(ship:apoapsis,0)+" " at (0,row+1).
          print "Periapsis: "+round(ship:periapsis,0)+" " at (0,row+2).
          print "ETA......: "+round(eta:periapsis,0)+" " at (0,row+3).
          lock throttle to 1.
        }
      else
        {
          print "                                 " at (5,8).
          print "Apoapsis.: "+round(ship:apoapsis,0)+" " at (0,row+1).
          print "Periapsis: "+round(ship:periapsis,0)+" " at (0,row+2).
          print "ETA......: "+round(eta:periapsis,0)+" " at (0,row+3).
        }.
  }.

set warpFlag2 to 0.
lock throttle to 0.
set burnFlag to false.

print "ORBIT            " at (11,4).
print "Stable orbit                       " at (5,8).
print "                         " at (0,row+1).
print "Program Complete         " at (0,row+2).
print "                         " at (0,row+3).
set ship:control:pilotmainthrottle to 0.
rcs off.
sas on.
