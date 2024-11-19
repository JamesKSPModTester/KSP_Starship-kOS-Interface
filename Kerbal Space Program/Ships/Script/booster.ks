wait until ship:unpacked.



if homeconnection:isconnected {
    if config:arch {
        shutdown.
    }
    switch to 0.
    if exists("1:booster.ksm") {
        if homeconnection:isconnected {
            if open("0:booster.ks"):readall:string = open("1:/boot/booster.ks"):readall:string {}
            else {
                COMPILE "0:/booster.ks" TO "0:/booster.ksm".
                if homeconnection:isconnected {
                    copypath("0:booster.ks", "1:/boot/").
                    copypath("booster.ksm", "1:").
                    set core:BOOTFILENAME to "booster.ksm".
                    reboot.
                }
            }
        }
    }
    else {
        print "booster.ksm doesn't yet exist in boot.. creating..".
        COMPILE "0:/booster.ks" TO "0:/booster.ksm".
        copypath("0:booster.ks", "1:/boot/").
        copypath("booster.ksm", "1:").
        set core:BOOTFILENAME to "booster.ksm".
        reboot.
    }
}



set devMode to true. // Disables switching to ship for easy quicksaving (@<0 vertical speed)
set LogData to false.
set starship to "xxx".
set ShipFound to false.
set LandSomewhereElse to false.
set idealVS to 0.
set LatCtrl to 0.
set LngCtrl to 0.
set LngError to 0.
set LatError to 0.
set ErrorVector to V(0, 0, 0).
set BoosterEngines to SHIP:PARTSNAMED("SEP.23.BOOSTER.CLUSTER").
set GridFins to SHIP:PARTSNAMED("SEP.23.BOOSTER.GRIDFIN").
for part in ship:parts {
    if part:name:contains("SEP.23.BOOSTER.INTEGRATED") {
        set BoosterCore to part.
    }
}

set HSR to SHIP:PARTSNAMED("SEP.23.BOOSTER.HSR").
if HSR:length = 0 {
    set HSR to SHIP:PARTSNAMED("SEP.23.BOOSTER.HSR (" + ship:name + ")").
}
wait 0.5.
set InitialError to -9999.
set maxDecel to 0.
set TotalstopTime to 0.
set TotalstopDist to 0.
set stopDist3 to 0.
set landingRatio to 0.
set maxstabengage to 0.5.  // Defines max closing of the stabilizers after landing.
set GS to 0.
set BoostBackComplete to false.
set lastVesselChange to time:seconds.
set LandingBurnStarted to false.
set BoosterHeight to 0.
set stopTime9 to 0.
set TimeStabilized to 0.
set LFBooster to 0.
set LFBoosterCap to 0.
set LiftingPointToGridFinDist to 0.
set MiddleEnginesShutdown to false.
set StarshipExists to false.
set TowerExists to false.
set TargetOLM to false.
set BoosterDocked to false.
set QuickSaveLoaded to false.
set ShipNotFound to false.
set RollAngle to 0.
set BoosterRot to 0.
if BoosterCore:hasmodule("FARPartModule") {
    set FAR to true.
}
else {
    set FAR to false.
}
set FailureMessage to false.
set WobblyTower to false.
set hover to false.

set RSS to false.
set KSRSS to false.
set STOCK to false.
set Rescale to false.
set Planet1G to CONSTANT():G * (ship:body:mass / (ship:body:radius * ship:body:radius)).
set Block1 to false.
set Block1HSR to false.
set VentCutOff to false.


if bodyexists("Earth") {
    if body("Earth"):radius > 1600000 {
        set RSS to true.
        set Planet to "Earth".
        set LaunchSites to lexicon("KSC", "28.6117,-80.58647").
        set BoosterHeight to 72.6.
        set LiftingPointToGridFinDist to 4.5.
        set LFBoosterFuelCutOff to 10600.
        if FAR {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        set BoosterGlideDistance to 2500.
        set LngCtrlPID:setpoint to 80.
        set LatCtrlPID to PIDLOOP(0.25, 0.2, 0.1, -5, 5).
        set RollVector to heading(270,0):vector.
        set BoosterReturnMass to 200.
        set BoosterRaptorThrust to 2363.
        set BoosterRaptorThrust3 to 2363.
        set Scale to 1.6.
        set CorrFactor to 0.7.
        set PIDFactor to 16.
        set CatchVS to -0.3.
    }
    else {
        set KSRSS to true.
        set Planet to "Earth".
        set LaunchSites to lexicon("KSC", "28.50895,-81.20396").
        set BoosterHeight to 45.4.
        set LiftingPointToGridFinDist to 0.3.
        set LFBoosterFuelCutOff to 1600.
        if FAR {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        set BoosterGlideDistance to 1500.
        set LngCtrlPID:setpoint to 100.
        set LatCtrlPID to PIDLOOP(0.25, 0.2, 0.1, -5, 5).
        set RollVector to heading(242,0):vector.
        set BoosterReturnMass to 135.
        set BoosterRaptorThrust to 580.
        set BoosterRaptorThrust3 to 580.
        set Scale to 1.
        set CorrFactor to 0.8.
        set PIDFactor to 8.
        set CatchVS to -0.1.
    }
}
else {
    if body("Kerbin"):radius > 1000000 {
        set KSRSS to true.
        set Planet to "Kerbin".
        set LaunchSites to lexicon("KSC", "28.50895,-81.20396").
        if body("Kerbin"):radius < 1500001 {
            set RESCALE to true.
            set LaunchSites to lexicon("KSC", "-0.0970,-74.5833").
        }
        set BoosterHeight to 45.4.
        set LiftingPointToGridFinDist to 0.3.
        set LFBoosterFuelCutOff to 1800.
        if FAR {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        set BoosterGlideDistance to 1500.
        set LngCtrlPID:setpoint to 100.
        set LatCtrlPID to PIDLOOP(0.25, 0.2, 0.1, -5, 5).
        set RollVector to heading(242,0):vector.
        set BoosterReturnMass to 135.
        set BoosterRaptorThrust to 580.
        set BoosterRaptorThrust3 to 580.
        set Scale to 1.
        set CorrFactor to 0.8.
        set PIDFactor to 8.
        set CatchVS to -0.1.
    }
    else {
        set STOCK to true.
        set Planet to "Kerbin".
        set LaunchSites to lexicon("KSC", "-0.0972,-74.5577", "Dessert", "-6.5604,-143.95", "Woomerang", "45.2896,136.11", "Baikerbanur", "20.6635,-146.4210").
        set BoosterHeight to 45.4.
        set LiftingPointToGridFinDist to 0.3.
        set LFBoosterFuelCutOff to 1700.
        if FAR {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        set BoosterGlideDistance to 1500.
        set LngCtrlPID:setpoint to 100.
        set LatCtrlPID to PIDLOOP(0.25, 0.2, 0.1, -5, 5).
        set RollVector to heading(270,0):vector.
        set BoosterReturnMass to 135.
        set BoosterRaptorThrust to 580.
        set BoosterRaptorThrust3 to 580.
        set Scale to 1.
        set CorrFactor to 0.8.
        set PIDFactor to 8.
        set CatchVS to -0.25.
    }
}
lock RadarAlt to alt:radar - BoosterHeight.
set FinalDeceleration to 6.5.

for res in BoosterCore:resources {
    if res:name = "LqdMethane" {
        set LFBoosterFuelCutOff to LFBoosterFuelCutOff * 5.310536.
    }
}

SetGridFinAuthority(32).

if exists("0:/BoosterFlightData.csv") {
    deletepath("0:/BoosterFlightData.csv").
}

clearscreen.
print "Booster Nominal Operation, awaiting command..".


until False {
    set ShipConnectedToBooster to false.
    for Part in SHIP:PARTS {
        if Part:name:contains("SEP.23.SHIP.BODY") or Part:name:contains("SEP.24.SHIP.CORE") {
            set ShipConnectedToBooster to true.
        }
    }
    if ShipConnectedToBooster = "false" and BoostBackComplete = "false" and not (ship:status = "LANDED") and altitude > 10000 and verticalspeed < 0 {
        Boostback().
    }
    if alt:radar < 150 and alt:radar > 40 and ship:mass - ship:drymass < 50 and ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0 and not (RSS) and not (LandSomewhereElse) {
        if homeconnection:isconnected {
            if exists("0:/settings.json") {
                set L to readjson("0:/settings.json").
                if L:haskey("Auto-Stack") {
                    if L["Auto-Stack"] = true {
                        setLandingZone().
                        setTargetOLM().
                        BoosterDocking().
                    }
                }
            }
        }
    }
    WAIT UNTIL NOT CORE:MESSAGES:EMPTY.
    SET RECEIVED TO CORE:MESSAGES:POP.
    IF RECEIVED:CONTENT = "Boostback" {
        Boostback().
    }
    ELSE {
        PRINT "Unexpected message: " + RECEIVED:CONTENT.
    }
    wait 0.01.
}


function Boostback {
    wait until SHIP:PARTSNAMED("SEP.23.SHIP.BODY"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.23.SHIP.BODY.EXP"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.24.SHIP.CORE"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.23.SHIP.DEPOT"):LENGTH = 0.
    wait 0.001.
    set ship:name to "Booster".
    rcs on.

    setLandingZone().
    setTargetOLM().

    set ApproachUPVector to (landingzone:position - body:position):normalized.
    set ApproachVector to vxcl(up:vector, landingzone:position - ship:position):normalized.
    //set ApproachVectorDraw to vecdraw(v(0,0,0), 5 * ApproachVector, green, "ApproachVector", 20, true, 0.005, true, true).

    if verticalspeed > 0 {
        set SeparationTime to time:seconds.
        if vang(facing:topvector, north:vector) < 90 {
            set ship:control:pitch to -2.
        }
        else {
            set ship:control:pitch to 2.
        }
        unlock steering.
        set ship:name to "Booster".
        rcs on.
        lock throttle to 0.43.
        sas off.
        set SteeringManager:ROLLCONTROLANGLERANGE to 0.
        set SteeringManager:rollts to 5.
        wait 0.1.
        HUDTEXT("Performing Boostback Burn..", 30, 2, 20, green, false).
        set ship:name to "Booster".
        clearscreen.
        print "Starting Boostback".
        set CurrentTime to time:seconds.
        set kuniverse:timewarp:warp to 0.
        BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).

        if RSS {
            SetLoadDistances(1650000).
        }
        else if KSRSS {
            SetLoadDistances(1000000).
        }
        else {
            SetLoadDistances(350000).
        }

        lock SteeringVector to lookdirup(vxcl(up:vector, -ErrorVector), -facing:topvector).
        lock steering to SteeringVector.

        wait 0.001.
        if defined L {
            if L:haskey("Ship Name") {
                set starship to L["Ship Name"].
                until ShipFound or verticalspeed < 0 or ShipNotFound {
                    list targets in tgtlist.
                    for tgt in tgtlist {
                        if (tgt:name) = (starship) {
                            set ShipFound to true.
                            print tgt:name.
                            wait 0.001.
                        }
                    }
                    if not (ShipFound) {
                        for tgt in tgtlist {
                            if tgt:name:contains("Starship") and tgt:orbit:periapsis < ship:body:atm:height {
                                set ShipFound to true.
                                print tgt:name.
                                set starship to tgt:name.
                                wait 0.001.
                            }
                        }
                        set ShipNotFound to true.
                    }
                }
            }
        }
        until time:seconds > SeparationTime + 5 {
            if ship:partsnamed("SEP.23.BOOSTER.HSR"):length = 0 {
                set ship:name to "Booster".
                set Block1HSR to true.
            }
        }

        when flipStartTime + 1 < time:seconds and flipStartTime + 2 > time:seconds then {
            set steeringmanager:yawtorquefactor to 1.
        }

        when BoostBackComplete then {
            set steeringmanager:yawtorquefactor to 0.1.
        }

        when time:seconds > flipStartTime + 150 then { 
            set steeringmanager:yawtorquefactor to 0.6.
        }

        set flipStartTime to time:seconds.
        
        

        when (time:seconds > flipStartTime + 4 and verticalspeed > 0 and not (RSS)) or (time:seconds > flipStartTime + 6 and verticalspeed > 0 and (RSS)) then {
            BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("previous engine mode", true).
            set ship:control:neutralize to true.
        }

        if RSS {
            set SteeringManager:pitchtorquefactor to 0.70.
            set SteeringManager:yawtorquefactor to 0.70.

        }
        else if KSRSS {
            set SteeringManager:pitchtorquefactor to 0.65.
            set SteeringManager:yawtorquefactor to 0.65.
        }
        else {
            set SteeringManager:pitchtorquefactor to 0.75.
            set SteeringManager:yawtorquefactor to 0.75.
        }

        until vang(vxcl(up:vector, facing:forevector), vxcl(up:vector, -ErrorVector)) < 15 or verticalspeed < -50 {
            SteeringCorrections().
            //set ErrorVectorDraw to vecdraw(v(0,0,0), -40 * ErrorVector:normalized, blue, "ErrorVector", 20, true, 0.005, true, true).
            if (RadarAlt < 30000 and RSS) or (RadarAlt < 69000 and not (RSS)) {
                if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
            }
            if ErrorVector = v(0,0,0) and not FailureMessage and time:seconds > flipStartTime + 1 {
                HUDTEXT("FAR failure! Please restart KSP..", 30, 2, 22, red, false).
                set FailureMessage to true.
            }
            rcs on.
            wait 0.1.
        }

        set steeringmanager:maxstoppingtime to 3.
        when time:seconds > flipStartTime + 10 then {
            set SteeringManager:ROLLCONTROLANGLERANGE to 10.
        }

        if RSS {
            lock throttle to max(min(-(LngError + BoosterGlideDistance - 1000) / 5000 + 0.01, 5 * 9.81 / (max(ship:availablethrust, 0.000001) / ship:mass)), 0.33).
        }
        else {
            lock throttle to max(min(-(LngError + BoosterGlideDistance - 1000) / 2500 + 0.01, 5 * 9.81 / (max(ship:availablethrust, 0.000001) / ship:mass)), 0.33).
        }
        lock SteeringVector to lookdirup(vxcl(up:vector, -ErrorVector), -up:vector).
        lock steering to SteeringVector.

        print "Available Thrust: " + round(max(ship:availablethrust, 0.000001)) + "kN".
        wait 0.1.

        when time:seconds > flipStartTime + 30 then {
            CheckFuel().
            if LFBooster > LFBoosterCap * 0.2 {
                BoosterCore:activate.
            }
        }


        until ErrorVector:mag < BoosterGlideDistance + 3200 * Scale or verticalspeed < -50 {
            SteeringCorrections().
            if (RadarAlt < 30000 and RSS) or (RadarAlt < 69000 and not (RSS)) {
                if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
            }
            SetBoosterActive().
            wait 0.1.
        }

        set CurrentVec to facing:forevector.
        lock SteeringVector to lookdirup(CurrentVec, ApproachVector:normalized - 0.5 * up:vector:normalized).
        lock steering to SteeringVector.
        BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("next engine mode", true).
        CheckFuel().
        if LFBooster > LFBoosterCap * 0.05 {
            BoosterCore:activate.
        } else {
            BoosterCore:shutdown.
        }

        until LngError + 50 > -BoosterGlideDistance or verticalspeed < -250 {
            SteeringCorrections().
            if (RadarAlt < 30000 and RSS) or (RadarAlt < 69000 and not (RSS)) {
                if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
            }
            SetBoosterActive().
            wait 0.001.
        }
        unlock throttle.
        lock throttle to 0.
        set BoostBackComplete to true.
        wait 0.01.
        
        set turnTime to time:seconds.
        BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("previous engine mode", true).
        set Planet1G to CONSTANT():G * (ship:body:mass / (ship:body:radius * ship:body:radius)).
        set SteeringManager:pitchtorquefactor to 1.
        set SteeringManager:yawtorquefactor to 0.

        CheckFuel().
        if LFBooster > LFBoosterFuelCutOff {
            BoosterCore:activate.
        }
        
        when time:seconds - turnTime > 4 and defined HSR then {
            BoosterCore:getmodule("ModuleDecouple"):DOACTION("Decouple", true).
            wait 0.01.
            if not Block1HSR {
                kuniverse:forceactive(vessel("Booster Ship")).
            } 
            HUDTEXT("HSR-Jettison confirmed.. Rotating Booster for re-entry and landing..", 20, 2, 20, green, false).
            if not Block1HSR {
                set vessel("Booster"):name to "Booster HSR".
            }
            set kuniverse:activevessel:name to "Booster".
        }

        set SteeringManager:maxstoppingtime to 5.
        lock SteeringVector to lookdirup(CurrentVec * AngleAxis(-5 * min(time:seconds - turnTime, 27), lookdirup(CurrentVec, up:vector):starvector), -up:vector).
        lock steering to SteeringVector.

        if vang(facing:forevector, lookdirup(CurrentVec * AngleAxis(-5 * 27, lookdirup(CurrentVec, up:vector):starvector), -up:vector):vector) > 10 {
            until time:seconds - turnTime > 18 {
                SteeringCorrections().
                SetBoosterActive().
                rcs on.
                CheckFuel().
                wait 0.1.
            }

            lock SteeringVector to lookdirup(CurrentVec * AngleAxis(-5 * min(time:seconds - turnTime, 27), lookdirup(CurrentVec, up:vector):starvector), up:vector).
            lock steering to SteeringVector.

            until time:seconds - turnTime > 22 {
                SteeringCorrections().
                SetBoosterActive().
                rcs on.
                CheckFuel().
                wait 0.1.
            }
            set SteeringManager:maxstoppingtime to 2.

            until time:seconds - turnTime > 35 {
                SteeringCorrections().
                SetBoosterActive().
                rcs on.
                CheckFuel().
                wait 0.1.
            }
        }

        set switchTime to time:seconds.
        until time:seconds > switchTime + 2.5 {
            SteeringCorrections().
            rcs on.
            SetBoosterActive().
            CheckFuel().
            wait 0.1.
        }

        HUDTEXT("Starship will continue its orbit insertion..", 10, 2, 20, green, false).
        ActivateGridFins().

        until time:seconds > switchTime + 5 {
            SteeringCorrections().
            rcs on.
            SetBoosterActive().
            CheckFuel().
            wait 0.1.
        }

        BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 5).
    }
    else {
        lock steering to facing:forevector.
    }

    if not (starship = "xxx") {
        list targets in tlist.
        for tgt in tlist {
            if tgt:name:contains(starship) {
                if not (devMode) {
                    KUniverse:forceactive(vessel(starship)).
                }
                set StarshipExists to true.
            }
        }
    }
    else {
        if homeconnection:isconnected {
            if exists("0:/settings.json") {
                set L to readjson("0:/settings.json").
                set starship to L["Ship Name"].
                if not (starship = "xxx") and not (devMode) {
                    //KUniverse:forceactive(vessel(starship)).
                }
                //else {
                    //print "Couldn't find vessel".
                    //wait 2.5.
                //}
            }
        }
    }

    until altitude < 35000 and not (RSS) or altitude < 75000 and RSS {
        SteeringCorrections().
        rcs on.
        CheckFuel().
        set kuniverse:timewarp:warp to 3.
        
        if abs(steeringmanager:angleerror) > 10 {
            SetBoosterActive().
            BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 25).
        }
        else if abs(steeringmanager:angleerror) < 0.25 and KUniverse:activevessel = ship {
            if TimeStabilized = "0" {
                set TimeStabilized to time:seconds.
                SetBoosterActive().
            }
            if time:seconds - TimeStabilized > 5 {
                //SetStarshipActive().
                BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 10).
                set TimeStabilized to 0.
            }
        }
        else {
            set TimeStabilized to 0.
        }
        wait 0.1.
    }
    when (RadarAlt < 30000 and RSS) or (RadarAlt < 69000 and not (RSS)) then {
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
    }
    
    SetBoosterActive().
    set SteeringManager:yawtorquefactor to 1.

    BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
    lock SteeringVector to lookdirup(-velocity:surface * AngleAxis(-LngCtrl, lookdirup(-velocity:surface, up:vector):starvector) * AngleAxis(LatCtrl, up:vector), ApproachVector * AngleAxis(2 * LatCtrl, up:vector)).
    lock steering to SteeringVector.

    until alt:radar < 1800 {
        SteeringCorrections().
        if altitude > 26000 {
            rcs on.
        }
        else {
            rcs off.
        }
        SetBoosterActive().
        CheckFuel().
        wait 0.1.
    }

    if RSS {
        //set ArmsHeight to (Mechazilla:position - ship:body:position):mag - SHIP:BODY:RADIUS - ship:geoposition:terrainheight + 12.
    }
    else {
        //set ArmsHeight to (Mechazilla:position - ship:body:position):mag - SHIP:BODY:RADIUS - ship:geoposition:terrainheight + 7.5.
    }
    lock throttle to LandingThrottle().
    if RSS {
        lock SteeringVector to lookdirup(-1*velocity:surface, ApproachVector).
    } else {
        lock SteeringVector to lookdirup(-1*velocity:surface, ApproachVector).
    }
    
    lock steering to SteeringVector.
    

    set LandingBurnAltitude to altitude.
    set LandingBurnStarted to true.
    HUDTEXT("Performing Landing Burn..", 3, 2, 20, green, false).

    if abs(LngError - LngCtrlPID:setpoint) > 40 * Scale or abs(LatError) > 5 {
        set LandSomewhereElse to true.
        lock RadarAlt to alt:radar - BoosterHeight.
        HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
        HUDTEXT("Landing somewhere else..", 10, 2, 20, red, false).
        lock SteeringVector to lookdirup(-1 * velocity:surface, ApproachVector).
        
        lock steering to SteeringVector.
    }

    set LngCtrlPID:setpoint to 0.

    when RadarAlt < 1500 and not (LandSomewhereElse) then {
        if not (TargetOLM = "false") and TowerExists {
            if Vessel(TargetOLM):distance < 2250 {

                lock RadarAlt to vdot(up:vector, GridFins[0]:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position) - LiftingPointToGridFinDist.

                when vxcl(up:vector, landingzone:position - BoosterCore:position):mag < 20 * Scale and RadarAlt < 7.5 * BoosterHeight and not (WobblyTower) then {
                    sendMessage(Vessel(TargetOLM), "MechazillaArms,8.2,10,90,true").
                    sendMessage(Vessel(TargetOLM), "MechazillaStabilizers,0").
                    when RadarAlt < 1.5 * BoosterHeight then {
                        sendMessage(Vessel(TargetOLM), ("MechazillaArms," + round(BoosterRot, 1) + ",10,8,true")).
                        rcs off.
                        if RadarAlt > 6 * Scale {
                            set t to time:seconds.
                            until time:seconds > t + 0.1 {}
                            preserve.
                        }
                        else {
                            sendMessage(Vessel(TargetOLM), ("MechazillaArms," + round(BoosterRot, 1.1) + ",5,60,false")).
                        }
                        when (RadarAlt < 3.4 * Scale and RSS) or (RadarAlt < 2.0 * Scale and not (RSS)) then {
                            sendMessage(Vessel(TargetOLM), "RetractMechazillaRails").
                        }
                        when RadarAlt < 1.6 * Scale then {
                            sendMessage(Vessel(TargetOLM), ("MechazillaArms,999,5,60,false")).
                        }
                    }
                }
                when WobblyTower and RadarAlt < 100 then {
                    HUDTEXT("Wobbly Tower detected..", 3, 2, 20, red, false).
                    HUDTEXT("Trying to land in the OLM..", 3, 2, 20, yellow, false).
                    sendMessage(Vessel(TargetOLM), "MechazillaArms,8.2,10,60,true").
                    lock RadarAlt to alt:radar - BoosterHeight.
                    ADDONS:TR:SETTARGET(landingzone).
                }
                when RadarAlt < -1 then {
                    set LandSomewhereElse to true.
                    lock RadarAlt to alt:radar - BoosterHeight.
                    HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
                    HUDTEXT("Landing somewhere else..", 10, 2, 20, red, false).
                    lock SteeringVector to lookdirup(-1 * velocity:surface, ApproachVector).
                    lock steering to SteeringVector.
                }
            }
        }
    }

    when ((verticalspeed > -120 and RSS) or (verticalspeed > -40 and not RSS)) and (stopDist3 / RadarAlt) < 1.5 and LngError < 200 or ((verticalspeed > -50 and RSS) or (verticalspeed > -20 and not RSS)) then {
        set SwingTime to time:seconds.
        lock SteeringVector to lookDirUp(up:vector, RollVector).
        lock steering to SteeringVector.
        when time:seconds > SwingTime + 1 then {
            set MiddleEnginesShutdown to true.
            BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("next engine mode", true).
            set LngCtrlPID:setpoint to 0.

            setTowerHeadingVector().

            if RSS {
                lock SteeringVector to lookdirup(up:vector - 0.02 * velocity:surface - 0.005 * ErrorVector, RollVector).
            }
            else if KSRSS {
                lock SteeringVector to lookdirup(up:vector - 0.01 * velocity:surface - 0.002 * ErrorVector, RollVector).
            }
            else {
                lock SteeringVector to lookdirup(up:vector - 0.01 * velocity:surface - 0.002 * ErrorVector, RollVector).
            }
            lock steering to SteeringVector.

            set steeringmanager:rolltorquefactor to 0.75.
            SetGridFinAuthority(2.5).
        }
        
    }


    until verticalspeed > CatchVS and RadarAlt < 1 or verticalspeed > -0.01 and RadarAlt < 2000 or hover {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        if RadarAlt > 500 {
            rcs off.
            set Once to false.
        }
        else {
            if Once = false {
                rcs on.
                set Once to true.
            } else {
                rcs off.
            }
        }
        SetBoosterActive().
        CheckFuel().
        DetectWobblyTower().
        wait 0.1.
    }
    set t to time:seconds.
    if LandSomewhereElse {
        lock steering to lookDirUp(up:vector - 0.025 * vxcl(up:vector, velocity:surface), facing:topvector).
    }
    else if not (TargetOLM = "False") {
        lock steering to lookDirUp(up:vector - 0.025 * vxcl(up:vector, velocity:surface), RollVector).
    }
    lock throttle to (Planet1G + (verticalspeed / CatchVS - 1)) / (max(ship:availablethrust, 0.000001) / ship:mass * 1/cos(vang(-velocity:surface, up:vector))).
    until time:seconds > t + 8 or ship:status = "LANDED" and verticalspeed > -0.4 or RadarAlt < -1 {
        SteeringCorrections().
        print "slowly lowering down booster..".
        rcs on.
        wait 0.01.
    }
    

    set ship:control:translation to v(0, 0, 0).
    unlock steering.
    lock throttle to 0.
    set ship:control:pilotmainthrottle to 0.
    rcs off.
    clearscreen.
    print "Booster Landed!".
    wait 0.01.
    BoosterEngines[0]:shutdown.
    
    
    SetLoadDistances("default").

    DeactivateGridFins().
    BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("next engine mode", true).

    if not (LandSomewhereElse) {
        if not (TargetOLM = "false") {
            if RSS {
                HUDTEXT("Booster Landing Confirmed!", 10, 2, 20, green, false).
            }
            else {
                HUDTEXT("Booster Landing Confirmed! Stand by for Mechazilla operation..", 30, 2, 20, green, false).
            }
            set LandingTime to time:seconds.
            set TowerReset to false.
            set RollAngleExceeded to false.
            if not (RSS) {
                BoosterEngines[0]:getmodule("ModuleDockingNode"):SETFIELD("docking acquire force", 200).
                sendMessage(Vessel(TargetOLM), "DockingForce,200").
            }
            print "Tower Operation in Progress..".

            sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.5,0.2,false").

            when time:seconds > LandingTime + 5 then {
                sendMessage(Vessel(TargetOLM), ("MechazillaPushers,0,0.25," + round(0.2 * Scale, 2) + ",false")).
                sendMessage(Vessel(TargetOLM), "MechazillaArms,8.2,0.25,60,false").
                when time:seconds > LandingTime + 10 * Scale then {
                    sendMessage(Vessel(TargetOLM), ("MechazillaPushers,0,0.1," + round(0.2 * Scale, 2) + ",false")).
                    when kuniverse:canquicksave and time:seconds > LandingTime + 32 and L["Auto-Stack"] = true and not (RSS) and not (LandSomewhereElse) then {
                        sendMessage(Vessel(TargetOLM), ("MechazillaStabilizers," + maxstabengage)).
                        HUDTEXT("Loading current Booster quicksave for safe docking! (to avoid the Kraken..)", 20, 2, 20, green, false).
                        sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (7 * Scale) + ",0.5")).
                        wait 1.5.
                        sendMessage(Vessel(TargetOLM), "MechazillaStabilizers,0").
                        when kuniverse:canquicksave and KUniverse:activevessel = ship then {
                            kuniverse:quicksave().
                            wait 0.1.
                            when kuniverse:canquicksave then {
                                kuniverse:quickload().
                            }
                        }
                    }
                    if not (L["Auto-Stack"] = true) or LandSomewhereElse {
                        HUDTEXT("Booster recovered!", 10, 2, 5, green, false).
                    }
                }
            }

            until TowerReset or (RSS) {
                clearscreen.
                set RollVector to vxcl(up:vector, Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position - BoosterCore:position).
                set RollAngle to vang(facing:starvector, AngleAxis(-270, up:vector) * RollVector).
                print "Roll Angle: " + round(RollAngle,1).
                if abs(RollAngle) > 30 {
                    set RollAngleExceeded to true.
                    set TowerReset to true.
                    break.
                }
            }
            if not RollAngleExceeded {
                if not (RSS) {
                    print "Booster has been secured & Tower has been reset!".
                    HUDTEXT("Tower has been reset, Booster may now be recovered!", 10, 2, 20, green, false).
                }
            }
            else {
                sendMessage(Vessel(TargetOLM), "EmergencyStop").
                print "Emergency Shutdown commanded! Roll Angle exceeded: " + round(RollAngle, 1).
                print "Continue manually with great care..".
                HUDTEXT("Emergency Shutdown commanded!", 10, 2, 20, red, false).
                HUDTEXT("Continue manually with great care..", 10, 2, 20, red, false).
                shutdown.
            }
        }
        else {
            print "Booster has been secured".
            HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
        }
    }
    else {
        print "Booster has touched down somewhere".
        HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
    }

    unlock throttle.
    //if BoosterCore:getmodule("ModuleSepPartSwitchAction"):getfield("current decouple system") = "Decoupler" {
    //    BoosterCore:getmodule("ModuleSepPartSwitchAction"):DoAction("next decouple system", true).
    //}

    HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
    clearscreen.
    print "Booster may now be recovered!".
}



FUNCTION SteeringCorrections {
    if KUniverse:activevessel = ship {
        set addons:tr:descentmodes to list(true, true, true, true).
        set addons:tr:descentgrades to list(true, true, true, true).
        set addons:tr:descentangles to list(180, 180, 180, 180).
        if not addons:tr:hastarget {
            ADDONS:TR:SETTARGET(landingzone).
        }
        if altitude > 5000 and KUniverse:activevessel = vessel(ship:name) {
            set ApproachVector to vxcl(up:vector, landingzone:position - ship:position):normalized.
        }

        if addons:tr:hasimpact {
            set ErrorVector to ADDONS:TR:IMPACTPOS:POSITION - landingzone:POSITION.
        }
        set LatError to vdot(AngleAxis(-90, ApproachUPVector) * ApproachVector, ErrorVector).
        set LngError to vdot(ApproachVector, ErrorVector).


        if altitude < 30000 * Scale or KUniverse:activevessel = vessel(ship:name) {
            set GS to groundspeed.
            set steeringmanager:yawtorquefactor to 1.

            if InitialError = -9999 and addons:tr:hasimpact {
                set InitialError to LngError.
            }
            set LngCtrlPID:maxoutput to max(min(abs(LngError - LngCtrlPID:setpoint) / (PIDFactor), 10), 2.5).
            set LngCtrlPID:minoutput to -LngCtrlPID:maxoutput.
            set LatCtrlPID:maxoutput to max(min(abs(LatError) / (10 * Scale), 5), 0.5).
            set LatCtrlPID:minoutput to -LatCtrlPID:maxoutput.

            set LngCtrl to -LngCtrlPID:UPDATE(time:seconds, LngError).
            set LatCtrl to -LatCtrlPID:UPDATE(time:seconds, LatError).
            if LngCtrl > 0 {
                set LatCtrl to -LatCtrl.
            }

            set maxDecel to max((ship:availablethrust / ship:mass) - 4.805, 0.000001).
            set maxDecel3 to (3 * BoosterRaptorThrust3 / min(ship:mass, BoosterReturnMass - 12.5 * Scale)) - 8.805.

            if not (MiddleEnginesShutdown) {
                set stopTime9 to (airspeed - 50) / min(maxDecel, 50).
                set stopDist9 to ((airspeed + 50) / 2) * stopTime9.
                set stopTime3 to min(50, airspeed) / min(maxDecel3, FinalDeceleration).
                set stopDist3 to (min(50, airspeed) / 2) * stopTime3.
                set TotalstopTime to stopTime9 + stopTime3.
                set TotalstopDist to (stopDist9 + stopDist3) * cos(vang(-velocity:surface, up:vector)).
                set landingRatio to TotalstopDist / (RadarAlt - 2.5).
            }
            else {
                set TotalstopTime to airspeed / min(maxDecel, FinalDeceleration).
                set TotalstopDist to (airspeed / 2) * TotalstopTime.
                set landingRatio to TotalstopDist / (RadarAlt - 2.5).
                set LngCtrlPID:setpoint to 0.
            }

            if alt:radar < 1500 {
                set magnitude to min(RadarAlt / 70, (ship:position - landingzone:position):mag / 12).
                if ErrorVector:mag > magnitude and LandingBurnStarted {
                    set ErrorVector to ErrorVector:normalized * magnitude.
                }
                if not (LandSomewhereElse) {
                    set BoosterRot to GetBoosterRotation().
                    if TargetOLM and verticalspeed > -18 {
                        set RollVector to vxcl(up:vector, Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position - BoosterCore:position).
                    }
                }
            }
            if CorrFactor * groundspeed < LngCtrlPID:setpoint and alt:radar < 5000 {
                set LngCtrlPID:setpoint to CorrFactor * groundspeed.

            }

            if LandSomewhereElse {
                set RadarAlt to alt:radar - BoosterHeight.
            }
        }

        clearscreen.
        print "Lng Error: " + round(LngError) + " / " + round(LngCtrlPID:setpoint).
        print "Lat Error: " + round(LatError).
        print "Radar Alt: " + round(RadarAlt) + "m".
        //print " ".

        if altitude < 30000 and not (RSS) or altitude < 50000 and RSS {
            print "LngCtrl: " + round(LngCtrl, 2) + " / " + round(LngCtrlPID:maxoutput, 1).
            print "LatCtrl: " + round(LatCtrl, 2) + " / " + round(LatCtrlPID:maxoutput, 1).
            print " ".
            print "Max Decel: " + round(maxDecel, 2).
            print "Radar Alt: " + round(RadarAlt).
            print "Stop Time: " + round(TotalstopTime, 2).
            print "Stop Distance: " + round(TotalstopDist, 2).
            print "Stop Distance 3: " + round(stopDist3, 2).
            print "Landing Ratio: " + round(landingRatio, 2).
            print " ".
            print "MZ Rotation: " + Round(BoosterRot,1).
            print "Ship Mass: " + round(ship:mass,3).
            if airspeed > 100 {
                print "Descent Angle: " + round(vang(-velocity:surface, up:vector), 1).
                print "GS: " + round(groundspeed).
            }
        }
    }
    else {
        clearscreen.
        //print "Booster: Coasting back to LZ..".
        //print " ".
        print "Radar Altitude: " + round(RadarAlt).
        //if ShipExists {
        //    print "Ship Distance: " + (round(vessel(starship):distance) / 1000) + "km".
        //}
    }
    if not (LFBooster = 0) {
        print "LF on Board: " + round(LFBooster, 1) + " / " + round(LFBoosterFuelCutOff).
    }
    print " ".
    print "Steering Error: " + round(SteeringManager:angleerror, 2).
    //print "OPCodes left: " + opcodesleft.
    LogBoosterFlightData().
}


function LandingThrottle {
    if verticalspeed > CatchVS {
        set minDecel to (Planet1G - 0.025) / (max(ship:availablethrust, 0.000001) / ship:mass * 1/cos(vang(-velocity:surface, up:vector))).
        set minDecel to minDecel + 0.2.
        set Hover to true.
        return minDecel.
    }
    if RSS {
        return max((landingRatio * min(maxDecel, 50)) / maxDecel, 0.165).
    }
    else {
        return max((landingRatio * min(maxDecel, 50)) / maxDecel, 0.33).
    }
    wait 0.001.
}


function LogBoosterFlightData {
    if LogData {
        if homeconnection:isconnected {
            if defined PrevLogTime {
                set TimeStep to 1.
                if timestamp(time:seconds) > PrevLogTime + TimeStep {
                    set DistanceToTarget to (vxcl(up:vector, landingzone:position - ship:position):mag * (ship:body:radius / 1000 * 2 * constant:pi) / 360).
                    LOG (timestamp():clock + "," + DistanceToTarget + "," + altitude + "," + ship:verticalspeed + "," + airspeed + "," + LngError + "," + LatError + "," + vang(ship:facing:forevector, -velocity:surface) + "," + throttle + "," + (ship:mass * 1000)) to "0:/BoosterFlightData.csv".
                    set PrevLogTime to timestamp(time:seconds).
                }
            }
            else {
                set PrevLogTime to timestamp(time:seconds).
                LOG "Time, Distance to Target (km), Altitude (m), Vertical Speed (m/s), Airspeed (m/s), Longitude Error (m), Latitude Error (m), Actual AoA (°), Throttle (%), Mass (kg)" to "0:/BoosterFlightData.csv".
            }
        }
    }
}


function sendMessage{
    parameter ves, msg.
    set cnx to ves:connection.
    if cnx:isconnected {
        if cnx:sendmessage(msg) {
            //print "message sent..(" + msg + ")".
        }
        else {
            //print "message could not be sent..".
        }.
    }
    else {
        //print "connection could not be established..".
    }
}


function SetBoosterActive {
    //if not Block1 {
        if KUniverse:activevessel = vessel("Booster") {}
        else if time:seconds > lastVesselChange + 2 {
            if not (vessel("Booster"):isdead) {
                HUDTEXT("Setting focus to Booster..", 3, 2, 20, yellow, false).
                KUniverse:forceactive(vessel("Booster")).
                set lastVesselChange to time:seconds.
            }
        }
    //} else if Block1 {
    //    if KUniverse:activevessel = vessel("Booster Ship") {}
    //    else if time:seconds > lastVesselChange + 2 {
    //        if not (vessel("Booster Ship"):isdead) {
    //            HUDTEXT("Setting focus to Booster..", 3, 2, 20, yellow, false).
    //            KUniverse:forceactive(vessel("Booster Ship")).
    //            set lastVesselChange to time:seconds.
    //        }
    //    }
    //}
}


function SetStarshipActive {
    if KUniverse:activevessel = vessel(ship:name) and time:seconds > lastVesselChange + 2 and StarshipExists {
        HUDTEXT("Setting focus to Ship..", 3, 2, 20, yellow, false).
        KUniverse:forceactive(vessel(starship)).
        set lastVesselChange to time:seconds.
    }
    else {}
}

function SetLoadDistances {
    parameter distance.

    if distance = "default" {
        set ship:loaddistance:flying:unload to 22500.
        set ship:loaddistance:flying:load to 2250.
        wait 0.001.
        set ship:loaddistance:flying:pack to 25000.
        set ship:loaddistance:flying:unpack to 2000.
        wait 0.001.
        set ship:loaddistance:suborbital:unload to 15000.
        set ship:loaddistance:suborbital:load to 2250.
        wait 0.001.
        set ship:loaddistance:suborbital:pack to 10000.
        set ship:loaddistance:suborbital:unpack to 200.
        wait 0.001.
        set ship:loaddistance:landed:unload to 2500.
        set ship:loaddistance:landed:load to 2250.
        wait 0.001.
        set ship:loaddistance:landed:pack to 350.
        set ship:loaddistance:landed:unpack to 200.
        wait 0.001.
    }
    else {
        set ship:loaddistance:flying:unload to distance.
        set ship:loaddistance:flying:load to distance - 5000.
        wait 0.001.
        set ship:loaddistance:flying:pack to distance - 2500.
        set ship:loaddistance:flying:unpack to distance - 10000.
        wait 0.001.
        set ship:loaddistance:suborbital:unload to distance.
        set ship:loaddistance:suborbital:load to distance - 5000.
        wait 0.001.
        set ship:loaddistance:suborbital:pack to distance - 2500.
        set ship:loaddistance:suborbital:unpack to distance - 10000.
        wait 0.001.
        set ship:loaddistance:landed:unload to distance.
        set ship:loaddistance:landed:load to distance - 5000.
        wait 0.001.
        set ship:loaddistance:landed:pack to distance - 2500.
        set ship:loaddistance:landed:unpack to distance - 10000.
        wait 0.001.
    }
}


function CheckFuel {
    for res in BoosterCore:resources {
        if res:name = "LiquidFuel" {
            set LFBooster to res:amount.
            set LFBoosterCap to res:capacity.
            if LFBooster < LFBoosterFuelCutOff {
                BoosterCore:shutdown.
            }
        }
        if res:name = "LqdMethane" {
            set LFBooster to res:amount.
            set LFBoosterCap to res:capacity.
            if LFBooster < LFBoosterFuelCutOff {
                BoosterCore:shutdown.
            }
        }
    }
}


function setLandingZone {
    if homeconnection:isconnected {
        if exists("0:/settings.json") {
            set L to readjson("0:/settings.json").
            if L:haskey("Log Data") {
                if L["Log Data"] = "true" {
                    set LogData to true.
                }
            }
            if L:haskey("Launch Coordinates") {
                if RSS {
                    set landingzone to latlng(L["Launch Coordinates"]:split(",")[0]:toscalar(28.6117), L["Launch Coordinates"]:split(",")[1]:toscalar(-80.5864)).
                }
                else {
                    set landingzone to latlng(L["Launch Coordinates"]:split(",")[0]:toscalar(-000.0972), L["Launch Coordinates"]:split(",")[1]:toscalar(-074.5577)).
                }
            }
            else {
                if RSS {
                    set landingzone to latlng(28.6117,-80.58647).
                }
                else if KSRSS {
                    if Rescale {
                        set landingzone to latlng(-0.0970,-74.5833).
                    }
                    else {
                        set landingzone to latlng(28.50895,-81.20396).
                    }
                }
                else {
                    set landingzone to latlng(-000.0972,-074.5577).
                }
            }
        }
    }
    else {
        if RSS {
            set landingzone to latlng(28.6117,-80.58647).
        }
        else if KSRSS {
            if Rescale {
                set landingzone to latlng(-0.0970,-74.5833).
            }
            else {
                set landingzone to latlng(28.50895,-81.20396).
            }
        }
        else {
            set landingzone to latlng(-000.0972,-074.5577).
        }
        wait 1.
        setLandingZone().
    }
}


function setTargetOLM {
    list targets in OLMTargets.
    if OLMTargets:length > 0 {
        for x in OLMTargets {
            if x:name:contains("OrbitalLaunchMount") {
                set TowerExists to true.
                if vxcl(up:vector, x:position - landingzone:position):mag < 100 {
                    set TargetOLM to x:name.
                }
            }
        }
    }
}


function BoosterDocking {
    wait 3.
    setTowerHeadingVector().
    setTargetOLM().
    set t to time:seconds.
    lock RollAngle to vang(facing:starvector, AngleAxis(-90, up:vector) * RollVector).
    lock PosDiff to vxcl(up:vector, BoosterEngines[0]:position - Vessel(TargetOLM):dockingports[0]:nodeposition):mag.
    when ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0 then {
        clearscreen.
        print "Roll Angle: " + round(RollAngle,1) + "".
        print "Position Error: " + round(PosDiff, 2) + "m".
        wait 0.001.
        if ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0 {
            preserve.
        }
    }
    if abs(RollAngle) < 5 and airspeed < 2 and PosDiff < 2.5 * Scale {
        clearscreen.
        print "Booster recovery in progress..".
        HUDTEXT("Wait for Booster docking to start..", 5, 2, 20, green, false).
        when abs(RollAngle) > 5 and ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0 or PosDiff > 1.5 * Scale and ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0 then {
            sendMessage(Vessel(TargetOLM), "EmergencyStop").
            print "Emergency Shutdown commanded! Roll Angle exceeded: " + round(RollAngle, 1).
            print "Continue manually with great care..".
            HUDTEXT("Emergency Shutdown commanded!", 10, 2, 20, red, false).
            HUDTEXT("Continue manually with great care..", 10, 2, 20, red, false).
            shutdown.
        }

        when PosDiff > 0.4 * Scale then {
            HUDTEXT("Wait for Booster to stabilize..", 5, 2, 20, yellow, false).
            set t to time:seconds.
            until time:seconds > t + 5 {}
            set t to time:seconds.
            preserve.
        }
        until time:seconds > t + 15 {}

        sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (29.9 * Scale) + ",0.5")).
        DeactivateGridFins().
        set LandingTime to time:seconds.
        clearscreen.
        HUDTEXT("Booster docking in progress..", 50, 2, 20, green, false).

        when time:seconds > LandingTime + 50 * Scale and not (BoosterDocked) then {
            HUDTEXT("Docking Booster..", 10, 2, 20, green, false).
            sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (29.6 * Scale) + ",0.05")).
            wait 6 * Scale.
            sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (29.9 * Scale) + ",0.05")).
            wait 6 * Scale.
            preserve.
        }
        when ship:partstitled("Starship Orbital Launch Integration Tower Base"):length > 0 then {
            set BoosterDocked to true.
        }

        when BoosterDocked then {
            HUDTEXT("Booster Docked! Resetting tower..", 20, 2, 20, green, false).
            sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (32.5 * Scale) + ",0.5")).
            sendMessage(Vessel(TargetOLM), "MechazillaArms,8.2,2.5,35,true").
            set DockedTime to time:seconds.
            if ship:partstitled("Starship Orbital Launch Mount"):length > 0 {
                if ship:partstitled("Starship Orbital Launch Mount")[0]:getmodule("ModuleAnimateGeneric"):hasevent("open clamps + qd") {
                    ship:partstitled("Starship Orbital Launch Mount")[0]:getmodule("ModuleAnimateGeneric"):DoAction("toggle clamps + qd", true).
                }
            }
            when time:seconds > DockedTime + 7.5 then {
                sendMessage(Vessel(TargetOLM), "MechazillaHeight,0,2").
                sendMessage(Vessel(TargetOLM), "MechazillaArms,8.2,5,35,true").
                sendMessage(Vessel(TargetOLM), ("MechazillaPushers,0,1," + (12.5 * Scale) + ",true")).
                sendMessage(Vessel(TargetOLM), "MechazillaStabilizers,0").
                when time:seconds > DockedTime + 20 then {
                    sendMessage(Vessel(TargetOLM), "MechazillaArms,8.2,5,90,true").
                    when time:seconds > DockedTime + 30 then {
                        set TowerReset to true.
                        HUDTEXT("Booster recovery complete, tower has been reset!", 10, 2, 20, green, false).
                        //if BoosterCore:getmodule("ModuleSepPartSwitchAction"):getfield("current decouple system") = "Decoupler" {
                        //BoosterCore:getmodule("ModuleSepPartSwitchAction"):DoAction("next decouple system", true).
                        //}
                        reboot.
                    }
                }
            }
        }
    }
    else {
        clearscreen.
        print "Automated Booster Docking not safe..".
        print "Continue manually with great care..".
        HUDTEXT("Automated Booster Docking currently not safe..", 10, 2, 20, yellow, false).
        HUDTEXT("Continue manually or toggle power on the kOS unit (booster) and try again..", 10, 2, 20, yellow, false).
        shutdown.
    }
}


function ActivateGridFins {
    for fin in GridFins {
        if fin:hasmodule("ModuleControlSurface") {
            fin:getmodule("ModuleControlSurface"):DoAction("activate pitch controls", true).
            fin:getmodule("ModuleControlSurface"):DoAction("activate yaw control", true).
            fin:getmodule("ModuleControlSurface"):DoAction("activate roll control", true).
        }
        if fin:hasmodule("SyncModuleControlSurface") {
            fin:getmodule("SyncModuleControlSurface"):DoAction("activate pitch controls", true).
            fin:getmodule("SyncModuleControlSurface"):DoAction("activate yaw control", true).
            fin:getmodule("SyncModuleControlSurface"):DoAction("activate roll control", true).
        }
    }
}


function DeactivateGridFins {
    for fin in GridFins {
        if fin:hasmodule("ModuleControlSurface") {
            fin:getmodule("ModuleControlSurface"):DoAction("deactivate pitch control", true).
            fin:getmodule("ModuleControlSurface"):DoAction("deactivate yaw control", true).
            fin:getmodule("ModuleControlSurface"):DoAction("deactivate roll control", true).
        }
        if fin:hasmodule("SyncModuleControlSurface") {
            fin:getmodule("SyncModuleControlSurface"):DoAction("deactivate pitch control", true).
            fin:getmodule("SyncModuleControlSurface"):DoAction("deactivate yaw control", true).
            fin:getmodule("SyncModuleControlSurface"):DoAction("deactivate roll control", true).
        }
    }
}


function setTowerHeadingVector {
    if not (LandSomewhereElse) {
        if not (TargetOLM = "false") {
            if homeconnection:isconnected {
                if exists("0:/settings.json") {
                    set L to readjson("0:/settings.json").
                    if L:haskey("TowerHeadingVector") {
                        set TowerHeadingVector to L["TowerHeadingVector"].
                    }
                }
            }
            lock RollVector to AngleAxis(2.9, up:vector) * vxcl(up:vector, Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position - BoosterCore:position).
        }
    }
}


function GetBoosterRotation {
    if not (TargetOLM = "false") and RadarAlt < 100 {
    //if 1=2 {
        set TowerHeadingVector to AngleAxis(8, up:vector) * vxcl(up:vector, Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position - Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position).

        set varR to vang(vxcl(up:vector, BoosterCore:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position), AngleAxis(-30, up:vector) * TowerHeadingVector) - 21.8.

        return min(max(varR, -22), 38).
    }
}


function DetectWobblyTower {
    if not (TargetOLM = "false") and RadarAlt < 100 {
        if Vessel(TargetOLM):distance < 2000 {
            set ErrorPos to vxcl(up:vector, Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position - Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Rooftop")[0]:position):mag.
            if ErrorPos > 1 * Scale {
                set WobblyTower to true.
            }
        }
    }
}


function SetGridFinAuthority {
    parameter x.
    for fin in GridFins {
        if fin:hasmodule("ModuleControlSurface") {
            fin:getmodule("ModuleControlSurface"):SetField("authority limiter", x).
        }
        if fin:hasmodule("SyncModuleControlSurface") {
            fin:getmodule("SyncModuleControlSurface"):SetField("authority limiter", x).
        }
    }
}