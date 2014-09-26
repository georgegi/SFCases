declare @t table (
StudentID uniqueidentifier not null,
InvolvementID uniqueidentifier null,
ItemID uniqueidentifier NULL,
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
TransportMonitor bit NULL,
TransportMedicalCond bit NULL,
TransportShortDay bit NULL,
TransportOtherDist bit NULL,
SpecialTestingAccommodations ntext NULL -- multiple possible
)

insert @t
select 
	StudentID = s.ID,
	i.InvolvementID,
	ItemID = i.ID,
	--ItemDefID = i.DefID,
-- TROUBLESHOOT DUPLICATES
	DateID = sdat.ID,
	DatesLatest = sdat.OnLatestVersion,
	ESYID = sesy.ID,
	LREInstanceID = plre.ID,
	LREID = lre.ID,
	--XPortInstanceID = xport.InstanceID,
	--MedicaidHistoryID = mh.ID,
-- TROUBLESHOOT DUPLICATES
	StudentName = convert(varchar(150), s.Firstname + ' ' + s.Lastname),
	StudentNumber = convert(varchar(50), s.Number),
	School  = isnull(convert(varchar(150), sch.name), ''), --(service)
	ENS = cast(0 as bit),
	FEFPProgram  = '', -- Leave blank for now, per Jamie
	N999 = cast(case sch.ID when 'C3666321-0EA5-4627-9DB5-4ABFB00A9F22' then 1 else 0 end as bit),
	ESY = convert(varchar(3), esyyn.DisplayValue),
	MedicaidPermissionDate  = isnull(convert(varchar, mh.StartDate, 101), NULL), -- initial 
--IEPDates:
	IEPPlanDate = convert(varchar, i.StartDate, 101),
	IEPExpirationDate = convert(varchar, I.PlannedEndDate, 101),
	ReEvaluationDueDate = convert(varchar, dat.NextEvaluationDate, 101),
	DismissalDate = NULL, -- date dismissed from ESE Exceptionality
	AssessmentType = convert(varchar(150), ''),
	SixtyDayException = cast(0 as bit),
	IDEAEnvironment = convert(varchar(500), po.Text),
	TTSW = convert(int, sch.MinutesInstruction), -- update if appropriate
	TNDP = cast(0 as bit), -- time with non-disabled peers -- update this later
	TransportEquipment = isnull(xport.Q1,0), --	Medical Equipment (Wheelchair, oxygen, unique seating, etc.) 
	TransportMonitor = isnull(xport.Q3,0), --	Aide or monitor is required due to disability and specific need to student. 
	TransportMedicalCond = isnull(xport.Q2,0), --	Special environment (dust controlled, temperature controlled, tinted windows).             ------------------- environment?
	TransportShortDay = isnull(xport.Q4,0), --	Shortened school day is required due to disability and specific need of student. 
	TransportOtherDist = convert(bit, 0), -------------------- ?
	SpecialTestingAccommodations = cast(NULL as ntext)
from Student s
join PrgInvolvement inv on s.ID = inv.StudentID and inv.ProgramID = 'F98A8EF2-98E2-4CAC-95AF-D7D89EF7F80C' and inv.EndDate is null
join PrgItem i on s.ID = i.StudentID and i.InvolvementID = inv.ID and i.EndDate is null
join PrgVersion v on i.ID = v.ItemID and v.DateFinalized = ( -- is versioning possible on PrgItem?
	select max(xv.DateFinalized)
	from PrgVersion xv 
	where i.ID = xv.ItemID)
join PrgItemDef id on i.DefID = id.ID and id.TypeID = 'A5990B5E-AFAD-4EF0-9CCA-DC3685296870' -- IEP
-- ESY
join PrgSection sesy on i.ID = sesy.ItemID /* and sesy.OnLatestVersion = 1 */ and v.ID = sesy.VersionID
	join IepEsy iesy on sesy.ID = iesy.ID
	join EnumValue esyyn on iesy.DecisionID = esyyn.ID
-- Dates
join PrgSection sdat on i.ID = sdat.ItemID /* and sdat.OnLatestVersion = 1 */ and v.ID = sdat.VersionID
	join IepDates dat on sdat.ID = dat.ID
-- LRE
left join PrgSection plre on i.ID = plre.ItemID and plre.OnLatestVersion = 1 /* and v.ID = plre.VersionID */ and plre.DefID in (select ID from PrgSectionDef where TypeID = 'D1C4004B-EF82-4E8F-BA12-D8F086EB9BBE') 
--	left join IepLeastRestrictiveEnvironment ilre on plre.ID = ilre.ID -- we should be able to do a full join without excluding legitimate results.... (trying this instead of TypeID as above)
/* */
left join IepPlacement lre on plre.ID = lre.InstanceID 
	and lre.AsOfDate = (
	SELECT max(AsOfDate) 
	FROM IepPlacement xlre
	WHERE lre.InstanceID = xlre.InstanceID
	and xlre.AsOfDate < getdate() -- 4947
	)
	and lre.SourceID = (
	select top 1 xsrc.ID
	From IepPlacement xlresrc
	join EnumValue xsrc on xlresrc.SourceID = xsrc.ID
	where lre.InstanceID = xlresrc.InstanceID
	order by xsrc.Sequence desc
	)
--												and lre.optionid in ('F5A63BBC-F331-4406-AEE5-359EE9EABF87', '23DB7EB2-9524-492D-A3AF-20A7879B4787')
	--left join IepPlacement_AsOfDate(getdate()) lreao on plre.id = lreao.
	left join IepPlacementOption po on lre.OptionID = po.ID
left join School sch on s.CurrentSchoolID = sch.ID
left join MedicaidEligibilityHistory mh on s.ID = mh.StudentID and 
	mh.ID = (
	select top 1 m.ID
	from MedicaidEligibilityHistory m
	where s.ID = m.StudentID
	order by m.StartDate asc
	) 
left join x_FormletView.Transportation xport on i.ID = xport.ItemID
where s.CurrentSchoolID is not null
-- and s.ID = '79E1D783-57EA-4E35-A5AA-B336A3FCA507'


--and convert(int, Q1)+convert(int, Q2)+convert(int, Q3)+convert(int, Q4) > 0


--select * from iepplacementoption where typeid = 'E47FBA7F-8EB0-4869-89DF-9DD3456846EC' order by sequence 

--F5A63BBC-F331-4406-AEE5-359EE9EABF87 -- inside
--23DB7EB2-9524-492D-A3AF-20A7879B4787 -- campus



-- select * from IepPlacement where ID in ('C6FC059C-0590-461F-ACEC-705853B2F70D', '10364F93-BAF6-43A2-9377-A6B45D7C7B15')

-- sourceid?
--x_DATATEAM.FindGUID 'C9967875-E09B-4F3E-BE00-5BF2A97C7DAD'

--select * from dbo.EnumValue where ID = 'C9967875-E09B-4F3E-BE00-5BF2A97C7DAD' -- User Created
--select * from dbo.EnumValue where ID = '3C5BFC1F-B3E6-4E69-BC32-FCFBA2E8185E' -- StartDate

--select * from EnumValue where Type = '743309E7-CA58-4E08-A320-92A3D9619EB6' order by Sequence
--StartDate
--AgedUp
--User Created



--select lre.*
--from @t t 
--join IepPlacement lre on t.LREID = lre.ID

-- 5561


--select StudentID, count(*) tot
--from @t t 
--group by StudentID 
--having count(*) > 1
--order by tot desc

--select * from @t where StudentID in ('B3909B4D-2881-4FCC-9BA1-BE733A8C1BE4', '98E92754-2B43-44CD-AA5B-BFF4E00626CD', 'AF8EAF7F-AAEF-40F5-A0B2-CA9799BD7F21', '6B377367-F758-4598-8E38-CEB4440D2A23', 'B182CE7F-BE14-401E-8471-D6E19D2A62C1', 'E1E769C8-8DDB-43ED-B68E-D791C36A8AE6', 'C1B10D2B-58DB-4E71-8AFA-E343C8596988', 'C300BB13-EDFF-41AA-9984-E523D6D4F152', '71A09DD7-13C4-464C-99B2-E620903C8DBB', 'FB0BBE58-11D4-415D-8A5A-E7D06AE67786', 'FE6FA818-1623-4788-926E-9BB12034A546', 'A9B42A5E-1818-4BA2-8AA9-9CC9F8529309', 'A83D976D-FA83-4BB7-A779-A08B3916BA23', '9ADE818D-E615-4152-88FC-A1DF2EED3730', '00FC7350-19B3-4C61-BF04-A71FE782E8C8', '723574A5-C3CE-42DB-8261-7A4C0968C760', '64ECC359-4261-4150-A48F-7108B3B2C677', '1368B14F-3132-41F0-8C09-747375BB3981', '2BE61219-2A43-4865-A771-4AE21F034EA7', 'E856CE08-8AED-4E1A-A644-501C70E63674', 'BE7550DC-EE7C-41E0-96E3-50324E22E849', '763EB300-8DC6-4046-B649-5C4B88E1E945', '66DE8BCD-79B0-4950-BB7E-279F408D9B1B', 'FC353E17-B132-40EA-8FF8-3296867BB994', '8E3F77E5-A154-4856-AD80-35C72625A15C', '8B79A267-9275-4D62-9538-462E045FF1A8', 'A48C0847-B9B0-4748-9F0B-02BAF208A024', 'CDBB4CB7-9256-49E2-9483-053A45774A5E', '60E0E39F-48D1-4C70-8A21-054D9CA35D52', '5FB1536D-1920-4652-9AC5-0657A16ADCA5', 'CF3051FB-3DD2-49F6-9878-0CE11E362771', '8BD7F859-C6C2-4E69-AA23-11F649BF8A03', '507997D1-610B-45AF-8569-21E165522A69', 'F2FBCB0A-9F8C-4EAE-9582-220A904DDE69', '1480BC57-053B-40AD-8F07-AF1EA38CEE82')

select src.* 
from @t t
join IepPlacement p on t.LREID = p.ID
join EnumValue src on p.SourceID = src.ID
where t.StudentID = 'CDBB4CB7-9256-49E2-9483-053A45774A5E'


--select * from EnumValue where Type = '743309E7-CA58-4E08-A320-92A3D9619EB6' order by Sequence
--select * from EnumType where ID = '743309E7-CA58-4E08-A320-92A3D9619EB6'
--IEP.PlacementSource

--StartDate
--AgedUp
--User Created




--select studentid, count(*) tot
--from @t t 
--group by studentid
--having count(*) > 1

--select * 
--from @t t
--join x_DATATEAM.DisabilityEligibilityHistory eh on t.InvolvementID = eh.InvolvementID
-- 2868


--select t.StudentID, count(*) tot
--from @t t 
--join x_DATATEAM.DisabilityEligibilityHistory eh on t.InvolvementID = eh.InvolvementID
--group by t.StudentID
--having count(*) > 1


--select * from Student where firstname = 'John' and lastname = 'Nguyen'


-- troubleshoot duplicates
--select * from @t 
----where StudentID in ('7F71C938-72C6-49CE-AC07-00CD9A155514', '06A10681-23D6-410A-B277-01226F426536', '45D8A863-DD44-4CBC-BA6F-019035156DAB')
--where StudentID = '45D8A863-DD44-4CBC-BA6F-019035156DAB'
--order by StudentNumber

--select * 
--from x_DATATEAM.DisabilityEligibilityHistory 
---- where StudentID in ('7F71C938-72C6-49CE-AC07-00CD9A155514', '06A10681-23D6-410A-B277-01226F426536', '45D8A863-DD44-4CBC-BA6F-019035156DAB')
--where StudentID = '45D8A863-DD44-4CBC-BA6F-019035156DAB'
--order by StudentNumber




--select * from x_FormletView.Transportation where StudentID = 'CDBB4CB7-9256-49E2-9483-053A45774A5E'


--select * from Student where ID = 'CDBB4CB7-9256-49E2-9483-053A45774A5E'



/*
if exists (select 1 from sys.schemas s join sys.objects o on s.schema_id = o.schema_id and s.name = 'x_FormletView' and o.name = 'Transportation')
drop view x_FormletView.Transportation
go

create view x_FormletView.Transportation
as
select
	ItemID = itm.ID,
	i.InstanceID,
	StudentID = stu.ID,
	stu.Number,
	StudentFirstname = stu.Firstname,
	StudentLastname = stu.Lastname,
	--
	Q1 = vv_0_0.Value, --	Medical Equipment (Wheelchair, oxygen, unique seating, etc.) 
	Q2 = vv_0_1.Value, --	Special environment (dust controlled, temperature controlled, tinted windows). 
	Q3 = vv_0_2.Value, --	Aide or monitor is required due to disability and specific need to student. 
	Q4 = vv_0_3.Value, --	Shortened school day is required due to disability and specific need of student. 
	Txt1 = vv_0_4.Value, --	Describe:  
	Txt2 = vv_0_5.Value, --	Describe:  
	Txt3 = vv_0_6.Value, --	Describe:  
	Txt4 = vv_0_7.Value --	Describe:  

from
	Student stu JOIN
	PrgItem itm on stu.ID = itm.StudentID JOIN
	PrgItemDef id on itm.DefID = id.ID JOIN
	PrgItemForm f on f.ItemID = itm.ID JOIN
	FormInstanceInterval i on i.InstanceId = f.ID JOIN
	
	--	Medical Equipment (Wheelchair, oxygen, unique seating, etc.)     < Q1 >    (Flag)
	FormInputValue v_0_0 on
		v_0_0.InputFieldId = 'E48B503F-2936-4DB7-B666-4704E95BCF89' AND
		v_0_0.Intervalid = i.ID JOIN
	FormInputFlagValue vv_0_0 on vv_0_0.ID = v_0_0.ID JOIN

	--	Special environment (dust controlled, temperature controlled, tinted windows).     < Q2 >    (Flag)
	FormInputValue v_0_1 on
		v_0_1.InputFieldId = '73ED618E-447F-450A-A321-16E5BEBBA6B5' AND
		v_0_1.Intervalid = i.ID JOIN
	FormInputFlagValue vv_0_1 on vv_0_1.ID = v_0_1.ID JOIN

	--	Aide or monitor is required due to disability and specific need to student.     < Q3 >    (Flag)
	FormInputValue v_0_2 on
		v_0_2.InputFieldId = 'CC63FCF3-CBBF-43F4-8EFD-457FDE5827F8' AND
		v_0_2.Intervalid = i.ID JOIN
	FormInputFlagValue vv_0_2 on vv_0_2.ID = v_0_2.ID JOIN

	--	Shortened school day is required due to disability and specific need of student.     < Q4 >    (Flag)
	FormInputValue v_0_3 on
		v_0_3.InputFieldId = 'DE828F3F-2352-46C3-9EC0-1BC386E4E6FE' AND
		v_0_3.Intervalid = i.ID JOIN
	FormInputFlagValue vv_0_3 on vv_0_3.ID = v_0_3.ID JOIN

	--	Describe:     < Txt1 >    (Text)
	FormInputValue v_0_4 on
		v_0_4.InputFieldId = '843FA824-0806-4C7F-A9A0-70CC5AB3C6DB' AND
		v_0_4.Intervalid = i.ID JOIN
	FormInputTextValue vv_0_4 on vv_0_4.ID = v_0_4.ID JOIN

	--	Describe:     < Txt2 >    (Text)
	FormInputValue v_0_5 on
		v_0_5.InputFieldId = '9CB0D4AF-0B70-48C8-94B1-B5915FB75EF1' AND
		v_0_5.Intervalid = i.ID JOIN
	FormInputTextValue vv_0_5 on vv_0_5.ID = v_0_5.ID JOIN

	--	Describe:     < Txt3 >    (Text)
	FormInputValue v_0_6 on
		v_0_6.InputFieldId = 'ACA0EA01-C679-41B3-8FA0-295D54A85551' AND
		v_0_6.Intervalid = i.ID JOIN
	FormInputTextValue vv_0_6 on vv_0_6.ID = v_0_6.ID JOIN

	--	Describe:     < Txt4 >    (Text)
	FormInputValue v_0_7 on
		v_0_7.InputFieldId = 'B7D8F535-3F81-4041-A772-3389F1D1E7EB' AND
		v_0_7.Intervalid = i.ID JOIN
	FormInputTextValue vv_0_7 on vv_0_7.ID = v_0_7.ID

 
go


create view x_DATATEAM.DisabilityEligibilityHistory
as
select * 
from x_DATATEAM.StudentPrgInvolvementHistory 
where Item in ('Eligibility Determination', 'Reeligibility Determination') 
and Program = 'Special Education'
and ItemIsEnded = 1 -- non-ended would not show the result
go





select * from PrgItemDef where name like 'Convert%'

select distinct startdate, plannedenddate  
from PrgItem where DefID = '8011D6A2-1014-454B-B83C-161CE678E3D3' and isended = 0
order by plannedenddate desc




select * from PrgItemDef where name like '%elig%' and ProgramID = 'F98A8EF2-98E2-4CAC-95AF-D7D89EF7F80C' -- Program Action
select * from PrgItemType where ID = '2A37FB49-1977-48C7-9031-56148AEE8328'




--select * from x_datateam.forminputfields where inputitemlabel like '%district%'






select top 10 * 
from prgsectiontype where name like '%service%'

select id.Name, sd.* 
from PrgItemDef id
join prgsectiondef sd on id.ID = sd.ItemDefID
where sd.TypeID = '54228EE4-3A8C-4544-9216-D842BE7B0A3B'


x_datateam.findguid 'D64E6263-FECA-4F6B-A29D-31F741444C94'
select * from dbo.PrgSection where DefID = 'D64E6263-FECA-4F6B-A29D-31F741444C94'
select * from dbo.PrgSectionDef where ID = 'D64E6263-FECA-4F6B-A29D-31F741444C94'
select * from dbo.SecurityTask where TargetID = 'D64E6263-FECA-4F6B-A29D-31F741444C94'
select * from dbo.SecurityTaskCategory where OwnerID = 'D64E6263-FECA-4F6B-A29D-31F741444C94'
select * from dbo.ServicesSectionDef where ID = 'D64E6263-FECA-4F6B-A29D-31F741444C94'

-- prgsection.id services
x_datateam.findguid '478B8302-3CA7-4103-BDFF-0011596EC66F'
select * from dbo.PrgSection where ID = '478B8302-3CA7-4103-BDFF-0011596EC66F'
select * from dbo.PrgServices where ID = '478B8302-3CA7-4103-BDFF-0011596EC66F'
select * from dbo.ServicePlan where InstanceID = '478B8302-3CA7-4103-BDFF-0011596EC66F'



-- create schema x_FormletView



select * from ServiceDef where name like '%tran%'


select * from formtemplate where name like '%transport%'

exec x_DATATEAM.FormletViewBuilder '97319774-3CDB-4315-9537-57B1A49B396E', 1, 'Q1
Q2
Q3
Q4
Txt1
Txt2
Txt3
Txt4'


select sd.Name, count(*) tot
from ServicePlan sp
join ServiceDef sd on sp.DefID = sd.ID
where DefID in ('8623C033-B63B-4248-AFE1-03A887D6CD84', 'F5B38010-1B6E-4B77-B462-0976A2D625D7', '2880F626-758D-40B5-98AB-5D440747B0C1', '003CF444-D485-43B9-8508-8D3B7E27FCB4', '56D01539-2B52-4C47-8FD6-B616B1CEC091')
group by sd.Name


select * from x_FormletView.Transportation


select id.name, i.* 
from PrgItem i
join PrgItemDef id on i.DefID = id.ID
where i.ID = 'F832A781-1171-41A7-8AF3-16FCC010BA0A'

*/



--Exceptionality varchar(50) NULL,
--ConsentDate datetime NULL,
--EligibilityDate datetime NULL,
--EvaluationDate datetime NULL,
--PlacementDate datetime NULL,

---- (CurrentESEServices)
--ServiceName varchar(50) NULL,
--MinutesPerWeek int NULL,
--Provider varchar(50) NULL,


sp_helptext 'x_DATATEAM.StudentProgramHistory'






