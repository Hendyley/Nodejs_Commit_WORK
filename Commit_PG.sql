/****** Script for SelectTopNRows command from SSMS  ******/
set nocount on
set transaction isolation level read uncommitted

if object_id('tempdb.dbo.#loop') is not null drop table #loop
if object_id('tempdb.dbo.#wip') is not null drop table #wip
if object_id('tempdb.dbo.#wip2') is not null drop table #wip2
if object_id('tempdb.dbo.#sim') is not null drop table #sim
if object_id('tempdb.dbo.#wsg') is not null drop table #wsg

Declare @start as datetime, @end as datetime, @st as datetime
Select @start =(case when DATEPART(hh,GETDATE()) < 09 then CONVERT(varchar(100), dateadd(day,-1,GETDATE()) ,112) + cast('07:00:00' as datetime) else CONVERT(varchar(100),GETDATE() ,112) + cast('07:00:00' as datetime) end),
    @end =(case when DATEPART(hh,GETDATE()) < 09 then CONVERT(varchar(100), GETDATE() ,112) + cast('07:00:00' as datetime) else CONVERT(varchar(100),dateadd(day,1,GETDATE()) ,112) + cast('07:00:00' as datetime) end)

Select
@st =(
case 
when DATEPART(hh,GETDATE()) >= 7 and DATEPART(hh,GETDATE()) <=19
then CONVERT(varchar(100),GETDATE() ,112) + cast('07:00:00' as datetime)



when DATEPART(hh,GETDATE()) <= 7 and DATEPART(hh,GETDATE()) >=00
then CONVERT(varchar(100),dateadd(day,-1,GETDATE()) ,112) + cast('07:00:00' as datetime) 


else CONVERT(varchar(100),dateadd(day,0,GETDATE()) ,112) + cast('07:00:00' as datetime) 
end)

--SELECT  distinct 
--s.TechNode,
--s.MfgAreaId,
--s.WorkWeek,
--s.[Model Version],
--s.StepName,
--sum(s.[Sim Moves]) as sim_moves,
--sum(s.[TG-2]) as TG_2
--into #sim
--FROM 
--[SIC_METRICS].[SIC_METRICS].[F10N Sim vs Act vs TG Accuracy Database (Stepname Level)] s 
--where
--s.[Model Version] = (select distinct top 1 d.[Model Version] from [SIC_METRICS].[SIC_METRICS].[F10N Sim vs Act vs TG Accuracy Database (Stepname Level)] d order by d.[Model Version] desc) 
--group by 
--s.TechNode,
--s.MfgAreaId,
--s.WorkWeek,
--s.[Model Version],
--s.StepName
--order by s.[Model Version] desc


SELECT distinct
ws.WS_name,
wsg.WS_group_name
into #wsg
FROM 
[reference].[dbo].[FP_WS] ws
inner join   [reference].[dbo].[FP_WS_in_WS_group] wsiwsg
on ws.WS_OID = wsiwsg.WS_OID
inner join   [reference].[dbo].[FP_WS_group] wsg
on wsg.WS_group_OID = wsiwsg.WS_group_OID
where
ws.WS_name like '%10-%'



Select 
    BASETRAV.[Tech Node],
    BASETRAV.[Part Group],
    BASETRAV.[Area Name],
    BASETRAV.[Step Name],
    MOVES.[OUT QTY],
    WIP.[CUR INV],
    WIP.[RUN INV],
    WIP.[HOLD INV],
    WIP.[AVG MTAS (Hrs)],
    WIP.[AVG MTAS (Hrs)]*WIP.[CUR INV] as [Weighted MTAS]


--EOH Traveler
into #wip2
--into #wip
FROM
    (    SELECT
            (CASE WHEN substring(EOH.TechNode,2,1)='0' THEN '100S' 
                     WHEN substring(EOH.TechNode,2,1)='1' THEN '110S'
                     WHEN substring(EOH.TechNode,2,1)='2' THEN '120S'
                     WHEN substring(EOH.TechNode,2,1)='3' THEN '130S'
					 WHEN substring(EOH.TechNode,2,1)='4' THEN '140S'
					 WHEN substring(EOH.TechNode,2,1)='5' THEN '150S'  END )[Tech Node],
            (CASE
    WHEN EOH.TechNode = 'L06B_PROD_CR6' THEN  'L06B'
    WHEN EOH.TechNode = 'L06B_PROD_CR8' THEN 'L06J'
    WHEN EOH.TechNode LIKE '%_PROD' THEN SUBSTRING(EOH.TechNode,1,4)
	WHEN EOH.TechNode = 'B47R_ENG' THEN 'B47R'
	WHEN EOH.TechNode = 'N48R_ENG' THEN 'N48R'
	WHEN EOH.TechNode = 'B57R_TD' THEN 'B57R'
    ELSE EOH.TechNode
    END) [Part Group],
            EOH.StepSequence [Seq No],
            EOH.StepName [Step Name],
            EOH.AreaName [Area Name]
        FROM OPS_IMP_METRICS.OI_METRICS.MfgEOHTechNodeSummary EOH
        WHERE EOH.TechNode NOT LIKE 'N%S' AND EOH.TechNode NOT LIKE '%_JDP' AND EOH.TechNode NOT LIKE 'L8_A' AND EOH.TechNode NOT LIKE 'B37R' AND EOH.TechNode NOT LIKE 'B48R' AND EOH.TechNode NOT LIKE 'B47R_PROD' AND EOH.TechNode NOT LIKE 'N48R_PROD'

    UNION

        SELECT
            (CASE WHEN substring(EOH.TechNode,2,1)='1' THEN '110S' END )[Tech Node],
            (CASE
      WHEN EOH.TechNode = 'B17A_PROD' THEN 'B17AW' END) [Part Group],
            EOH.StepSequence,
            EOH.StepName,
            EOH.AreaName
        FROM OPS_IMP_METRICS.OI_METRICS.MfgEOHTechNodeSummary EOH
        WHERE EOH.TechNode = 'B17A_PROD'

) BASETRAV

    --Lot History
    LEFT JOIN
    (SELECT (CASE
    WHEN FLH.design_id = 'B17A' AND ATTR.lot_attr_value = 'YES' THEN 'B17A'
    WHEN FLH.design_id = 'B17A' THEN 'B17AW'
    ELSE FLH.design_id END ) DID,
        rtrim(STEP.step_name) AS STEP, sum (FLH.lot_out_qty) AS [OUT QTY]
    FROM fab_lot_extraction..fab_lot_hist FLH WITH (NOLOCK)
        JOIN traveler.dbo.trav_step TS WITH (NOLOCK)
        ON FLH.trav_step_OID = TS.trav_step_OID
        JOIN traveler..traveler TRAV WITH (NOLOCK)
        ON TS.trav_OID = TRAV.trav_OID
        JOIN traveler..step STEP WITH (NOLOCK)
        ON TS.step_OID = STEP.step_OID
       LEFT JOIN fab_lot_extraction..fab_lot_attr_value ATTR
        ON ATTR.lot_id = FLH.lot_id AND ATTR.corr_item_OID = 0xC07A75626E050080
    WHERE FLH.owned_mfg_facility_OID = 0x8E3074D7400A9854
        AND FLH.tracked_out_datetime >= @start and FLH.tracked_out_datetime < @end
        AND FLH.part_type_code NOT LIKE 'TW'
        AND FLH.reworked_step_sw = 'N'
		AND TRAV.trav_type != 'NONPRODUCTION'
        AND FLH.part_type_code NOT LIKE '____[BUX]%'
    GROUP by (CASE
    WHEN FLH.design_id = 'B17A' AND ATTR.lot_attr_value = 'YES' THEN 'B17A'
    WHEN FLH.design_id = 'B17A' THEN 'B17AW'
    ELSE FLH.design_id END),  STEP.step_name) MOVES
    ON BASETRAV.[Part Group] = MOVES.DID
        AND BASETRAV.[Step Name] = MOVES.STEP
    --join with lot status
    
	LEFT JOIN
    (SELECT (CASE
WHEN FLS.design_id = 'B17A' AND ATTR.lot_attr_value = 'YES' THEN 'B17A'
WHEN FLS.design_id = 'B17A' THEN 'B17AW'
ELSE FLS.design_id END) [DID]
    , rtrim(STEP.step_name) AS STEP
    , sum(FLS.lot_current_qty) AS [CUR INV]
    , sum(case when FLS.scheduling_state_code = 'Running' THEN FLS.lot_current_qty ELSE 0 end) AS [RUN INV]
    , sum(case when FLS.state_code like '%Hold%' THEN FLS.lot_current_qty ELSE 0 end) AS [HOLD INV]
    , AVG(datediff(minute, FLS.staged_datetime, getdate()) / 60.0) AS [AVG MTAS (Hrs)]
    , MAX(datediff(minute, FLS.staged_datetime, getdate()) / 60.0) AS [MAX MTAS (Hrs)]
    FROM fab_lot_extraction.dbo.fab_lot_status FLS WITH (NOLOCK)
        JOIN traveler.dbo.trav_step TS WITH (NOLOCK)
        ON FLS.trav_step_OID = TS.trav_step_OID
        JOIN traveler..traveler TRAV WITH (NOLOCK)
        ON TS.trav_OID = TRAV.trav_OID
        JOIN traveler..step STEP WITH (NOLOCK)
        ON TS.step_OID = STEP.step_OID
        LEFT JOIN fab_lot_extraction..fab_lot_attr_value ATTR
        ON ATTR.lot_id = FLS.lot_id AND ATTR.corr_item_OID = 0xC07A75626E050080
    WHERE FLS.owned_mfg_facility_OID = 0x8E3074D7400A9854
        AND FLS.state_code != 'Complete'
        AND FLS.state_code != 'On Hold Long Term'
        AND FLS.mfg_part_code NOT LIKE 'TW'
        AND FLS.mfg_part_code NOT LIKE '____[BUX]%'
		AND TRAV.trav_type != 'NONPRODUCTION'
        AND FLS.lot_current_qty > 0
        AND FLS.lot_id NOT LIKE 'VL%'
    GROUP by (CASE
WHEN FLS.design_id = 'B17A' AND ATTR.lot_attr_value = 'YES' THEN 'B17A'
WHEN FLS.design_id = 'B17A' THEN 'B17AW'
ELSE FLS.design_id END), STEP.step_name) WIP
    ON BASETRAV.[Part Group] = WIP.DID
        AND BASETRAV.[Step Name] = WIP.STEP
    LEFT JOIN
    (SELECT DISTINCT TNS.TechNode, TNS.StepName, TNS.WorkstationGroupName AS Workstation
    FROM OPS_IMP_METRICS.OI_METRICS.MfgEOHTechNodeSummary TNS WITH (NOLOCK)
       JOIN OPS_IMP_METRICS.OI_METRICS.MfgWorkstationSummary WSS WITH (NOLOCK)
        ON TNS.WorkstationGroupName = WSS.Workstation
    Where WSS.InServEquip != '0') WORKSTATION
    ON BASETRAV.[Step Name] = WORKSTATION.StepName
        AND BASETRAV.[Tech Node] = WORKSTATION.TechNode
ORDER BY BASETRAV.[Part Group], BASETRAV.[Seq No]



select distinct
*
into #wip
from #wip2 w2


select distinct
cast( datediff(minute,@st,getdate())  as float) / 1440 as TimeVal,
wip.[Area Name] as AreaName ,
wip.[Step Name] as StepName,
--wip.[Tech Node] as TechNode,
wip.[Part Group] as TechNode, --as PartGroup,
case when sum(wip.[OUT QTY]) is null then 0 else sum(wip.[OUT QTY]) end as Moves,
case when sum(wip.[CUR INV]) is null then 0 else sum(wip.[CUR INV]) end as Wip,
case when sum(wip.[RUN INV]) is null then 0 else sum(wip.[RUN INV]) end as Running,
case when sum(wip.[HOLD INV]) is null then 0 else sum(wip.[HOLD INV]) end as Hold,
case when sum(wip.[Weighted MTAS]) /sum(wip.[CUR INV])/24   is null then 0 else sum(wip.[Weighted MTAS]) /sum(wip.[CUR INV])/24  end as MTAS
--,s.sim_moves
--,s.TG_2
from #wip wip
--inner join OPS_IMP_METRICS.OI_METRICS.MfgEOHTechNodeSummary EOH 
--on EOH.StepName = wip.[Step Name] 
--left join #wsg wsg on wsg.WS_group_name = EOH.WorkstationGroupName
--left join #sim s
--on s.MfgAreaId = wip.[Area Name] COLLATE SQL_Latin1_General_CP1_CS_AS
--and s.TechNode = wip.[Tech Node] COLLATE SQL_Latin1_General_CP1_CS_AS
--and s.StepName = wip.[Step Name] COLLATE SQL_Latin1_General_CP1_CS_AS
where
 wip.[Area Name] <>''
--and EOH.TechNode not IN ('N100S', 'N110S', 'N110R', 'N120S', 'N130S', 'N140S', 'N150S', 'N160S', 'N170S')
and wip.[Area Name] Not in ('F10 AMHS','F10 METROLOGY','F10 RDA', 'F10 PROBE', 'F10 GENERAL')
and wip.[Tech Node] is not null
--and wip.[Step Name] like '%5030-21 PILLAR INTEGRATED DRY ETCH%' and [Tech Node] = '150S'
group by
wip.[Area Name] ,
wip.[Step Name],
--wip.[Tech Node]   
wip.[Part Group]



--SELECT distinct
--ws.WS_name,
--wsg.WS_group_name
--FROM 
--[reference].[dbo].[FP_WS] ws
--inner join   [reference].[dbo].[FP_WS_in_WS_group] wsiwsg
--on ws.WS_OID = wsiwsg.WS_OID
--inner join   [reference].[dbo].[FP_WS_group] wsg
--on wsg.WS_group_OID = wsiwsg.WS_group_OID
--where
--ws.WS_name like '%10-%'



;
select Format(cast(GETDATE() as datetime), 'MM/dd/yyyy hh:mm:ss tt') as last_refresh