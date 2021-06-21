set transaction isolation level Read Uncommitted
Set nocount on


if object_id('tempdb.dbo.#WIP') is not null drop table #WIP
if object_id('tempdb.dbo.#MOVES') is not null drop table #MOVES


Declare @start as datetime, @end as datetime
Select @start =(case when DATEPART(hh,GETDATE()) < 09 then CONVERT(varchar(100), dateadd(day,-1,GETDATE()) ,112) + cast('07:00:00' as datetime) else CONVERT(varchar(100),GETDATE() ,112) + cast('07:00:00' as datetime) end),
        @end =(case when DATEPART(hh,GETDATE()) < 09 then CONVERT(varchar(100), GETDATE() ,112) + cast('07:00:00' as datetime) else CONVERT(varchar(100),dateadd(day,1,GETDATE()) ,112) + cast('07:00:00' as datetime) end)



select distinct 
rtrim(FLS.lot_id) as lot_id,
rtrim(FLS.lot_priority_status) as lot_priority_status,
rtrim(case when FLS.scheduling_state_code is null then FLS.state_code else FLS.scheduling_state_code end) as lot_status,
rtrim(FLS.design_id) as design_id,
rtrim(STEP.step_name) as step_name,
rtrim(FLS.lot_in_qty) as lot_in_qty,
rtrim(FLS.lot_current_qty) as lot_current_qty,
case datediff(minute, FLS.staged_datetime, getdate()) / 60.0 when 0.0 then '0' else ltrim(str(datediff(minute, FLS.staged_datetime, getdate()) / 60.0, 15, 1)) end as MTAS,
rtrim(CML.carrier_id) as carrier_id,
--FLS.mfg_part_code,
--trav.trav_id,
--FLS.hold_datetime,
FLS.location_state,
--FLS.lot_start_datetime,
case when recipe.recipe_name is null then '' else recipe.recipe_name end as recipe_name,
case when recipe.exception_name is null then '' else recipe.exception_name end as exception
--FLS.tracked_in_datetime
,
rtrim(
CASE
WHEN SUBSTRING (FLS.mfg_part_code,2,1)='0' THEN '100S'
WHEN SUBSTRING (FLS.mfg_part_code,2,1)='1' THEN '110S'
WHEN SUBSTRING (FLS.mfg_part_code,2,1)='2' THEN '120S'
WHEN SUBSTRING (FLS.mfg_part_code,2,1)='3' THEN '130S'
WHEN SUBSTRING (FLS.mfg_part_code,2,1)='4' THEN '140S'
WHEN SUBSTRING (FLS.mfg_part_code,2,1)='5' THEN '150S'
WHEN SUBSTRING (FLS.mfg_part_code,2,1)='6' THEN '160S' END) AS TechNode
FROM 
fab_lot_extraction..fab_lot_status FLS
--	ON ([recipe_hold_flag] NOT LIKE 'Y' OR  [recipe_hold_flag] IS NULL) AND FLS.lot_id = FLR.lot_id
LEFT JOIN traveler..trav_step TS
	ON FLS.trav_step_OID = TS.trav_step_OID
LEFT JOIN traveler..step STEP
	ON TS.step_OID = STEP.step_OID
LEFT JOIN fab_lot_extraction..carrier_map_lot CML
	ON FLS.lot_id = CML.lot_id
LEFT JOIN reference..traveler trav
	on trav.trav_OID = TS.trav_OID
LEFT JOIN [scheduler_source].[dbo].[fab_lot_recipe] recipe
	on recipe.lot_id = FLS.lot_id
	and recipe.step_name= STEP.step_name
LEFT JOIN fab_lot_extraction..fab_lot_attr_value ATTR
ON ATTR.lot_id = FLS.lot_id AND ATTR.corr_item_OID = 0xC07A75626E050080
WHERE
FLS.current_mfg_facility_OID = 0x8E3074D7400A9854
AND FLS.state_code != 'Complete'
AND FLS.state_code != 'On Hold Long Term'
AND FLS.mfg_part_code NOT LIKE 'TW'
AND FLS.mfg_part_code NOT LIKE '____[BUX]%'
AND trav.trav_type != 'NONPRODUCTION'
AND FLS.lot_current_qty > 0
AND FLS.lot_id NOT LIKE 'VL%'


order by 
--FLS.lot_start_datetime,
design_id





--SELECT 
--rtrim(FLH.design_id) AS DID,
--rtrim(STEP.step_name) AS STEP,
--sum(FLH.lot_out_qty) AS [OUT QTY]
--into #MOVES
--FROM fab_lot_extraction..fab_lot_hist FLH
--JOIN traveler.dbo.trav_step TS
--ON FLH.trav_step_OID = TS.trav_step_OID
--JOIN traveler..traveler TRAV
--ON TS.trav_OID = TRAV.trav_OID'
--JOIN traveler..step STEP
--ON TS.step_OID = STEP.step_OID
--WHERE FLH.owned_mfg_facility_OID = 0x8E3074D7400A9854
--AND FLH.tracked_out_datetime >= @start and FLH.tracked_out_datetime < @end
--AND FLH.part_type_code NOT LIKE 'TW'
--AND FLH.reworked_step_sw = 'N'
--AND FLH.part_type_code NOT LIKE '____[BUX]%'
--GROUP by FLH.design_id, STEP.step_name


;
select 
Format(cast(GETDATE() as datetime), 'MM/dd/yyyy hh:mm:ss tt') as last_update