//KSP kOS Orbit Guidance Computer
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
//To run the OGC type "run ogc." and press enter. Using your orbit's eccentricity
//this program will make the required maneuvers and throttle adjustments to
//circularize your craft/probe's orbit.

//Note this will not make apoapsis/periapsis adjustments, it will just correct
//an elliptical orbit into a more circular orbit.

clearscreen.
print "************ ORBIT GUIDANCE COMPUTER *************".
print "Craft....: "+ship:shipname.
print "**************************************************".

rcs on.
sas off.
lock throttle to 1.
set ecc to orbit:eccentricity.

until ecc < orbit:eccentricity
  {
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
        print "Aborting... not enough thrust available." at (0,10).
        break.
      }

    set angle to arctan(totalForce/sqrt(thrust^2-totalForce^2)).

    lock throttle to power.
    lock steering to up + R(0,angle-90,180).
    wait 0.1.
  }

lock throttle to 0.
sas on.
rcs off.
