
declare @t table (
StudentID uniqueidentifier not null,
InvolvementID uniqueidentifier null,
ItemID uniqueidentifier NULL,
VersionID uniqueidentifier NULL,
ItemDef varchar(100) NULL,
DateID uniqueidentifier NULL,
DatesLatest bit null,
ESYID uniqueidentifier NULL,
LREInstanceID uniqueidentifier NULL,
LREID uniqueidentifier null,
--XPortInstanceID uniqueidentifier NULL,
--MeicaidHistoryID uniqueidentifier NULL,
StudentName varchar(150) NULL,
StudentNumber varchar(50) NULL,
School varchar(150) NULL,
ENS bit NULL,
FEFP varchar(50) NULL,
N999 bit NULL,
ESY varchar(10) NULL,
MedicaidPermissionDate datetime NULL,
IEPPlanDate datetime NULL,
IEPExpirationDate datetime NULL,
ReevaluationDueDate datetime NULL,
DismissalDate datetime NULL,
AssessmentType varchar(150) NULL, -- (FAA, Standard) 
SixtyDayException bit NULL,
IDEAEnvironment varchar(500) NULL,
TTSW int NULL, -- set this to School default, then update it if necessary, from IEP or ???
TNDP int NULL,
TransportEquipment bit NULL,
TransportMedicalCond bit NULL,
TransportMonitor bit NULL,
TransportShortDay bit NULL,
TransportOtherDist bit NULL,
SpecialTestingAccommodations ntext NULL -- multiple possible
)

set ansi_warnings off;
insert @t (StudentID, InvolvementID, ItemID, VersionID, ItemDef, StudentName, StudentNumber, School, IEPPlanDate, IEPExpirationDate, ENS, N999, SixtyDayException, TTSW, TNDP, TransportEquipment, TransportMedicalCond, TransportMonitor, TransportShortDay, TransportOtherDist)
select 
	StudentID = s.ID,
	InvolvementID = inv.ID,
	ItemID = i.ID,
	VersionID = v.ID,
	ItemDef = id.Name,
	StudentName = s.Firstname + ' ' + s.Lastname,
	StudentNumber = s.Number,
	School  = sch.name, --(service)
	IEPPlanDate = i.StartDate,
	IEPExpirationDate = i.PlannedEndDate,
	ENS = 0,
	N999 = cast(case sch.ID when 'C3666321-0EA5-4627-9DB5-4ABFB00A9F22' then 1 else 0 end as bit),
	SixtyDayException = 0,
	TTSW = sch.MinutesInstruction, -- update later if appropriate
	TNDP = 0, -- time with non-disabled peers -- update this later
	TransportEquipment = isnull(xport.Q1,0), --	Medical Equipment (Wheelchair, oxygen, unique seating, etc.) 
	TransportMedicalCond = isnull(xport.Q2,0), --	Special environment (dust controlled, temperature controlled, tinted windows).             ------------------- environment?
	TransportMonitor = isnull(xport.Q3,0), --	Aide or monitor is required due to disability and specific need to student. 
	TransportShortDay = isnull(xport.Q4,0), --	Shortened school day is required due to disability and specific need of student. 
	TransportOtherDist = 0
-- select xport.StudentID, count(*) tot
from Student s
join PrgInvolvement inv on s.ID = inv.StudentID and inv.ProgramID = 'F98A8EF2-98E2-4CAC-95AF-D7D89EF7F80C' and inv.EndDate is null
join PrgItem i on s.ID = i.StudentID and i.InvolvementID = inv.ID and i.EndDate is null
join PrgVersion v on i.ID = v.ItemID and v.DateFinalized = ( -- is versioning possible on PrgItem?
	select max(xv.DateFinalized)
	from PrgVersion xv 
	where i.ID = xv.ItemID)
join PrgItemDef id on i.DefID = id.ID and id.TypeID = 'A5990B5E-AFAD-4EF0-9CCA-DC3685296870' -- IEP
join School sch on s.CurrentSchoolID = sch.ID
left join MedicaidEligibilityHistory mh on s.ID = mh.StudentID and 
	mh.ID = (
	select top 1 m.ID
	from MedicaidEligibilityHistory m
	where s.ID = m.StudentID
	order by m.StartDate asc
	) 
left join x_FormletView.Transportation xport on i.ID = xport.ItemID and xport.CreatedDate = (
	select max(xxp.CreatedDate)
	from x_FormletView.Transportation xxp 
	where xport.ItemID = xxp.ItemID)
--group by xport.StudentID having count(*) > 1


--select count(*) from @t -- 4760
--select count(distinct ItemID) from @t -- 4760

--select * from x_FormletView.Transportation where StudentID = '7DEFF636-CBE7-4503-BB72-B071831E9B0C'

---- search for the view instance id. find where it can be narrowed to the correct result row
--x_datateam.findguid '3BF9A99B-7D9E-41E1-8424-02980EA6F5E8'
--select * from dbo.PrgItemForm where ID = '3BF9A99B-7D9E-41E1-8424-02980EA6F5E8' -- createddate
--select * from dbo.FormInstance where Id = '3BF9A99B-7D9E-41E1-8424-02980EA6F5E8'
--select * from dbo.FormInstanceInterval where InstanceId = '3BF9A99B-7D9E-41E1-8424-02980EA6F5E8'
--select * from dbo.IepSpecialFactor where FormInstanceId = '3BF9A99B-7D9E-41E1-8424-02980EA6F5E8'



--select ItemID, count(*) tot
--from @t
--group by ItemID
--having count(*) > 1


--select * from @t where ItemID = '01E3470E-4E27-4CD3-8575-07544A2A526D'



-- select * from MedicaidEligibilityHistory where StudentID = 'E856CE08-8AED-4E1A-A644-501C70E63674'


update t set ESY = esyyn.DisplayValue
--select esyyn.DisplayValue, t.*
from @t t
-- ESY
join PrgSection sesy on t.ItemID = sesy.ItemID and sesy.OnLatestVersion = 1 and t.VersionID = sesy.VersionID
	join IepEsy iesy on sesy.ID = iesy.ID
	join EnumValue esyyn on iesy.DecisionID = esyyn.ID

-- Dates
update t set ReEvaluationDueDate = dat.NextEvaluationDate
--select 	ReEvaluationDueDate = dat.NextEvaluationDate
from @t t
join PrgSection sdat on t.ItemID = sdat.ItemID and sdat.OnLatestVersion = 1 and t.VersionID = sdat.VersionID
	join IepDates dat on sdat.ID = dat.ID

-- LRE

declare @maxlre table (
StudentNumber varchar(10) not null,
ItemID uniqueidentifier not null,
InstanceID uniqueidentifier not null,
LreID uniqueidentifier not null,
SourceID uniqueidentifier not null,
Sequence int not null
)
insert @maxlre 
select t.StudentNumber, t.ItemID, InstanceID = s.ID, LreID = psrc.ID, psrc.SourceID, lresrc.Sequence 
from @t t 
join PrgSection s on t.ItemID = s.ItemID and s.OnLatestVersion = 1 
join IepLeastRestrictiveEnvironment lre on s.ID = lre.ID
join IepPlacement psrc on s.ID = psrc.InstanceID 
join IepPlacement_AsOfDate(getdate()) currlre on psrc.ID = currlre.ID and currlre.IsActive = 1
join EnumValue lresrc on psrc.SourceID = lresrc.ID
--where t.StudentNumber in ('306222055', '306221485')

--select * 
--from @maxlre xl
--order by StudentNumber, Sequence desc

--select * from Student where ID = '1BFE486A-62A8-489D-86BE-05A036C8F919'

--select * from IepPlacement_AsOfDate(getdate())  where IsActive = 1

-- 306222055 John Nguyen
-- 306221485 Dylan Thompson



--select count(*) from @t
--select count(*) from @maxlre


--select ItemID, count(*) tot
--from @maxlre x
--group by ItemID 
--having count(*) > 1
--order by 2 desc

--select distinct p.* 
--from @maxlre x
--join IepPlacement p on x.lreid = p.id
--where ItemID = '4578D32D-90CC-4890-9AAE-33CDFEF9162D'




----select * from @t where StudentID = '1BFE486A-62A8-489D-86BE-05A036C8F919'
--select count(*) from @maxlre

/**/

--select * from @t t where t.StudentNumber in ('306222055', '306221485')

-- select InstanceID, SourceID, Sequence, LRE, count(*) tot from (
update t set IDEAEnvironment = po.Text
-- select maxlre.*, LRE = convert(varchar(max), po.Text)
from @t t
join @maxlre maxlre on t.ItemID = maxlre.ItemID 
join (
	select xl.ItemID, max(xl.Sequence) maxSequence
	from @maxlre xl
	group by xl.ItemID
	) xl on maxlre.ItemID = xl.ItemID and maxlre.Sequence = xl.maxSequence
	--and maxlre.Sequence = (
	--select max(xl.sequence)
	--from @maxlre xl 
	--where maxlre.ItemID = t.ItemID
	--)
join IepPlacement p on maxlre.lreid = p.ID
join IepPlacementOption po on p.OptionID = po.ID 
-- where t.StudentID = '1BFE486A-62A8-489D-86BE-05A036C8F919'
--where lre.InstanceID = '2A892AC1-66E8-4F10-87B1-055410D29B16'
--) t group by InstanceID, SourceID, Sequence, LRE having count(*) > 1
-- where t.StudentNumber in ('306222055', '306221485')



select t.*
from @t t
--where t.IDEAEnvironment is null
--where t.StudentNumber in ('306222055', '306221485')

--select t.Name, o.* 
--from IepPlacementType t
--join IepPlacementOption o on t.ID = o.TypeID
--order by t.name, o.sequence

--select t.Name, p.InstanceID, count(*) tot
--from iepPlacement p
--join IepPlacementOption o on p.OptionID = o.ID
--join IepPlacementType t on o.TypeId = t.Id
--group by t.Name, p.instanceid
--order by 3 desc

--select * from PrgSection where ID = '50843E17-19CB-4532-B993-0F2193854DD8'
--select * from PrgItem where ID = '4DF90EFA-3FD2-4975-9519-11051342D986'
--select * from Student where ID = 'C67A49DC-57CA-48B1-AD92-770218F8635B'





--select * from @t
--where IdeaEnvironment is null

-- select count(*) from iepplacement where sourceid is null

-- select * from IepPlacement_AsOfDate(getdate()) where isactive = 1

-- 4538
-- 4465 distinct
-- 58 dup+ instance


--maxlre view

--select * 
--from PrgSectionType where name like '%lre%'

--select st.name, sd.Title, sd.IsVersioned, count(*) tot 
--from PrgItemDef id
--join PrgSectionDef sd on id.ID = sd.ItemDefID
--join PrgSectionType st on sd.TypeID = st.ID
--where id.TypeID = 'A5990B5E-AFAD-4EF0-9CCA-DC3685296870'
--group by st.Name, sd.Title, sd.IsVersioned
--order by 1



--select * from PrgItemType where name = 'IEP'




--Exceptionality varchar(50) NULL,
--ConsentDate datetime NULL,
--EligibilityDate datetime NULL,
--EvaluationDate datetime NULL,
--PlacementDate datetime NULL,

