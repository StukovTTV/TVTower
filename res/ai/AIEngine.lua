-- ============================
-- === AI Engine ===
-- ============================
-- Autor: Manuel Vögele (STARS_crazy@gmx.de)

-- ##### HISTORY #####
-- 22.02.2012 Manuel
-- Ein paar Methoden umbenannt
-- 13.12.2007 Manuel
-- NEW: SLFDataObject eingefügt
-- 12.12.2007 Manuel
-- +++++ Library erstellt +++++

-- ##### INCLUDES #####
dofile("res/ai/SLF.lua")

-- ##### GLOBALS #####
globalPlayer = nil

-- ##### KONSTANTEN #####
TASK_STATUS_OPEN	= "T_open"
TASK_STATUS_PREPARE	= "T_prepare"
TASK_STATUS_RUN		= "T_run"
TASK_STATUS_DONE	= "T_done"

JOB_STATUS_NEW		= "J_new"
JOB_STATUS_REDO		= "J_redo"
JOB_STATUS_RUN		= "J_run"
JOB_STATUS_DONE		= "J_done"

-- ##### KLASSEN #####
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
KIObjekt = SLFObject:new()			-- Erbt aus dem Basic-Objekt des Frameworks
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
KIDataObjekt = SLFDataObject:new()	-- Erbt aus dem DataObjekt des Frameworks
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
AIPlayer = KIDataObjekt:new{
	CurrentTask = nil;
}

function AIPlayer:typename()
	return "KIPlayer"
end

function AIPlayer:initialize()
	math.randomseed(TVT.GetMillisecs())

	self:initializePlayer()

	self.TaskList = {}
	self:initializeTasks()
end

function AIPlayer:initializePlayer()
	--Zum überschreiben
end

function AIPlayer:initializeTasks()
	--Zum überschreiben
end

function AIPlayer:ValidateRound()
	--Zum überschreiben
end

function AIPlayer:Tick()
	self:TickAnalyse()

	if (self.CurrentTask == nil) or (self.CurrentTask.Status == JOB_STATUS_DONE) then
		self:BeginNewTask()
	else
		if self.CurrentTask.Status == TASK_STATUS_DONE then
			self:BeginNewTask()
		else
			self.CurrentTask:Tick()
		end
	end
end

function AIPlayer:TickAnalyse()
	--Zum überschreiben
end

function AIPlayer:BeginNewTask()
	self.CurrentTask = self:SelectTask()
	if self.CurrentTask = nil
		debugMsg("AIPlayer:BeginNewTask - task is nil... " )
	else
		self.CurrentTask:Activate()
		self.CurrentTask:StartNextJob()
	end
end

function AIPlayer:SelectTask()
	local BestPrio = -1
	local BestTask = nil

	for k,v in pairs(self.TaskList) do
		v:RecalcPriority()
		if (BestPrio < v.CurrentPriority) then
			BestPrio = v.CurrentPriority
			BestTask = v
		end
	end

	return BestTask
end

function AIPlayer:OnDayBegins()
	--Zum überschreiben
end

function AIPlayer:OnReachRoom()
	self.CurrentTask:OnReachRoom()
end
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Ein Task repräsentiert eine zu erledigende KI-Aufgabe die sich üblicherweise wiederholt. Diese kann wiederum aus verschiedenen Jobs bestehen
AITask = KIDataObjekt:new{
	Status = TASK_STATUS_OPEN; -- Der Status der Aufgabe
	CurrentJob = nil; -- Welcher Job wird aktuell bearbeitet und bei jedem Tick benachrichtigt
	BasePriority = 0; -- Grundlegende Priorität der Aufgabe
	SituationPriority = 0; -- Dieser Wert kann sich ändern, wenn besondere Ereignisse auftreten, die von einer bestimmen Aufgabe eine höhere Priorität erfordert
	CurrentPriority = 0; -- Berechnet: Aktuelle Priorität dieser Aufgabe
	LastDone = 0; -- Zeit, wann der Task zuletzt abgeschlossen wurde
	StartTask = 0; -- Zeit, wann der Task zuletzt gestartet wurde
	TickCounter = 0; -- Gibt die Anzahl der Ticks an seit dem der Task läuft
	TargetRoom = -1; -- Wie lautet die ID des Standard-Zielraumes? !!! Muss überschrieben werden !!!
	CurrentBudget = 0; -- Wie viel Geld steht der KI noch zur Verfügung um diese Aufgabe zu erledigen.
	BudgetWholeDay = 0; -- Wie hoch war das Budget das die KI für diese Aufgabe an diesem Tag einkalkuliert hat.
	BudgetWeigth = 0 -- Wie viele Budgetanteile verlangt diese Aufgabe vom Gesamtbudget?
}

function AITask:typename()
	return "AITask"
end

function AITask:Activate()
	debugMsg("Implementiere mich... " .. type(self))
end

function AITask:OnDayBegins()
	--kann überschrieben werden
end

--Wird aufgerufen, wenn der Task zur Bearbeitung ausgew�hlt wurde (NICHT �BERSCHREIBEN!)
function AITask:StartNextJob()
	debugMsg("StartNextJob")
	local roomNumber = TVT.GetPlayerRoom()
	debugMsg("Player-Raum: " .. roomNumber .. " - Target-Raum: " .. self.TargetRoom)
	if TVT.GetPlayerRoom() ~= self.TargetRoom then --sorgt dafür, dass der Spieler in den richtigen Raum geht!
		self.Status = TASK_STATUS_PREPARE
		self.CurrentJob = self:getGotoJob()
	else
		self.Status = TASK_STATUS_RUN
		self.StartTask = TVT.GetTime()
		self.TickCounter = 0;
		self.CurrentJob = self:GetNextJobInTargetRoom()

		if (self.Status == TASK_STATUS_DONE) then
			return
		end
	end

	self.CurrentJob:Start()
end

function AITask:Tick()
	if (self.Status == TASK_STATUS_RUN) then
		self.TickCounter = self.TickCounter + 1
	end

	if (self.CurrentJob == nil) then
		--debugMsg("----- Kein Job da - Neuen Starten")
		self:StartNextJob() --Von vorne anfangen
	else
		if self.CurrentJob.Status == JOB_STATUS_DONE then
			self.CurrentJob = nil
			--debugMsg("----- Alter Job ist fertig - Neuen Starten")
			self:StartNextJob() --Von vorne anfangen
		else
			--debugMsg("----- Job-Tick")
			self.CurrentJob:Tick() --Fortsetzen
		end
	end
end

function AITask:GetNextJobInTargetRoom()
	--return self:getGotoJob()
	error("Muss noch implementiert werden")
end

function AITask:getGotoJob()
	local aJob = AIJobGoToRoom:new()
	aJob.TargetRoom = self.TargetRoom
	return aJob
end

function AITask:RecalcPriority()
	local Ran1 = math.random(4)
	local Ran2 = math.random(4)
	local TimeDiff = TVT.GetTime() - self.LastDone
	self.CurrentPriority = self.SituationPriority + (self.BasePriority * (8+Ran1)) + (TimeDiff / 10 * (self.BasePriority - 2 + Ran2))
end

function AITask:SetDone()
	debugMsg("Done!")
	self.Status = TASK_STATUS_DONE
	self.SituationPriority = 0
	self.LastDone = TVT.GetTime()
end

function AITask:OnReachRoom()
	debugMsg("OnReachRoom!")
	if (self.CurrentJob ~= nil) then
		self.CurrentJob:OnReachRoom()
	end
end

-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
AIJob = KIDataObjekt:new{
	Id = "";
	Status = JOB_STATUS_NEW;
	StartJob = 0;
	LastCheck = 0;
	StartParams = nil;
}

function AIJob:typename()
	return "AIJob"
end

function AIJob:Start(pParams)
	self.StartParams = pParams
	self.StartJob = TVT.GetTime()
	self.LastCheck = TVT.GetTime()
	self:Prepare(pParams)
end

function AIJob:Prepare(pParams)
	debugMsg("Implementiere mich: " .. type(self))
end

function AIJob:Tick()
	--Kann �berschrieben werden
end

function AIJob:ReDoCheck(pWait)
	if ((self.LastCheck + pWait) < TVT.GetTime()) then
		debugMsg("ReDoCheck")
		self.Status = JOB_STATUS_REDO
		self.LastCheck = TVT.GetTime()
		self:Prepare(self.StartParams)
	end
end

function AIJob:OnReachRoom()
	--Kann überschrieben werden
end
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
AIJobGoToRoom = AIJob:new{
	TargetRoom = 0
}

function AIJobGoToRoom:typename()
	return "AIJobGoToRoom"
end

function AIJobGoToRoom:OnReachRoom()
	debugMsg("AIJobGoToRoom DONE!")
	self.Status = JOB_STATUS_DONE
end

function AIJobGoToRoom:Prepare(pParams)
	if ((self.Status == JOB_STATUS_NEW) or (self.Status == TASK_STATUS_PREPARE) or (self.Status == JOB_STATUS_REDO)) then
		TVT.DoGoToRoom(self.TargetRoom)
		self.Status = JOB_STATUS_RUN
	end
end

function AIJobGoToRoom:Tick()
	if (self.Status ~= JOB_STATUS_DONE) then
		self:ReDoCheck(10)
	end
end
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
StatisticEvaluator = SLFDataObject:new{
	MinValue = -1;
	AverageValue = -1;
	MaxValue = -1;

	MinValueTemp = 100000000000000;
	AverageValueTemp = -1;
	MaxValueTemp = -1;

	TotalSum = 0;
	Values = 0;
}

function StatisticEvaluator:Adjust()
	self.MinValueTemp = 100000000000000
	self.AverageValueTemp = -1
	self.MaxValueTemp = -1
	self.Values = 0
end

function StatisticEvaluator:AddValue(value)
	self.Values = self.Values + 1

	if value < self.MinValueTemp then
		self.MinValue = value
		self.MinValueTemp = value
	end
	if value > self.MaxValueTemp then
		self.MaxValue = value
		self.MaxValueTemp = value
	end

	self.TotalSum = self.TotalSum + value
	self.AverageValueTemp = math.round(self.TotalSum / self.Values, 0)
	self.AverageValue = self.AverageValueTemp
end
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


function debugMsg(pMessage)
	if TVT.ME == 2 then --Nur Debugausgaben von Spieler 2
		TVT.PrintOut(TVT.ME .. ": " .. pMessage)
		--TVT.SendToChat(TVT.ME .. ": " .. pMessage)
	end
end

function CutFactor(factor, minValue, maxValue)
	if (factor > maxValue) then
		return maxValue
	elseif (factor < minValue) then
		return minValue
	else
		return factor
	end
end